
#region DevEnvGui Functions
# # # WFFormButtonFunctions
$path = "$($(Get-Item $PSScriptRoot).Parent.Parent.FullName)\Mdm_WinFormPS\Private\WFFormButtonFunctions.ps1"
. $path
function DevEnv_DoOk {
    param ($sender, $e)
    $buttonName = "DevEnv_DoOk"
    DoButtonUpdateDisplay -Text "Command $($buttonName)"
    Update-WFStatusBarStrip -sender $sender -e $e -statusBarLabel 'statusBarActionState'
}
function DevEnv_DoCancel {
    param ($sender, $e)
    $buttonName = "DevEnv_DoCancel"
    DoButtonUpdateDisplay -Text "Command $($buttonName)"
    Update-WFStatusBarStrip -sender $sender -e $e -statusBarLabel 'statusBarActionState'
}
function DevEnv_DoApply {
    param ($sender, $e)
    $buttonName = "DevEnv_DoApply"
    DoButtonUpdateDisplay -Text "Command $($buttonName)"
    Update-WFStatusBarStrip -sender $sender -e $e -statusBarLabel 'statusBarActionState'
}
function DevEnv_DoReset {
    param ($sender, $e)
    $buttonName = "DevEnv_DoReset"
    DoButtonUpdateDisplay -Text "Command $($buttonName)"
    Update-WFStatusBarStrip -sender $sender -e $e -statusBarLabel 'statusBarActionState'
}
function DevEnv_SaveAs {
    param ($sender, $e)
    $buttonName = "DevEnv_SaveAs"
    DoButtonUpdateDisplay -Text "Command $($buttonName)"
    Update-WFStatusBarStrip -sender $sender -e $e -statusBarLabel 'statusBarActionState'
}
#endregion
# DevEnv Gui Form
function DevEnvGui {
    <#
.SYNOPSIS
    A short one-line action-based description, e.g. 'Tests if a function is valid'
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
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
        [Parameter()]
        [string]$fileNameFull = "",
        [switch]$ResetSettings,
        [string]$logFilePath = "",
        [string]$logFileName = "",
        [switch]$LogOneFile,
        [string]$companyName = "MacroDM",
        [string]$Title,
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause
    )
    begin {
        # Initialization, Open Log
        try {
            # Project settings and paths
            # Get-ModuleRootPath
            $path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Modules\Project.ps1"
            . "$path"
            # $null = Get-Import "Mdm_WinFormPS" -DoForce
            $assemblyName = "System.Windows.Forms"
            $null = Get-Assembly -assemblyName $assemblyName

            $global:appName = "DevEnv"
            $global:fileDialogInitialDirectory = "$($(get-item $PSScriptRoot).Parent.FullName)\data"

            if (-not $Title) { $Title = "$global:appName - Development Envrionment Install / Update" }
            $global:displayWindow = [DisplayElement]::new(10, 10, 150, 250)
            $global:displayMargins = [MarginClass]::new(10, 10, 10, 10)
            $global:timeStarted = Get-Date
            $global:timeStartedFormatted = "{0:yyyyMMdd_HHmmss}" -f $global:timeStarted
            $global:timeCompleted = $null
            # $tabArray = @($modulesPage, $componentsPage, $categoriesPage, $inspectorPage)
            # $global:buttonBarUsed = @("AutoSave", "ButtonBar", "OkButton", "CancelButton", "ApplyButton", "ResetButton")
            $global:buttonBarUsed = @("AutoSave", "OkButton", "CancelButton", "ApplyButton", "ResetButton")

            $global:buttonBarArray["ButtonBar"] = $false
            $global:buttonBarArray["AutoSave"] = $true
            $global:buttonBarArray["OkButton"] = { DevEnv_DoOk }
            $global:buttonBarArray["CancelButton"] = { DevEnv_DoCancel }
            $global:buttonBarArray["ApplyButton"] = { DevEnv_DoApply }
            $global:buttonBarArray["ResetButton"] = { DevEnv_DoReset }
            # $global:buttonAction['SaveAs'] = { DevEnv_SaveAs }

            $global:DoTimer = $true
            # $global:autoSaveTimerInterval = 60000
            $global:autoSaveTimerInterval = 30000

            # Logging:
            # $global:logFileNameFull = 
            if (-not $logFilePath) { $logFilePath = "$global:projectRootPath\log" }
            if (-not $logFileName) { $logFileName = "$($global:companyNamePrefix)_DevEnvGui_Log" }
            # Sets the global log file name and creates the file
            Open-LogFile -DoOpen -logFilePath $logFilePath -logFileName $logFileName
            $logFileNameFull = $global:logFileNameFull
            Write-Host "Log File: $global:logFileNameFull"
            # Start
            $Message = @(
                " ", `
                    "==================================================================", `
                    "Loading User Interface at $global:timeStartedFormatted", `
                    "==================================================================", `
                    "   Function: $PSCommandPath", `
                    "    Logfile: $global:logFileNameFull", `
                    "Script Root: $PSScriptRoot"
            )
            Add-LogText -Messages $Message `
                -ForegroundColor Green
            # Accessible Form Data Storage
            [hashtable]$global:moduleDataArray = New-Object System.Collections.Hashtable
            $global:moduleDataChanged = $false
        } catch {
            $Message = "DevEnvGui unable to initialize the Window state."
            Add-LogText -Messages $Message -IsCritical -IsError -ErrorPSItem $_
        }
        # Get Data
        try {
            $global:dataSourceName = $global:appName
            $global:dataSet = "Data"
            $global:dataSetState = "Current"
            Read-WFDataSet -SkipStatusUpdate
            if ($false) {
                # Load Configuration: Update, Build, CurrentSave {null}, AutoSave, {UserDefined}
                $dataSetLastUpdate = Read-WFDataSet -dataSetState "Update"
                $dataSet = "GuiConfig"
                $formControlData = Get-WFDataSet -dataArray $dataSet
                # Check if closed normally
                $formState = $formControlData['dataSetState']
                if ($formState -ne "Closed") {
                    # Check if autoSave exists
                    # prompt to load it
                    $dataSetLastUpdate = Read-WFDataSet -dataSetState "AutoSave"
                    # build dialog
                    # Ask for using it. if 'y' overwrite current
                }
            }
        } catch {
            $Message = "DevEnvGui unable to initialize the Window State."
            Add-LogText -Messages $Message -IsCritical -IsError -ErrorPSItem $_
        }
    }
    process {
        # region Create Window, Menu and TabPages
        try {
            #region Create Menus and Tool Strips - Build and Install Menus Items
            # Create a menu strip
            $menuStrip = New-Object System.Windows.Forms.MenuStrip
            # Build Menu
            $menuBuild = New-Object System.Windows.Forms.ToolStripMenuItem
            $menuDoUpdate = New-Object System.Windows.Forms.ToolStripMenuItem
            $menuDoBuild = New-Object System.Windows.Forms.ToolStripMenuItem
            # Install Menu
            $menuInstall = New-Object System.Windows.Forms.ToolStripMenuItem
            $menuDoInstall = New-Object System.Windows.Forms.ToolStripMenuItem
            $menuDoDevEnvOsWin = New-Object System.Windows.Forms.ToolStripMenuItem
            $menuDoDevEnvRepository = New-Object System.Windows.Forms.ToolStripMenuItem
            $menuDoDevEnvIde = New-Object System.Windows.Forms.ToolStripMenuItem
            $menuDoDevEnvWhisper = New-Object System.Windows.Forms.ToolStripMenuItem
            $menuDoDevEnvLlm = New-Object System.Windows.Forms.ToolStripMenuItem
            $menuDoDevEnvInstall = New-Object System.Windows.Forms.ToolStripMenuItem
            $menuDoDevEnvGetVs = New-Object System.Windows.Forms.ToolStripMenuItem

            # Create Tool Strip
            # Build Menu
            $toolStrip = New-Object System.Windows.Forms.ToolStrip
            # $toolStripBuild = New-Object System.Windows.Forms.ToolStrip
            $toolStripDoUpdate = New-Object System.Windows.Forms.ToolStripButton
            $toolStripDoBuild = New-Object System.Windows.Forms.ToolStripButton
            # Install Menu
            # $toolStripInstall = New-Object System.Windows.Forms.ToolStrip
            $toolStripDoInstall = New-Object System.Windows.Forms.ToolStripButton
            $toolStripDoDevEnvOsWin = New-Object System.Windows.Forms.ToolStripButton
            $toolStripDoDevEnvRepository = New-Object System.Windows.Forms.ToolStripButton
            $toolStripDoDevEnvIde = New-Object System.Windows.Forms.ToolStripButton
            $toolStripDoDevEnvWhisper = New-Object System.Windows.Forms.ToolStripButton
            $toolStripDoDevEnvLlm = New-Object System.Windows.Forms.ToolStripButton
            $toolStripDoDevEnvInstall = New-Object System.Windows.Forms.ToolStripButton
            $toolStripDoDevEnvGetVs = New-Object System.Windows.Forms.ToolStripButton
            #endregion
            # TODO Fix buttons ***
            #region Menu Controls Text and Action (Click Event)
            # Build Menu
            # Menu: Build -> *
            $menuBuild.Text = "Build"
            # Menu: Build -> Build
            $menuDoBuild.Text = "Build"
            $menuDoBuild.Add_Click({ DoButtonAction -ScriptBlock { Build } })
            $toolStripDoBuild.Text = "Build"
            $toolStripDoBuild.Add_Click({ DoButtonAction -ScriptBlock { Build } })
            # Menu: Build -> Update
            $menuDoUpdate.Text = "Update"
            $menuDoUpdate.Add_Click({ DoButtonAction -ScriptBlock { Update } })
            $toolStripDoUpdate.Text = "Update"
            $toolStripDoUpdate.Add_Click({ DoButtonAction -ScriptBlock { Update } })
            # Install Menu
            # Menu: Install -> *
            $menuInstall.Text = "Install"
            # Menu: Install -> Install
            $menuDoInstall.Text = "Install Dev Environment"
            $menuDoInstall.Add_Click({ DoButtonAction -ScriptBlock { Install-DevEnv } })
            $toolStripDoInstall.Text = "Install"
            $toolStripDoInstall.Add_Click({ DoButtonAction -ScriptBlock { Install-DevEnvWin } })
            # Menu: Install -> Repository
            $menuDoDevEnvRepository.Text = "Repositiory for Installs"
            $menuDoDevEnvRepository.Add_Click({ DoButtonAction -ScriptBlock { Install-DevEnvRepository } })
            $toolStripDoDevEnvRepository.Text = "Repositiory"
            $toolStripDoDevEnvRepository.Add_Click({ DoButtonAction -ScriptBlock { Install-DevEnvRepository } })
            # Menu: Install -> IDE
            $menuDoDevEnvIde.Text = "IDE tools and support"
            $menuDoDevEnvIde.Add_Click({ DoButtonAction -ScriptBlock { Install-DevEnvIdeWin } })
            $toolStripDoDevEnvIde.Text = "IDE"
            $toolStripDoDevEnvIde.Add_Click({ DoButtonAction -ScriptBlock { Install-DevEnvIdeWin } })
            # Menu: Install -> Voice (Recognition)
            $menuDoDevEnvWhisper.Text = "Whisper Voice LLM"
            $menuDoDevEnvWhisper.Add_Click({ DoButtonAction -ScriptBlock { Install-DevEnvWhisperWin } })
            $toolStripDoDevEnvWhisper.Text = "Voice"
            $toolStripDoDevEnvWhisper.Add_Click({ DoButtonAction -ScriptBlock { Install-DevEnvWhisperWin } })
            # Menu: Install -> LLM
            $menuDoDevEnvLlm.Text = "LLM platform"
            $menuDoDevEnvLlm.Add_Click({ DoButtonAction -ScriptBlock { Install-DevEnvLlmWin } })
            $toolStripDoDevEnvLlm.Text = "LLM"
            $toolStripDoDevEnvLlm.Add_Click({ DoButtonAction -ScriptBlock { Install-DevEnvLlmWin } })
            # Menu: Install -> Install
            $menuDoDevEnvGetVs.Text = "Versions"
            $menuDoDevEnvGetVs.Add_Click({ DoButtonAction -ScriptBlock { Get-DevEnvVersions } })
            $toolStripDoDevEnvGetVs.Text = "Vs"
            $toolStripDoDevEnvGetVs.Add_Click({ DoButtonAction -ScriptBlock { Get-DevEnvVersions } })
            #endregion
            #region Add to Menu DropDownItems and Items - Build and Install
            # Build Menu
            [void]$menuBuild.DropDownItems.Add($menuDoUpdate)
            [void]$menuBuild.DropDownItems.Add($menuDoBuild)
            # Install Menu
            [void]$menuInstall.DropDownItems.Add($menuDoInstall)
            [void]$menuInstall.DropDownItems.Add($menuDoDevEnvOsWin)
            [void]$menuInstall.DropDownItems.Add($menuDoDevEnvRepository)
            [void]$menuInstall.DropDownItems.Add($menuDoDevEnvIde)
            [void]$menuInstall.DropDownItems.Add($menuDoDevEnvWhisper)
            [void]$menuInstall.DropDownItems.Add($menuDoDevEnvLlm)
            # Add the menus to the menu strip
            [void]$menuStrip.Items.Add($menuBuild)
            [void]$menuStrip.Items.Add($menuInstall)
            #endregion
            #region Create Form Menu Actions Array and ToolStrip Actions
            $formMenuActions = @( $menuBuild, $menuInstall )
            # Tool Strip
            # [object[]]$formToolStripActions = @()
            $formToolStripActions = @()
            # Build
            $formToolStripActions += $toolStripDoUpdate
            $formToolStripActions += $toolStripDoBuild
            # Install Tool Strip
            $separator = New-Object System.Windows.Forms.ToolStripSeparator

            $formToolStripActions += $separator
            $formToolStripActions += $toolStripDoUpdate
            $formToolStripActions += $toolStripDoBuild
            $formToolStripActions += $separator
            $formToolStripActions += $toolStripDoDevEnvGetVs
            $formToolStripActions += $toolStripDoInstall
            $formToolStripActions += $separator
            $formToolStripActions += $toolStripDoDevEnvOsWin
            $formToolStripActions += $toolStripDoDevEnvRepository
            $formToolStripActions += $toolStripDoDevEnvIde
            $formToolStripActions += $toolStripDoDevEnvWhisper
            $formToolStripActions += $toolStripDoDevEnvLlm
            $formToolStripActions += $separator
            #endregion
        } catch {
            $Message = "DevEnvGui unable to create Window Controls and Form objects."
            Add-LogText -Messages $Message -IsCritical -IsError -ErrorPSItem $_
        }
        try {
            # Create Window
            $window = New-WFWindow `
                -Name $global:appName `
                -Title $Title `
                -formMenuActions $formMenuActions `
                -formToolStripActions $formToolStripActions

            $global:window = $window
            $resultDefault = [CommandResult]::new()
            $window.state.CommandResult = $resultDefault
            $window.state.CommandResult.CommandName = "Initialization"
            $window.state.data = $formControlData
            #region Create Tabs
            $tabControls = New-Object System.Windows.Forms.TabControl
            $tabControls.Dock = [System.Windows.Forms.DockStyle]::None
            # Create the Modules Selection Tab
            $modulesName = "Modules"
            $modulesPage = New-Object System.Windows.Forms.TabPage
            $modulesPage.Text = $modulesName
            # Create the Components Tab
            $ComponentsName = "Components"
            $componentsPage = New-Object System.Windows.Forms.TabPage
            $componentsPage.Text = $ComponentsName
            # Create the Categories Tab
            $CategoriesName = "Categories"
            $CategoriesPage = New-Object System.Windows.Forms.TabPage
            $CategoriesPage.Text = $CategoriesName
            # Data Inspection
            $InspectorName = "DataSet"
            $InspectorPage = New-Object System.Windows.Forms.TabPage
            $InspectorPage.Text = $InspectorName
            # Action Output
            $ActionOutputName = "Output"
            $actionOuputPage = New-Object System.Windows.Forms.TabPage
            $actionOuputPage.Text = $ActionOutputName
            #endregion
        } catch {
            $Message = "DevEnvGui unable to create Window, Menu and Form objects."
            Add-LogText -Messages $Message -IsCritical -IsError -ErrorPSItem $_
        }
        # region Group Boxes: 1 - Modules
        try {
            # Load and build components
            $dataSet = "Modules"
            $moduleData = Get-WFDataSet -dataSet $dataSet
            # $moduleData = Get-JsonData -Name $dataSet -UpdateGlobal -AddSource `
            #     -jsonItem ".\DevEnvModules.json"
            $modulesGroupBox = New-Object System.Windows.Forms.GroupBox
            $modulesGroupBox = Build-WFCheckBoxList `
                -Name $dataSet `
                -groupBox $modulesGroupBox `
                -form $window.Forms[0] `
                -jsonData $moduleData `
                -groupBoxLabel "Select active modules:"
            $modulesPage.Controls.Add($modulesGroupBox)

            # region Tab Page 2 - Components
            # Load and build components
            $dataSet = "Components"
            $componentData = Get-WFDataSet -dataSet $dataSet
            $componentsGroupBox = New-Object System.Windows.Forms.GroupBox
            $componentsGroupBox = Build-WFCheckBoxList `
                -Name $dataSet `
                -groupBox $componentsGroupBox `
                -form $window.Forms[0] `
                -jsonData $componentData `
                -groupBoxLabel "Select active components:"
            $componentsPage.Controls.Add($componentsGroupBox)

            # region Tab Page 3 - Categories
            # Load and build Categories
            $dataSet = "Categories"
            $categoryData = Get-WFDataSet -dataSet $dataSet
            $categoryGroupBox = New-Object System.Windows.Forms.GroupBox
            $categoryGroupBox = Build-WFCheckBoxList `
                -Name $dataSet `
                -groupBox $categoryGroupBox `
                -form $window.Forms[0] `
                -jsonData $categoryData `
                -groupBoxLabel "Select active categories:"
            $categoriesPage.Controls.Add($categoryGroupBox)

            # region Tap Page 4 - Json DataSet Inspector
            $dataSet = "Inspector"
            # Create a Panel to hold the TreeView
            $inspectorPanel = New-Object System.Windows.Forms.Panel
            $inspectorPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
            $inspectorPanel.BackColor = [System.Drawing.Color]::White
            $inspectorPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
            $null = Get-WFDataSetTreeView `
                -dataArray $global:moduleDataArray `
                -DoAll -control $inspectorPanel
            $inspectorPage.Controls.Add($inspectorPanel)

            # Output display Panel
            $dataSet = "Output"
            # Create a Panel to hold the TreeView
            $ActionOutputPanel = New-Object System.Windows.Forms.Panel
            $ActionOutputPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
            $ActionOutputPanel.BackColor = [System.Drawing.Color]::White
            $ActionOutputPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle

            $global:ActionOutputTextBox = New-Object System.Windows.Forms.TextBox
            $global:ActionOutputTextBox.Text = ""
            $global:ActionOutputTextBox.Multiline = $true
            $global:ActionOutputTextBox.Dock = [System.Windows.Forms.DockStyle]::Fill
            $ActionOutputPanel.Controls.Add($global:ActionOutputTextBox)
            $actionOuputPage.Controls.Add($ActionOutputPanel)
        } catch {
            $Message = "DevEnvGui unable to load and create Tab Page objects."
            Add-LogText -Messages $Message -IsCritical -IsError -ErrorPSItem $_
        }
        # region Add TabPages, Layout Form, adjust Controls and Page Size
        try {
            $tabControls.TabPages.Add($modulesPage)
            $tabControls.TabPages.Add($componentsPage)
            $tabControls.TabPages.Add($categoriesPage)
            $tabControls.TabPages.Add($inspectorPage)
            $tabControls.TabPages.Add($actionOuputPage)

            # Build the form. Target is for groupBox
            # Note. 
            $null = Build-WFFormControls `
                -Target "Window" `
                -window $window `
                -formIndex 0 `
                -DoAll `
                -DoMenuBars `
                -Buttons $global:buttonBarUsed `
                -formMenuActions $formMenuActions `
                -formToolStripActions $formToolStripActions `
                -margins $margins

            # not used, excluded
            # -DoMenuBars `
            # -Title "Development Environment Install / Update" `
            # -form $form `
            # -tabPage $modulesPage ` NOTE: Not implemented
            # -tabIndex 0 `
            # -jsonData $modules `
            # -groupBox $null `
            # -groupBoxLabel "" `
            # -$DoControls ($DoAll)
            # -$DoEvents ($DoAll)

            # Finish Form
            $dataSet = "Data"
            $window.FormIndex = 0
            # Adjust Size for TabPages
            $tabArray = @($modulesPage, $componentsPage, $categoriesPage)

            $widthMaxForm = $window.Forms[$window.FormIndex].PreferredSize.Width
            $widthMaxTabs = $tabControls.PreferredSize.Width
            $widthMax = $modulesPage.PreferredSize.Width
            $widthMax = [Math]::Max($componentsPage.PreferredSize.Width, $widthMax)
            $widthMax = [Math]::Max($categoriesPage.PreferredSize.Width, $widthMax)
            $widthMax += 20 # padding
            $widthMaxForm = [Math]::Max($widthMax, $widthMaxForm)
            $widthMaxForm += 20 # padding
            # $widthMaxForm = [Math]::Min($global:displaySizeMax.Width, $widthMaxForm)

            $heightMaxForm = $window.Forms[$window.FormIndex].PreferredSize.Height
            $heightMaxTab = $tabControls.PreferredSize.Height
            $heightMax = $modulesPage.PreferredSize.Height
            $heightMax = [Math]::Max($componentsPage.PreferredSize.Height, $heightMax)
            $heightMax = [Math]::Max($categoriesPage.PreferredSize.Height, $heightMax)
            $heightMax += 20 # + padding
            $heightMaxForm = [Math]::Max($heightMax, $heightMaxForm)
            $heightMaxForm += $global:displayButtonSize.Height
            $heightMaxForm += $global:displayMargins.Bottom
            $heightMaxForm += 150 # extra room for buttons.
            # $heightMaxForm = [Math]::Min($global:displaySizeMax.Height, $heightMaxForm)

            # # Add the TabControl to the form
            # # $modulePage.Size = New-Object System.Drawing.Size($widthMax, $heightMax)
            # # $componentsPage.Size = New-Object System.Drawing.Size($widthMax, $heightMax)
            # # $categoriesPage.Size = New-Object System.Drawing.Size($widthMax, $heightMax)
            # $tabControls.TabPages.Add($modulesPage)
            # $tabControls.TabPages.Add($componentsPage)
            # $tabControls.TabPages.Add($categoriesPage)
            # $tabControls.Size = New-Object System.Drawing.Size($widthMax, $heightMax)

            # Tab Controls
            $window.Forms[$window.FormIndex].Controls.Add($tabControls)
            $tabControls.Size = New-Object System.Drawing.Size($widthMax, $heightMax)
            $tabControls.Location = New-Object System.Drawing.Point($global:displayMargins.Left, 50)
            $global:tabControls = $tabControls

            # Status Bar
            $window.MenuBar[$window.FormIndex].StatusBar.Dock = [System.Windows.Forms.DockStyle]::Bottom
            $window.Forms[$window.FormIndex].Controls.Add($window.MenuBar[$window.FormIndex].StatusBar)
            Update-WFStatusBarStrip -sender $window -e "Open" -statusBarLabel 'statusBarDataSetLabel' -text $dataSet
            Update-WFStatusBarStrip -sender $window -e "Open" -statusBarLabel 'statusBarDataSetState' -text $dataSetState
            $textOut = "AutoSaved at " + (Get-Date).ToString("HH:mm:ss")
            Update-WFStatusBarStrip -sender $window -e "Open" -statusBarLabel 'statusBarAutoSaveLabel' -text $textOut

            $window.Forms[$window.FormIndex].MinimumSize = New-Object System.Drawing.Size($widthMaxForm, $heightMaxForm)
            $window.Forms[$window.FormIndex].AutoSize = $true
            $window.Forms[$window.FormIndex].AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
            $global:ActionOutputTextBox.Text = "Hello`n"
        } catch {
            $Message = "DevEnvGui unable to Build the Window."
            Add-LogText -Messages $Message -IsCritical -IsError -ErrorPSItem $_
        }
        # Show the form as a modal dialog
        try {
            $dialogResult = Show-WFForm([System.Windows.Forms.Form]($window.Forms[$window.FormIndex]))
            # $dialogResult = $window.Forms[0].ShowDialog()

            # Optionally, you can check the dialog result if needed
            if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
                # Handle OK result
                # Update data
            } elseif ($dialogResult -eq [System.Windows.Forms.DialogResult]::Cancel) {
                # Handle Cancel result
            }        
        } catch {
            $Message = "DevEnvGui unable to Show or process Window Result."
            Add-LogText -Messages $Message -IsCritical -IsError -ErrorPSItem $_
        }
    }
    end { }
}
