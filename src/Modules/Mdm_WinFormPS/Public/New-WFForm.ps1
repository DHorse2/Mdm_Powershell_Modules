
# New-WFForm
function New-WFForm {
    <#
	.SYNOPSIS
		Function to create a Form
	
	.DESCRIPTION
		Function to create a Form
	
	.PARAMETER Form
		Specifies the Form. A new forw is returned if null.
	
	.PARAMETER Controls
		TODO Specifies that you want create all the controls in the form.
	
	.PARAMETER DoTabIndex
		TODO Specifies that you want to create the tab index.
	
	.PARAMETER Title
		Specifies that you want to set the Title of the form
	
	.NOTES
		Author: Francois-Xavier Cat
		Twitter:@LazyWinAdm
		WWW: 	lazywinadmin.com
		github.com/lazywinadmin
#>


    [CmdletBinding()]
    param
    (
        [System.Windows.Forms.Form]$form,
        [string]$Title,
        [MenuBar]$menuBar,
        [MarginClass]$margins,
        [string]$TextInput,
        [array]$Buttons,
        [switch]$DoMenuBar,
        [switch]$DoControls,
        [switch]$DoEvents,
        # [switch]$DoTabIndex,
        [switch]$Inquire,
        $state
    )
    BEGIN {
        try {
            Get-Assembly -AssemblyName "System.Windows.Forms"
        } catch {
            Add-LogText -IsError -ErrorPSItem $_ "Failed to load System.Windows.Forms assembly: $_"
            return
        }
    }
    PROCESS {
        try {
            if (-not $form) {
                [System.Windows.Forms.Form]$form = New-Object System.Windows.Forms.Form
                $form.AutoSize = $true
                $form.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
                # $form.Size = New-Object System.Drawing.Size($global:displayWindow.Width, $global:displayWindow.Height)
            }
            if ($Title) {
                $form.Text = $Title
            } else {
                $form.Text = "Unknown Windows GUI Form"
            }
            # Styling
            $form.TopMost = $true
            $form.AutoSize = $true
            $form.AutoSize = $true
            $form.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
            # $form.Size = New-Object System.Drawing.Size($global:displayWindow.Width, $global:displayWindow.Height)
            # $form.FormBorderStyle = 'FixedDialog'
            $form.FormBorderStyle = 'Sizable'
            $form.FormBorderStyle = 'SizableToolWindow'
            if ($state -and $state.x -ge 0 -and $state.y -ge 0) {
                $form.StartPosition = 'Manual'
                $form.Location = New-Object System.Drawing.Point($state.x, $state.y)
            } else {
                # $form.StartPosition = 'CenterScreen'
                $form.StartPosition = 'WindowsDefaultBounds'
            }
            # $form.Size = New-Object System.Drawing.Size($global:displayWindow.Width, $global:displayWindow.Height)

            # if ($DoMenuBar) {
            #     ($menuMain, $mainToolStrip) = New-WFMenuStrip -form $form
            # }
            if ($DoMenuBar) {
                if (-not $menuBar) { [MenuBar]$menuBar = New-WFMenuStrip }
                $form.MainMenuStrip = [System.Windows.Forms.MenuStrip]$menuBar.MenuStrip
                $form.MainMenuStrip.Dock = [System.Windows.Forms.DockStyle]::Top
                if ($DoControls) {
                    $form.Controls.Add([System.Windows.Forms.MenuStrip]$menuBar.MenuStrip)
                    $form.Controls.Add([System.Windows.Forms.ToolStrip]$menuBar.ToolStrip)
                }
            }

            # ( $menuMain, $mainToolStrip ) = New-WFMenuStrip
            # if ($menuMain) {
            #     $form.MainMenuStrip = $menuMain
            #     $form.Controls.Add($menuMain)
            #     [void]$form.Controls.Add($mainToolStrip)
            # }
            # WFFormControls
            $path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\lib\WFFormControls.ps1"
            . $path
            # WFFormButtons
            $path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\lib\WFFormButtons.ps1"
            . $path
            # WFFormEvents
            $path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\lib\WFFormEvents.ps1"
            . $path

            # State
            if ($state) {
                $state.x = [Math]::Max(0, $form.Location.X)
                $state.y = [Math]::Max(0, $form.Location.Y)
            }

            # Get-Result
            function Get-Result ($default) {
                $result = $form.ShowDialog()
                if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
                    return $text.Text
                }
                if ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
                    return 'continue'
                }
                $result = $default
                if (-not $result) { $result = 'quit' }
                return $result
            }
        } catch {
            Add-LogText -IsError -ErrorPSItem $_ "Failed to create form using System.Windows.Forms assembly: $_"
            return
        }
    } #PROCESS
    end { return [System.Windows.Forms.Form]$form }
}