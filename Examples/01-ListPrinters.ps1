param()
<#
.Synopsis
    Example 01: List all printers and their status.
.Description
    Demonstrates Get-Printer to inventory local CUPS printers, filter by status,
    and display in a formatted table. Covers the most common use case:
    "what printers do I have and are they working?"
.Expected output
    A table of printers with Name, PrinterStatus, DeviceUri, IsAccepting columns.
    Empty output if no printers are configured.
#>

# List all printers
Write-Host '=== All printers ===' -ForegroundColor Cyan
$printers = Get-Printer
if ($printers) {
    $printers | Format-Table Name, PrinterStatus, DeviceUri, IsAccepting, ComputerName -AutoSize
} else {
    Write-Host 'No printers configured. Add one with: Add-Printer -Name <name> -DeviceUri <uri>'
}

# Show only idle (ready) printers
Write-Host '=== Ready printers ===' -ForegroundColor Cyan
$ready = Get-Printer | Where-Object PrinterStatus -eq 'Idle'
if ($ready) {
    $ready | Format-Table Name, DeviceUri -AutoSize
} else {
    Write-Host 'No idle printers.'
}

# Show stopped/disabled printers
Write-Host '=== Stopped printers ===' -ForegroundColor Cyan
$stopped = Get-Printer | Where-Object PrinterStatus -eq 'Stopped'
if ($stopped) {
    $stopped | Format-Table Name, DeviceUri -AutoSize
} else {
    Write-Host 'No stopped printers.'
}
