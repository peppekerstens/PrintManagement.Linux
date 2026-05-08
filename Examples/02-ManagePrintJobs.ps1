param()
<#
.Synopsis
    Example 02: View and manage the print queue (list jobs, cancel, hold, release).
.Description
    Demonstrates Get-PrintJob, Remove-PrintJob, Suspend-PrintJob, and Resume-PrintJob.
    Shows the common "what's in the queue and how do I clear it" workflow.
.Expected output
    Table of queued jobs (may be empty). WhatIf output for cancel/hold/release operations.
#>

# List all queued print jobs
Write-Host '=== All queued print jobs ===' -ForegroundColor Cyan
$jobs = Get-PrintJob
if ($jobs) {
    $jobs | Format-Table Id, PrinterName, UserName, Size, SubmittedTime -AutoSize

    # Show how to cancel a specific job (WhatIf — does not actually cancel)
    $firstJob = $jobs[0]
    Write-Host "`nWould cancel job $($firstJob.Id) on $($firstJob.PrinterName):" -ForegroundColor Yellow
    Remove-PrintJob -PrinterName $firstJob.PrinterName -Id $firstJob.Id -WhatIf

    # Show how to hold (suspend) a job
    Write-Host "`nWould hold job $($firstJob.Id):" -ForegroundColor Yellow
    Suspend-PrintJob -PrinterName $firstJob.PrinterName -Id $firstJob.Id -WhatIf

    # Show how to resume a held job
    Write-Host "`nWould resume job $($firstJob.Id):" -ForegroundColor Yellow
    Resume-PrintJob -PrinterName $firstJob.PrinterName -Id $firstJob.Id -WhatIf
} else {
    Write-Host 'No queued print jobs.'
}

# List jobs for a specific printer
Write-Host '=== Jobs per printer ===' -ForegroundColor Cyan
$printers = Get-Printer
foreach ($p in $printers) {
    $pJobs = Get-PrintJob -PrinterName $p.Name
    "$($p.Name): $($pJobs.Count) job(s)"
}
