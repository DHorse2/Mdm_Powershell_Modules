
# Update-WFStatusBarStrip
function Update-WFStatusBarStrip {
    <#
    .SYNOPSIS
        Update the Status Bar at the bottom of the Form.
    .DESCRIPTION
        Buttons call this functions with text updates to Label on the Status Bar.
    .NOTES
        MenuStrips and ToolStips do not have the Property Name.
        They also lack the Tag property.
        This results an inability to access it. 
        Forms.Control("MyStatusBar") does not work!
    .LINK
        Not implemented.
    .EXAMPLE
        Update-WFStatusBarStrip -sender $sender -e $e -statusBarLabel 'statusBarActionState' -text $textOut
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    
    
    [CmdletBinding()]
    param($sender, $e,
        $statusBarLabel,
        $text,
        $logFileNameFull = ""
    )
    begin {
        try {
            $senderName = $e
            if ($sender -is [WFWindow]) {
                $senderName = $e
            } elseif ($sender -is [System.Windows.Forms.Form]) {
                $senderName = $sender.Name
                if (-not $senderName) { $senderName = $global:appName }
            } elseif ($sender -is [System.Windows.Forms.Control]) {
                if ($sender.Name) {
                    $senderName = $sender.Name
                } else { $senderName = $sender.Text }
            } else {
                $Message = "Update-WFStatusBarStrip the sender is not a Control and has no Parents for $($senderName)."
                Add-LogText -IsError -Message $Message -logFileNameFull $logFileNameFull
                return
            }
            $parentControl = Find-WFForm -sender $sender -e $e
        } catch {
            $Message = "Update-WFStatusBarStrip error walking Control Parents for $($senderName)."
            Add-LogText -IsError -ErrorPSItem $_ -Message $Message -logFileNameFull $logFileNameFull
            return
        }
    }
    process {
        # Should be the form
        try {
            if ($parentControl -is [System.Windows.Forms.Form]) {
                # You can now access the form and its properties
                $form = $parentControl
                $statusBarStrip = Find-WFToolStrip -toolStrip "StdStatusBar" -form $form -logFileNameFull $logFileNameFull

                # $statusBarStrip = $form.Controls['StdStatusBar']
                if ($statusBarStrip) {
                    if ($statusBarStrip.Items[$statusBarLabel]) {
                        $statusBarAutoSaveLabel = $statusBarStrip.Items[$statusBarLabel]
                        if (-not $text ) { 
                            $text = "Action $($senderName) at " + (Get-Date).ToString("HH:mm:ss")
                        }
                        $statusBarAutoSaveLabel.Text = $text
                        $width = $statusBarAutoSaveLabel.PreferredSize.Width
                        $height = $global:displayButtonSize.Height
                        # update something (StatusBarSize)
                        Write-Verbose "ToolStrip updated."
                    } else { 
                        $Message = "Update-WFStatusBarStrip Status Bar Label not found for $($senderName)."
                        Add-LogText -IsError -Message $Message -logFileNameFull $logFileNameFull
                    }
                } else {
                    $Message = "Update-WFStatusBarStrip Status Bar not found for $($senderName)."
                    Add-LogText -IsError -Message $Message -logFileNameFull $logFileNameFull
                }
            } else {
                $Message = "Update-WFStatusBarStrip the sender Parent does not lead to the form. $($senderName)."
                Add-LogText -IsError -Message $Message -logFileNameFull $logFileNameFull
            }
        } catch {
            $Message = "Update-WFStatusBarStrip error updating Form Status Bar for $($senderName)."
            Add-LogText -IsError -ErrorPSItem $_ -Message $Message -logFileNameFull $logFileNameFull
        }
    }
    end {
        
    }
}