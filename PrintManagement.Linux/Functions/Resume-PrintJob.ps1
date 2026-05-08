function Resume-PrintJob {
    <#
    .Synopsis
        Resumes a suspended (held) print job in the CUPS queue.
    .Description
        Uses `cancel -H resume <jobid>` to release a held print job back into the
        active CUPS queue. Complement to Suspend-PrintJob.

        Requires CUPS to be installed. The current user must own the job, or
        have lpadmin/operator privileges.

        Unsupported Windows parameters: -ComputerName, -CimSession, -AsJob.
    .Parameter PrinterName
        The name of the printer. Used with -Id to identify the job.
        Accepts pipeline input by property name (compatible with Get-PrintJob output).
    .Parameter Id
        The job ID to resume. Required. Accepts pipeline input by property name.
    .Parameter ComputerName
        Not supported on Linux. Emits a warning and is ignored.
    .Example
        # Resume a specific held job
        Resume-PrintJob -PrinterName 'HP_LaserJet' -Id 42

    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/resume-printjob
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
            Write-Warning 'Resume-PrintJob: -ComputerName is not supported on Linux. Ignoring.'
        }

        if (-not (Get-Command cancel -ErrorAction SilentlyContinue)) {
            $ex  = [System.InvalidOperationException]::new(
                'cancel not found. Install CUPS: sudo apt install cups (Debian/Ubuntu) or sudo dnf install cups (RHEL/Fedora).'
            )
            $err = [System.Management.Automation.ErrorRecord]::new(
                $ex, 'Resume-PrintJob.CancelNotFound',
                [System.Management.Automation.ErrorCategory]::NotInstalled, 'cancel'
            )
            $PSCmdlet.ThrowTerminatingError($err)
        }

        $jobSpec = "$PrinterName-$Id"
        if ($PSCmdlet.ShouldProcess($jobSpec, 'Resume print job')) {
            $output = & cancel -H resume $Id 2>&1
            if ($LASTEXITCODE -ne 0) {
                $ex  = [System.InvalidOperationException]::new(
                    "cancel -H resume failed for job $jobSpec`: $output"
                )
                $err = [System.Management.Automation.ErrorRecord]::new(
                    $ex, 'Resume-PrintJob.ResumeFailed',
                    [System.Management.Automation.ErrorCategory]::InvalidOperation, $jobSpec
                )
                $PSCmdlet.WriteError($err)
            }
        }
    }
}
