#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.2.0' }

BeforeDiscovery {
    $script:onLinux = $IsLinux
}

Describe 'PrintManagement.Linux Examples' -Skip:(-not $script:onLinux) {

    BeforeAll {
        if ($IsLinux) {
            $modulePath = Join-Path $PSScriptRoot '..' 'PrintManagement.Linux' 'PrintManagement.Linux.psd1'
            Import-Module (Resolve-Path $modulePath).Path -Force
            $script:examplesDir = $PSScriptRoot
            $script:cupsAvailable = [bool](Get-Command lpstat -ErrorAction SilentlyContinue)
        }
    }

    AfterAll {
        if ($IsLinux) {
            Remove-Module PrintManagement.Linux -ErrorAction SilentlyContinue
        }
    }

    Context '01-ListPrinters.ps1' {
        It 'Script file exists' {
            Test-Path (Join-Path $script:examplesDir '01-ListPrinters.ps1') | Should -Be $true
        }

        It 'Script runs without error' -Skip:(-not $script:cupsAvailable) {
            { & (Join-Path $script:examplesDir '01-ListPrinters.ps1') } | Should -Not -Throw
        }

        It 'Get-Printer returns objects with Name property when printers exist' {
            if (-not $script:cupsAvailable) { Set-ItResult -Skipped -Because 'CUPS not installed'; return }
            $printers = Get-Printer
            if ($printers) {
                $printers[0].Name | Should -Not -BeNullOrEmpty
            } else {
                Set-ItResult -Skipped -Because 'No printers configured in CUPS'
            }
        }

        It 'Get-Printer PrinterStatus is a known value when printers exist' {
            if (-not $script:cupsAvailable) { Set-ItResult -Skipped -Because 'CUPS not installed'; return }
            $printers = Get-Printer
            if ($printers) {
                $printers[0].PrinterStatus | Should -BeIn @('Idle', 'Printing', 'Stopped', 'Paused', 'Unknown')
            } else {
                Set-ItResult -Skipped -Because 'No printers configured in CUPS'
            }
        }
    }

    Context '02-ManagePrintJobs.ps1' {
        It 'Script file exists' {
            Test-Path (Join-Path $script:examplesDir '02-ManagePrintJobs.ps1') | Should -Be $true
        }

        It 'Script runs without error' -Skip:(-not $script:cupsAvailable) {
            { & (Join-Path $script:examplesDir '02-ManagePrintJobs.ps1') } | Should -Not -Throw
        }

        It 'Get-PrintJob returns objects with Id and PrinterName properties when jobs exist' {
            if (-not $script:cupsAvailable) { Set-ItResult -Skipped -Because 'CUPS not installed'; return }
            $jobs = Get-PrintJob
            if ($jobs) {
                $jobs[0].Id | Should -BeGreaterThan 0
                $jobs[0].PrinterName | Should -Not -BeNullOrEmpty
            } else {
                Set-ItResult -Skipped -Because 'No print jobs in queue'
            }
        }

        It 'Remove-PrintJob supports -WhatIf' {
            if (-not (Get-Command cancel -ErrorAction SilentlyContinue)) {
                Set-ItResult -Skipped -Because 'cancel not found (CUPS not installed)'
                return
            }
            { Remove-PrintJob -PrinterName 'Test' -Id 1 -WhatIf } | Should -Not -Throw
        }

        It 'Suspend-PrintJob supports -WhatIf' {
            if (-not (Get-Command cancel -ErrorAction SilentlyContinue)) {
                Set-ItResult -Skipped -Because 'cancel not found (CUPS not installed)'
                return
            }
            { Suspend-PrintJob -PrinterName 'Test' -Id 1 -WhatIf } | Should -Not -Throw
        }

        It 'Resume-PrintJob supports -WhatIf' {
            if (-not (Get-Command cancel -ErrorAction SilentlyContinue)) {
                Set-ItResult -Skipped -Because 'cancel not found (CUPS not installed)'
                return
            }
            { Resume-PrintJob -PrinterName 'Test' -Id 1 -WhatIf } | Should -Not -Throw
        }
    }

    Context '03-AddRemovePrinter.ps1' {
        It 'Script file exists' {
            Test-Path (Join-Path $script:examplesDir '03-AddRemovePrinter.ps1') | Should -Be $true
        }

        It 'Script runs without error (WhatIf throughout)' {
            if (-not (Get-Command lpadmin -ErrorAction SilentlyContinue)) {
                Set-ItResult -Skipped -Because 'lpadmin not found (CUPS not installed)'
                return
            }
            { & (Join-Path $script:examplesDir '03-AddRemovePrinter.ps1') } | Should -Not -Throw
        }

        It 'Add-Printer supports -WhatIf' {
            if (-not (Get-Command lpadmin -ErrorAction SilentlyContinue)) {
                Set-ItResult -Skipped -Because 'lpadmin not found (CUPS not installed)'
                return
            }
            { Add-Printer -Name 'PesterTest_WhatIf' -DeviceUri 'socket://10.0.0.1:9100' -WhatIf } |
                Should -Not -Throw
        }

        It 'Remove-Printer supports -WhatIf' {
            if (-not (Get-Command lpadmin -ErrorAction SilentlyContinue)) {
                Set-ItResult -Skipped -Because 'lpadmin not found (CUPS not installed)'
                return
            }
            { Remove-Printer -Name 'PesterTest_WhatIf' -WhatIf } | Should -Not -Throw
        }
    }

    Context '04-PrinterHealthReport.ps1' {
        It 'Script file exists' {
            Test-Path (Join-Path $script:examplesDir '04-PrinterHealthReport.ps1') | Should -Be $true
        }

        It 'Script runs without error' -Skip:(-not $script:cupsAvailable) {
            { & (Join-Path $script:examplesDir '04-PrinterHealthReport.ps1') } | Should -Not -Throw
        }

        It 'Health report object has expected properties' {
            if (-not $script:cupsAvailable) { Set-ItResult -Skipped -Because 'CUPS not installed'; return }
            $printers = Get-Printer
            if ($printers) {
                $jobs = Get-PrintJob -PrinterName $printers[0].Name
                $report = [PSCustomObject]@{
                    Name        = $printers[0].Name
                    Status      = $printers[0].PrinterStatus
                    IsAccepting = $printers[0].IsAccepting
                    QueuedJobs  = if ($jobs) { @($jobs).Count } else { 0 }
                    DeviceUri   = $printers[0].DeviceUri
                }
                $report.Name | Should -Not -BeNullOrEmpty
                $report.QueuedJobs | Should -BeGreaterOrEqual 0
            } else {
                Set-ItResult -Skipped -Because 'No printers configured in CUPS'
            }
        }
    }
}
