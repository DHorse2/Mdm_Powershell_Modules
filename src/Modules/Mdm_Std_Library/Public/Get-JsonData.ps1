
function Get-JsonData {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$jsonObject,
        [string]$Name,
        [hashtable]$parentObject,
        [switch]$AddSource,
        [switch]$UpdateGlobal
    )

    begin {
        [Collections.ArrayList]$jsonObjects = @()
        [hashtable]$dataOut = New-Object System.Collections.Hashtable
    }
    process {
        [void]$jsonObjects.Add($jsonObject)
    }
    end {
        ForEach ($JsonItem in $jsonObjects) {
            # Check if the JSON file exists
            try {
                if (-Not (Test-Path $JsonItem)) {
                    $Message = "Get-JsonData: The specified JSON file does not exist: $JsonItem"
                    Add-LogText -IsError -Message $Message
                    return $false
                }
                # Read the JSON file
                $jsonContent = Get-Content -Path $JsonItem -Raw -ErrorAction Stop
                # Parse the content.
                try {
                    # (also) Convert the JSON string to a PowerShell object
                    # JSON.parse() is a JavaScript function for parsing JSON strings into JavaScript objects.
                    # const $data = JSON.parse(jsonContent);
                    # ConvertFrom-Json is for converting JSON strings into PowerShell objects.
                    $data = $jsonContent | ConvertFrom-Json -ErrorAction Stop
                    if ($data) {
                        if ($global:DoDebug -and $global:DoVerbose) {
                            $Message = "Data: $($data | ConvertTo-Json -Depth 10)"
                            Add-LogText $Message -ForegroundColor Blue
                        }
                        foreach ($property in $data.PSObject.Properties) {
                            if ($global:DoVerbose) {
                                Write-Host "prop: $($property.Name)"
                            }
                            if ($parentObject) {
                                # Update existing fields
                                $parentObject[$property.Name] = $property.Value
                            } else {
                                # If no parentObject, collect results in dataOut
                                $dataOut[$property.Name] = $property.Value
                                # (also) could build a property list:
                                # $dataOut += $property
                            }
                        }
                    } else {
                        Add-LogText -IsWarning "Get-JsonData Json item is empty: $($JsonItem)"
                    }
                } catch {
                    Add-LogText -IsError -ErrorPSItem $_ "Get-JsonData Error processing the json Content: $($JsonItem)"
                    return $false
                }
            } catch {
                Add-LogText -IsError -ErrorPSItem $_ "Get-JsonData Json item doesn't exist: $($JsonItem)"
                return $false
            }
        }
        if ($DoDebug) {
            $Message = "JsonContent: $jsonContent Count($($jsonData.items.Count))"
            Add-LogText -Message $Message -ForegroundColor Blue
            $Message = "JsonData: $($jsonData | Format-List -Property *)"
            Add-LogText -Message $Message -ForegroundColor Blue
        }
        # 
        # Collect results if not using parentObject
        if ($parentObject) { $dataOut = $parentObject }
        if ($AddSource -and $jsonItem) {
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
