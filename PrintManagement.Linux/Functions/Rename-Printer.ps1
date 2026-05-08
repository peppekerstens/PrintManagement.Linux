function Rename-Printer {
    <#
    .Synopsis
        Renames the specified printer.
    .Description
        NOT SUPPORTED on Linux. Rename-Printer requires CUPS has no rename operation; would require remove + re-add which loses configuration.
        This cmdlet is a stub that emits a warning and returns nothing.
        On Windows, use the built-in PrintManagement module: Import-Module PrintManagement
    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/rename-printer
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param()
    Write-Warning 'Rename-Printer is not supported on Linux. This cmdlet requires CUPS has no rename operation; would require remove + re-add which loses configuration. Use the built-in PrintManagement module on Windows.'
}
