function Write-PrinterNfcTag {
    <#
    .Synopsis
        Writes printer connection information to an NFC tag.
    .Description
        NOT SUPPORTED on Linux. Write-PrinterNfcTag requires NFC hardware and Windows NFC stack; no Linux equivalent.
        This cmdlet is a stub that emits a warning and returns nothing.
        On Windows, use the built-in PrintManagement module: Import-Module PrintManagement
    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/write-printernfctag
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param()
    Write-Warning 'Write-PrinterNfcTag is not supported on Linux. This cmdlet requires NFC hardware and Windows NFC stack; no Linux equivalent. Use the built-in PrintManagement module on Windows.'
}
