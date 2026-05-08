function Get-PrintConfiguration {
    <#
    .Synopsis
        Gets the configuration information of a printer.
    .Description
        NOT SUPPORTED on Linux. Get-PrintConfiguration requires Windows-specific GDI print configuration (paper size, orientation via WMI/CIM).
        This cmdlet is a stub that emits a warning and returns nothing.
        On Windows, use the built-in PrintManagement module: Import-Module PrintManagement
    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/get-printconfiguration
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param()
    Write-Warning 'Get-PrintConfiguration is not supported on Linux. This cmdlet requires Windows-specific GDI print configuration (paper size, orientation via WMI/CIM). Use the built-in PrintManagement module on Windows.'
}
