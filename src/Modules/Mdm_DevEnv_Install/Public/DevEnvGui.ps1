
# DevEnv Gui
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
        # $assemblySystemWindowsForms = Get-Assembly -assemblyName $assemblyName
        # Project settings and paths
        # Get-ModuleRootPath
        $path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Modules\Project.ps1"
        . "$path"
        # $null = Get-Import "Mdm_WinFormPS" -DoForce
        $assemblyName = "System.Windows.Forms"
        $null = Get-Assembly -assemblyName $assemblyName

        $global:appName = "DevEnvGui"
        if (-not $Title) { $Title = "$global:appName - Development Envrionment Install / Update" }
        $global:displayWindow = [DisplayElement]::new(10, 10, 150, 250)
        $global:displayMargins = [MarginClass]::new(10, 10, 10, 10)
        $global:timeStarted = Get-Date
        $global:timeStartedFormatted = "{0:yyyyMMdd_HHmmss}" -f $global:timeStarted
        $global:timeCompleted = $null
        # $tabArray = @($modulesPage, $componentsPage, $categoriesPage, $inspectorPage)
        [bool]$global:DoButtonBar = $true
        $global:buttonArray = @("OkButton", "CancelButton", "ApplyButton")

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
        Add-LogText -Message $Message `
            -ForegroundColor Green
        # Accessable Form Data Storage
        [hashtable]$global:moduleDataArray = New-Object System.Collections.Hashtable
        $global:moduleDataChanged = $false
        # Get Data
        $global:dataSourceName = $global:appName
        Read-WFDataSet
        # Load Configuration
        $dataSetName = "Control"
        $formControlData = Get-WFDataSet -dataSet $dataSetName
        # # Load Window State from file 
        # $formControlData = Get-JsonData -Name $dataSetName -UpdateGlobal -AddSource `
        #     -jsonObject ".\DevEnvGuiConfig.json"
    }
    process {
        # region Create Window and TabPages
        try {
            $window = New-WFWindow `
                -Title $Title
            $resultDefault = [CommandResult]::new()
            $window.state.CommandResult = $resultDefault
            $window.state.CommandResult.CommandName = "Initialization"
            $window.state.data = $formControlData

            # Create Tabs
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
        } catch {
            $Message = "DevEnvGui unable to create Window and Form objects."
            Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_
        }
        # region Group Boxes: 1 - Modules
        try {
            # Load and build components
            $dataSetName = "Modules"
            $moduleData = Get-WFDataSet -dataSet $dataSetName
            # $moduleData = Get-JsonData -Name $dataSetName -UpdateGlobal -AddSource `
            #     -jsonObject ".\DevEnvModules.json"
            $modulesGroupBox = New-Object System.Windows.Forms.GroupBox
            $modulesGroupBox = Build-WFCheckBoxList `
                -Name $dataSetName `
                -groupBox $modulesGroupBox `
                -form $window.forms[0] `
                -jsonData $moduleData `
                -groupBoxLabel "Select active modules:"
            $modulesPage.Controls.Add($modulesGroupBox)

            # region Tab Page 2 - Components
            # Load and build components
            $dataSetName = "Components"
            $componentData = Get-WFDataSet -dataSet $dataSetName
            $componentsGroupBox = New-Object System.Windows.Forms.GroupBox
            $componentsGroupBox = Build-WFCheckBoxList `
                -Name $dataSetName `
                -groupBox $componentsGroupBox `
                -form $window.forms[0] `
                -jsonData $componentData `
                -groupBoxLabel "Select active components:"
            $componentsPage.Controls.Add($componentsGroupBox)

            # region Tab Page 3 - Categories
            # Load and build Categories
            $dataSetName = "Categories"
            $categoryData = Get-WFDataSet -dataSet $dataSetName
            $categoryGroupBox = New-Object System.Windows.Forms.GroupBox
            $categoryGroupBox = Build-WFCheckBoxList `
                -Name $dataSetName `
                -groupBox $categoryGroupBox `
                -form $window.forms[0] `
                -jsonData $categoryData `
                -groupBoxLabel "Select active categories:"
            $categoriesPage.Controls.Add($categoryGroupBox)

            # region Tap Page 4 - Json DataSet Inspector
            $dataSetName = "Inspector"
            $inspectorTreeView = Get-WFDataSetTreeView `
                -json $global:moduleDataArray
            # -control $window.forms[0] `
            $inspectorPage.Controls.Add($inspectorTreeView)

        } catch {
            $Message = "DevEnvGui unable to load and create Tab Page objects."
            Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_
        }
        # region Add TabPages and adjust Controls and Page Size
        try {
            $tabControls.TabPages.Add($modulesPage)
            $tabControls.TabPages.Add($componentsPage)
            $tabControls.TabPages.Add($categoriesPage)
            $tabControls.TabPages.Add($inspectorPage)

            # Build the form. Target is for groupBox
            $window = Build-WFFormControls `
                -Target "Window" `
                -DoControls `
                -DoMenuBar `
                -DoEvents `
                -window $window `
                -formIndex 0 `
                -margins $margins `
                -Buttons $global:buttonArray

            # not used, excluded
            # -OkButton "Update" `
            # -CancelButton "Cancel" 
            # -DoMenuBar `
            # -Title "Development Envrionment Install / Update" `
            # -form $form `
            # -tabPage $modulesPage `
            # -tabIndex 0 `
            # -jsonData $modules `
            # -groupBox $null `
            # -groupBoxLabel "" `

            # Finish Form
            # Adjust Size for TabPages
            $tabArray = @($modulesPage, $componentsPage, $categoriesPage)

            $widthMaxForm = $window.forms[0].PreferredSize.Width
            $widthMaxTabs = $tabControls.PreferredSize.Width
            $widthMax = $modulesPage.PreferredSize.Width
            $widthMax = [Math]::Max($componentsPage.PreferredSize.Width, $widthMax)
            $widthMax = [Math]::Max($categoriesPage.PreferredSize.Width, $widthMax)
            $widthMax += 20 # padding
            $widthMaxForm = [Math]::Max($widthMax, $widthMaxForm)
            $widthMaxForm += 20 # padding
            # $widthMaxForm = [Math]::Min($global:displaySizeMax.Width, $widthMaxForm)

            $heightMaxForm = $window.forms[0].PreferredSize.Height
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

            $window.forms[0].Controls.Add($tabControls)
            $tabControls.Size = New-Object System.Drawing.Size($widthMax, $heightMax)
            $tabControls.Location = New-Object System.Drawing.Point($global:displayMargins.Left, 50)

            $window.forms[0].MinimumSize = New-Object System.Drawing.Size($widthMaxForm, $heightMaxForm)
            $window.forms[0].AutoSize = $true
            $window.forms[0].AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
        } catch {
            $Message = "DevEnvGui unable to Build the Window."
            Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_
        }
        # Show the form as a modal dialog
        try {
            $dialogResult = Show-WFForm([System.Windows.Forms.Form]($window.forms[0]))
            # $dialogResult = $window.forms[0].ShowDialog()

            # Optionally, you can check the dialog result if needed
            if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
                # Handle OK result
                # Update data
            } elseif ($dialogResult -eq [System.Windows.Forms.DialogResult]::Cancel) {
                # Handle Cancel result
            }        
        } catch {
            $Message = "DevEnvGui unable to Show or process Window Result."
            Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_
        }
    }
    end { }
}
