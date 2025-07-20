
# Add-Type -AssemblyName System.Windows.Forms
function Add-WFDataSetTreeViewNodes {
    [CmdletBinding()]
    param (
        [System.Windows.Forms.TreeNode]$parentNode,
        $dataSetData,
		[string]$logFileNameFull = ""
    )
    # [hashtable]
    # [array]
    # [PSCustomObject]
    # [string][Int32][Itnt64]etc.
    $global:WFDataSetTreeViewNodesDepth += 1
    $dataSetType = $dataSetData.GetType()
    $nodeFirst = $true
    if ($dataSetData -is [array]) {
        foreach ($item in $dataSetData) {
            $itemType = $item.GetType()
            $node = New-Object System.Windows.Forms.TreeNode($item.ToString())
            if ($item -is [hashtable] -or $item -is [array] -or $item -is [PSCustomObject]) {
                Add-WFDataSetTreeViewNodes -parentNode $node -dataSetData $item -logFileNameFull $logFileNameFull
            }
            $parentNode.Nodes.Add($node)
        }
    } elseif ($dataSetData -is [hashtable]) {
        foreach ($key in $dataSetData.Keys) {
            $value = $dataSetData[$key]
            $valueType = $value.GetType()
            $node = New-Object System.Windows.Forms.TreeNode($key)
            if ($value -is [hashtable] -or $value -is [array] -or $value -is [PSCustomObject]) {
                if ($nodeFirst -and -not $parentNode.Text) {
                    $nodeFirst = $false
                    $Node.Text = $value.ToString()
                }
                Add-WFDataSetTreeViewNodes -parentNode $node -dataSetData $value -logFileNameFull $logFileNameFull
            } else {
                $node.Text += ": $value"
            }
            $nodeIndex = $parentNode.Nodes.Add($node)
        }
    } elseif ($dataSetData -is [PSCustomObject]) {
        foreach ($property in $dataSetData.PSObject.Properties) {
            $node = New-Object System.Windows.Forms.TreeNode($property.Name)
            if ($nodeFirst -and -not $parentNode.Text) {
                $nodeFirst = $false
                $parentNode.Text = "$($property.Value)"
            }
            $propertyValue = $property.Value
            if ($propertyValue -is [hashtable] -or $propertyValue -is [PSCustomObject] -or $propertyValue -is [array]) {
                Add-WFDataSetTreeViewNodes -parentNode $node -dataSetData $propertyValue -logFileNameFull $logFileNameFull
            } else {
                $node.Text += ": $($property.Value)"
            }
            $nodeIndex = $parentNode.Nodes.Add($node)
        }
    } else {
        $Message = "Get-WFDataSetTreeViewNodes invalid data in DataSet format: $($dataSetData.GetType())"
        Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
        return
    }
    # $nodeIndex = $parentNode.Nodes.Add($node)
}

function Get-WFDataSetTreeView {
    [CmdletBinding()]
    param (
        [hashtable]$dataArray,
        [System.Windows.Forms.TreeView]$treeView,
        $control,
        [switch]$DoAll,
        [switch]$DoControls,
        [string]$logFileNameFull = ""
    )
    process {
        try {
            if ($dataArray -is [string]) {
                $dataSetObject = $dataArray | ConvertFrom-Json
            } elseif ($dataArray -is [hashtable]) {
                # Valid format already
                $dataSetObject = $dataArray
            } else {
                $Message = "Get-WFDataSetTreeView invalid DataSet format. String or Hashtable only."
                Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
                return $null
            }
            # form
            # $form = New-Object System.Windows.Forms.Form
            # $form.Text = "JSON Viewer"
            # $form.Size = New-Object System.Drawing.Size(600, 400)
            # treeView
            if (-not $treeView) {
                $treeView = New-Object System.Windows.Forms.TreeView
                $treeView.Dock = 'Fill'
            }
            if ($DoAll -or $DoControls -and $control) { $control.Controls.Add($treeView) }
            $rootNode = New-Object System.Windows.Forms.TreeNode("Root")
            # Add-Nodes
            Add-WFDataSetTreeViewNodes -parentNode $rootNode -dataSetData $dataSetObject -logFileNameFull $logFileNameFull
            $nodeIndex = $treeView.Nodes.Add($rootNode)
        } catch {
            $Message = "Get-WFDataSetTreeView unable to process Json TreeView."
            Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
            return $null
        }
    }
    end {
        # $form.Add_Shown({ $control.Activate() })
        # [void]$form.ShowDialog()
        return [System.Windows.Forms.TreeView]$treeView
        # return [System.Windows.Forms.TreeNode]$rootNode
    }
}
function Test-JsonTreeView() {
    # Example JSON
    $dataSetData = '{"name": "John", "age": 30, "city": "New York", "children": [{"name": "Jane", "age": 10}]}'
    $treeView = Show-JsonTree -json $dataSetData
}
