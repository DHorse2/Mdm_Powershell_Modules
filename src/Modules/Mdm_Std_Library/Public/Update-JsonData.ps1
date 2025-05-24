
function Update-JsonData {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [hashtable]$jsonObjectA,
        [parameter(Mandatory = $true)]
        [hashtable]$jsonObjectB  
    )
    process {
        [hashtable]$dataOut = New-Object System.Collections.Hashtable
        # Parse the content.
        # (also) Convert the JSON string to a PowerShell object
        # JSON.parse() is a JavaScript function for parsing JSON strings into JavaScript objects.
        # const $data = JSON.parse(jsonContent);
        # ConvertFrom-Json is for converting JSON strings into PowerShell objects.
        if ($jsonObjectA -or $jsonObjectB) {
            if ($jsonObjectA) {
                foreach ($property in $jsonObjectA.PSObject.Properties) {
                    if ($global:DoVerbose) {
                        Write-Host "prop: $($property.Name)"
                    }
                    if ($jsonObjectB) {
                        # Update existing fields
                        $jsonObjectB[$property.Name] = $property.Value
                    } else {
                        # If no jsonObjectB, collect results in dataOut
                        $dataOut[$property.Name] = $property.Value
                        # (also) could build a property list:
                        # $dataOut += $property
                    }
                }
            } else {
                Add-LogText -IsWarning "Update-JsonData First Json item is empty."
            }

        } else {
            Add-LogText -IsWarning "Update-JsonData Json items are empty."
        }
        if ($jsonObjectB) {
            return $jsonObjectB
        } else { return $dataOut }
    }
}
