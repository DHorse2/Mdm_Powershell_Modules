
# Set-WFButtonState
function Set-WFButtonState {
    param ($sender, $e, $text)
    try {
        if ($sender -is [WFWindow]) {
            $button = $sender
            $buttonAction = $e
        } elseif ($sender -is [System.Windows.Forms.Form]) {
            $button = $sender
            $buttonAction = $e
        } elseif ($sender -is [System.Windows.Forms.Control]) { 
            $button = $sender
            $buttonAction = $sender.Name
        } else {
            $buttonAction = $e 
        }
        if (-not $text) { $text = $buttonAction }
        Update-WFStatusBarStrip -sender $sender -e $e -statusBarLabel 'statusBarActionState' -text $text
        New-WFSpeakerBeep
        $form = Find-WFForm -sender $sender -e $e
        if ($form) {
            switch ($buttonAction) {
                # State
                "Load" {
                    $cancel = $form.Controls["CancelButton"]
                    if ($cancel) {
                        $cancel.Enabled = $false
                    }
                    $apply = $form.Controls["ApplyButton"]
                    if ($apply) {
                        $apply.Enabled = $false
                    }
                    $global:moduleDataChanged = $false
                }
                # State
                "Changed" {
                    $cancel = $form.Controls["CancelButton"]
                    if ($cancel) {
                        $cancel.Enabled = $true
                    }
                    $apply = $form.Controls["ApplyButton"]
                    if ($apply) {
                        $apply.Enabled = $true
                    }
                    $global:moduleDataChanged = $true
                }
                # Buttons
                "PreviousButton" {
                    # Change focus to previous TabPage
                    # turn off on page 1
                }
                "OkButton" {
                    $button.Text = $global:buttonText['OkButton']
                    if (-not $button.Text) { $button.Text = "Ok" }
                    $button.DialogResult = [System.Windows.Forms.DialogResult]::OK
                }
                "CancelButton" {
                    $button.Text = $global:buttonText['CancelButton']
                    if (-not $button.Text) { $button.Text = "Cancel" }
                    $button.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
                    # $form.CancelButton = $button
                }
                "ApplyButton" {
                    $button.Text = $global:buttonText['ApplyButton']
                    if (-not $button.Text) { $button.Text = "Apply" }
                    $button.DialogResult = [System.Windows.Forms.DialogResult]::OK
                    $dataSetState = "Current"
                }
                "ResetButton" {
                    $button.Text = $global:buttonText['ResetButton']
                    if (-not $button.Text) { $button.Text = "Reset" }
                    $button.DialogResult = [System.Windows.Forms.DialogResult]::None
                    # Read data from file
                    #
                    $cancel = $form.Controls["CancelButton"]
                    if ($cancel) {
                        $cancel.Enabled = $false
                    }
                    $apply = $form.Controls["ApplyButton"]
                    if ($apply) {
                        $apply.Enabled = $false
                    }
                    $global:moduleDataChanged = $true
                }
                "NextButton" {
                    # Change focus to next TabPage
                    # disable on last page
                }
                Default {
                    Add-LogText -IsError "Set-WFButtonState failed processing. $buttonAction is invalid."
                }
            }
        } else {
            Add-LogText -IsError "Set-WFButtonState could not find a form $buttonAction."
        }
    } catch {
        Add-LogText -IsError -ErrorPSItem $_ "Set-WFButtonState Failed to update button state $buttonAction."
    }
}            
