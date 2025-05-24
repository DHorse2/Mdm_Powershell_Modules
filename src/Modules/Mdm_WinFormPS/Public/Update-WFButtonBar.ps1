
function Update-WFButtonBar {
    [CmdletBinding()]
    param ($sender, $e)
    begin {
        if ($sender) {
            $button = $sender
            $buttonName = $button.Name
            $buttonText = $button.Text
        } else {
            $buttonName = $e
            $buttonText = $e
        }
        if (-not $buttonText) { $buttonText = $buttonName }
        # $isChecked = $button.Checked
        $isPressed = $true

        # Implement your data update logic here
        $buttonKeys = $buttonName -split "_"
        # Assign to variables
        $dataSet = $buttonKeys[0]
        $dataSetItemSet = $buttonKeys[1..($buttonKeys.Length - 1)]
        $dataSetItem = $dataSetItemSet -join "_"
        if (-not $dataSetItem) {
            $dataSetItem = $dataSet
            $dataSet = "Form"
        }
        Write-Host "Update-WFButtonBar Control $buttonName '$buttonText' DataSet: $dataSet, Item: $dataSetItem, Checked: $isChecked."
    }
    process {
        switch ($dataSetItem) {
            "PreviousButton" { 
                # Enable if used
                # Disable on page 1
            }
            "OkButton" { 
                # Update File
                # Close Form
                # Disable Apply
                $apply = $form.Controls["ApplyButton"]
                $apply.Enabled = $false
            }
            "CancelButton" { 
                # Close form
                $form.Close()
            }
            "ApplyButton" {  
                # Update File
                # Disable Apply
                $apply = $form.Controls["ApplyButton"]
                $apply.Enabled = $false
            }
            "NextButton" {
                # Enable if used
                # Disable on lasat page
            }
            Default {}
        }
    }
    
    end {
        
    }
}