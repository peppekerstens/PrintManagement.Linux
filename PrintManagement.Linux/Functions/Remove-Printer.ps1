function Remove-Printer {
    <#
    .Synopsis
        Removes a printer from the local CUPS print system.
    .Description
        Uses `lpadmin -x` to remove a printer from the local CUPS daemon.

        Requires CUPS to be installed and the current user to have permission to
        run lpadmin (typically requires membership in the 'lpadmin' group or root).

        Unsupported Windows parameters: -ComputerName, -CimSession, -AsJob.
        These emit a warning and are ignored.
    .Parameter Name
        The name of the printer to remove. Required. Accepts pipeline input by
        property name (compatible with Get-Printer output).
    .Parameter ComputerName
        Not supported on Linux. Emits a warning and is ignored.
    .Example
        # Remove a printer by name
        Remove-Printer -Name 'OldPrinter'

    .Example
        # Remove all stopped printers
        Get-Printer | Where-Object PrinterStatus -eq 'Stopped' | Remove-Printer

    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/remove-printer
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType([void])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [string] $Name,

        [Parameter()]
        [string] $ComputerName
    )

    process {
        if ($PSBoundParameters.ContainsKey('ComputerName')) {
            Write-Warning 'Remove-Printer: -ComputerName is not supported on Linux. Ignoring.'
        }

        if (-not (Get-Command lpadmin -ErrorAction SilentlyContinue)) {
            $ex  = [System.InvalidOperationException]::new(
                'lpadmin not found. Install CUPS: sudo apt install cups (Debian/Ubuntu) or sudo dnf install cups (RHEL/Fedora).'
            )
            $err = [System.Management.Automation.ErrorRecord]::new(
                $ex, 'Remove-Printer.LpadminNotFound',
                [System.Management.Automation.ErrorCategory]::NotInstalled, 'lpadmin'
            )
            $PSCmdlet.ThrowTerminatingError($err)
        }

        if ($PSCmdlet.ShouldProcess($Name, 'Remove printer')) {
            $output = & lpadmin -x $Name 2>&1
            if ($LASTEXITCODE -ne 0) {
                $ex  = [System.InvalidOperationException]::new(
                    "lpadmin failed to remove printer '$Name': $output"
                )
                $err = [System.Management.Automation.ErrorRecord]::new(
                    $ex, 'Remove-Printer.LpadminFailed',
                    [System.Management.Automation.ErrorCategory]::InvalidOperation, $Name
                )
                $PSCmdlet.WriteError($err)
            }
        }
    }
}
