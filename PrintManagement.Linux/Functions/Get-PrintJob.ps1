function Get-PrintJob {
    <#
    .Synopsis
        Retrieves a list of print jobs in the specified printer queue via CUPS.
    .Description
        Uses `lpstat -o` to retrieve print job information from the local CUPS daemon.
        Returns one object per queued print job with Id, PrinterName, UserName,
        DocumentName, JobStatus, SubmittedTime, and Size properties.

        Requires CUPS to be installed and the cupsd service to be running.

        Unsupported Windows parameters: -ComputerName, -CimSession, -AsJob.
        These emit a warning and are ignored.
    .Parameter PrinterName
        The name of the printer whose jobs to retrieve. If omitted, all queued
        jobs across all printers are returned.
    .Parameter Id
        The job ID to retrieve. If omitted, all queued jobs are returned.
    .Parameter ComputerName
        Not supported on Linux. Emits a warning and is ignored.
    .Example
        # List all queued jobs
        Get-PrintJob

    .Example
        # List jobs for a specific printer
        Get-PrintJob -PrinterName 'HP_LaserJet'

    .Example
        # Get a specific job by ID
        Get-PrintJob -Id 42

    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/get-printjob
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [string] $PrinterName,

        [Parameter()]
        [int] $Id,

        [Parameter()]
        [string] $ComputerName
    )

    process {
        if ($PSBoundParameters.ContainsKey('ComputerName')) {
            Write-Warning 'Get-PrintJob: -ComputerName is not supported on Linux. Ignoring.'
        }

        if (-not (Get-Command lpstat -ErrorAction SilentlyContinue)) {
            $ex  = [System.InvalidOperationException]::new(
                'lpstat not found. Install CUPS: sudo apt install cups (Debian/Ubuntu) or sudo dnf install cups (RHEL/Fedora).'
            )
            $err = [System.Management.Automation.ErrorRecord]::new(
                $ex, 'Get-PrintJob.LpstatNotFound',
                [System.Management.Automation.ErrorCategory]::NotInstalled, 'lpstat'
            )
            $PSCmdlet.ThrowTerminatingError($err)
        }

        # Build lpstat command — optionally scope to one printer
        $lpArgs = @('-o')
        if ($PrinterName) { $lpArgs += $PrinterName }

        # lpstat -o output:
        # <printer>-<jobid>   <user>   <size>   <datetime>
        # e.g.: HP_LaserJet-42  peppe  2048   Thu 08 May 2026 10:00:00 AM CEST
        $lines = & lpstat @lpArgs 2>/dev/null

        $jobs = foreach ($line in $lines) {
            if ($line -match '^(\S+)-(\d+)\s+(\S+)\s+(\d+)\s+(.+)$') {
                $jobPrinter     = $Matches[1]
                $jobId          = [int]$Matches[2]
                $jobUser        = $Matches[3]
                $jobSize        = [long]$Matches[4]
                $jobTimeStr     = $Matches[5].Trim()
                $jobTime        = $null
                try { $jobTime = [datetime]$jobTimeStr } catch { $jobTime = $jobTimeStr }

                [PSCustomObject]@{
                    PSTypeName    = 'PrintManagement.Linux.PrintJob'
                    Id            = $jobId
                    PrinterName   = $jobPrinter
                    DocumentName  = "$jobPrinter-$jobId"
                    UserName      = $jobUser
                    JobStatus     = 'Queued'
                    SubmittedTime = $jobTime
                    Size          = $jobSize
                    ComputerName  = $env:HOSTNAME
                }
            }
        }

        # Filter by -Id if specified
        if ($Id) {
            $jobs = $jobs | Where-Object Id -eq $Id
        }

        $jobs
    }
}
