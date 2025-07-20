
# Update-WFTextBox
function Update-WFTextBox {
    [CmdletBinding()]
    param(
        $textBox,
        $text,
        [switch]$IsCritical,
        [switch]$IsError,
        [switch]$IsWarning,
        [System.Management.Automation.ErrorRecord]$ErrorPSItem,
        [string]$logFileNameFull = ""

    )
    $global:timeCurrent
    if (-not $textBox) { 
        if (-not $global:ActionOutputTextBox) {
            $global:ActionOutputTextBox = New-Object System.Windows.Forms.TextBox
            $global:ActionOutputTextBox.Multiline = $true
            $global:ActionOutputTextBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Both
            $global:ActionOutputTextBox.Dock = [System.Windows.Forms.DockStyle]::Fill
            $global:ActionOutputTextBox.BorderStyle = $global:borderStyle
        }
        $textBox = $global:ActionOutputTextBox 
    }
    
    $textBoxParams = @{}
    if ($IsError) { 
        $textBoxParams['IsError'] = $true }
    if ($IsWarning) { 
        $textBoxParams['IsWarning'] = $true }
    if ($IsCritical) { 
        $textBoxParams['IsCritical'] = $true }
    if ($ErrorPSItem) { $textBoxParams['ErrorPSItem'] = $ErrorPSItem }

    if ($global:outputBuffer) {
        $textBox.Text += ($global:outputBuffer -join $global:NL) + $global:NL
        Add-LogText -Message $global:outputBuffer -logFileNameFull $logFileNameFull @textBoxParams
        $global:outputBuffer = ""
    }

    if ($text) { 
        $textBox.Text += ($text -join $global:NL) + $global:NL 
        Add-LogText -Message $text -logFileNameFull $logFileNameFull @textBoxParams
    }
    # $textBox.ScrollToCaret()
}
