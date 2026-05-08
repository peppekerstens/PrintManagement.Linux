#Requires -Version 7.2

# PrintManagement.Linux.psm1
# Root module for PrintManagement.Linux.
# Dot-sources all function files from the Functions\ subdirectory.

# Linux-only guard — this module wraps CUPS (lpstat/lpadmin/cancel) and must not be loaded on Windows.
# On Windows, use the built-in module:
#   Import-Module PrintManagement
if (-not $IsLinux) {
    throw (
        "PrintManagement.Linux cannot be loaded on Windows. " +
        "On Windows, use the built-in 'PrintManagement' module.`n" +
        "PrintManagement.Linux is a Linux-only peer module that wraps CUPS (lpstat/lpadmin/cancel)."
    )
}

$functionPath = Join-Path $PSScriptRoot 'Functions'
$functionFiles = Get-ChildItem -Path $functionPath -Filter '*.ps1' -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notlike '*.Tests.ps1' }
foreach ($file in $functionFiles) {
    . $file.FullName
}
