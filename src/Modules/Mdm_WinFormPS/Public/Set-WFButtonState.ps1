
# Set-WFButtonState
function Set-WFButtonState {
    param ($sender, $e, $text, $logFileNameFull = "")
    try {
        if ($sender -is [WFWindow]) {
            $button = $sender
            $buttonAction = $e
        } elseif ($sender -is [System.Windows.Forms.Form]) {
            $button = $sender
            $buttonAction = $e
        } elseif ($sender -is [System.Windows.Forms.CheckBox]) {
            $buttonAction = "CheckBox"
        } elseif ($sender -is [System.Windows.Forms.Control]) { 
            $button = $sender
            $buttonAction = $sender.Name
        } else {
            $buttonAction = $e 
        }
        if (-not $text) { $text = $buttonAction }
        Update-WFStatusBarStrip -sender $sender -e $e -statusBarLabel 'statusBarActionState' -text $text -logFileNameFull $logFileNameFull
        New-WFSpeakerBeep
        $form = Find-WFForm -sender $sender -e $e
        if ($sender -is [WFWindow]) {
            $null
        } elseif ($form) {
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
                    $global:appDataChanged = $false
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
                    $global:appDataChanged = $true
                }
                # Data
                "CheckBox" {
                    $global:appDataChanged = $true
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
                    $global:appDataChanged = $true
                }
                "NextButton" {
                    # Change focus to next TabPage
                    # disable on last page
                }
                Default {
                    $Message = "Set-WFButtonState failed processing. $buttonAction is invalid."
                    Add-LogText -IsError $Message -logFileNameFull $logFileNameFull
                }
            }
        } else {
            $Message = "Set-WFButtonState could not find a form $buttonAction."
            Add-LogText -IsError $Message -logFileNameFull $logFileNameFull
        }
    } catch {
        $Message = "Set-WFButtonState Failed to update button state $buttonAction."
        Add-LogText -IsError -ErrorPSItem $_ $Message -logFileNameFull $logFileNameFull
    }
}            
