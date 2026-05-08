param()
<#
.Synopsis
    Example 04: Printer health summary report.
.Description
    Combines Get-Printer and Get-PrintJob to produce a summary health report
    of all configured printers: status, job count, and device URI.
    Useful as a quick check or as input to monitoring scripts.
.Expected output
    A formatted health report per printer, grouped by status.
#>

Write-Host '=== Printer Health Summary ===' -ForegroundColor Cyan
Write-Host "Host: $env:HOSTNAME   Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host ''

$printers = Get-Printer

if (-not $printers) {
    Write-Host 'No printers configured.' -ForegroundColor Yellow
    return
}

$report = foreach ($p in $printers) {
    $jobs     = Get-PrintJob -PrinterName $p.Name
    $jobCount = if ($jobs) { @($jobs).Count } else { 0 }

    [PSCustomObject]@{
        Name          = $p.Name
        Status        = $p.PrinterStatus
        IsAccepting   = $p.IsAccepting
        QueuedJobs    = $jobCount
        DeviceUri     = $p.DeviceUri
    }
}

# Full table
$report | Format-Table -AutoSize

# Summary counts
$idle    = @($report | Where-Object Status -eq 'Idle').Count
$stopped = @($report | Where-Object Status -eq 'Stopped').Count
$busy    = @($report | Where-Object Status -eq 'Printing').Count
$total   = @($report).Count

Write-Host "Total: $total   Idle: $idle   Printing: $busy   Stopped: $stopped" -ForegroundColor Cyan

if ($stopped -gt 0) {
    Write-Host "`nStopped printers:" -ForegroundColor Red
    $report | Where-Object Status -eq 'Stopped' | Format-Table Name, DeviceUri
}
