
# Build-WFCheckBoxList
function Build-WFCheckBoxList {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$jsonData,
        # form require for graphics object
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Windows.Forms.Form]$form,
        [string]$Name,
        [System.Windows.Forms.GroupBox]$groupBox,
        [string]$groupBoxLabel = "",
        [switch]$NotDialog,
        [MarginClass]$margins,
        [int]$xPos = $global:displayWindow.Top,
        [int]$yPos = $global:displayWindow.Top,
        [int]$xWidth = 100,
        [int]$yHeight = 30,
        [int]$groupHeightMax = 300
    )
    begin { 
        [Collections.ArrayList]$checkboxes = @()
        # Create a Graphics object
        $graphics = $form.CreateGraphics()
        $xTop = $xPos
        $yTop = $yPos
        if (-not $groupBox) {
            # Create a GroupBox to hold the checkboxes
            $groupBox = New-Object System.Windows.Forms.GroupBox
            $groupBox.Location = New-Object System.Drawing.Point($xPos, $yPos)
        }
        if ($groupBoxLabel) {
            $groupBox.Text = $groupBoxLabel
        }
        if ($groupBox.Text) {
            # Actual Size
            $size = $graphics.MeasureString($groupBox.Text, $groupBox.Font)
            # $yPos += [Math]::Max($size.Height, $yPos)
        }
        if ($Name) { $groupBox.Name = $Name }
        $yPos += 10 # + padding
        # Common event handler for CheckBox click events
        $global:checkboxEventHandler = {
            param($sender, $e)
            Update-WFDataSet -sender $sender -e $e
            $global:moduleDataChanged = $true
            $textOut = "Changed"
            Set-WFButtonState -sender $sender -e $e -text $textOut
        }
        # Common event handler for CheckBox click events
        # $global:checkboxEventHandler = {
        #     param($sender, $e)
        #     Update-WFDataSet($sender, $e)
        #     # $checkBox = $sender
        #     # $name = $checkBox.Name
        #     # $text = $checkBox.Text
        #     # if (-not $text) { $text = $name }
        #     # $state = $checkBox.Checked
        #     # Update-WFDataSet($name, $text, $state)
        # }    
    }
    process { [void]$checkboxes.Add($jsonData) }
    end {
        try {
            # Create checkboxes based on JSON data
            # Text length in characters
            $xWidthMeasured = 50
            foreach ($jsonCheckboxes in $checkboxes) {
                foreach ($checkboxItem in $jsonCheckboxes.items) {
                    if ($checkboxItem.label.Length -gt $xWidthMeasured) {
                        $xWidthMeasured = $checkboxItem.label.Length
                    }
                }
            }
            $xWidth = $xWidthMeasured * 5 + 50 # approximate
            $xWidthMax = $xWidth + 20
            $yHeight = 30
            $yHeightMax = 300
            $xPosMax = $xTop + $xWidthMax
            $yPosMax = $yTop + $yHeight
            # $xPos = $xTop
            # $yPos = $yTop
            foreach ($jsonCheckboxes in $checkboxes) {
                $dataType = $jsonCheckboxes.description
                if (-not $dataType) { $dataType = $Name }
                if (-not $dataType) { $dataType = "Form" }
                foreach ($checkboxItem in $jsonCheckboxes.items) {
                    if ($checkboxItem -is [PSCustomObject]) {
                        if ($checkboxItem.label.Length -gt $xWidthMax) { $xWidthMax = $checkboxItem.label.Length }
                        if ($yPos -ge $groupHeightMax) {
                            $yPosMax = [Math]::Max($yPos, $yHeightMax)
                            $yPos = $yTop
                            $xPos += ($xWidth + 20)
                            $xPosMax = $xPos + $xWidthMax
                        }
                        $checkbox = New-Object System.Windows.Forms.CheckBox
                        $checkbox.Text = $checkboxItem.label
                        $checkbox.Name = "$($dataType)_$($checkboxItem.label)"
                        $checkbox.Checked = $checkboxItem.checked
                        if ($checkboxItem.label.Length -gt $xWidthMeasured) {
                            $xWidthMeasured = $checkboxItem.label.Length
                        }
                        $checkbox.Location = New-Object System.Drawing.Point($xPos, $yPos)
                        $xTmp = $xWidth
                        $yTmp = $yHeight - 5
                        # Actual Size
                        $size = $graphics.MeasureString($checkbox.Text, $checkbox.Font)
                        # Set the label width based on the measured width
                        $xTmp = [int]$size.Width + 50 + 10  # + some padding
                        # Adjust column width updward dynamically
                        if ($xTmp -gt $xWidth) { $xWidth = $xTmp }
                        # Actual Height
                        $yTmp = [int]$size.Height
                        $checkbox.Size = New-Object System.Drawing.Size($xTmp, $yTmp)
                        # Add Control
                        # if ($form) { $form.Controls.Add($checkbox) }
                        # else { 
                        $groupBox.Controls.Add($checkbox) 
                        # }
                        $checkbox.Add_Click($global:checkboxEventHandler)
                        $yPos += $yTmp + 10 # + padding
                        # $yPos += $yHeight
                        if ($yPos -ge $yPosMax) { $yPosMax = $yPos }
                    }
                }
            }
            # $xPosMax = $xPos + $xWidthMax
            # $yPosMax += 20 # + padding
            # Adjust the size of the group box or form
            $groupBox.Size = New-Object System.Drawing.Size($xPosMax, $yPosMax)
        } catch {
            $Message = "An error occurred while building the checkbox list ($checkbox)."
            Add-LogText -Messages $Message -IsError -ErrorPSItem $_
            return $null
        }
        return $groupBox 
    }
}
