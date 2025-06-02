
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
        [switch]$UpdateGlobal
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
                    Add-LogText -IsError -Message $Message
                    return $false
                }
                # Read the JSON file
                $jsonContent = Get-Content -Path $JsonItem -Raw -ErrorAction Stop
            } catch {
                Add-LogText -IsError -ErrorPSItem $_ "Get-JsonData Json item doesn't exist: $($JsonItem)"
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
                if ($global:DoDebug -and $global:DoVerbose) {
                    $Message = "Data: $($data | ConvertTo-Json -Depth 10)"
                    Add-LogText $Message -ForegroundColor Blue
                }
                foreach ($property in $data.PSObject.Properties) {
                    if ($global:DoVerbose) {
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
                Add-LogText -IsWarning "Get-JsonData Json item is empty: $($JsonItem)"
            }
        } catch {
            Add-LogText -IsError -ErrorPSItem $_ "Get-JsonData Error processing the json Content: $($JsonItem)"
            return $false
        }
        if ($DoDebug) {
            $Message = "JsonContent: $jsonContent Count($($jsonData.items.Count))"
            Add-LogText -Messages $Message -ForegroundColor Blue
            $Message = "JsonData: $($jsonData | Format-List -Property *)"
            Add-LogText -Messages $Message -ForegroundColor Blue
        }
        # 
        # Collect results if not using parentObject
        if ($parentObject) { $dataOut = $parentObject }
        if ($AddSource -and $jsonItem) {
            # if ($Name) { $dataOut['name'] = $Name }
            $dataOut['source'] = $jsonItem
            $dataOut['changed'] = $false
        }
        if ($UpdateGlobal) {
            $global:moduleDataArray[$Name] = $dataOut
        }
        # return results if not using parentObject
        if (-not $parentObject) {
            return $dataOut
        }
    }
}
