
function Get-JsonData {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline)]
        $inputObject,
        # Parameter help description
        $parentObject
    )

    begin {
        [Collections.ArrayList]$inputObjects = @()
        # Path to the JSON file
        $jsonFilePath = "path\to\your\file.json"
        $dataOut = @{}

    }
    process {
        [void]$inputObjects.Add($_)
    }
    end {
        $inputObjects | ForEach-Object {
            try {
                $filePath = $_
                # Read the JSON file
                $jsonContent = Get-Content -Path $_ -Raw
                # Convert the JSON string to a PowerShell object
                # const $data = JSON.parse(jsonContent);
                $data = $jsonContent | ConvertFrom-Json
                # Access the properties of the object
                if ($parentObject) {
                    if ($data.name) {
                        $parentObject[$data.name] = $data
                    } else { $parentObject += $data }
                } else {
                    $dataOut += $data
                }
                Write-Verbose "Data: $data"
            } catch {
                Add-LogError -IsError -ErrorPSItem $ErrorPSItem "Error processing file $($filePath): $_"
            }
        }
        # Collect results if not using parentObject
        if ($parentObject) {
            Write-Output $parentObject
        } else {
            Write-Output $dataOut
        }
    }
}
