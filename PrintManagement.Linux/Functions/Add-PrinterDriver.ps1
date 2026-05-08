function Add-PrinterDriver {
    <#
    .Synopsis
        Installs a printer driver on the specified computer.
    .Description
        NOT SUPPORTED on Linux. Add-PrinterDriver requires Windows printer driver infrastructure (INF/CAB files, Windows Driver Store).
        This cmdlet is a stub that emits a warning and returns nothing.
        On Windows, use the built-in PrintManagement module: Import-Module PrintManagement
    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/add-printerdriver
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param()
    Write-Warning 'Add-PrinterDriver is not supported on Linux. This cmdlet requires Windows printer driver infrastructure (INF/CAB files, Windows Driver Store). Use the built-in PrintManagement module on Windows.'
}
