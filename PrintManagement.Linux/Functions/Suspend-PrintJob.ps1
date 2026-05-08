function Suspend-PrintJob {
    <#
    .Synopsis
        Suspends (holds) a print job in the CUPS queue.
    .Description
        Uses `cancel -H hold <jobid>` to place a print job on hold in the CUPS queue.
        The job remains in the queue but does not print until released with Resume-PrintJob.

        Requires CUPS to be installed. The current user must own the job, or
        have lpadmin/operator privileges.

        Unsupported Windows parameters: -ComputerName, -CimSession, -AsJob.
    .Parameter PrinterName
        The name of the printer. Used with -Id to identify the job.
        Accepts pipeline input by property name (compatible with Get-PrintJob output).
    .Parameter Id
        The job ID to hold. Required. Accepts pipeline input by property name.
    .Parameter ComputerName
        Not supported on Linux. Emits a warning and is ignored.
    .Example
        # Hold a specific job
        Suspend-PrintJob -PrinterName 'HP_LaserJet' -Id 42

    .Example
        # Hold all queued jobs for a printer
        Get-PrintJob -PrinterName 'HP_LaserJet' | Suspend-PrintJob

    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/suspend-printjob
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $PrinterName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int] $Id,

        [Parameter()]
        [string] $ComputerName
    )

    process {
        if ($PSBoundParameters.ContainsKey('ComputerName')) {
            Write-Warning 'Suspend-PrintJob: -ComputerName is not supported on Linux. Ignoring.'
        }

        if (-not (Get-Command cancel -ErrorAction SilentlyContinue)) {
            $ex  = [System.InvalidOperationException]::new(
                'cancel not found. Install CUPS: sudo apt install cups (Debian/Ubuntu) or sudo dnf install cups (RHEL/Fedora).'
            )
            $err = [System.Management.Automation.ErrorRecord]::new(
                $ex, 'Suspend-PrintJob.CancelNotFound',
                [System.Management.Automation.ErrorCategory]::NotInstalled, 'cancel'
            )
            $PSCmdlet.ThrowTerminatingError($err)
        }

        $jobSpec = "$PrinterName-$Id"
        if ($PSCmdlet.ShouldProcess($jobSpec, 'Hold print job')) {
            $output = & cancel -H hold $Id 2>&1
            if ($LASTEXITCODE -ne 0) {
                $ex  = [System.InvalidOperationException]::new(
                    "cancel -H hold failed for job $jobSpec`: $output"
                )
                $err = [System.Management.Automation.ErrorRecord]::new(
                    $ex, 'Suspend-PrintJob.HoldFailed',
                    [System.Management.Automation.ErrorCategory]::InvalidOperation, $jobSpec
                )
                $PSCmdlet.WriteError($err)
            }
        }
    }
}
