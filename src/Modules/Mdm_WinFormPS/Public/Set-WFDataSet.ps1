
# Set-WFDataSet
function Set-WFDataSet {
    [CmdletBinding()]
    param (
        $dataSet,
        $dataSetItem,
        [hashtable]$dataArray,
        $inputDataArray
    )
    process {
        try {
            if (-not $dataArray) { $dataArray = $global:appDataArray }
            if ($dataSetItem -and $dataSet) {
                if (-not $dataArray.ContainsKey($dataSet)) {
                    $dataArray[$dataSet] = @{}
                    Add-LogText -Message "Set-WFDataSet: DataSetItem $dataSet, $dataSetItem does not exist."
                }
                if (-not $dataArray[$dataSet].item) {
                    $dataArray[$dataSet].item = @{}
                    Add-LogText -Message "Set-WFDataSet: DataSetItem $dataSet, $dataSetItem does not exist."
                }
                $dataArray[$dataSet].item[$dataSetItem] = $inputDataArray
            } elseif ($dataSet) {
                if (-not $dataArray.ContainsKey($dataSet)) {
                    $dataArray[$dataSet] = @{}
                    Add-LogText -Message "Set-WFDataSet: DataSetItem $dataSet, $dataSetItem does not exist."
                }
                $dataArray[$dataSet] = $inputDataArray
            } else {
                Add-LogText -IsError -Message "Set-WFDataSet: Invalid parameters DataSetItem $dataSet, $dataSetItem."
            }
        } catch {
            Add-LogText -IsError -ErrorPSItem $_ -Message "Set-WFDataSet: Error setting DataSet $dataSet, $dataSetItem."
        }
    }
}
