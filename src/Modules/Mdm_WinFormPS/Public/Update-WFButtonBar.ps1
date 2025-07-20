
function Update-WFButtonBar {
    [CmdletBinding()]
    param ($sender, $e, $logFileNameFull = "")
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
        Write-Host "Update-WFButtonBar Control $buttonName '$buttonText'."
    }
    process {
        Update-WFStatusBarStrip -sender $sender -e $e -statusBarLabel 'statusBarActionState' -text $textOut -logFileNameFull $logFileNameFull
        switch ($buttonName) {
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
            "ResetButton" {  
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