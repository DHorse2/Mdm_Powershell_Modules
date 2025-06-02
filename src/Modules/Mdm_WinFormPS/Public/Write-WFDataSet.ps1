
# Write-WFDataSet
function Write-WFDataSet {
    [CmdletBinding()]
    param($sender, $e, 
        [string]$fileNameFull,
        [string]$sourceDirectory,
        [string]$dataSourceName,
        [string]$dataSetState,
        [switch]$IgnoreState,
        [hashtable]$dataArray,
        [string]$commandSource = "",
        [switch]$SkipStatusUpdate
    )
    process {
        $global:fileSystemActive = $true
        try {
            if (-not $dataSourceName) { $dataSourceName = $global:dataSourceName }
            if (-not $dataSourceName) { $dataSourceName = $global:appName }
            if (-not $dataSourceName) { $dataSourceName = "Application" }
            if (-not $dataArray) { $dataArray = $global:moduleDataArray }
            $description = ""
            if (-not $sourceDirectory) {
                $sourceDirectory = "$global:fileDialogInitialDirectory"
            }
            # Id
            if (-not $IgnoreState) {
                if (-not $dataSetState) { $dataSetState = "Current" }
                $dataSourceId = "$($dataSourceName)_$dataSetState"
            } else { $dataSourceId = $dataSourceName }
            if (-not $SkipStatusUpdate) {
                $textOut = $dataSetState
                if ($dataSetState -ne "AutoSave" ) {
                    Update-WFStatusBarStrip -sender $sender -e $e -statusBarLabel 'statusBarDataSetState' -text $textOut
                $textOut = "Write"
                Update-WFStatusBarStrip -sender $sender -e $e -statusBarLabel 'statusBarActionState' -text $textOut
            }
        }    
            New-WFSpeakerBeep
            # Step 1: Check if changed is true
            if ($dataArray['changed'] -or $dataSetState -eq "AutoSave" `
                    -or $commandSource -eq "Save" -or $commandSource -eq "SaveAs" `
            ) {
                if ($fileNameFull) {
                    $outputFileNameFull = $fileNameFull
                } else {
                    $outputFileNameFull = "$sourceDirectory\$($dataSourceId).json" 
                }
                $dataArray['source'] = $outputFileNameFull
                $dataArray['changed'] = $false
                $jsonString = $dataArray | ConvertTo-Json -Depth 7
                $jsonString | Out-File -FilePath $outputFileNameFull -Encoding UTF8
                Write-Host "JSON data $description has been written to $outputFileNameFull."                    

                # Update DataSets
                try {
                    if ($dataSetState -eq "Current") {
                        $dataSourceId = $dataSourceName
                        # Process DataSets
                        foreach ($dataSet in $dataArray) {
                            try {
                                <# $dataSet is the current item #>
                                $description = $dataSet['description']
                                $type = $dataSet['type']
                                # ignore regular properties
                                if ($type -eq "DataSet") {
                                    if (-not $description) { $description = "Form" }
                                    # Step 1: Check if changed is true
                                    if ($dataSet['changed']) {
                                        $dataSet['changed'] = $false
                                        # Step 2: Convert the object to JSON
                                        # Use -Depth to handle nested objects
                                        $jsonString = $dataSet | ConvertTo-Json -Depth 7
                                        # Step 3: Write the JSON to a file
                                        $outputFileNameFull = $dataSet['source']
                                        if (-not $outputFileNameFull) {
                                            # Specify expected file path
                                            $outputFileNameFull = "$source\$($dataSourceId)$($description).json" 
                                        }
                                        # Stemp 3: Method 1 Set-Content
                                        # Set-Content -Path $outputFileNameFull -Value $jsonString -Encoding UTF8
                                        # Stemp 3: Method 2 use Out-File (used in logging)
                                        $jsonString | Out-File -FilePath $outputFileNameFull -Encoding UTF8
                                        Write-Host "JSON data $description has been written to $outputFileNameFull."                    
                                    } else {
                                        $Message = "Write-WFDataSet Current DataSet $description is unchanged. State $dataSetState for $dataSourceName."
                                        Add-LogText -Messages $Message
                                    }
                                }
                            } catch {
                                Add-LogText -IsCritical -IsError -ErrorPSItem $_  "Write-WFDataSet error processing DataSet. State $dataSetState for $dataSourceName, DataSet: $dataSet."
                                $global:fileSystemActive = $false
                                return $false
                            }
                        }
                        $global:moduleDataChanged = $false
                    }
                } catch {
                    Add-LogText -IsCritical -IsError -ErrorPSItem $_  "Write-WFDataSet failed processing $dataSetState for $dataSourceName."
                    $global:fileSystemActive = $false
                    return $false
                }
            } else {
                Add-LogText -Messages "Write-WFDataSet $dataSetState, $dataSourceName is unchanged."
            }
        } catch {
            Add-LogText -IsCritical -IsError -ErrorPSItem $_ -Message "Write-WFDataSet write Current Dataset error storing DataSet State $dataSetState, $dataSourceName."
        }
        $global:fileSystemActive = $false
        return $false
    }
}
