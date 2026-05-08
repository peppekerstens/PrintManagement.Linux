function Remove-PrintJob {
    <#
    .Synopsis
        Removes (cancels) a print job from the CUPS queue.
    .Description
        Uses `cancel <jobid>` to remove a print job from the CUPS queue.

        Requires CUPS to be installed. The current user must own the job, or
        have lpadmin/operator privileges to cancel other users' jobs.

        Unsupported Windows parameters: -ComputerName, -CimSession, -AsJob.
    .Parameter PrinterName
        The name of the printer. Used together with -Id to identify the job.
        Accepts pipeline input by property name (compatible with Get-PrintJob output).
    .Parameter Id
        The job ID to cancel. Required. Accepts pipeline input by property name.
    .Parameter ComputerName
        Not supported on Linux. Emits a warning and is ignored.
    .Example
        # Cancel a specific job
        Remove-PrintJob -PrinterName 'HP_LaserJet' -Id 42

    .Example
        # Cancel all queued jobs for a printer
        Get-PrintJob -PrinterName 'HP_LaserJet' | Remove-PrintJob

    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/remove-printjob
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
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
            Write-Warning 'Remove-PrintJob: -ComputerName is not supported on Linux. Ignoring.'
        }

        if (-not (Get-Command cancel -ErrorAction SilentlyContinue)) {
            $ex  = [System.InvalidOperationException]::new(
                'cancel not found. Install CUPS: sudo apt install cups (Debian/Ubuntu) or sudo dnf install cups (RHEL/Fedora).'
            )
            $err = [System.Management.Automation.ErrorRecord]::new(
                $ex, 'Remove-PrintJob.CancelNotFound',
                [System.Management.Automation.ErrorCategory]::NotInstalled, 'cancel'
            )
            $PSCmdlet.ThrowTerminatingError($err)
        }

        $jobSpec = "$PrinterName-$Id"
        if ($PSCmdlet.ShouldProcess($jobSpec, 'Cancel print job')) {
            $output = & cancel $Id 2>&1
            if ($LASTEXITCODE -ne 0) {
                $ex  = [System.InvalidOperationException]::new(
                    "cancel failed for job $jobSpec`: $output"
                )
                $err = [System.Management.Automation.ErrorRecord]::new(
                    $ex, 'Remove-PrintJob.CancelFailed',
                    [System.Management.Automation.ErrorCategory]::InvalidOperation, $jobSpec
                )
                $PSCmdlet.WriteError($err)
            }
        }
    }
}
