
# Read-WFDataSet
function Read-WFDataSet {
    [CmdletBinding()]
    param (
        [string]$fileNameFull,
        [string]$sourceDirectory,
        [string]$dataSourceName,
        [string]$dataSetState,
        [switch]$IgnoreState,
        [hashtable]$dataArray,
        [switch]$DoReturn,
        [switch]$SkipStatusUpdate
    )
    begin {
        $global:fileSystemActive = $true
        if (-not $dataSourceName) { $dataSourceName = $global:dataSourceName }
        if (-not $dataSourceName) { $dataSourceName = $global:appName }
        if (-not $dataSourceName) { $dataSourceName = "Application" }
        if (-not $sourceDirectory) { $sourceDirectory = "$global:fileDialogInitialDirectory" }
        if (-not $dataSetState) { $dataSetState = "Current" }
        if ($DoReset) {
            [hashtable]$dataArray = New-Object System.Collections.Hashtable
        }
        if ($dataArray) {
            $dataOut = $dataArray
        } else {
            [hashtable]$dataOut = New-Object System.Collections.Hashtable
        }
    }
    process {
        if (-not $SkipStatusUpdate) {
            $textOut = $dataSetState
            Update-WFStatusBarStrip -sender $sender -e $e -statusBarLabel 'statusBarDataSetState' -text $textOut
            $textOut = "Read"
            Update-WFStatusBarStrip -sender $sender -e $e -statusBarLabel 'statusBarActionState' -text $textOut
        }
        if ($IgnoreState -or $dataSetState -ne "Current") {
            # Read DataSet
            try {
                if (-not $IgnoreState) {
                    if (-not $dataSetState) { $dataSetState = "Current" }
                    $dataSourceId = "$($dataSourceName)_$dataSetState"
                } else { $dataSourceId = $dataSourceName }
                # read
                if (-not $fileNameFull) {
                    $fileNameFull = "$sourceDirectory\$dataSourceId.json"
                }
                if (-not $dataSet) { $dataSet = "Data" }
                $dataOut = Get-JsonData `
                    -AddSource `
                    -Name $dataSet `
                    -jsonItem $fileNameFull

            } catch {
                $Message = "Read-WFDataSet $($dataSetState): unable to Read DataSet."
                Add-LogText -Messages $Message -IsCritical -IsError -ErrorPSItem $_
            }
        } else {
            # Load Configuration into DataSet
            try {
                if ($DoReset) {
                    [hashtable]$global:moduleDataArray = New-Object System.Collections.Hashtable
                }
                $dataSet = "GuiConfig"
                Get-JsonData `
                    -AddSource `
                    -Name $dataSet `
                    -parentObject $dataOut `
                    -Append `
                    -jsonItem "$sourceDirectory\DevEnvGuiConfig.json"
                # Load components
                $dataSet = "Modules"
                Get-JsonData `
                    -Name $dataSet `
                    -parentObject $dataOut `
                    -Append `
                    -jsonItem "$sourceDirectory\DevEnvModules.json"
                # $global:moduleDataArray += $modulesData
                # $global:moduleDataArray = Update-JsonData $componentsData $global:moduleDataArray
                #
                $dataSet = "Components"
                Get-JsonData `
                    -Name $dataSet `
                    -parentObject $dataOut `
                    -Append `
                    -jsonItem "$sourceDirectory\DevEnvComponents.json"
                #
                $dataSet = "Categories"
                Get-JsonData `
                    -Name $dataSet `
                    -parentObject $dataOut `
                    -Append `
                    -jsonItem "$sourceDirectory\DevEnvCategories.json"

                $global:moduleDataArray = $dataOut
                # $global:moduleDataArray['changed'] = $false
            } catch {
                $Message = "Read-WFDataSet $($dataSetState): unable to load and build DataSet."
                Add-LogText -Messages $Message -IsCritical -IsError -ErrorPSItem $_
            }
        }
    }
    end {
        $global:fileSystemActive = $false
        if ($DoReturn) {
            return $dataOut
            # return $global:moduleDataArray
        }
    }
}