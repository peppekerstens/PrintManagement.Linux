function Get-PrinterDriver {
    <#
    .Synopsis
        Retrieves the list of printer drivers installed on the specified computer.
    .Description
        NOT SUPPORTED on Linux. Get-PrinterDriver requires Windows Driver Store; on Linux use `lpinfo -m` directly.
        This cmdlet is a stub that emits a warning and returns nothing.
        On Windows, use the built-in PrintManagement module: Import-Module PrintManagement
    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/get-printerdriver
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param()
    Write-Warning 'Get-PrinterDriver is not supported on Linux. This cmdlet requires Windows Driver Store; on Linux use `lpinfo -m` directly. Use the built-in PrintManagement module on Windows.'
}
