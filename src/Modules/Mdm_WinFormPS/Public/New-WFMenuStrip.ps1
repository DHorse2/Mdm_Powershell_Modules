
function New-WFMenuStrip {
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        Source: https://theitbros.com/powershell-gui-for-scripts/

    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    
    
    [CmdletBinding()]
    param (
        [System.Windows.Forms.Form]$form
    )
    
    begin {
        # if (-not $form) {
        #     $form = New-WFForm
        # }
        $menuMain = New-Object System.Windows.Forms.MenuStrip
        $mainToolStrip = New-Object System.Windows.Forms.ToolStrip
        $menuFile = New-Object System.Windows.Forms.ToolStripMenuItem
        $menuSave = New-Object System.Windows.Forms.ToolStripMenuItem
        $menuExit = New-Object System.Windows.Forms.ToolStripMenuItem
        $menuHelp = New-Object System.Windows.Forms.ToolStripMenuItem
        $menuAbout = New-Object System.Windows.Forms.ToolStripMenuItem
        $toolStripOpen = New-Object System.Windows.Forms.ToolStripButton
        $toolStripSave = New-Object System.Windows.Forms.ToolStripButton
        $toolStripExit = New-Object System.Windows.Forms.ToolStripButton
        $toolStripAbout = New-Object System.Windows.Forms.ToolStripButton        
    }
    process {
        try {
            # File Menu
            # add a drop-down menu item to the File menu:
            # Menu: File -> Save
            $menuSave.Text = "Save"
            $menuSave.Add_Click({ SaveFile })
            [void]$menuFile.DropDownItems.Add($menuSave)

            # script  stopped when the Exit menu is clicked
            # Menu: File -> Exit
            $menuExit.Text = "Exit"
            $menuExit.Add_Click({ $mainForm.Close() })
            [void]$menuFile.DropDownItems.Add($menuExit)

            # Menu: File -> *
            $menuFile.Text = "File"
            [void]$menuMain.Items.Add($menuFile)

            # Help
            # Menu: Help
            # Menu: Help -> About
            $menuAbout.Text = "About"
            $menuAbout.Add_Click({ ShowAbout })
            [void]$menuHelp.DropDownItems.Add($menuAbout)        

            $menuHelp.Text = "Help"
            [void]$menuMain.Items.Add($menuHelp)
        } catch {
            Add-LogError -IsError -ErrorPSItem $ErrorPSItem "New-WFMenuStrip Failed to create menu strip. $_"
        }
    }
    end {
        try {
            if ($form) {
                $form.MainMenuStrip = [System.Windows.Forms.MenuStrip]$menuMain
                $form.Controls.Add([System.Windows.Forms.ToolStrip]$mainToolStrip)
                $form.Controls.Add([System.Windows.Forms.MenuStrip]$menuMain)
            }
        } catch {
            Add-LogError -IsError -ErrorPSItem $ErrorPSItem "New-WFMenuStrip Failed to add menu strip to form. $_"
        }
        return ( [System.Windows.Forms.MenuStrip]$menuMain, [System.Windows.Forms.ToolStrip]$mainToolStrip )
    }
}

# Functions section
#  menu items (SaveFile, OpenFile, ShowAbout)
function ShowAbout {
    [void] [System.Windows.Forms.MessageBox]::Show( “My PowerShell GUI script with dialog elements and menus v1.0”, “About script”, “OK”, “Information” )
}
# Create the form
# $form = New-Object System.Windows.Forms.Form
# $form.Text = "Save Configuration File"
# $form.Size = New-Object System.Drawing.Size(300,200)
# # Create a button to trigger the save file dialog
# $saveButton = New-Object System.Windows.Forms.Button
# $saveButton.Text = "Save"
# $saveButton.Location = New-Object System.Drawing.Point(10,10)
# $form.Controls.Add($saveButton)
# # Add click event for the save button
# $saveButton.Add_Click({
    

function SaveFile {
    [CmdletBinding()]
    param (
        [Parameter()]
        $data
    )    
    Add-Type -AssemblyName System.Windows.Forms

    # Create a SaveFileDialog
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "JSON Files (*.json)|*.json|All Files (*.*)|*.*"
    $saveFileDialog.Title = "Save an Options File"
    $saveFileDialog.DefaultExt = "json"
    $saveFileDialog.AddExtension = $true
    
    # Show the save file dialog
    if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        # Get the selected file path
        $filePath = $saveFileDialog.FileName
            
        # Example data to save (you can replace this with your actual data)
        if (-not $data) {
            # TODO create default config? Error?
            $data = @{
                Option1 = $true
                Option2 = $false
                Option3 = $true
            }
        }
    
        # Convert the data to JSON
        $json = $data | ConvertTo-Json
            
        # Save the JSON to the selected file
        $json | Set-Content -Path $filePath -Encoding UTF8
            
        # Inform the user
        [System.Windows.Forms.MessageBox]::Show("File saved successfully to $filePath")
    }
}
