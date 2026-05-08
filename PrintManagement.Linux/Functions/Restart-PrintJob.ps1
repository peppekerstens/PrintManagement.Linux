function Restart-PrintJob {
    <#
    .Synopsis
        Restarts a print job on the specified printer.
    .Description
        NOT SUPPORTED on Linux. Restart-PrintJob requires CUPS has no restart operation for completed/failed jobs; cancel and resubmit manually.
        This cmdlet is a stub that emits a warning and returns nothing.
        On Windows, use the built-in PrintManagement module: Import-Module PrintManagement
    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/restart-printjob
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param()
    Write-Warning 'Restart-PrintJob is not supported on Linux. This cmdlet requires CUPS has no restart operation for completed/failed jobs; cancel and resubmit manually. Use the built-in PrintManagement module on Windows.'
}
