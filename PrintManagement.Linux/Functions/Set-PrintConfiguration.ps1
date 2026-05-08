function Set-PrintConfiguration {
    <#
    .Synopsis
        Sets the configuration information for the specified printer.
    .Description
        NOT SUPPORTED on Linux. Set-PrintConfiguration requires Windows-specific GDI print configuration via CIM.
        This cmdlet is a stub that emits a warning and returns nothing.
        On Windows, use the built-in PrintManagement module: Import-Module PrintManagement
    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/set-printconfiguration
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param()
    Write-Warning 'Set-PrintConfiguration is not supported on Linux. This cmdlet requires Windows-specific GDI print configuration via CIM. Use the built-in PrintManagement module on Windows.'
}
