param()
<#
.Synopsis
    Example 03: Add and remove a printer (using WhatIf to avoid actual changes).
.Description
    Demonstrates Add-Printer and Remove-Printer. Uses -WhatIf throughout so the
    script can be run without modifying the CUPS configuration.
    In production, remove -WhatIf to actually add or remove printers.
    Requires lpadmin privileges (sudo or lpadmin group membership).
.Expected output
    WhatIf output showing what Add-Printer and Remove-Printer would do.
#>

Write-Host '=== Add a network IPP printer (WhatIf) ===' -ForegroundColor Cyan
Add-Printer `
    -Name       'Office_Color' `
    -DeviceUri  'ipp://192.168.1.50/ipp/print' `
    -WhatIf

Write-Host '=== Add a raw TCP/IP printer (WhatIf) ===' -ForegroundColor Cyan
Add-Printer `
    -Name       'Floor2_HP' `
    -DeviceUri  'socket://192.168.1.100:9100' `
    -WhatIf

Write-Host '=== Add a PDF virtual printer (WhatIf) ===' -ForegroundColor Cyan
Add-Printer `
    -Name       'PDF_Printer' `
    -DeviceUri  'pdf:/' `
    -WhatIf

Write-Host '=== Remove a printer (WhatIf) ===' -ForegroundColor Cyan
Remove-Printer -Name 'OldPrinter' -WhatIf

Write-Host '=== Remove all stopped printers (WhatIf) ===' -ForegroundColor Cyan
Get-Printer | Where-Object PrinterStatus -eq 'Stopped' | Remove-Printer -WhatIf

Write-Host "`nTo actually add/remove, re-run without -WhatIf (requires lpadmin privileges)." -ForegroundColor Yellow
