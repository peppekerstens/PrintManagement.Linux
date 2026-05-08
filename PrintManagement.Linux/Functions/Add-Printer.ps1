function Add-Printer {
    <#
    .Synopsis
        Adds a printer to the local CUPS print system.
    .Description
        Uses `lpadmin -p` to add a printer to the local CUPS daemon. The printer is
        enabled and set to accept jobs by default (-E flag).

        Requires CUPS to be installed and the current user to have permission to
        run lpadmin (typically requires membership in the 'lpadmin' group or root).

        Unsupported Windows parameters: -ComputerName, -DriverName, -PortName,
        -PrintProcessor, -Datatype, -ShareName, -Shared, -Published, -Priority,
        -DefaultJobPriority, -StartTime, -UntilTime, -SeparatorPageFile,
        -RenderingMode, -CimSession, -AsJob.
        These emit a warning and are ignored.
    .Parameter Name
        The name of the printer to add. Required.
    .Parameter DeviceUri
        The CUPS device URI for the printer. Required.
        Examples:
          socket://192.168.1.100:9100   (network printer, raw)
          ipp://192.168.1.100/ipp/print (IPP printer)
          lpd://192.168.1.100/lp        (LPD/LPR printer)
          usb://HP/LaserJet             (USB printer)
          pdf:/                         (PDF virtual printer)
    .Parameter DriverModel
        The CUPS PPD model string as returned by `lpinfo -m`. Optional.
        If omitted, the printer uses a generic/raw queue.
        Example: 'drv:///sample.drv/generpcl.ppd'
    .Parameter ComputerName
        Not supported on Linux. Emits a warning and is ignored.
    .Example
        # Add a network IPP printer
        Add-Printer -Name 'Office_Printer' -DeviceUri 'ipp://192.168.1.50/ipp/print'

    .Example
        # Add a raw network printer with a PPD model
        Add-Printer -Name 'HP_LaserJet' -DeviceUri 'socket://192.168.1.100:9100' -DriverModel 'drv:///sample.drv/generpcl.ppd'

    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/add-printer
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $DeviceUri,

        [Parameter()]
        [string] $DriverModel,

        [Parameter()]
        [string] $ComputerName
    )

    if ($PSBoundParameters.ContainsKey('ComputerName')) {
        Write-Warning 'Add-Printer: -ComputerName is not supported on Linux. Ignoring.'
    }

    if (-not (Get-Command lpadmin -ErrorAction SilentlyContinue)) {
        $ex  = [System.InvalidOperationException]::new(
            'lpadmin not found. Install CUPS: sudo apt install cups (Debian/Ubuntu) or sudo dnf install cups (RHEL/Fedora).'
        )
        $err = [System.Management.Automation.ErrorRecord]::new(
            $ex, 'Add-Printer.LpadminNotFound',
            [System.Management.Automation.ErrorCategory]::NotInstalled, 'lpadmin'
        )
        $PSCmdlet.ThrowTerminatingError($err)
    }

    if ($PSCmdlet.ShouldProcess($Name, 'Add printer')) {
        $lpadminArgs = @('-p', $Name, '-E', '-v', $DeviceUri)
        if ($DriverModel) { $lpadminArgs += @('-m', $DriverModel) }

        $output = & lpadmin @lpadminArgs 2>&1
        if ($LASTEXITCODE -ne 0) {
            $ex  = [System.InvalidOperationException]::new(
                "lpadmin failed to add printer '$Name': $output"
            )
            $err = [System.Management.Automation.ErrorRecord]::new(
                $ex, 'Add-Printer.LpadminFailed',
                [System.Management.Automation.ErrorCategory]::InvalidOperation, $Name
            )
            $PSCmdlet.ThrowTerminatingError($err)
        }
    }
}
