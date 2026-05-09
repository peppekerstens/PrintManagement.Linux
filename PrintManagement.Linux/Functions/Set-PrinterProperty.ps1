function Set-PrinterProperty {
    <#
    .Synopsis
        Sets a PPD option value for a printer via lpoptions.
    .Description
        On Linux, wraps 'lpoptions -p <PrinterName> -o <PropertyName>=<Value>' to set a
        per-printer PPD option. Requires CUPS.
    .Parameter PrinterName
        The name of the printer.
    .Parameter PropertyName
        The PPD option keyword to set (e.g. 'Duplex', 'MediaType').
    .Parameter Value
        The value to set for the option.
    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/set-printerproperty
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$PrinterName,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$PropertyName,

        [Parameter(Mandatory = $true, Position = 2)]
        [string]$Value
    )
    process {
        if (-not (Get-Command lpoptions -ErrorAction SilentlyContinue)) {
            Write-Error 'Set-PrinterProperty: lpoptions not found. Install CUPS (sudo apt install cups).'
            return
        }
        $optionArg = "${PropertyName}=${Value}"
        if ($PSCmdlet.ShouldProcess($PrinterName, "Set printer property $optionArg")) {
            $result = & lpoptions -p $PrinterName -o $optionArg 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Set-PrinterProperty: lpoptions failed: $result"
            }
        }
    }
}
