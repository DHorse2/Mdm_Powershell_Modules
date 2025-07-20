
# Get-JsonData
function Get-JsonData {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [string]$jsonItem,
        [string]$Name,
        [string]$jsonContent,
        [hashtable]$parentObject,
        [switch]$AddSource,
        [switch]$Append,
        [switch]$UpdateGlobal,
        [string]$logFileNameFull = ""
    )

    begin {
        [hashtable]$dataOut = New-Object System.Collections.Hashtable
    }
    process {
    }
    end {
        if (-not $jsonContent) {
            try {
                if (-Not (Test-Path $JsonItem)) {
                    $Message = "Get-JsonData: The specified JSON file does not exist: $JsonItem"
                    Add-LogText -IsError -Message $Message -logFileNameFull $logFileNameFull
                    return $false
                }
                # Read the JSON file
                $jsonContent = Get-Content -Path $JsonItem -Raw -ErrorAction Stop
            } catch {
                $Message = "Get-JsonData Json item doesn't exist: $($JsonItem)"
                Add-LogText -IsError -ErrorPSItem $_ $Message -logFileNameFull $logFileNameFull
                return $false
            }
        }

        # Parse the content.
        try {
            # (also) Convert the JSON string to a PowerShell object
            # JSON.parse() is a JavaScript function for parsing JSON strings into JavaScript objects.
            # const $data = JSON.parse(jsonContent);
            # ConvertFrom-Json is for converting JSON strings into PowerShell objects.
            # [hashtable]$data = New-Object System.Collections.Hashtable
            $newdata = $jsonContent | ConvertFrom-Json -ErrorAction Stop
            $data = $newdata
            if ($data) {
                if ($global:app.DoDebug -and $global:app.DoVerbose) {
                    $Message = "Data: $($data | ConvertTo-Json -Depth 10)"
                    Add-LogText $Message -ForegroundColor Blue -logFileNameFull $logFileNameFull
                }
                foreach ($property in $data.PSObject.Properties) {
                    if ($global:app.DoVerbose) {
                        Write-Host "prop: $($property.Name)"
                    }
                    if ($Append) {
                        if ($parentObject) {
                            if (-not $parentObject.ContainsKey($Name)) { $parentObject[$Name] = @{} }
                            $parentObject[$Name][$property.Name] += $property.Value
                        } else {
                            $dataOut[$property.Name] += $property.Value
                        }
                    } else {
                        if ($parentObject) {
                            if (-not $parentObject.ContainsKey($Name)) { $parentObject[$Name] = @{} }
                            $parentObject[$Name][$property.Name] = $property.Value
                        } else {
                            $dataOut[$property.Name] = $property.Value
                        }
                    }
                }
            } else {
                $Message = "Get-JsonData Json item is empty: $($JsonItem)"
                Add-LogText -IsWarning $Message -logFileNameFull $logFileNameFull
            }
        } catch {
            $Message = "Get-JsonData Error processing the json Content: $($JsonItem)"
            Add-LogText -IsError -ErrorPSItem $_ $Message -logFileNameFull $logFileNameFull
            return $null
        }
        if ($DoDebug) {
            $Message = "JsonContent: $jsonContent Count($($jsonData.items.Count))"
            Add-LogText -Message $Message -ForegroundColor Blue -logFileNameFull $logFileNameFull
            $Message = "JsonData: $($jsonData | Format-List -Property *)"
            Add-LogText -Message $Message -ForegroundColor Blue -logFileNameFull $logFileNameFull
        }
        # 
        # Collect results if not using parentObject
        if ($parentObject) { $dataOut = $parentObject }
        if ($AddSource -and $jsonItem) {
            # if ($Name) { $dataOut['name'] = $Name }
            $dataOut['source'] = $jsonItem
            $dataOut['changed'] = $false
        }
        [hashtable]$global:jsonDataResult = $dataOut
        if ($UpdateGlobal) {
            $global:appDataArray[$Name] = $dataOut
        }
        # return results if not using parentObject
        if (-not $parentObject) {
            $dataOut
            # return $dataOut
        }
    }
}
