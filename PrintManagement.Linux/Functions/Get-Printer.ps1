function Get-Printer {
    <#
    .Synopsis
        Retrieves a list of printers installed on the local Linux system via CUPS.
    .Description
        Uses `lpstat -p` and `lpstat -v` to retrieve printer information from the local
        CUPS daemon. Returns one object per printer with Name, PrinterStatus, DeviceUri,
        IsAccepting, and EnabledSince properties.

        Requires CUPS to be installed and the cupsd service to be running.
        Install with: sudo apt install cups  (Debian/Ubuntu)
                      sudo dnf install cups  (RHEL/Fedora)

        Unsupported Windows parameters: -ComputerName, -Full, -CimSession, -AsJob.
        These emit a warning and are ignored.
    .Parameter Name
        One or more printer names to retrieve. Supports wildcard matching.
        If omitted, all printers are returned.
    .Parameter ComputerName
        Not supported on Linux. Emits a warning and is ignored.
    .Parameter Full
        Not supported on Linux. Emits a warning and is ignored.
    .Example
        # List all printers
        Get-Printer

    .Example
        # Get a specific printer
        Get-Printer -Name 'HP_LaserJet'

    .Example
        # Get only idle printers
        Get-Printer | Where-Object PrinterStatus -eq 'Idle'

    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/get-printer
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [string[]] $Name,

        [Parameter()]
        [string] $ComputerName,

        [Parameter()]
        [switch] $Full
    )

    process {
        if ($PSBoundParameters.ContainsKey('ComputerName')) {
            Write-Warning 'Get-Printer: -ComputerName is not supported on Linux. Remote CUPS servers are not queried. Ignoring.'
        }
        if ($Full) {
            Write-Warning 'Get-Printer: -Full is not supported on Linux. All available properties are always returned. Ignoring.'
        }

        # Verify lpstat is available
        if (-not (Get-Command lpstat -ErrorAction SilentlyContinue)) {
            $ex  = [System.InvalidOperationException]::new(
                'lpstat not found. Install CUPS: sudo apt install cups (Debian/Ubuntu) or sudo dnf install cups (RHEL/Fedora).'
            )
            $err = [System.Management.Automation.ErrorRecord]::new(
                $ex, 'Get-Printer.LpstatNotFound',
                [System.Management.Automation.ErrorCategory]::NotInstalled, 'lpstat'
            )
            $PSCmdlet.ThrowTerminatingError($err)
        }

        # lpstat -p: printer <name> is <status>. enabled since <date>
        #             printer <name> disabled since <date>
        $statusLines = lpstat -p 2>/dev/null

        # lpstat -v: device for <name>: <uri>
        $deviceMap = @{}
        $deviceLines = lpstat -v 2>/dev/null
        foreach ($line in $deviceLines) {
            if ($line -match '^device for (.+?):\s+(.+)$') {
                $deviceMap[$Matches[1]] = $Matches[2]
            }
        }

        # lpstat -a: <name> accepting requests since <date>
        #             <name> not accepting requests since <date>
        $acceptMap = @{}
        $acceptLines = lpstat -a 2>/dev/null
        foreach ($line in $acceptLines) {
            if ($line -match '^(\S+)\s+(accepting|not accepting)') {
                $acceptMap[$Matches[1]] = ($Matches[2] -eq 'accepting')
            }
        }

        $printers = foreach ($line in $statusLines) {
            # "printer <name> is idle.  enabled since <date>"
            # "printer <name> is processing <doc>.  enabled since <date>"
            # "printer <name> disabled since <date>"
            if ($line -match '^printer\s+(\S+)\s+(.+)$') {
                $printerName = $Matches[1]
                $rest        = $Matches[2]

                $status      = 'Unknown'
                $enabledSince = $null

                if ($rest -match '^is idle') {
                    $status = 'Idle'
                } elseif ($rest -match '^is processing') {
                    $status = 'Printing'
                } elseif ($rest -match '^disabled') {
                    $status = 'Stopped'
                } elseif ($rest -match '^is paused') {
                    $status = 'Paused'
                }

                if ($rest -match 'since\s+(.+)$') {
                    try { $enabledSince = [datetime]$Matches[1] } catch { $enabledSince = $Matches[1] }
                }

                [PSCustomObject]@{
                    PSTypeName    = 'PrintManagement.Linux.Printer'
                    Name          = $printerName
                    PrinterStatus = $status
                    DeviceUri     = $deviceMap[$printerName]
                    IsAccepting   = if ($acceptMap.ContainsKey($printerName)) { $acceptMap[$printerName] } else { $null }
                    EnabledSince  = $enabledSince
                    ComputerName  = $env:HOSTNAME
                }
            }
        }

        # Filter by -Name if specified
        if ($Name) {
            $printers = $printers | Where-Object {
                $pName = $_.Name
                $Name | ForEach-Object { if ($pName -like $_) { $true } }
            }
        }

        $printers
    }
}
