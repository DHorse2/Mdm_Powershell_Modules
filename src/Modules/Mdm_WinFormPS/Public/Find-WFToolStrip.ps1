
# Find-WFToolStrip
function Find-WFToolStrip {
    <#
    .SYNOPSIS
        Walks (navigates) up the Parent of a control to locate the Form
    .DESCRIPTION
        xxx
    .NOTES
        xxx
    .LINK
        Not implemented.
    .EXAMPLE
        Find-WFToolStrip -sender $sender -e $e 
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    
    
    [CmdletBinding()]
    param($sender, $e,
        [string]$toolStrip,
        [System.Windows.Forms.Form]$form,
        [switch]$DefaultToRoot,
		[string]$logFileNameFull = ""
    )
    begin {
        try {
            if (-not $form) {
                if ($sender -is [WFWindow]) {
                    $form = $sender.Forms[$sender.FormIndex]
                } elseif ($sender -is [System.Windows.Forms.Form]) {
                    $form = $sender
                } elseif ($sender -is [System.Windows.Forms.Control]) {
                    $form = Find-WFForm -sender $sender -e $e
                } else {
                    $form = $global:window.Forms[$global:window.FormIndex]
                    # $Message = "Find-WFToolStrip the sender is not a Control and has no Parents for $($sender)."
                    # Add-LogText -IsError -Message $Message
                }
                if (-not $DefaultToRoot -and ($form -isnot [System.Windows.Forms.Form])) { 
                    $form = $null
                }
            }
        } catch {
            $Message = "Find-WFToolStrip error locating form for $($sender)."
            Add-LogText -IsError -ErrorPSItem $_ -Message $Message -logFileNameFull $logFileNameFull
        }
    }
    process {
        try {
            if ($form -is [System.Windows.Forms.Form]) {
                # You can now access the form and its properties
                if (-not $toolStrip) { $toolStrip = "StdStatusBar" }
                $statusBarStrip = $null
                # Assuming $form is your form instance
                foreach ($control in $form.Controls) {
                    if ($control -is [System.Windows.Forms.ToolStrip]) {
                        Write-Verbose "Found ToolStrip $toolStrip."
                        if ($control.Items[$toolStrip]) {
                            $statusBarStrip = $control
                            break
                        }
                    }
                }
                return $statusBarStrip
            } else {
                $Message = "Find-WFToolStrip the call does not lead to the form. $toolStrip $($sender)."
                Add-LogText -IsError -Message $Message -logFileNameFull $logFileNameFull
            }
        } catch {
            $Message = "Find-WFToolStrip error locating Tool Strip for $toolStrip $($sender)."
            Add-LogText -IsError -ErrorPSItem $_ -Message $Message -logFileNameFull $logFileNameFull
        }
        return $null
    }
}