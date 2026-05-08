# PrintManagement.Linux

Linux parity module for the Windows **PrintManagement** PowerShell module.

Implements print management cmdlets on Linux using **CUPS** (`lpstat`, `lpadmin`, `cancel`) — no Windows driver infrastructure required.

Part of the [Linux PowerShell Cmdlet Parity](https://peppekerstens.github.io) project.

---

## What it does

Provides Linux implementations of the most useful Windows PrintManagement cmdlets:

| Cmdlet | What it does |
|---|---|
| `Get-Printer` | Lists printers configured in CUPS with name, status, device URI, accepting state |
| `Get-PrintJob` | Lists queued print jobs across all printers or for a specific printer |
| `Add-Printer` | Adds a new printer to CUPS via `lpadmin -p -E -v` |
| `Remove-Printer` | Removes a printer from CUPS via `lpadmin -x` |
| `Remove-PrintJob` | Cancels a queued print job via `cancel` |
| `Suspend-PrintJob` | Holds a print job via `cancel -H hold` |
| `Resume-PrintJob` | Releases a held print job via `cancel -H resume` |

Windows-specific cmdlets (driver management, port management, NFC tags, GDI configuration) are exported as stubs that emit `Write-Warning`.

---

## Requirements

- PowerShell 7.2+
- Linux (tested on Ubuntu 22.04, Debian 12)
- CUPS installed: `sudo apt install cups` (Debian/Ubuntu) or `sudo dnf install cups` (RHEL/Fedora)
- `Add-Printer` and `Remove-Printer` require lpadmin privileges (membership in the `lpadmin` group or root)

> **Note:** CUPS must be installed and running (`systemctl status cups`). Without CUPS, `Get-Printer` and `Get-PrintJob` throw a terminating error pointing to the installation command.

---

## Installation

```powershell
# From source
git clone https://github.com/peppekerstens/PrintManagement.Linux.git
Import-Module ./PrintManagement.Linux/PrintManagement.Linux/PrintManagement.Linux.psd1

# From PowerShell Gallery (future)
Install-Module PrintManagement.Linux
```

---

## Usage

```powershell
Import-Module PrintManagement.Linux

# List all printers
Get-Printer

# List only idle printers
Get-Printer | Where-Object PrinterStatus -eq 'Idle'

# List all queued print jobs
Get-PrintJob

# List jobs for a specific printer
Get-PrintJob -PrinterName 'HP_LaserJet'

# Add a network IPP printer
Add-Printer -Name 'Office_Color' -DeviceUri 'ipp://192.168.1.50/ipp/print'

# Add a raw TCP/IP printer
Add-Printer -Name 'HP_LaserJet' -DeviceUri 'socket://192.168.1.100:9100'

# Cancel a print job
Remove-PrintJob -PrinterName 'HP_LaserJet' -Id 42

# Cancel all jobs for a printer (pipeline)
Get-PrintJob -PrinterName 'HP_LaserJet' | Remove-PrintJob

# Hold a print job
Suspend-PrintJob -PrinterName 'HP_LaserJet' -Id 42

# Release a held job
Resume-PrintJob -PrinterName 'HP_LaserJet' -Id 42

# Remove a printer
Remove-Printer -Name 'OldPrinter'

# Remove all stopped printers (pipeline)
Get-Printer | Where-Object PrinterStatus -eq 'Stopped' | Remove-Printer
```

---

## Examples

See the [`Examples\`](Examples/) folder:

| Script | Description |
|---|---|
| `01-ListPrinters.ps1` | List all printers, filter by status |
| `02-ManagePrintJobs.ps1` | View queue, cancel/hold/release jobs |
| `03-AddRemovePrinter.ps1` | Add and remove printers (WhatIf safe) |
| `04-PrinterHealthReport.ps1` | Combined health report with job counts |

---

## Cmdlet Status

| Cmdlet | Status | Implementation |
|---|---|---|
| `Get-Printer` | ✅ Implemented | `lpstat -p` + `lpstat -v` + `lpstat -a` |
| `Get-PrintJob` | ✅ Implemented | `lpstat -o` |
| `Add-Printer` | ✅ Implemented | `lpadmin -p -E -v` |
| `Remove-Printer` | ✅ Implemented | `lpadmin -x` |
| `Remove-PrintJob` | ✅ Implemented | `cancel <jobid>` |
| `Suspend-PrintJob` | ✅ Implemented | `cancel -H hold <jobid>` |
| `Resume-PrintJob` | ✅ Implemented | `cancel -H resume <jobid>` |
| `Add-PrinterDriver` | 🔶 Stub | Windows Driver Store (INF/CAB) |
| `Add-PrinterPort` | 🔶 Stub | Windows port concepts (TCP/IP Monitor, WSD) |
| `Get-PrintConfiguration` | 🔶 Stub | Windows GDI config via CIM |
| `Get-PrinterDriver` | 🔶 Stub | Windows Driver Store; use `lpinfo -m` on Linux |
| `Get-PrinterPort` | 🔶 Stub | Windows port concepts; use `lpinfo -v` on Linux |
| `Get-PrinterProperty` | 🔶 Stub | Windows-specific CIM printer properties |
| `Read-PrinterNfcTag` | 🔶 Stub | NFC hardware + Windows NFC stack |
| `Remove-PrinterDriver` | 🔶 Stub | Windows Driver Store management |
| `Remove-PrinterPort` | 🔶 Stub | Windows port management |
| `Rename-Printer` | 🔶 Stub | CUPS has no rename; use remove + re-add |
| `Restart-PrintJob` | 🔶 Stub | CUPS has no restart for completed/failed jobs |
| `Set-PrintConfiguration` | 🔶 Stub | Windows GDI config via CIM |
| `Set-Printer` | 🔶 Stub | Complex reconfig; use `lpadmin` directly |
| `Set-PrinterProperty` | 🔶 Stub | Windows-specific CIM printer properties |
| `Write-PrinterNfcTag` | 🔶 Stub | NFC hardware + Windows NFC stack |

---

## Implementation Notes

### Why CUPS and not a direct printer protocol?

The Windows `PrintManagement` module is backed by the Windows print spooler and WMI/CIM. Neither exists on Linux. CUPS (Common Unix Printing System) is the universal print layer on Linux — it handles all printer queuing, driver management, and protocol translation. `lpstat`, `lpadmin`, and `cancel` are the standard CUPS management tools and are available on every major distribution.

### What CUPS provides

- `lpstat -p` — printer list with status (idle/processing/disabled)
- `lpstat -v` — device URI per printer (maps to `PortName` in Windows)
- `lpstat -a` — accepting/not-accepting state per printer
- `lpstat -o [printer]` — queued jobs, optionally scoped to one printer
- `lpadmin -p <name> -E -v <uri>` — add printer (enable + set device URI)
- `lpadmin -x <name>` — remove printer
- `cancel <jobid>` — cancel a job
- `cancel -H hold <jobid>` — hold a job
- `cancel -H resume <jobid>` — release a held job

### Windows parameters not supported on Linux

The following parameter types have no CUPS equivalent and emit `Write-Warning` when used:

- `-ComputerName` — CUPS is local-only; remote CUPS servers require IPP URIs at the device level, not at the cmdlet level
- `-DriverName` / `-PortName` — Windows Driver Store concepts; CUPS uses PPD files and device URIs
- `-Shared` / `-ShareName` — Windows SMB printer sharing; CUPS sharing is configured via `/etc/cups/cupsd.conf`
- `-CimSession` / `-AsJob` — Windows-only infrastructure

### Output object shape

`Get-Printer` returns `PSCustomObject` with `PSTypeName = 'PrintManagement.Linux.Printer'`:

| Property | Type | Source |
|---|---|---|
| `Name` | string | `lpstat -p` |
| `PrinterStatus` | string | `lpstat -p` (Idle/Printing/Stopped/Paused/Unknown) |
| `DeviceUri` | string | `lpstat -v` |
| `IsAccepting` | bool | `lpstat -a` |
| `EnabledSince` | datetime/string | `lpstat -p` |
| `ComputerName` | string | `$env:HOSTNAME` |

`Get-PrintJob` returns `PSCustomObject` with `PSTypeName = 'PrintManagement.Linux.PrintJob'`:

| Property | Type | Source |
|---|---|---|
| `Id` | int | `lpstat -o` |
| `PrinterName` | string | `lpstat -o` |
| `DocumentName` | string | `<printer>-<jobid>` (CUPS default) |
| `UserName` | string | `lpstat -o` |
| `JobStatus` | string | `Queued` (lpstat only shows active/held jobs) |
| `SubmittedTime` | datetime/string | `lpstat -o` |
| `Size` | long | `lpstat -o` (bytes) |
| `ComputerName` | string | `$env:HOSTNAME` |

---

## How we built this

This module was built as part of the **Linux PowerShell Cmdlet Parity** project.

The Windows `PrintManagement` module is backed by the Windows print spooler — a Windows-only service with no cross-platform equivalent. Rather than attempting to wrap it, PrintManagement.Linux targets CUPS, which is installed and running on virtually every Linux system that does any printing.

The key research question was which of the 22 Windows cmdlets could map onto CUPS commands. The answer split into three groups:

1. **Directly implementable** (7 cmdlets): `Get-Printer`, `Get-PrintJob`, `Add-Printer`, `Remove-Printer`, `Remove-PrintJob`, `Suspend-PrintJob`, `Resume-PrintJob` — all have direct `lpstat`/`lpadmin`/`cancel` equivalents.

2. **No equivalent exists** (2 cmdlets): `Read-PrinterNfcTag`, `Write-PrinterNfcTag` — depend on Windows NFC hardware stack with no Linux counterpart.

3. **Concept mismatch** (13 cmdlets): driver management (`Add/Remove/Get-PrinterDriver`) uses Windows INF/CAB files and the Driver Store. Port management (`Add/Remove/Get-PrinterPort`) uses Windows TCP/IP Monitor and WSD. GDI configuration (`Get/Set-PrintConfiguration`) is Windows-specific. `Rename-Printer` has no CUPS equivalent (CUPS has no rename operation). All 13 are stubs.

---

## Version History

| Version | Date | Notes |
|---|---|---|
| 0.1.0 | 2026-05-08 | Initial release. 7 cmdlets implemented via CUPS, 15 stubs. |

---

## License

GPL-3.0 — see [LICENSE](LICENSE).
