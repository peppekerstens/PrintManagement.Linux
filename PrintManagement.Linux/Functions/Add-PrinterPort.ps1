function Add-PrinterPort {
    <#
    .Synopsis
        Installs a printer port on the specified computer.
    .Description
        NOT SUPPORTED on Linux. Add-PrinterPort requires Windows printer port concepts (TCP/IP Monitor, WSD) that don't map to CUPS backends.
        This cmdlet is a stub that emits a warning and returns nothing.
        On Windows, use the built-in PrintManagement module: Import-Module PrintManagement
    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/add-printerport
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param()
    Write-Warning 'Add-PrinterPort is not supported on Linux. This cmdlet requires Windows printer port concepts (TCP/IP Monitor, WSD) that don''t map to CUPS backends. Use the built-in PrintManagement module on Windows.'
}
