function Set-Printer {
    <#
    .Synopsis
        Updates printer attributes via lpadmin.
    .Description
        On Linux, wraps 'lpadmin -p <PrinterName>' to modify printer attributes such as
        location, info (description), and device URI. Requires CUPS.
    .Parameter Name
        The name of the printer to update. Required.
    .Parameter Location
        Human-readable printer location string (lpadmin -L).
    .Parameter Comment
        Human-readable printer description (lpadmin -D).
    .Parameter DeviceUri
        New device URI for the printer (lpadmin -v), e.g. 'socket://10.0.0.1:9100'.
    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/set-printer
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$Name,

        [Parameter()]
        [string]$Location,

        [Parameter()]
        [string]$Comment,

        [Parameter()]
        [string]$DeviceUri
    )
    process {
        if (-not (Get-Command lpadmin -ErrorAction SilentlyContinue)) {
            Write-Error 'Set-Printer: lpadmin not found. Install CUPS (sudo apt install cups).'
            return
        }
        $lpadminArgs = @('-p', $Name)
        if ($Location)  { $lpadminArgs += '-L', $Location }
        if ($Comment)   { $lpadminArgs += '-D', $Comment }
        if ($DeviceUri) { $lpadminArgs += '-v', $DeviceUri }

        if ($PSCmdlet.ShouldProcess($Name, 'Update printer attributes')) {
            $result = & lpadmin @lpadminArgs 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Set-Printer: lpadmin failed: $result"
            }
        }
    }
}
