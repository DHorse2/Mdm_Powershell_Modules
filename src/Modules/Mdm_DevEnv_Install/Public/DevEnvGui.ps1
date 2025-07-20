
#region DevEnvGui Functions
# # # WFFormButtonFunctions
$path = "$($(Get-Item $PSScriptRoot).Parent.Parent.FullName)\Mdm_WinFormPS\Private\WFFormButtonFunctions.ps1"
. $path @global:combinedParams
function DevEnv_DoOk {
    param ($sender, $e)
    $buttonName = "DevEnv_DoOk"
    Update-WFTextBox -textBox $global:ActionOutputTextBox -text "Command $($buttonName)" -logFileNameFull $logFileNameFull
    Update-WFStatusBarStrip -sender $sender -e $e -statusBarLabel 'statusBarActionState' -logFileNameFull $logFileNameFull
}
function DevEnv_DoCancel {
    param ($sender, $e)
    $buttonName = "DevEnv_DoCancel"
    Update-WFTextBox -textBox $global:ActionOutputTextBox -text "Command $($buttonName)" -logFileNameFull $logFileNameFull
    Update-WFStatusBarStrip -sender $sender -e $e -statusBarLabel 'statusBarActionState' -logFileNameFull $logFileNameFull
}
function DevEnv_DoApply {
    param ($sender, $e)
    $buttonName = "DevEnv_DoApply"
    Update-WFTextBox -textBox $global:ActionOutputTextBox -text "Command $($buttonName)" -logFileNameFull $logFileNameFull
    Update-WFStatusBarStrip -sender $sender -e $e -statusBarLabel 'statusBarActionState' -logFileNameFull $logFileNameFull
}
function DevEnv_DoReset {
    param ($sender, $e)
    $buttonName = "DevEnv_DoReset"
    Update-WFTextBox -textBox $global:ActionOutputTextBox -text "Command $($buttonName)" -logFileNameFull $logFileNameFull
    Update-WFStatusBarStrip -sender $sender -e $e -statusBarLabel 'statusBarActionState' -logFileNameFull $logFileNameFull
}
function DevEnv_SaveAs {
    param ($sender, $e)
    $buttonName = "DevEnv_SaveAs"
    Update-WFTextBox -textBox $global:ActionOutputTextBox -text "Command $($buttonName)" -logFileNameFull $logFileNameFull
    Update-WFStatusBarStrip -sender $sender -e $e -statusBarLabel 'statusBarActionState' -logFileNameFull $logFileNameFull
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
        [string]$companyName = "",
        [string]$title,
        [string]$fileNameFull = "",
        [switch]$ResetSettings,

        [string]$logFilePath = "",
        [string]$logFileName = "",
        [switch]$LogOneFile,
        [switch]$DoCheckState,

        [string]$appName = "",
        [int]$actionStep = 0,
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [string]$logFileNameFull = ""
    )
    begin {
        $global:GuiActive = $true
        # Initialization
        try {
            $functionParams = $PSBoundParameters
            Write-Host "====== Start ======" -ForegroundColor Green
            Write-Host "===================" -ForegroundColor Green
            if (-not $appName) {
                $appName = "DevEnv"
                $functionParams['appName'] = $appName
            }
            if (-not $actionStep) { $actionStep = $global:actionStep }
            if (-not $logFileNameFull) {
                if (-not $logFileNameFull -and $global:app) { $logFileNameFull = $global:app.logFileNames[$appName] }
                if (-not $logFileNameFull) { $logFileNameFull = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Std_Library\log\DevEnv_Log.txt" }
                $functionParams['logFileNameFull'] = $logFileNameFull
            }
            # Project Parameters
            $inArgs = $args
            # Get-Parameters
            $path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Std_Library\lib\Get-ParametersLib.ps1"
            . $path @functionParams
            $DevEnvParams = $global:combinedParams
            
            # Project settings and paths
            # ProjectLib Get-ModuleRootPath
            $path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Std_Library\lib\ProjectLib.ps1"
            . $path @DevEnvParams
            # $null = Get-Import "Mdm_WinFormPS" -DoForce
            $assemblyName = "System.Windows.Forms"
            $null = Get-Assembly -assemblyName $assemblyName

            $appDirectory = "$($(get-item $PSScriptRoot).Parent.FullName)"
            if (-not $title) { $title = "$appName - Development Envrionment Install / Update" }
            $fileDialogInitialDirectory = "$appDirectory\data"

            Initialize-StdGlobals `
                -InitForce -InitStd -InitLogFile -InitGui `
                -appName $appName -appDirectory $appDirectory -Title $title `
                -logFileNameFull $logFileNameFull `
                -DoOpen -DoCheckState -DoSetGlobal
            # -logFilePath "$appDirectory\log"
            $app = $global:appResult
            $logFileNameFull = $global:logFileNameFullResult

            $DoTimer = $true; $global:DoTimer = $DoTimer
            $global:autoSaveTimerInterval = 30000 # 30 seconds

            # Initialize-StdGui -InitForce
            # handled in Open Log file
            # $timeStarted = Get-Date; $global:app.timeStarted = $timeStarted
            # $timeStartedFormatted = "{0:yyyyMMdd_HHmmss}" -f $global:app.timeStarted
            # $global:app.timeStartedFormatted = $timeStartedFormatted
            # $timeCompleted = [System.DateTime]::MinValue; $global:app.timeCompleted = [System.DateTime]::MinValue
            # Logging: # Moved to Initialize-StdGlobals
            # $logFileNameFull = Use defaults:
            # if (-not $logFilePath) { $logFilePath = "$global:projectRootPath\log" }
            # if (-not $logFilePath) { $logFilePath = "$($(get-item $PSScriptRoot).Parent.FullName)\log" }
            # if (-not $logFileName) { $logFileName = "$($global:companyNamePrefix)_$($appName)_Log" }
            # Sets the global log file name and creates the file
            # TODO Hold Powershell bug. [1] Duplicate object upon return
            # $null = Open-LogFile -DoOpen -DoSetGlobal -logFilePath $logFilePath -logFileName $logFileName
            # $null = Open-LogFile -logFilePath $fileDialogInitialDirectory -DoOpen -DoSetGlobal
            # $logFileNameFull = $global:logFileNameFullResult
            # if ($logFileNameFull[1]) { $logFileNameFull = $logFileNameFull[1]}
            # $tabArray = @($modulesPage, $componentsPage, $categoriesPage, $inspectorPage, $TreeViewPage, $OutputPage)

            # Start
            $Message = @(
                " ", `
                    "==================================================================", `
                    "Loading User Interface at $global:app.timeStartedFormatted", `
                    "==================================================================", `
                    "   Function: $PSCommandPath", `
                    "    Logfile: $logFileNameFull", `
                    "Script Root: $PSScriptRoot"
            )
            Add-LogText -Message $Message `
                -ForegroundColor Green -logFileNameFull $logFileNameFull

                # $global:buttonBarUsed = @("AutoSave", "ButtonBar", "OkButton", "CancelButton", "ApplyButton", "ResetButton")
            $global:buttonBarUsed = @("AutoSave", "OkButton", "CancelButton", "ApplyButton", "ResetButton")

            # Application functionality
            $global:buttonBarArray["ButtonBar"] = $false
            $global:buttonBarArray["AutoSave"] = $true
            # There is the Current selection (changes)
            # The Last Update and data
            # User Defined sets. If saved they become Current.
            # Incidentally there is Autosaved data.
            # Form opening checks 'closed correctly' and may offer the autosave.
            $global:buttonBarArray["OkButton"] = { DevEnv_DoOk }
            $global:buttonBarArray["CancelButton"] = { DevEnv_DoCancel }
            $global:buttonBarArray["ApplyButton"] = { DevEnv_DoApply }
            # Reset offers the above options.
            $global:buttonBarArray["ResetButton"] = { DevEnv_DoReset }
            # $global:buttonAction['SaveAs'] = { DevEnv_SaveAs }

            # Accessible Form Data Storage
            [hashtable]$global:appDataArray = New-Object System.Collections.Hashtable
            $global:appDataChanged = $false

            # Styling
            $global:displayWindow = [DisplayElement]::new(10, 10, 150, 250)
            $global:displayMargins = [MarginClass]::new(10, 10, 10, 10)
        } catch {
            $Message = "DevEnvGui unable to initialize the Global State of the Window."
            Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
        }
        # Get Data
        try {
            $global:dataSourceName = $global:appName
            $global:dataSet = "Data"
            $global:dataSetState = "Current"
            $global:dataSetDirectory = "$appDirectory\data"
            $global:fileDialogInitialDirectory = $global:dataSetDirectory
            Read-WFDataSet -SkipStatusUpdate -logFileNameFull $logFileNameFull
            if ($false) {
                # Load Configuration: Update, Build, CurrentSave {null}, AutoSave, {UserDefined}
                $dataSetLastUpdate = Read-WFDataSet -dataSetState "Update" -logFileNameFull $logFileNameFull
                $global:dataSet = "GuiConfig"
                $formControlData = Get-WFDataSet -dataArray $global:dataSet
                # Check if closed normally
                $formState = $formControlData['dataSetState']
                if ($formState -ne "Closed") {
                    # Check if autoSave exists
                    # prompt to load it
                    $dataSetLastUpdate = Read-WFDataSet -dataSetState "AutoSave" -logFileNameFull $logFileNameFull
                    # build dialog
                    # Ask for using it. if 'y' overwrite current
                }
            }
        } catch {
            $Message = "DevEnvGui unable to initialize the Window State."
            Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
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
            $menuBuild.Text = "Build_Mdm"
            # Menu: Build -> Build
            $menuDoBuild.Name = "Build_Mdm"
            $menuDoBuild.Text = "Build"
            $menuDoBuild.Add_Click({ DoButtonAction -ScriptBlock { Build_Mdm } -e "Build_Mdm" })
            $toolStripDoBuild.Name = "Build_Mdm"
            $toolStripDoBuild.Text = "Build"
            $toolStripDoBuild.Add_Click({ DoButtonAction -ScriptBlock { Build_Mdm } -e "Build_Mdm" })
            # Menu: Build -> Update_Mdm
            $menuDoUpdate.Name = "Update_Mdm"
            $menuDoUpdate.Text = "Update"
            $menuDoUpdate.Add_Click({ DoButtonAction -ScriptBlock { Update_Mdm } -e "Update_Mdm" })
            $toolStripDoUpdate.Name = "Update_Mdm"
            $toolStripDoUpdate.Text = "Update"
            $toolStripDoUpdate.Add_Click({ DoButtonAction -ScriptBlock { Update_Mdm } -e "Update_Mdm" })
            # Install Menu
            # Menu: Install -> *
            $menuInstall.Text = "Install"
            # Menu: Install -> Install
            $menuDoInstall.Name = "Install-DevEnv"
            $menuDoInstall.Text = "Install Dev Environment"
            $menuDoInstall.Add_Click({ DoButtonAction -ScriptBlock { Install-DevEnv } -e "Install-DevEnv" })
            $toolStripDoInstall.Name = "Install"
            $toolStripDoInstall.Text = "Install"
            $toolStripDoInstall.Add_Click({ DoButtonAction -ScriptBlock { Install-DevEnvWin } -e "Install-DevEnv" })
            # Menu: Install -> Repository
            $menuDoDevEnvRepository.Name = "Install-DevEnvRepository"
            $menuDoDevEnvRepository.Text = "Repositiory for Installs"
            $menuDoDevEnvRepository.Add_Click({ DoButtonAction -ScriptBlock { Install-DevEnvRepository } -e "Install-DevEnvRepository" })
            $toolStripDoDevEnvRepository.Name = "Install-DevEnvRepository"
            $toolStripDoDevEnvRepository.Text = "Repositiory"
            $toolStripDoDevEnvRepository.Add_Click({ DoButtonAction -ScriptBlock { Install-DevEnvRepository } -e "Install-DevEnvRepository" })
            # Menu: Install -> IDE
            $menuDoDevEnvIde.Name = "Install-DevEnvIdeWin"
            $menuDoDevEnvIde.Text = "IDE tools and support"
            $menuDoDevEnvIde.Add_Click({ DoButtonAction -ScriptBlock { Install-DevEnvIdeWin } -e "Install-DevEnvIdeWin" })
            $toolStripDoDevEnvIde.Text = "IDE"
            $toolStripDoDevEnvIde.Add_Click({ DoButtonAction -ScriptBlock { Install-DevEnvIdeWin } -e "Install-DevEnvIdeWin" })
            # Menu: Install -> Voice (Recognition)
            $menuDoDevEnvWhisper.Name = "Install-DevEnvWhisperWin"
            $menuDoDevEnvWhisper.Text = "Whisper Voice LLM"
            $menuDoDevEnvWhisper.Add_Click({ DoButtonAction -ScriptBlock { Install-DevEnvWhisperWin } -e "Install-DevEnvWhisperWin" })
            $toolStripDoDevEnvWhisper.Text = "Voice"
            $toolStripDoDevEnvWhisper.Add_Click({ DoButtonAction -ScriptBlock { Install-DevEnvWhisperWin } -e "Install-DevEnvWhisperWin" })
            # Menu: Install -> LLM
            $menuDoDevEnvLlm.Name = "Install-DevEnvLlmWin"
            $menuDoDevEnvLlm.Text = "LLM platform"
            $menuDoDevEnvLlm.Add_Click({ DoButtonAction -ScriptBlock { Install-DevEnvLlmWin } -e "Install-DevEnvLlmWin" })
            $toolStripDoDevEnvLlm.Text = "LLM"
            $toolStripDoDevEnvLlm.Add_Click({ DoButtonAction -ScriptBlock { Install-DevEnvLlmWin } -e "Install-DevEnvLlmWin" })
            # Menu: Install -> Install
            $menuDoDevEnvGetVs.Name = "Get-DevEnvVersions"
            $menuDoDevEnvGetVs.Text = "Versions"
            $menuDoDevEnvGetVs.Add_Click({ DoButtonAction -ScriptBlock { Get-DevEnvVersions } -e "Get-DevEnvVersions" })
            $toolStripDoDevEnvGetVs.Text = "Vs"
            $toolStripDoDevEnvGetVs.Add_Click({ DoButtonAction -ScriptBlock { Get-DevEnvVersions } -e "Get-DevEnvVersions" })
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
            Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
        }
        try {
            # Create Window
            $window = New-WFWindow `
                -Name $appName `
                -Title $title `
                -formMenuActions $formMenuActions `
                -formToolStripActions $formToolStripActions `
                -logFileNameFull $logFileNameFull

            $global:window = $window
            $resultDefault = [CommandAction]::new()
            $window.state.command = $resultDefault
            $window.state.command.CommandName = "Initialization"
            $window.state.scriptState = $formControlData
            #region Create Tabs
            $tabControls = New-Object System.Windows.Forms.TabControl
            $tabControls.Name = "TabControls"
            # $tabControls.Dock = [System.Windows.Forms.DockStyle]::None
            # $tabControls.Margin = $global:displayMargins.Margin
            # $tabControls.Padding = $global:displayMargins.Padding
            # Create the Modules Selection Tab
            $modulesName = "Modules"
            $modulesPage = New-Object System.Windows.Forms.TabPage
            $modulesPage.Name = $modulesName
            $modulesPage.Text = $modulesName
            $modulesPage.Dock = [System.Windows.Forms.DockStyle]::Fill
            $modulesPage.BorderStyle = $global:borderStyle
            # Create the Components Tab
            $ComponentsName = "Components"
            $componentsPage = New-Object System.Windows.Forms.TabPage
            $componentsPage.Name = $ComponentsName
            $componentsPage.Text = $ComponentsName
            $componentsPage.Dock = [System.Windows.Forms.DockStyle]::Fill
            $componentsPage.BorderStyle = $global:borderStyle
            # Create the Categories Tab
            $CategoriesName = "Categories"
            $CategoriesPage = New-Object System.Windows.Forms.TabPage
            $CategoriesPage.Name = $CategoriesName
            $CategoriesPage.Text = $CategoriesName
            $CategoriesPage.Dock = [System.Windows.Forms.DockStyle]::Fill
            $CategoriesPage.BorderStyle = $global:borderStyle
            # Data Inspection
            $InspectorName = "DataSet"
            $InspectorPage = New-Object System.Windows.Forms.TabPage
            $InspectorPage.Name = $InspectorName
            $InspectorPage.Text = $InspectorName
            $InspectorPage.BorderStyle = $global:borderStyle
            # Action Output
            $ActionOutputName = "Output"
            $actionOuputPage = New-Object System.Windows.Forms.TabPage
            $actionOuputPage.Name = $ActionOutputName
            $actionOuputPage.Text = $ActionOutputName
            $actionOuputPage.BorderStyle = $global:borderStyle
            #endregion
        } catch {
            $Message = "DevEnvGui unable to create Window, Menu and Form objects."
            Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
            return
        }
        # region Group Boxes: 1 - Modules
        try {
            # Load and build components
            $global:dataSet = "Modules"
            $moduleData = Get-WFDataSet -dataSet $global:dataSet -logFileNameFull $logFileNameFull
            $groupBoxHeightMax = $global:displaySizeMax.Height - 300 # Top menu + buttons
            # $moduleData = $global:jsonDataResult = Get-JsonData -Name $global:dataSet -UpdateGlobal -AddSource `
            #     -jsonItem ".\DevEnvModules.json" -logFileNameFull $logFileNameFull
            $modulesGroupBox = New-Object System.Windows.Forms.GroupBox
            $modulesGroupBox = Update-WFCheckBoxList `
                -Name $global:dataSet `
                -groupBox $modulesGroupBox `
                -form $window.Forms[0] `
                -jsonData $moduleData `
                -groupBoxHeightMax $groupBoxHeightMax `
                -logFileNameFull $logFileNameFull
            # -groupBoxLabel "Select active modules:" `
            # $modulesGroupBox.Margin = $global:displayMargins.Margin
            # $modulesGroupBox.Padding = $global:displayMargins.Padding
            # $modulesPage.Margin = $global:displayMargins.Margin
            # $modulesPage.Padding = $global:displayMargins.Padding
            $modulesPage.Controls.Add($modulesGroupBox)

            # region Tab Page 2 - Components
            # Load and build components
            $global:dataSet = "Components"
            $componentData = Get-WFDataSet -dataSet $global:dataSet
            $componentsGroupBox = New-Object System.Windows.Forms.GroupBox
            $componentsGroupBox = Update-WFCheckBoxList `
                -Name $global:dataSet `
                -groupBox $componentsGroupBox `
                -form $window.Forms[0] `
                -jsonData $componentData `
                -groupBoxHeightMax $groupBoxHeightMax `
                -logFileNameFull $logFileNameFull
            # -groupBoxLabel "Select active components:" `
            # $componentsGroupBox.Margin = $global:displayMargins.Margin
            # $componentsGroupBox.Padding = $global:displayMargins.Padding
            # $componentsPage.Margin = $global:displayMargins.Margin
            # $componentsPage.Padding = $global:displayMargins.Padding
            $componentsPage.Controls.Add($componentsGroupBox)

            # region Tab Page 3 - Categories
            # Load and build Categories
            $global:dataSet = "Categories"
            $categoryData = Get-WFDataSet -dataSet $global:dataSet
            $categoryGroupBox = New-Object System.Windows.Forms.GroupBox
            $categoryGroupBox = Update-WFCheckBoxList `
                -Name $global:dataSet `
                -groupBox $categoryGroupBox `
                -form $window.Forms[0] `
                -jsonData $categoryData `
                -groupBoxHeightMax $groupBoxHeightMax `
                -logFileNameFull $logFileNameFull
            # -groupBoxLabel "Select active categories:" `
            # $categoryGroupBox.Margin = $global:displayMargins.Margin
            # $categoryGroupBox.Padding = $global:displayMargins.Padding
            # $categoriesPage.Margin = $global:displayMargins.Margin
            # $categoriesPage.Padding = $global:displayMargins.Padding
            $categoriesPage.Controls.Add($categoryGroupBox)

            # region Tap Page 4 - Json DataSet Inspector
            $global:dataSet = "Inspector"
            # Create a Panel to hold the TreeView
            $inspectorPanel = New-Object System.Windows.Forms.Panel
            $inspectorPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
            $inspectorPanel.BorderStyle = $global:borderStyle
            $inspectorPanel.BackColor = [System.Drawing.Color]::White
            $null = Get-WFDataSetTreeView `
                -dataArray $global:appDataArray `
                -DoAll -control $inspectorPanel `
                -logFileNameFull $logFileNameFull
            # $modulesGroupBox.Margin = $global:displayMargins.Margin
            # $modulesGroupBox.Padding = $global:displayMargins.Padding
            # $inspectorPage.Margin = $global:displayMargins.Margin
            # $inspectorPage.Padding = $global:displayMargins.Padding
            $inspectorPage.Controls.Add($inspectorPanel)

            # Output display Panel
            $global:dataSet = "Output"
            # Create a Panel to hold the TreeView
            $ActionOutputPanel = New-Object System.Windows.Forms.Panel
            $ActionOutputPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
            $ActionOutputPanel.BackColor = [System.Drawing.Color]::White
            $ActionOutputPanel.BorderStyle = $global:borderStyle
            # $ActionOutputPanel.Margin = $global:displayMargins.Margin
            # $ActionOutputPanel.Padding = $global:displayMargins.Padding

            $global:ActionOutputTextBox = New-Object System.Windows.Forms.TextBox
            $global:ActionOutputTextBox.Multiline = $true
            $global:ActionOutputTextBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Both
            $global:ActionOutputTextBox.Dock = [System.Windows.Forms.DockStyle]::Fill
            $global:ActionOutputTextBox.BorderStyle = $global:borderStyle
            # $global:ActionOutputTextBox.Margin = $global:displayMargins.Margin
            # $global:ActionOutputTextBox.Padding = $global:displayMargins.Padding

            $ActionOutputPanel.Controls.Add($global:ActionOutputTextBox)
            $actionOuputPage.Margin = $global:displayMargins.Margin
            $actionOuputPage.Padding = $global:displayMargins.Padding
            $actionOuputPage.Controls.Add($ActionOutputPanel)
            Update-WFTextBox -textBox $global:ActionOutputTextBox -text "Start" -logFileNameFull $logFileNameFull
        } catch {
            $Message = "DevEnvGui unable to load and create Tab Page objects."
            Add-LogText -Message $Message `
                -IsCritical -IsError -ErrorPSItem $_ `
                -logFileNameFull $logFileNameFull
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
            $null = Update-WFFormControls `
                -Target "Window" `
                -window $window `
                -formIndex 0 `
                -Name $appName `
                -DoAll `
                -DoMenuBars `
                -Buttons $global:buttonBarUsed `
                -formMenuActions $formMenuActions `
                -formToolStripActions $formToolStripActions `
                -margins $margins `
                -logFileNameFull $logFileNameFull
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
            $global:dataSet = "Data"
            $window.FormIndex = 0
            # Adjust Size for TabPages
            $tabArray = @($modulesPage, $componentsPage, $categoriesPage)

            $widthMaxForm = $window.Forms[$window.FormIndex].PreferredSize.Width
            $widthMaxTabs = $tabControls.PreferredSize.Width
            $widthMax1 = $modulesPage.PreferredSize.Width
            $widthMax2 = [Math]::Max($componentsPage.PreferredSize.Width, $widthMax)
            $widthMax3 = [Math]::Max($categoriesPage.PreferredSize.Width, $widthMax)
            $widthMax = $modulesPage.PreferredSize.Width
            $widthMax = [Math]::Max($componentsPage.PreferredSize.Width, $widthMax)
            $widthMax = [Math]::Max($categoriesPage.PreferredSize.Width, $widthMax)
            $widthMax += 20 # padding
            $widthMaxForm = [Math]::Max($widthMax, $widthMaxForm)
            $widthMaxForm += 20 # padding
            # $widthMaxForm = [Math]::Min($global:displaySizeMax.Width, $widthMaxForm)

            $heightMaxForm = $window.Forms[$window.FormIndex].PreferredSize.Height
            $heightMaxTab = $tabControls.PreferredSize.Height
            $heightMax1 = $modulesPage.PreferredSize.Height
            $heightMax2 = [Math]::Max($componentsPage.PreferredSize.Height, $heightMax)
            $heightMax3 = [Math]::Max($categoriesPage.PreferredSize.Height, $heightMax)
            $heightMax = $modulesPage.PreferredSize.Height
            $heightMax = [Math]::Max($componentsPage.PreferredSize.Height, $heightMax)
            $heightMax = [Math]::Max($categoriesPage.PreferredSize.Height, $heightMax)
            $heightMax += $global:displayMargins.Top + $global:displayMargins.Bottom
            $heightMaxForm = [Math]::Max($heightMax, $heightMaxForm)
            $heightMaxForm += $global:displayButtonSize.Height
            $heightMaxForm += $global:displayMargins.Bottom
            $heightMaxForm += 100 # extra room for buttons.
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
            # $window.Forms[$window.FormIndex].SuspendLayout()
            $window.Forms[$window.FormIndex].Controls.Add($tabControls)
            $tabControls.Size = New-Object System.Drawing.Size($widthMax, $heightMax)
            $xTmp = $global:displayMargins.Left * 2
            $tabControls.Location = New-Object System.Drawing.Point($xTmp, 50)
            $global:tabControls = $tabControls

            # Status Bar
            $window.MenuBar[$window.FormIndex].StatusBar.Dock = [System.Windows.Forms.DockStyle]::Bottom
            $window.Forms[$window.FormIndex].Controls.Add($window.MenuBar[$window.FormIndex].StatusBar)
            Update-WFStatusBarStrip -sender $window -e "Open" -statusBarLabel 'statusBarDataSetLabel' -text $global:dataSet -logFileNameFull $logFileNameFull
            Update-WFStatusBarStrip -sender $window -e "Open" -statusBarLabel 'statusBarDataSetState' -text $global:dataSetState -logFileNameFull $logFileNameFull
            $textOut = "AutoSaved at " + (Get-Date).ToString("HH:mm:ss")
            Update-WFStatusBarStrip -sender $window -e "Open" -statusBarLabel 'statusBarAutoSaveLabel' -text $textOut -logFileNameFull $logFileNameFull

            $window.Forms[$window.FormIndex].MinimumSize = New-Object System.Drawing.Size($widthMaxForm, $heightMaxForm)
            $window.Forms[$window.FormIndex].AutoSize = $true
            $window.Forms[$window.FormIndex].AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
            Update-WFTextBox -textBox $global:ActionOutputTextBox -text "Hello" -logFileNameFull $logFileNameFull
        } catch {
            $Message = "DevEnvGui unable to Build the Window."
            Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
        }
        # Show the form as a modal dialog
        try {
            # $window.Forms[$window.FormIndex].ResumeLayout()
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
            Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
        }
    }
    end { }
}
