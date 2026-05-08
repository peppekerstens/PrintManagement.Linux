function Get-PrinterPort {
    <#
    .Synopsis
        Retrieves a list of printer ports installed on the specified computer.
    .Description
        NOT SUPPORTED on Linux. Get-PrinterPort requires Windows printer port concepts; on Linux use `lpinfo -v` directly.
        This cmdlet is a stub that emits a warning and returns nothing.
        On Windows, use the built-in PrintManagement module: Import-Module PrintManagement
    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/get-printerport
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param()
    Write-Warning 'Get-PrinterPort is not supported on Linux. This cmdlet requires Windows printer port concepts; on Linux use `lpinfo -v` directly. Use the built-in PrintManagement module on Windows.'
}
