function Remove-PrinterPort {
    <#
    .Synopsis
        Removes a printer port from the specified computer.
    .Description
        NOT SUPPORTED on Linux. Remove-PrinterPort requires Windows printer port management.
        This cmdlet is a stub that emits a warning and returns nothing.
        On Windows, use the built-in PrintManagement module: Import-Module PrintManagement
    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/remove-printerport
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param()
    Write-Warning 'Remove-PrinterPort is not supported on Linux. This cmdlet requires Windows printer port management. Use the built-in PrintManagement module on Windows.'
}
