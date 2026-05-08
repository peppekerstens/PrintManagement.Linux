function Set-Printer {
    <#
    .Synopsis
        Updates the configuration of an existing printer.
    .Description
        NOT SUPPORTED on Linux. Set-Printer requires complex printer reconfiguration; use `lpadmin` directly on Linux.
        This cmdlet is a stub that emits a warning and returns nothing.
        On Windows, use the built-in PrintManagement module: Import-Module PrintManagement
    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/set-printer
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param()
    Write-Warning 'Set-Printer is not supported on Linux. This cmdlet requires complex printer reconfiguration; use `lpadmin` directly on Linux. Use the built-in PrintManagement module on Windows.'
}
