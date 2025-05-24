
# Get-WFDataSet
function Get-WFDataSet {
    [CmdletBinding()]
    param (
        $dataSet,
        $dataSetItem
    )
    process {
        if ($dataSetItem -and $dataSet) {
            if ($global:moduleDataArray[$dataSet]) {
                if ($global:moduleDataArray[$dataSet].item[$dataSetItem]) {
                    return $global:moduleDataArray[$dataSet].item[$dataSetItem]
                } else {
                    # TODO error
                }
            } else {
                # TODO error
            }
        } elseif ($dataSet) {
            if ($global:moduleDataArray[$dataSet]) {
                return $global:moduleDataArray[$dataSet]
            } else {
                # TODO error
            }
        }
    }
}
