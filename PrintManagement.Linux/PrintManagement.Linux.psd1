#
# Module manifest for module 'PrintManagement.Linux'
#

@{
    RootModule        = 'PrintManagement.Linux.psm1'
    ModuleVersion     = '0.2.0'
    GUID              = 'f7a8b9c0-d1e2-3456-abcd-789012345678'
    Author            = 'Peppe Kerstens'
    CompanyName       = ''
    Copyright         = '(c) Peppe Kerstens. GPL-3.0 license.'
    Description       = 'PowerShell module for Linux providing cmdlet parity with the Windows PrintManagement module. Implements Get-Printer, Get-PrintJob, Add-Printer, Remove-Printer, Remove-PrintJob, Suspend-PrintJob, Resume-PrintJob using CUPS (lpstat, lpadmin, cancel). Windows-specific driver and port management cmdlets are stubs.'
    PowerShellVersion = '7.2'
    RequiredModules   = @()

    FunctionsToExport = @(
        # Implemented via CUPS (lpstat / lpadmin / cancel)
        'Get-Printer',
        'Get-PrintJob',
        'Add-Printer',
        'Remove-Printer',
        'Remove-PrintJob',
        'Suspend-PrintJob',
        'Resume-PrintJob',
        # Stubs — Windows-specific or require complex driver/port infrastructure
        'Add-PrinterDriver',
        'Add-PrinterPort',
        'Get-PrintConfiguration',
        'Get-PrinterDriver',
        'Get-PrinterPort',
        'Get-PrinterProperty',
        'Read-PrinterNfcTag',
        'Remove-PrinterDriver',
        'Remove-PrinterPort',
        'Rename-Printer',
        'Restart-PrintJob',
        'Set-PrintConfiguration',
        'Set-Printer',
        'Set-PrinterProperty',
        'Write-PrinterNfcTag'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags         = @('Linux', 'Print', 'CUPS', 'Printer', 'PrintJob', 'CrossPlatform')
            LicenseUri   = 'https://github.com/peppekerstens/PrintManagement.Linux/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/peppekerstens/PrintManagement.Linux'
            ReleaseNotes = @'
0.2.0 - Implement Get-PrintConfiguration, Get-PrinterProperty (lpoptions -l), Set-PrintConfiguration, Set-Printer (lpadmin), Set-PrinterProperty, Rename-Printer (remove+re-add). Tests: 18 pass, 16 skip (CUPS absent), 0 fail.
0.1.1 - Fix invalid GUID (non-hex chars fghi replaced with abcd). Skip CUPS-dependent example tests when CUPS not installed.
0.1.0 - Initial release. Get-Printer, Get-PrintJob, Add-Printer, Remove-Printer, Remove-PrintJob, Suspend-PrintJob, Resume-PrintJob implemented via CUPS. 15 Windows-specific cmdlets are stubs.
'@
        }
    }
}
