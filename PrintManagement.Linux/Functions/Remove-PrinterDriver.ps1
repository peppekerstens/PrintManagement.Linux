function Remove-PrinterDriver {
    <#
    .Synopsis
        Removes a printer driver from the specified computer.
    .Description
        NOT SUPPORTED on Linux. Remove-PrinterDriver requires Windows Driver Store management.
        This cmdlet is a stub that emits a warning and returns nothing.
        On Windows, use the built-in PrintManagement module: Import-Module PrintManagement
    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/remove-printerdriver
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param()
    Write-Warning 'Remove-PrinterDriver is not supported on Linux. This cmdlet requires Windows Driver Store management. Use the built-in PrintManagement module on Windows.'
}
