
function Get-JsonData {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$jsonObject,
        [hashtable]$parentObject  
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
            try {
                # Check if the JSON file exists
                if (-Not (Test-Path $JsonItem)) {
                    $Message = "Get-JsonData: The specified JSON file does not exist: $jsonFileName"
                    Add-LogText -IsError -Message $Message
                    return $false
                }
                # Read the JSON file
                $jsonContent = Get-Content -Path $JsonItem -Raw -ErrorAction Stop
                try {
                    # Parse the content.
                    # (also) Convert the JSON string to a PowerShell object
                    # JSON.parse() is a JavaScript function for parsing JSON strings into JavaScript objects.
                    # const $data = JSON.parse(jsonContent);
                    # ConvertFrom-Json is for converting JSON strings into PowerShell objects.
                    $data = $jsonContent | ConvertFrom-Json -ErrorAction Stop
                    if ($data) {
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
                        Add-LogText -IsWarning "Get-JsonDate Json item is empty: $($JsonItem)"
                    }
                    if ($global:DoDebug) {
                        $Message = "Data: $($data | ConvertTo-Json -Depth 10)"
                        Add-LogText $Message -ForegroundColor Blue
                    }
                } catch {
                    Add-LogText -IsError -ErrorPSItem $_ "Get-JsonDate Error processing json item: $($JsonItem)"
                }
            } catch {
                Add-LogText -IsError -ErrorPSItem $_ "Get-JsonDate Json item doesn't exist: $($JsonItem)"
            }
        }
        if ($DoDebug) {
            $Message = "JsonContent: $jsonContent Count($($jsonData.items.Count))"
            Add-LogText -Message $Message -ForegroundColor Blue
            $Message = "JsonData: $($jsonData | Format-List -Property *)"
            Add-LogText -Message $Message -ForegroundColor Blue
        }
        # Collect results if not using parentObject
        if ($parentObject) {
            # Write-Output $parentObject
        } else {
            # Write-Output $dataOut
            return $dataOut
        }
    }
}
