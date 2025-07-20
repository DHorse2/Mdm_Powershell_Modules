
# Find-WFForm
function Find-WFForm {
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
        Find-WFForm -sender $sender -e $e 
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    
    
    [CmdletBinding()]
    param($sender, $e,
        [switch]$DefaultToRoot,
        [string]$logFileNameFull = ""
    )
    begin {
        $parentControl = $null
        try {
            if ($sender -is [WFWindow]) {
                $parentControl = $sender.Forms[$sender.FormIndex]
            } elseif ($sender -is [System.Windows.Forms.Form]) {
                $parentControl = $sender
            } elseif ($sender -is [System.Windows.Forms.Control]) {
                $parentControl = $sender.Parent
                while ($parentControl -and -not ($parentControl -is [System.Windows.Forms.Form])) {
                    $parentControl = $parentControl.Parent
                }
            } else {
                $Message = "Find-WFForm the sender is not a Control and has no Parents for $($senderName)."
                Add-LogText -IsError -Message $Message -logFileNameFull $logFileNameFull
            }
            if (-not $DefaultToRoot -and ($parentControl -isnot [System.Windows.Forms.Form])) { 
                $parentControl = $null
            }
        } catch {
            $Message = "Find-WFForm error walking Control Parents for $($senderName)."
            Add-LogText -IsError -ErrorPSItem $_ -Message $Message -logFileNameFull $logFileNameFull
        }
        return $parentControl
    }
}