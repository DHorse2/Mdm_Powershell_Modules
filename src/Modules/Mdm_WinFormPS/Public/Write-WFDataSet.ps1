
# Write-WFDataSet
function Write-WFDataSet {
    [CmdletBinding()]
    param($sender, $e)
    # param (
    #     $optionName, 
    #     $optionText, 
    #     $isChecked
    # )
    process {
        $description = ""
        $source = ""
        # Write Run Control All Data
        if (-not $description) { $description = "Form" }
        # Step 1: Check if changed is true
        if ($global:moduleDataArray['changed']) {
            $source = $global:moduleDataArray['source']
            if (-not $source) {
                # Specify default file path
                $source = ".\$($global:dataSourceName)_dataSetOutput.json" 
                $global:moduleDataArray['source'] = $source
            }
            $global:moduleDataArray['changed'] = $false
            # Step 2: Convert the object to JSON
            # Use -Depth to handle nested objects
            $jsonString = $global:moduleDataArray | ConvertTo-Json -Depth 5
            # Step 3: Write the JSON to a file
            # Stemp 3: Method 1 Set-Content
            # Set-Content -Path $source -Value $jsonString -Encoding UTF8
            # Stemp 3: Method 2 use Out-File (used in logging)
            $jsonString | Out-File -FilePath $source -Encoding UTF8
            Write-Host "JSON data $description has been written to $source."                    
        } else {
            Add-LogText -Message "Write-WFDataSet $($description)."
        }

        # Update Components
        try {
            # Process DataSets
            foreach ($dataSet in $global:moduleDataArray) {
                <# $dataSet is the current item #>
                $description = $dataSet['description']
                if (-not $description) { $description = "Form" }
                # Step 1: Check if changed is true
                if ($dataSet['changed']) {
                    $source = $dataSet['source']
                    $dataSet['changed'] = $false
                    # Step 2: Convert the object to JSON
                    # Use -Depth to handle nested objects
                    $jsonString = $dataSet | ConvertTo-Json -Depth 5
                    # Step 3: Write the JSON to a file
                    if (-not $source) {
                        # Specify default file path
                        $source = ".\$($description)_dataSetOutput.json" 
                    }
                    # Stemp 3: Method 1 Set-Content
                    # Set-Content -Path $source -Value $jsonString -Encoding UTF8
                    # Stemp 3: Method 2 use Out-File (used in logging)
                    $jsonString | Out-File -FilePath $source -Encoding UTF8
                    Write-Host "JSON data $description has been written to $source."                    
                } else {
                    Add-LogText -Message "Write-WFDataSet $($description)."
                }
            }
            $global:moduleDataChanged = $false
        } catch {
            Add-LogText -IsError -ErrorPSItem $_ "Write-WFDataSet failed processing $optionName."
            return $false
        }
        return $false
    }
}

