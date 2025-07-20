
# Confirm-ModuleScan
function Confirm-ModuleScan {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$moduleName,
        [string]$jsonFileName,
        [PSCustomObject]$jsonData,

        [string]$appName = "",
        [int]$actionStep = 0,
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [string]$logFileNameFull = ""
    )
    try {
        if (-not $jsonData) {
            if ($jsonFileName) {
                $jsonData = Get-JsonData -Name "Modules" -jsonItem $jsonFileName -logFileNameFull $logFileNameFull
                # $jsonData = $global:jsonDataResult
                if ($DoDebug) {
                    $Message = "Data: $($jsonData.description) Count($($jsonData.items.Count))"
                    Add-LogText -Message $Message -logFileNameFull $logFileNameFull
                }
            } else {
                $Message = "Confirm-ModuleScan: No Module data specified. Can't check module '$moduleName'."
                MessagesMessages $Message -logFileNameFull $logFileNameFull
                return $false
            }
        }
        if ($jsonData -and $jsonData.items) {
            # Find the item with the specified label
            $moduleData = $jsonData.items | Where-Object { $_.label.Trim() -eq $moduleName }
            if ($DoVerbose) {
                $Message = "    moduleData: $moduleData"
                Add-LogText -Message $Message -logFileNameFull $logFileNameFull
            }
            # Check if the module was found and return its checked status
            if ($moduleData) {
                if ($moduleData.memberScan) { return $true } else { return $false }
                # return $moduleData.checked
            } else {
                $Message = "Confirm-ModuleScan: Module '$moduleName' not found."
                Add-LogText -IsError -Message $Message -logFileNameFull $logFileNameFull
                return $false
            }
        } else {
            $Message = "Confirm-ModuleScan: Module data is invalid. Can't check module '$moduleName'."
            Add-LogText -IsError -Message $Message -logFileNameFull $logFileNameFull
            return $false
        }
    } catch {
        $Message = "Confirm-ModuleScan had an error checking module '$moduleName'."
        Add-LogText -IsError -ErrorPSItem $_ -Message $Message -logFileNameFull $logFileNameFull
        return $false
    }
    return $false
}
# Example usage:
# $isActive = Confirm-ModuleScan -moduleName "Mdm_Modules" -jsonFileName "path\to\your\file.json"
# Write-Host "Is Mdm_Modules active? $isActive"
