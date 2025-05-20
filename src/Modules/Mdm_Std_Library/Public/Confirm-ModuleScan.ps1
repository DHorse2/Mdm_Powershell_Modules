
# Confirm-ModuleScan
function Confirm-ModuleScan {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [string]$jsonFileName,
        [PSCustomObject]$jsonData,
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause
    )
    try {
        if (-not $jsonData) {
            if ($jsonFileName) {
                $jsonData = Get-JsonData -jsonObject $jsonFileName
                if ($DoDebug) {
                    $Message = "Data: $($jsonData.description) Count($($jsonData.items.Count))"
                    Add-LogText -Message $Message
                }
            } else {
                $Message = "Confirm-ModuleActive: No Module data specified. Can't check module '$Name'."
                Add-LogText -IsError -Message $Message
                return $false
            }
        }
        if ($jsonData -and $jsonData.items) {
            # Find the item with the specified label
            $moduleData = $jsonData.items | Where-Object { $_.label.Trim() -eq $Name }
            if ($DoVerbose) {
                $Message = "moduleData: $moduleData"
                Add-LogText -Message $Message
            }
            # Check if the module was found and return its checked status
            if ($moduleData) {
                if ($moduleData.memberScan) { return $true } else { return $false }
                # return $moduleData.checked
            } else {
                $Message = "Confirm-ModuleActive: Module '$Name' not found."
                Add-LogText -IsError -Message $Message
                return $false
            }
        } else {
            $Message = "Confirm-ModuleActive: Module data is invalid. Can't check module '$Name'."
            Add-LogText -IsError -Message $Message
            return $false
        }
    } catch {
        $Message = "Confirm-ModuleActive had an error checking module '$Name'."
        Add-LogText -IsError -ErrorPSItem $_ -Message $Message
        return $false
    }
    return $false
}
# Example usage:
# $isActive = Confirm-ModuleActive -Name "Mdm_Modules" -jsonFileName "path\to\your\file.json"
# Write-Output "Is Mdm_Modules active? $isActive"
