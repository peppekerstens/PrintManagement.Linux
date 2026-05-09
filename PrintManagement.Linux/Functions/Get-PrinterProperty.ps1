function Get-PrinterProperty {
    <#
    .Synopsis
        Retrieves available PPD options and their values for a printer via lpoptions -l.
    .Description
        On Linux, wraps 'lpoptions -p <PrinterName> -l' to list PPD option keywords with
        their supported values. Requires CUPS. If CUPS is not installed, a warning is emitted.
    .Parameter PrinterName
        The name of the printer. Required.
    .Parameter PropertyName
        Optional filter — only return properties whose name matches this value.
    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/get-printerproperty
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$PrinterName,

        [Parameter(Position = 1)]
        [string]$PropertyName
    )
    process {
        if (-not (Get-Command lpoptions -ErrorAction SilentlyContinue)) {
            Write-Error 'Get-PrinterProperty: lpoptions not found. Install CUPS (sudo apt install cups).'
            return
        }
        $raw = & lpoptions -p $PrinterName -l 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Get-PrinterProperty: lpoptions failed for printer '$PrinterName': $raw"
            return
        }
        # Each line: OptionName/Label: *SelectedValue OtherValue ...
        foreach ($line in $raw) {
            if ($line -match '^([^/]+)/[^:]*:\s+(.+)$') {
                $key    = $Matches[1].Trim()
                $values = $Matches[2].Trim()
                if ($PropertyName -and $key -ne $PropertyName) { continue }
                $selected = ($values -split '\s+' | Where-Object { $_ -match '^\*' }) -replace '^\*'
                [PSCustomObject]@{
                    PrinterName   = $PrinterName
                    PropertyName  = $key
                    Value         = $selected
                    SupportedValues = ($values -split '\s+' | ForEach-Object { $_ -replace '^\*' })
                }
            }
        }
    }
}
