function Get-PrintConfiguration {
    <#
    .Synopsis
        Gets the configuration options of a printer via lpoptions.
    .Description
        On Linux, wraps 'lpoptions -p <PrinterName>' to return per-printer default options.
        Requires CUPS (lpstat/lpoptions). If CUPS is not installed, a warning is emitted.
    .Parameter PrinterName
        The name of the printer. Required.
    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/get-printconfiguration
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$PrinterName
    )
    process {
        if (-not (Get-Command lpoptions -ErrorAction SilentlyContinue)) {
            Write-Error 'Get-PrintConfiguration: lpoptions not found. Install CUPS (sudo apt install cups).'
            return
        }
        $raw = & lpoptions -p $PrinterName 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Get-PrintConfiguration: lpoptions failed for printer '$PrinterName': $raw"
            return
        }
        # lpoptions output: space-separated key=value pairs on one line
        $options = @{}
        foreach ($token in ($raw -split '\s+')) {
            if ($token -match '^([^=]+)=(.*)$') {
                $options[$Matches[1]] = $Matches[2]
            }
        }
        [PSCustomObject]@{
            PrinterName = $PrinterName
            Options     = $options
        }
    }
}
