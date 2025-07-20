
# Read-WFDataSet
function Read-WFDataSet {
    [CmdletBinding()]
    param (
        [string]$fileNameFull,
        [string]$sourceDirectory,
        [string]$dataSourceName,
        [string]$dataSet,
        [string]$dataSetState,
        [switch]$IgnoreState,
        [hashtable]$dataArray,
        [switch]$DoReturn,
        [switch]$SkipStatusUpdate,
        [string]$logFileNameFull = "",
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause
    )
    begin {
        $global:dataSetBusy = $true
        if (-not $dataSourceName) { $dataSourceName = $global:dataSourceName }
        if (-not $dataSourceName) { $dataSourceName = $global:appName }
        if (-not $dataSourceName) { $dataSourceName = "Application" }
        if (-not $sourceDirectory) { $sourceDirectory = "$global:dataSetDirectory" }
        if (-not $dataSet) { $dataSet = $global:dataSet }
        if (-not $dataSet) { $dataSet = "Data" }
        if (-not $dataSetState) { $dataSetState = $global:dataSetState }
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
            Update-WFStatusBarStrip -sender $sender -e $e -statusBarLabel 'statusBarDataSetState' -text $textOut -logFileNameFull $logFileNameFull
            $textOut = "Read"
            Update-WFStatusBarStrip -sender $sender -e $e -statusBarLabel 'statusBarActionState' -text $textOut -logFileNameFull $logFileNameFull
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
                $jsonData = Get-JsonData `
                    -AddSource `
                    -Name $dataSet `
                    -jsonItem $fileNameFull `
                    -logFileNameFull $logFileNameFull
                # $dataOut = $global:jsonDataResult

            } catch {
                $Message = "Read-WFDataSet $($dataSetState): unable to Read DataSet."
                Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
            }
        } else {
            # Load Configuration into DataSet
            try {
                if ($DoReset) {
                    [hashtable]$global:appDataArray = New-Object System.Collections.Hashtable
                }
                $dataSet = "GuiConfig"
                Get-JsonData `
                    -AddSource `
                    -Name $dataSet `
                    -parentObject $dataOut `
                    -Append `
                    -jsonItem "$sourceDirectory\DevEnvGuiConfig.json" `
                    -logFileNameFull $logFileNameFull
                # Load components
                $dataSet = "Modules"
                Get-JsonData `
                    -Name $dataSet `
                    -parentObject $dataOut `
                    -Append `
                    -jsonItem "$sourceDirectory\DevEnvModules.json" `
                    -logFileNameFull $logFileNameFull
                # $global:appDataArray += $modulesData
                # $global:appDataArray = Update-JsonData $componentsData $global:appDataArray
                #
                $dataSet = "Components"
                Get-JsonData `
                    -Name $dataSet `
                    -parentObject $dataOut `
                    -Append `
                    -jsonItem "$sourceDirectory\DevEnvComponents.json" `
                    -logFileNameFull $logFileNameFull
                #
                $dataSet = "Categories"
                Get-JsonData `
                    -Name $dataSet `
                    -parentObject $dataOut `
                    -Append `
                    -jsonItem "$sourceDirectory\DevEnvCategories.json" `
                    -logFileNameFull $logFileNameFull

                $global:appDataArray = $dataOut
                # $global:appDataArray['changed'] = $false
            } catch {
                $Message = "Read-WFDataSet $($dataSetState): unable to load and build DataSet."
                Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
            }
        }
    }
    end {
        $global:dataSetBusy = $false
        if ($DoReturn) {
            return $dataOut
            # return $global:appDataArray
        }
    }
}