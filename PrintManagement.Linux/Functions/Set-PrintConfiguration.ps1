function Set-PrintConfiguration {
    <#
    .Synopsis
        Sets a default option for a printer via lpoptions.
    .Description
        On Linux, wraps 'lpoptions -p <PrinterName> -o <OptionName>=<OptionValue>' to set
        a per-printer default. Requires CUPS. If CUPS is not installed, an error is emitted.
    .Parameter PrinterName
        The name of the printer.
    .Parameter OptionName
        The PPD option keyword to set (e.g. 'sides', 'media').
    .Parameter OptionValue
        The value for the option (e.g. 'two-sided-long-edge', 'A4').
    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/set-printconfiguration
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$PrinterName,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$OptionName,

        [Parameter(Mandatory = $true, Position = 2)]
        [string]$OptionValue
    )
    process {
        if (-not (Get-Command lpoptions -ErrorAction SilentlyContinue)) {
            Write-Error 'Set-PrintConfiguration: lpoptions not found. Install CUPS (sudo apt install cups).'
            return
        }
        $optionArg = "${OptionName}=${OptionValue}"
        if ($PSCmdlet.ShouldProcess($PrinterName, "Set print option $optionArg")) {
            $result = & lpoptions -p $PrinterName -o $optionArg 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Set-PrintConfiguration: lpoptions failed: $result"
            }
        }
    }
}
