
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
        [string]$title
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
        $global:timeStarted = Get-Date
        $global:timeStartedFormatted = "{0:yyyyMMdd_HHmmss}" -f $global:timeStarted
        $global:timeCompleted = $null
    
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
    }
    process {
        #region Create Window
        try {
            $global:displayWindow = [DisplayElement]::new(10, 10, 150, 250)
            $global:displayMargins = [DisplayElement]::new(10, 10, 10, 10)
            $window = New-WFWindow `
                -Title "Development Envrionment Install / Update" `
                -DoMenuBar `
                -OkButton "Update" `
                -CancelButton "Cancel"
            $resultDefault = [CommandResult]::new()
            $window.state.CommandResult = $resultDefault
            $window.state.CommandResult.CommandName = "Initialization"

            # Load Window State from file 
            # $null = 
            Get-JsonData -parentObject $window.state.data -jsonObject ".\DevEnvGuiConfig.json"

            # Create Tabs
            $tabControls = New-Object System.Windows.Forms.TabControl
            $tabControls.Dock = [System.Windows.Forms.DockStyle]::Top
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
        } catch {
            $Message = "DevEnvGui unable to create Window and Form objects."
            Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_
        }
        #endregion
        #region Tab Page 1 - Modules
        try {
            # Load and build components
            $modulesData = Get-JsonData -jsonObject ".\DevEnvModules.json"
            $modulesGroupBox = New-Object System.Windows.Forms.GroupBox
            $modulesPage.Controls.Add($modulesGroupBox)
            $modulesGroupBox = Build-WFCheckBoxList `
                -groupBox $modulesGroupBox `
                -form $window.forms[0] `
                -jsonData $modulesData `
                -groupBoxLabel "Select active modules:"
            # $tabControls.TabPages.Add($modulesPage)
            # endregion
            # region Tab Page 2 - Components
            # Load and build components
            $window.components = Get-JsonData -jsonObject ".\DevEnvComponents.json"
            $componentsData = $window.components
            $componentsGroupBox = New-Object System.Windows.Forms.GroupBox
            $componentsPage.Controls.Add($componentsGroupBox)
            $componentsGroupBox = Build-WFCheckBoxList `
                -groupBox $componentsGroupBox `
                -form $window.forms[0] `
                -jsonData $componentsData `
                -groupBoxLabel "Select active components:"
            # $tabControls.TabPages.Add($componentsPage)
            # endregion
            # region Tab Page 3 - Categories
            # Load and build Categories
            $categoryData = Get-JsonData -jsonObject ".\DevEnvCategories.json"
            $categoryGroupBox = New-Object System.Windows.Forms.GroupBox
            $categoriesPage.Controls.Add($categoryGroupBox)
            $categoryGroupBox = Build-WFCheckBoxList `
                -groupBox $categoryGroupBox `
                -form $window.forms[0] `
                -jsonData $categoryData `
                -groupBoxLabel "Select active categories:"
            # $tabControls.TabPages.Add($categoriesPage)
        } catch {
            $Message = "DevEnvGui unable to load and create Tab Page objects."
            Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_
        }
        #endregion
        try {
            # Add the TabControl to the form
            # $modulePage.Size = New-Object System.Drawing.Size($widthMax, $heightMax)
            # $componentsPage.Size = New-Object System.Drawing.Size($widthMax, $heightMax)
            # $categoriesPage.Size = New-Object System.Drawing.Size($widthMax, $heightMax)
            $tabControls.TabPages.Add($modulesPage)
            $tabControls.TabPages.Add($componentsPage)
            $tabControls.TabPages.Add($categoriesPage)
            # $tabControls.Size = New-Object System.Drawing.Size($widthMax, $heightMax)

            $window.forms[0].Controls.Add($tabControls)
            # $tabControls.Location = New-Object System.Drawing.Point(30, 50)
            # Build the form. Target is for groupBox
            $null = Build-WFFormControls `
                -Target "Window" `
                -window $window `
                -formIndex 0 `
                -margins $margins `
                -Title "Development Envrionment Install / Update" `
                -DoControls `
                -DoMenuBar `
                -OkButton "Update" `
                -CancelButton "Cancel" 
            # not used, excluded
            # -form $form `
            # -tabPage $modulesPage `
            # -tabIndex 0 `
            # -jsonData $modules `
            # -groupBox $null `
            # -groupBoxLabel "" `

            # Finish Form
            # Adjust Size for TabPages
            # This is without TabPages so a minimul
            $tabArray = @($modulesPage, $componentsPage, $categoriesPage)

            $widthMaxForm = $window.forms[0].PreferredSize.Width
            $widthMaxTabs = $tabControls.PreferredSize.Width
            $widthMax = $modulesPage.PreferredSize.Width
            $widthMax = [Math]::Max($componentsPage.PreferredSize.Width, $widthMax)
            $widthMax = [Math]::Max($categoriesPage.PreferredSize.Width, $widthMax)
            $widthMax += 20 # padding
            $widthMaxForm += $widthMax
            $widthMaxForm += 20 # padding
            # $widthMaxForm = [Math]::Min($global:displaySizeMax.Width, $widthMaxForm)

            $heightMaxForm = $window.forms[0].PreferredSize.Height
            $heightMaxTab = $tabControls.PreferredSize.Height
            $heightMax = $modulesPage.PreferredSize.Height
            $heightMax = [Math]::Max($componentsPage.PreferredSize.Height, $heightMax)
            $heightMax = [Math]::Max($categoriesPage.PreferredSize.Height, $heightMax)
            $heightMax += 20 # + padding
            $heightMaxForm += $heightMax
            $heightMaxForm += 20 # + padding
            # $heightMaxForm = [Math]::Min($global:displaySizeMax.Height, $heightMaxForm)
            $tabControls.Size = New-Object System.Drawing.Size($widthMax, $heightMax)
            # # Add the TabControl to the form
            # # $modulePage.Size = New-Object System.Drawing.Size($widthMax, $heightMax)
            # # $componentsPage.Size = New-Object System.Drawing.Size($widthMax, $heightMax)
            # # $categoriesPage.Size = New-Object System.Drawing.Size($widthMax, $heightMax)
            # $tabControls.TabPages.Add($modulesPage)
            # $tabControls.TabPages.Add($componentsPage)
            # $tabControls.TabPages.Add($categoriesPage)
            # $tabControls.Size = New-Object System.Drawing.Size($widthMax, $heightMax)

            # $window.forms[0].Controls.Add($tabControls)
            # $tabControls.Location = New-Object System.Drawing.Point(30, 50)
            $window.forms[0].MinimumSize = New-Object System.Drawing.Size($widthMaxForm, $heightMaxForm)
            $window.forms[0].AutoSize = $true
            $window.forms[0].AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink

        } catch {
            $Message = "DevEnvGui unable to Build the Window."
            Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_
        }
        try {
            # Show the form as a modal dialog
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
