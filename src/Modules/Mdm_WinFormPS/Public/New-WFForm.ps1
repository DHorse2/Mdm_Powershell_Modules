
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
        [Margins]$margins,
        [string]$TextInput,
        [string]$OkButton,
        [string]$CancelButton,
        [switch]$DoMenuBar,
        [switch]$DoControls,
        [switch]$DoTabIndex,
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
                # FormClosing event handler
                $form.Add_FormClosing({
                        param($sender, $e)
                        if ($Inquire) {
                            # Prompt the user for confirmation
                            $result = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to close the form?", "Confirm Close", [System.Windows.Forms.MessageBoxButtons]::YesNo)
                            # If the user clicks "No", cancel the closing event
                            if ($result -eq [System.Windows.Forms.DialogResult]::No) {
                                $e.Cancel = $true
                            }
                        }
                    })
                # On Load
                $form.Add_Load({
                        param($sender, $e)
                        if ($OkButton -and $ok) {
                            $xTmp = $margins.Left + 200; $yTmp = $window.ClientSize.Height - $ok.Height - $margins.Bottom
                            $ok.Location = New-Object System.Drawing.Point($xTmp, $yTmp)
                        }
                        if ($CancelButton -and $cancel) {
                            $xTmp = $margins.Left + 300; $yTmp = $window.ClientSize.Height - $cancel.Height - $margin.Bottom
                            $cancel.Location = New-Object System.Drawing.Point($xTmp, $yTmp)
                        }
                        if ($TextInput -and $text) { $text.Select() }
                        elseif ($OkButton -and $ok) { $ok.Select() }
                        else { $this.Select() }
                        $this.Activate()
                    })
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
                [MenuBar]$menuBar = New-WFMenuStrip
                $form.MainMenuStrip = [System.Windows.Forms.MenuStrip]$menuBar.MenuStrip
                if ($DoControls) {
                $form.Controls.Add([System.Windows.Forms.ToolStrip]$menuBar.ToolStrip)
                $form.Controls.Add([System.Windows.Forms.MenuStrip]$menuBar.MenuStrip)
                }
            }

            # ( $menuMain, $mainToolStrip ) = New-WFMenuStrip
            # if ($menuMain) {
            #     $form.MainMenuStrip = $menuMain
            #     $form.Controls.Add($menuMain)
            #     [void]$form.Controls.Add($mainToolStrip)
            # }
            
            $ok = $null
            $cancel = $null
            $text = $null

            if ($TextInput) {
                # $label = New-Object System.Windows.Forms.Label
                # $label.Location = New-Object System.Drawing.Point(10, 10)
                # $label.Size = New-Object System.Drawing.Size(380, 20)
                # $label.Text = $Prompt
                # $form.Controls.Add($label)
                $text = New-Object System.Windows.Forms.TextBox
                $text.Text = $TextInput
                $text.Location = New-Object System.Drawing.Point(10, 30)
                $text.Size = New-Object System.Drawing.Size(365, 20)
                if ($DoControls) { 
                    $form.Controls.Add($text) 
                }
            }
    
            if ($OkButton) {
                $ok = New-Object System.Windows.Forms.Button
                $ok.Location = New-Object System.Drawing.Point(225, 60)
                $ok.Size = New-Object System.Drawing.Size(75, 23)
                $ok.Text = $OkButton
                # $ok.DialogResult = 'Ok'
                $ok.DialogResult = [System.Windows.Forms.DialogResult]::OK
                $form.AcceptButton = $ok
                if ($DoControls) { 
                    $form.Controls.Add($ok) 
                }
            }
    
            if ($CancelButton) {
                $cancel = New-Object System.Windows.Forms.Button
                $cancel.Location = New-Object System.Drawing.Point(300, 60)
                $cancel.Size = New-Object System.Drawing.Size(75, 23)
                $cancel.Text = $CancelButton
                $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
                if ($DoControls) { 
                    $form.Controls.Add($cancel) 
                }
            }
            # State
            if ($state) {
                $state.x = [Math]::Max(0, $form.Location.X)
                $state.y = [Math]::Max(0, $form.Location.Y)
            }
    
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
            # ####
            # IF ($PSBoundParameters["Controls"])
            # {
            # 	$form.Controls
            # }            # IF ($PSBoundParameters["DoTabIndex"])
            # {
            # 	$form.DoTabIndex
            # }
            # # [Alias('Title')]
            # IF ($PSBoundParameters["Text"])
            # {
            # 	$form.Text
            # }
        } catch {
            Add-LogText -IsError -ErrorPSItem $_ "Failed to create form using System.Windows.Forms assembly: $_"
            return
        }
    } #PROCESS
    end { return [System.Windows.Forms.Form]$form }
}