
# Function to update data
function Update-WFDataSet {
    [CmdletBinding()]
    param($sender, $e)
    # param (
    #     $optionName, 
    #     $optionText, 
    #     $isChecked
    # )
    process {
        try {
            # sender based
            $control = $sender
            if ($sender -is [System.Windows.Forms.Control]) {
                $optionName = $control.Name
                $optionText = $control.Text
                if (-not $optionText) { $optionText = $optionName }
            }
            if ($sender -is [System.Windows.Forms.CheckBox]) {
                $isChecked = $control.Checked
            } elseif ($sender -is [System.Windows.Forms.Button]) {
                $isChecked = $true
            } elseif ($sender -is [System.Windows.Forms.TextBox]) {
                $isChecked = $true
            } else {
                $optionName = $e
                $optionText = $e
                $isChecked = $true
            }
            # Implement your data update logic here
            $optionKeys = $optionName -split "_"
            # Assign to variables
            $dataSet = $optionKeys[0]
            $dataSetItemSet = $optionKeys[1..($optionKeys.Length - 1)]
            $dataSetItem = $dataSetItemSet -join "_"
            if (-not $dataSetItem) {
                $dataSetItem = $dataSet
                $dataSet = "Form"
            }
            Write-Host "Update-WFDataSet Control $optionName '$optionText' DataSet: $dataSet, Item: $dataSetItem, Checked: $isChecked."
            # Locate Data Type
            $moduleData = $global:moduleDataArray[$dataSet]
            if ($moduleData) {
                # Locate Data Item
                # Find the specific item in the array
                $itemData = $moduleData.items | Where-Object { $_.label -eq $dataSetItem }
                if ($itemData) {
                    try {
                        # Found, Update it.
                        $itemData.checked = $isChecked
                        $moduleData['changed'] = $true
                        $global:moduleDataChanged = $true
                        if (-not $global:moduleDataArray['Control']) { $global:moduleDataArray['Control'] = @{} }
                        $global:moduleDataArray['Control']['ActionLast'] = $optionText
                        # if ($global:DoDebug -or $global:DoVerbose) {
                        $Message = "Update-WFDataSet Update $optionName '$optionText' DataSet: $dataSet, Item: $dataSetItem, Checked: $isChecked."
                        Add-LogText $Message
                        # }
                        $global:moduleDataArray['changed'] = $true
                        return $true
                    } catch {
                        $Message = "Update-WFDataSet Error valid json DataSet and Item, Field not found: $optionName"
                        Add-LogText -IsError -ErrorPSItem $_ -Messages $Message
                        return $false
                    }
                } else {
                    $Message = "Update-WFDataSet Error valid json DataSet, but Item not found: $optionName"
                    Add-LogText -IsError -Messages $Message
                    return $false
                }
            } else {
                $Message = "Update-WFDataSet Error json DataSet Key not found: $optionName"
                Add-LogText -IsError -Messages $Message
                return $false
            }
        } catch {
            $Message = "Update-WFDataSet failed processing $optionName."
            Add-LogText -IsError -ErrorPSItem $_ -Messages $Message
            return $false
        }
        return $false
    }
}
