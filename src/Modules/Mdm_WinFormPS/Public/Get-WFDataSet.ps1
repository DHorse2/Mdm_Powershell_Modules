
# Get-WFDataSet
function Get-WFDataSet {
    [CmdletBinding()]
    param (
        $dataSet,
        $dataSetItem,
        [hashtable]$dataArray
    )
    process {
        try {
            if (-not $dataArray) { $dataArray = $global:moduleDataArray }
            if ($dataSetItem -and $dataSet) {
                if ($dataArray[$dataSet]) {
                    if ($dataArray[$dataSet].item[$dataSetItem]) {
                        return $dataArray[$dataSet].item[$dataSetItem]
                    } else {
                        Add-LogText -IsError -Message "Get-WFDataSet: DataSetItem $dataSet, $dataSetItem does not exist."
                    }
                } else {
                    Add-LogText -IsError -Message "Get-WFDataSet: DataSetItem $dataSet does not exist."
                }
            } elseif ($dataSet) {
                if ($dataArray[$dataSet]) {
                    return $dataArray[$dataSet]
                } else {
                    Add-LogText -IsError -Message "Get-WFDataSet: DataSetItem $dataSet does not exist."
                }
            } else {
                Add-LogText -IsError -Message "Get-WFDataSet: Invalid parameters DataSetItem $dataSet, $dataSetItem."
            }
        } catch {
            Add-LogText -IsError -ErrorPSItem $_ -Message "Get-WFDataSet: Error setting DataSet $dataSet, $dataSetItem."
        }
    }
}
