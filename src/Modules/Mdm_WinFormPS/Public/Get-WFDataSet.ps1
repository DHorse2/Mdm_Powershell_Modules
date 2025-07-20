
# Get-WFDataSet
function Get-WFDataSet {
    [CmdletBinding()]
    param (
        $dataSet,
        $dataSetItem,
        [hashtable]$dataArray,
        [string]$logFileNameFull = ""
    )
    process {
        try {
            if (-not $dataArray) { $dataArray = $global:appDataArray }
            if ($dataSetItem -and $dataSet) {
                if ($dataArray[$dataSet]) {
                    if ($dataArray[$dataSet].item[$dataSetItem]) {
                        return $dataArray[$dataSet].item[$dataSetItem]
                    } else {
                        Add-LogText -IsError -Message "Get-WFDataSet: DataSetItem $dataSet, $dataSetItem does not exist." -logFileNameFull $logFileNameFull
                    }
                } else {
                    Add-LogText -IsError -Message "Get-WFDataSet: DataSetItem $dataSet does not exist." -logFileNameFull $logFileNameFull
                }
            } elseif ($dataSet) {
                if ($dataArray[$dataSet]) {
                    return $dataArray[$dataSet]
                } else {
                    Add-LogText -IsError -Message "Get-WFDataSet: DataSetItem $dataSet does not exist." -logFileNameFull $logFileNameFull
                }
            } else {
                Add-LogText -IsError -Message "Get-WFDataSet: Invalid parameters DataSetItem $dataSet, $dataSetItem." -logFileNameFull $logFileNameFull
            }
        } catch {
            Add-LogText -IsError -ErrorPSItem $_ -Message "Get-WFDataSet: Error setting DataSet $dataSet, $dataSetItem." -logFileNameFull $logFileNameFull
        }
    }
}
