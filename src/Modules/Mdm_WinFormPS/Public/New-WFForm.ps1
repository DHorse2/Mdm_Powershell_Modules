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
	
	.PARAMETER TabIndex
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
        [Switch]$Controls,
        [Switch]$TabIndex,
        [Switch]$Text,
        [switch]$OkButton,
        [switch]$CancelButton
    )
	
    BEGIN {
        Get-Assembly -AssemblyName "System.Windows.Forms"
    }
    PROCESS {
        if (-not $form) {
            $form = New-Object System.Windows.Forms.Form
            $form
            $form.Size = New-Object System.Drawing.Size(400, 400)
            # FormClosing event handler
            $form.Add_FormClosing({
                    param($sender, $e)
                    # Prompt the user for confirmation
                    $result = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to close the form?", "Confirm Close", [System.Windows.Forms.MessageBoxButtons]::YesNo)
                    # If the user clicks "No", cancel the closing event
                    if ($result -eq [System.Windows.Forms.DialogResult]::No) {
                        $e.Cancel = $true
                    }
                })
        }
        if ($Title) {
            $form.Title = $Title
        } else {
            $form.Text = "Unknown Windows GUI Form"
        }
        if (-not $form.Data) {
            # Initialize $data as a property of the form
            $form.Data = @{
                Package    = "MacroDM"
                Module     = ""
                ScriptName = ""
                FormName   = ""
                Options    = [PSCustomObject]@{
                    Options = $false
                }
            }

        }
        # Styling
        $form.TopMost = $true
        $form.Size = New-Object System.Drawing.Size(400, 132)
        $form.FormBorderStyle = 'FixedDialog'
        if ($State -and $State.x -ge 0 -and $State.y -ge 0) {
            $form.StartPosition = 'Manual'
            $form.Location = New-Object System.Drawing.Point($State.x, $State.y)
        } else {
            $form.StartPosition = 'CenterScreen'
        }
        
        if ($Text) {
            # $label = New-Object System.Windows.Forms.Label
            # $label.Location = New-Object System.Drawing.Point(10, 10)
            # $label.Size = New-Object System.Drawing.Size(380, 20)
            # $label.Text = $Prompt
            # $form.Controls.Add($label)
            $text = New-Object System.Windows.Forms.TextBox
            $text.Text = $Default
            $text.Location = New-Object System.Drawing.Point(10, 30)
            $text.Size = New-Object System.Drawing.Size(365, 20)
            $form.Controls.Add($text)
        }
    
        if ($OkButton) {
            $ok = New-Object System.Windows.Forms.Button
            $ok.Location = New-Object System.Drawing.Point(225, 60)
            $ok.Size = New-Object System.Drawing.Size(75, 23)
            $ok.Text = $Text1
            $ok.DialogResult = 'OK'
            $form.AcceptButton = $ok
            $form.Controls.Add($ok)
        }
    
        if ($CancelButton) {
            $cancel = New-Object System.Windows.Forms.Button
            $cancel.Location = New-Object System.Drawing.Point(300, 60)
            $cancel.Size = New-Object System.Drawing.Size(75, 23)
            $cancel.Text = $Text2
            $cancel.DialogResult = 'Continue'
            $form.Controls.Add($cancel)
        }
    
        $form.add_Load({
                if ($Text) { $Text.Select() }
                elseif ($OkButton) { $ok.Select() }
                else { $form.Select() }
                $form.Activate()
            })
    
        $result = $form.ShowDialog()
    
        if ($State) {
            $State.x = [Math]::Max(0, $form.Location.X)
            $State.y = [Math]::Max(0, $form.Location.Y)
        }
    
        if ($result -eq 'OK') {
            return $text.Text
        }
    
        if ($result -eq 'Continue') {
            return 'continue'
        }
    
        'quit'

        # ####
        # IF ($PSBoundParameters["Controls"])
        # {
        # 	$form.Controls
        # }
        # IF ($PSBoundParameters["TabIndex"])
        # {
        # 	$form.TabIndex
        # }
        # # [Alias('Title')]
        # IF ($PSBoundParameters["Text"])
        # {
        # 	$form.Text
        # }
    } #PROCESS
}