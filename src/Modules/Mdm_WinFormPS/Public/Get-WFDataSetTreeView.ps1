Add-Type -AssemblyName System.Windows.Forms

function Get-WFDataSetTreeView {
    param (
        [string]$json,
        $control,
        $DoControls
    )

    # $form = New-Object System.Windows.Forms.Form
    # $form.Text = "JSON Viewer"
    # $form.Size = New-Object System.Drawing.Size(600, 400)

    $treeView = New-Object System.Windows.Forms.TreeView
    $treeView.Dock = 'Fill'
    if ($DoControls) { $control.Controls.Add($treeView) }

    $jsonObject = $json | ConvertFrom-Json
    $rootNode = New-Object System.Windows.Forms.TreeNode("Root")
    $treeView.Nodes.Add($rootNode)

    function Add-Nodes {
        param (
            [System.Windows.Forms.TreeNode]$parentNode,
            [object]$jsonData
        )
        foreach ($key in $jsonData.PSObject.Properties.Name) {
            $value = $jsonData.$key
            $node = New-Object System.Windows.Forms.TreeNode($key)
            if ($value -is [System.Management.Automation.PSObject]) {
                Add-Nodes -parentNode $node -jsonData $value
            } else {
                $node.Text += ": $value"
            }
            $parentNode.Nodes.Add($node)
        }
    }
    Add-Nodes -parentNode $rootNode -jsonData $jsonObject
    # $form.Add_Shown({ $control.Activate() })
    # [void]$form.ShowDialog()
}
function Test-JsonTreeView() {
    # Example JSON
    $jsonData = '{"name": "John", "age": 30, "city": "New York", "children": [{"name": "Jane", "age": 10}]}'
    $treeView = Show-JsonTree -json $jsonData
}
