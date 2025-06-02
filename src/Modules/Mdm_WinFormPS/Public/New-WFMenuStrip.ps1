
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
        [System.Windows.Forms.Form]$form,
        [System.Windows.Forms.ToolStripMenuItem[]]$formMenuActions,
        [object[]]$formToolStripActions,
        [switch]$SkipFileMenu,
        [switch]$SkipHelpMenu
    )
    begin {
        # User Menu
        # Main Menu and Standard Toolstrip Functions
        $menuMainStrip = New-Object System.Windows.Forms.MenuStrip
        $menuFile = New-Object System.Windows.Forms.ToolStripMenuItem
        $menuDoOpen = New-Object System.Windows.Forms.ToolStripMenuItem
        $menuDoSave = New-Object System.Windows.Forms.ToolStripMenuItem
        $menuDoSaveAs = New-Object System.Windows.Forms.ToolStripMenuItem
        $menuDoExit = New-Object System.Windows.Forms.ToolStripMenuItem
        $menuHelp = New-Object System.Windows.Forms.ToolStripMenuItem
        $menuDoHelp = New-Object System.Windows.Forms.ToolStripMenuItem
        $menuDoAbout = New-Object System.Windows.Forms.ToolStripMenuItem

        $mainToolStrip = New-Object System.Windows.Forms.ToolStrip
        $mainToolStripId = New-Object System.Windows.Forms.ToolStripLabel
        $toolStripOpen = New-Object System.Windows.Forms.ToolStripButton
        $toolStripSave = New-Object System.Windows.Forms.ToolStripButton
        $toolStripSaveAs = New-Object System.Windows.Forms.ToolStripButton
        $toolStripExit = New-Object System.Windows.Forms.ToolStripButton
        $toolStripHelp = New-Object System.Windows.Forms.ToolStripButton        
        $toolStripAbout = New-Object System.Windows.Forms.ToolStripButton 
        
        $statusBarStrip = New-Object System.Windows.Forms.ToolStrip
        $statusBarStripId = New-Object System.Windows.Forms.ToolStripLabel
        $statusBarAutoSaveLabel = New-Object System.Windows.Forms.ToolStripLabel
        $statusBarDataSetLabel = New-Object System.Windows.Forms.ToolStripLabel
        $statusBarDataSetState = New-Object System.Windows.Forms.ToolStripLabel
        $statusBarActionState = New-Object System.Windows.Forms.ToolStripLabel
        $statusBarMessage = New-Object System.Windows.Forms.ToolStripLabel

        # $mainMenuStrip.Tag = "StdMenuStrip"
        $mainToolStrip.Tag = "StdToolStrip"
        $mainToolStrip.Dock = [System.Windows.Forms.DockStyle]::Top
        $mainToolStripId.Name = "StdToolStrip"
        $mainToolStripId.Text = ""
        $statusBarStrip.Tag = "StdStatusBar"
        $statusBarStrip.Dock = [System.Windows.Forms.DockStyle]::Bottom
        $statusBarStripId.Name = "StdStatusBar"
        $statusBarStripId.Text = ""
    }
    process {
        try {
            #region Main Menu
            if (-not $SkipFileMenu) {
                # File Menu
                # Menu: File -> *
                $menuFile.Text = $global:buttonText['FileMenu']
                # TODO Hook up *** open and save to DataSet
                # Menu: File -> Open
                $menuDoOpen.Text = $global:buttonText['Open']
                $menuDoOpen.Add_Click( $global:buttonAction['Open'] )
                $toolStripOpen.Text = $global:buttonText['Open']
                $toolStripOpen.Add_Click( $global:buttonAction['Open'] )
                # Menu: File -> Save
                $menuDoSave.Text = $global:buttonText['Save']
                $menuDoSave.Add_Click( $global:buttonAction['Save'] )
                $toolStripSave.Text = $global:buttonText['Save']
                $toolStripSave.Add_Click( $global:buttonAction['Save'] )
                # Menu: File -> SaveAs
                $menuDoSaveAs.Text = $global:buttonText['SaveAs']
                $menuDoSaveAs.Add_Click( $global:buttonAction['SaveAs'] )
                $toolStripSaveAs.Text = $global:buttonText['SaveAs']
                $toolStripSaveAs.Add_Click( $global:buttonAction['SaveAs'] )
                # Menu: File -> Exit
                $menuDoExit.Text = 'Exit'
                # script  stopped when the Exit menu is clicked
                $menuDoExit.Add_Click( $global:buttonAction['Close'] )
                $toolStripExit.Text = $global:buttonText['Exit']
                $toolStripExit.Add_Click( $global:buttonAction['Close'] )
            }
            if (-not $SkipHelpMenu) {
                # Help
                # Menu: Help
                $menuHelp.Text = $global:buttonText['HelpMenu']
                # Menu: Help -> About
                $menuDoAbout.Text = $global:buttonText['ShowAbout']
                $menuDoAbout.Add_Click( $global:buttonAction['ShowAbout'] )
                $toolStripAbout.Text = "(i)"
                $toolStripAbout.Add_Click( $global:buttonAction['ShowAbout'] )

                $menuDoHelp.Text = $global:buttonText['ShowHelp']
                $menuDoHelp.Add_Click( $global:buttonAction['ShowHelp'] )
                $toolStripHelp.Text = "?"
                $toolStripHelp.Add_Click( $global:buttonAction['ShowHelp'] )
            }
            # Main Menu
            if (-not $SkipFileMenu) {
                [void]$menuFile.DropDownItems.Add($menuDoOpen)
                [void]$menuFile.DropDownItems.Add($menuDoSave)
                [void]$menuFile.DropDownItems.Add($menuDoSaveAs)
                [void]$menuFile.DropDownItems.Add($menuDoExit)
                [void]$menuMainStrip.Items.Add($menuFile)
            }
            # User defined menus
            if ($formMenuActions) {
                foreach ($menuItem in $formMenuActions) {
                    try {
                        [void]$menuMainStrip.Items.Add($menuItem)
                    } catch {
                        Add-LogText -IsError -ErrorPSItem $_ "New-WFMenuStrip Invalid MenuStrip Item: $menuItem."
                    }
                }
            }
            # Support (none), Help and About
            if (-not $SkipHelpMenu) {
                [void]$menuHelp.DropDownItems.Add($menuDoAbout)        
                [void]$menuHelp.DropDownItems.Add($menuDoHelp)        
                [void]$menuMainStrip.Items.Add($menuHelp)
            }
            #endregion
            #region Tool Strip
            if (-not $SkipFileMenu) {
                [void]$mainToolStrip.Items.Add($mainToolStripId)
                [void]$mainToolStrip.Items.Add($toolStripOpen)
                [void]$mainToolStrip.Items.Add($toolStripSave)
                [void]$mainToolStrip.Items.Add($toolStripSaveAs)
            }
            if ($formToolStripActions) {
                # if not first add separator
                # separate menus not added.
                foreach ($control in $formToolStripActions) {
                    try {
                        [void]$mainToolStrip.Items.Add($control)
                    } catch {
                        Add-LogText -IsError -ErrorPSItem $_ "New-WFMenuStrip Invalid ToolStrip Control: $control."
                    }
                }
            }
            if (-not $SkipHelpMenu) {
                [void]$mainToolStrip.Items.Add($toolStripAbout)
                [void]$mainToolStrip.Items.Add($toolStripHelp)
            }
            if (-not $SkipFileMenu) {
                [void]$mainToolStrip.Items.Add($toolStripExit)
            }
            #endregion
            #region Status Bar
            $statusBarAutoSaveLabel.Name = "statusBarAutoSaveLabel"
            $statusBarAutoSaveLabel.Size = New-Object System.Drawing.Size($global:displayButtonSize.Width, $global:displayButtonSize.Height)
            $statusBarDataSetLabel.Name = "statusBarDataSetLabel"
            $statusBarDataSetLabel.Size = New-Object System.Drawing.Size($global:displayButtonSize.Width, $global:displayButtonSize.Height)
            $statusBarDataSetState.Name = "statusBarDataSetState"
            $statusBarDataSetState.Size = New-Object System.Drawing.Size($global:displayButtonSize.Width, $global:displayButtonSize.Height)
            $statusBarActionState.Name = "statusBarActionState"
            $statusBarActionState.Size = New-Object System.Drawing.Size($global:displayButtonSize.Width, $global:displayButtonSize.Height)
            $statusBarMessage.Name = "statusBarMessage"
            $statusBarMessage.Size = New-Object System.Drawing.Size($global:displayButtonSize.Width, $global:displayButtonSize.Height)

            [void]$StatusBarStrip.Items.Add($statusBarStripId)
            [void]$StatusBarStrip.Items.Add($statusBarAutoSaveLabel)
            [void]$StatusBarStrip.Items.Add($statusBarDataSetLabel)
            [void]$StatusBarStrip.Items.Add($statusBarDataSetState)
            [void]$StatusBarStrip.Items.Add($statusBarActionState)
            [void]$StatusBarStrip.Items.Add($statusBarMessage)
            #endregion
        } catch {
            Add-LogText -IsError -ErrorPSItem $_ "New-WFMenuStrip Failed to create menu strip."
        }
    }
    end {
        try {
            if ($form) {
                $form.MainMenuStrip = [System.Windows.Forms.MenuStrip]$menuMainStrip
                $form.Controls.Add([System.Windows.Forms.MenuStrip]$menuMainStrip)
                $form.Controls.Add([System.Windows.Forms.ToolStrip]$mainToolStrip)
                # $form.Controls.Add([System.Windows.Forms.ToolStrip]$statusBarStrip)
            }
        } catch {
            Add-LogText -IsError -ErrorPSItem $_ "New-WFMenuStrip Failed to add menu strip to form. $_"
        }
        # things are valid by now
        $result = [MenuBar]::new()
        $result.MenuBarSet($menuMainStrip, $mainToolStrip, $statusBarStrip)
        # $result.MenuStrip = $menuMainStrip
        # $result.ToolStrip = $mainToolStrip
        # $result.StatusBar = $statusBarStrip
        return [MenuBar]$result
    }
}

#region Functions section
#  menu items (DoFileSave, DoOpenFile, DoShowAbout)
function DoShowAbout {
    param($sender, $e)
    Write-Host "DoShowAbout"
    Update-WFStatusBarStrip -sender $global:window "DoShowAbout" -statusBarLabel 'statusBarActionState'
    # TODO DoShowAbout 
    [void] [System.Windows.Forms.MessageBox]::Show( “PowerShell GUI script with dialog elements and menus v1.0”, “About script”, “OK”, “Information” )
}
function DoOpenFile {
    param($sender, $e, $initialDirectory, $filter)
    Write-Host "DoOpenFile"
    Update-WFStatusBarStrip -sender $global:window -"DoOpenFile" -statusBarLabel 'statusBarActionState'
    if (-not $initialDirectory) { $initialDirectory = $global:fileDialogInitialDirectory }
    if (-not $filter) { $filter = $global:fileDialogFilter }

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = "$($global:appName) Open File"
    $OpenFileDialog.InitialDirectory = $initialDirectory
    $OpenFileDialog.Filter = $filter
    $OpenFileDialog.RestoreDirectory = $true
    
    if ($OpenFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        # Get the path of specified file
        $filePath = $OpenFileDialog.FileName
        # $fileResult = Get-JsonData `
        #     -AddSource `
        #     -Name $dataSet `
        #     -parentObject $dataOut `
        #     -Append `
        #     -jsonItem $filePath
        # Update Buttons and state
        $global:dataSet = "Data"
        $global:dataSetState = "Custom"
        $dataSetLastUpdate = Read-WFDataSet -fileNameFull $filePath -dataSetState $global:dataSetState
    }
}
function DoFileSave {
    param($sender, $e)
    Write-Host "DoFileSave"
    Update-WFStatusBarStrip -sender $global:window -e "DoFileSave" -statusBarLabel 'statusBarActionState'
    if ($global:moduleDataChanged) {
        Write-WFDataSet -sender $sender -e $e -commandSource "Save"
    }
}
function DoFileSaveAs {
    param($sender, $e)
    Write-Host "DoFileSaveAs"
    Update-WFStatusBarStrip -sender $global:window -e "DoFileSaveAs" -statusBarLabel 'statusBarActionState'
    Function Get-FileName {
        param($sender, $e, $initialDirectory, $filter, $fileName, $title)
        Update-WFStatusBarStrip -sender $global:window -e "Get-FileName" -statusBarLabel 'statusBarActionState'
        if (-not $initialDirectory -and -not $fileName) { $initialDirectory = $global:fileDialogInitialDirectory }
        if (-not $filter) { $filter = $global:fileDialogFilter }
        $SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
        if ($title) {
            $SaveFileDialog.Title = $title    
        } else {
            $SaveFileDialog.Title = "$($global:appName) Save File"
        }
        if ($initialDirectory) { $SaveFileDialog.InitialDirectory = $initialDirectory }
        if ($fileName) { $SaveFileDialog.FileName = $fileName }
        $SaveFileDialog.Filter = $filter
        $SaveFileDialog.DefaultExt = "json"
        $SaveFileDialog.AddExtension = $true

        # $SaveFileDialog.ShowDialog() | Out-Null
        if ($SaveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            //Get the path of specified file
            $savefile = $SaveFileDialog.FileName
            Write-WFDataSet -sender $global:window -e $e -fileNameFull $saveFile -commandSource "SaveAs"
            # Update Buttons and state
        }
        $SaveFileDialog.FileName
    }
    # Get-FileName -initialDirectory ".\"
    $initialDirectory
    $fileNameFull = $global:moduleDataArray['source']
    if (-not $fileNameFull) {
        $dataSourceName = "$global:appName"
        if (-not $dataSourceName) { $dataSourceName = "DataSet" }
        if (-not $IgnoreState) {
            if (-not $dataSetState) { $dataSetState = "Current" }
            $dataSourceId = "$($dataSourceName)_$dataSetState"
        } else { $dataSourceId = $dataSourceName }
        $fileName = $dataSourceId
    } else { $fileName = $fileNameFull }
    $savefile = Get-Filename -sender $sender -e $e -fileName $fileName
    # Write-WFDataSet -fileNameFull $saveFile -commandSource "Save"
}
function DoCloseForm { 
    param($sender, $e)
    Write-Host "DoCloseForm"
    Update-WFStatusBarStrip -sender $global:window -e "DoCloseForm" -statusBarLabel 'statusBarActionState'
    $form.Close() 
}
function DoShowHelp { 
    param($sender, $e)
    Write-Host "DoShowHelp"
    Update-WFStatusBarStrip -sender $global:window -e "DoShowHelp" -statusBarLabel 'statusBarActionState'
    # TODO DoShowHelp 
}        
#endregion
