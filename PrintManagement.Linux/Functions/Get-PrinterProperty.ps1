function Get-PrinterProperty {
    <#
    .Synopsis
        Retrieves printer properties for the specified printer.
    .Description
        NOT SUPPORTED on Linux. Get-PrinterProperty requires Windows-specific per-printer CIM properties not present in CUPS.
        This cmdlet is a stub that emits a warning and returns nothing.
        On Windows, use the built-in PrintManagement module: Import-Module PrintManagement
    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/get-printerproperty
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param()
    Write-Warning 'Get-PrinterProperty is not supported on Linux. This cmdlet requires Windows-specific per-printer CIM properties not present in CUPS. Use the built-in PrintManagement module on Windows.'
}
