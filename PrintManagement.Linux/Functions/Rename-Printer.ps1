function Rename-Printer {
    <#
    .Synopsis
        Renames a printer by removing and re-adding it under the new name via lpadmin.
    .Description
        CUPS has no native rename operation. This cmdlet emulates rename by copying the
        existing printer's device URI to a new queue and deleting the old one. Printer-specific
        option defaults and PPD are not migrated. Requires CUPS (lpadmin/lpstat).
    .Parameter Name
        The current name of the printer.
    .Parameter NewName
        The new name for the printer.
    .Link
        https://learn.microsoft.com/powershell/module/printmanagement/rename-printer
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$NewName
    )
    process {
        if (-not (Get-Command lpadmin -ErrorAction SilentlyContinue)) {
            Write-Error 'Rename-Printer: lpadmin not found. Install CUPS (sudo apt install cups).'
            return
        }
        if (-not (Get-Command lpstat -ErrorAction SilentlyContinue)) {
            Write-Error 'Rename-Printer: lpstat not found. Install CUPS (sudo apt install cups).'
            return
        }
        # Get the device URI of the existing printer
        $deviceLine = & lpstat -v $Name 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Rename-Printer: Cannot find printer '$Name': $deviceLine"
            return
        }
        $deviceUri = ($deviceLine -split ': ', 2)[1].Trim()
        if ($PSCmdlet.ShouldProcess("$Name -> $NewName", 'Rename printer (re-add + delete old)')) {
            # Add new queue with same device URI
            $addResult = & lpadmin -p $NewName -v $deviceUri -E 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Rename-Printer: Failed to create new printer '$NewName': $addResult"
                return
            }
            # Delete the old queue
            $delResult = & lpadmin -x $Name 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Rename-Printer: Failed to delete old printer '$Name': $delResult"
            }
        }
    }
}
