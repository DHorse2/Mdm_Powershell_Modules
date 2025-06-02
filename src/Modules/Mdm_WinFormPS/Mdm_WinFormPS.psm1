Using namespace Microsoft.VisualBasic
Using namespace PresentationFramework
Using namespace System.Drawing
Using namespace System.Windows.Forms
Using namespace System.Web
Using module "..\Mdm_Std_Library\Mdm_Std_Library.psm1"
# Using module Mdm_Std_Library

Write-Host "Mdm_WinFormPS_FrancoisXavierCat.psm1"
Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Web

if (-not $global:moduleRootPath) {
	$path = "$($(get-item $PSScriptRoot).Parent.FullName)\Mdm_Modules\Project.ps1"
	. "$path"
}
#region Classes - Margin, WFWindow, WindowState
$global:window = $null # used to access StatusBar
$global:form = $null # not used anywhere
$global:tabControls = $null
$global:displayWindow = [DisplayElement]::new(10, 10, 50, 50)
$global:displayMargins = [DisplayElement]::new(20, 20, 20, 20)
$global:displayPadding = [DisplayElement]::new(10, 10, 10, 10)
$global:displaySizeMax = [DisplayElement]::new(10, 10, 2000, 2000)
$global:displayButtonSize = [DisplayElement]::new(0, 0, 100, 23)
[hashtable]$global:moduleDataArray = New-Object System.Collections.Hashtable
[string]$global:appName = "default"
[string]$global:appDirectory = "default"
[string]$global:fileDialogInitialDirectory = "$($global:moduleRootPath)\$global:appName"
[string]$global:fileDialogFilter = “Json files (*.json)|*.json|Text files (*.txt)|*.txt|All files (*.*)|*.*”

[bool]$global:moduleDataChanged = $false
[array]$global:buttonBarUsed = @("AutoSave", "ButtonBar", "PreviousButton", "OkButton", "CancelButton", "ApplyButton", "ResetButton", "NextButton")
# Declare the data as a hashtable
[hashtable]$global:buttonBarArray = @{
    AutoSave       = $true
    ButtonBar      = $true
	ButtonAction   = $true
    PreviousButton = { DoPrevious }
    OkButton       = { DoOk }
    CancelButton   = { DoCancel }
    ApplyButton    = { DoApply }
    ResetButton    = { DoReset }
    NextButton     = { DoNext }
}
[hashtable]$global:buttonAction = @{
	Open = { DoOpenFile }
	Save = { DoFileSave }
	SaveAs = { DoFileSaveAs }
	Close = { DoCloseForm }
	ShowAbout = { DoShowAbout }
	ShowHelp = { DoShowHelp }
}
[hashtable]$global:buttonText = @{
	Timer          	= "Timer"
    ButtonBar      	= "ButtonBar"
	StatusBar		= "StatusBar"
	FileMenu		= "File"
	HelpMenu		= "Help"
    PreviousButton 	= "Previous"
    OkButton       	= "Ok"
    CancelButton   	= "Cancel"
    ApplyButton    	= "Apply"
    ResetButton    	= "Reset"
    NextButton     	= "Next"
	Open 			= "Open"
	Save 			= "Save"
	SaveAs 			= "Save As"
	Close 			= "Close"
	ShowAbout 		= "About"
	ShowHelp 		= "Help"
}
[string]$global:dataSourceName = "Application"
[string]$global:dataSet = "Data"
[string]$global:dataSetState = "Current"
[bool]$global:autoSaveActive = $false
[bool]$global:fileSystemActive = $false
# AutoSave
[bool]$global:DoTimer = $true
[System.Windows.Forms.Timer]$global:autoSaveTimer = $null
[int]$global:autoSaveTimerInterval = 30000
[bool]$global:autoSaveTimerBusy = $false
# Menu Action Output
$global:outputBuffer = ""
$global:ActionExecutionMethod = "Start-Process" # vs "Invoke-Command"
$global:ActionOutputTextBox = $null
[System.Windows.Forms.Timer]$global:buttonActionTimer = $null
[int]$global:buttonActionTimerInterval = 1000
[bool]$global:buttonActionTimerBusy = $false

class DisplayElement {
	[string]$Name
	[string]$Position
	[int]$Top
	[int]$Left
	[int]$Width
	[int]$Height
	[string]$BackgroundColor
	[System.Drawing.Size]$Size
	[System.Drawing.Point]$Location

	# Default constructor
	DisplayElement() {
		$this.Name = ""
		$this.Position = "absolute"
		$this.Top = 0
		$this.Left = 0
		$this.Width = 100
		$this.Height = 100
		$this.BackgroundColor = "transparent"
		$this.Size = New-Object System.Drawing.Size(0, 0)
		$this.Location = New-Object System.Drawing.Point(0, 0)

	}

	# Parameterized constructor
	DisplayElement([string]$name, [string]$position, [int]$top, [int]$left, [int]$width, [int]$height, [string]$backgroundColor) {
		$this.Name = $name
		$this.Position = $position
		$this.Top = $top
		$this.Left = $left
		$this.Width = $width
		$this.Height = $height
		$this.BackgroundColor = $backgroundColor
		$this.Size = New-Object System.Drawing.Size($width, $height)
		$this.Location = New-Object System.Drawing.Point($left, $top)
	}

	# Standard constructor
	DisplayElement([int]$top, [int]$left, [int]$width, [int]$height) {
		$this.Name = ""
		$this.Position = ""
		$this.Top = $top
		$this.Left = $left
		$this.Width = $width
		$this.Height = $height
		$this.BackgroundColor = ""
		$this.Size = New-Object System.Drawing.Size($width, $height)
		$this.Location = New-Object System.Drawing.Point($left, $top)
	}

	# Method to display the properties
	[void] Display() {
		Write-Host "Name: $($this.Name)"
		Write-Host "Position: $($this.Position)"
		Write-Host "Top: $($this.Top)"
		Write-Host "Left: $($this.Left)"
		Write-Host "Width: $($this.Width)"
		Write-Host "Height: $($this.Height)"
		Write-Host "Background Color: $($this.BackgroundColor)"
	}
}
function DisplayElementTest () {
	# Example of creating an instance of the DisplayElement class using the default constructor
	$defaultElement = [DisplayElement]::new()
	$defaultElement.Display()

	# Example of creating an instance of the DisplayElement class using the parameterized constructor
	$customElement = [DisplayElement]::new("absolute", "100px", "150px", "200px", "100px", "lightblue")
	$customElement.Display()
}
class MarginClass {
	[int]$Top
	[int]$Bottom
	[int]$Left
	[int]$Right

	MarginClass() {
		$this.Top = $global:displayWindow.Top
		$this.Bottom = $global:displayWindow.Bottom
		$this.Left = $global:displayWindow.Top
		$this.Right = $global:displayWindow.Right
	}
	MarginClass([int]$top = 0, [int]$bottom = 0, [int]$left = 0, [int]$right = 0) {
		$this.Top = $top
		$this.Bottom = $bottom
		$this.Left = $left
		$this.Right = $right
	}
}
class MenuBar {
	[System.Windows.Forms.MenuStrip]$MenuStrip
	[System.Windows.Forms.ToolStrip]$ToolStrip
	[System.Windows.Forms.ToolStrip]$StatusBar

	MenuBar() {
		$this.MenuStrip = New-Object System.Windows.Forms.MenuStrip
		$this.ToolStrip = New-Object System.Windows.Forms.ToolStrip
		$this.StatusBar = New-Object System.Windows.Forms.ToolStrip
	}
	MenuBarSet($inputMenuStrip, $inputToolStrip, $inputStatusBar) {
		$this.MenuStrip = $inputMenuStrip
		$this.ToolStrip = $inputToolStrip
		$this.StatusBar = $inputStatusBar
	}
}
class WFWindow {
	[string]$Name
	[System.Windows.Forms.Form[]]$Forms
	[MenuBar[]]$MenuBar
	[System.Windows.Forms.TabControl[]]$TabPage
	[int]$FormIndex
	[int]$TabIndex
	[hashtable]$Components
	[MarginClass]$Margins
	[WindowState]$State

	# Default constructor
	WFWindow() {
		$this.SetWindow($null, $null, $null, $null, 0, 0, $null, $null, $null)
		Write-Host "WFWindow Warning: Default constructor invoked."
	}

	# Constructor that accepts a form
	WFWindow(
		[System.Windows.Forms.Form[]]$inputForms
	) {
		$this.SetWindow($null, $inputForms, $null, $null, 0, 0, $null, $null, $null)
	}
	# Constructor that accepts a form and menu strips
	WFWindow(
		[System.Windows.Forms.Form[]]$inputForms,
		[MenuBar[]]$inputMenuBar = $null,
		[System.Windows.Forms.TabControl[]]$TabPage
	) {
		$this.SetWindow($null, $inputForms, $inputMenuBar, $TabPage, 0, 0, $null, $null, $null)
	}
	# Constructor that accepts optional data
	WFWindow(
		[string]$inputName = $null,
		[System.Windows.Forms.Form[]]$inputForms = $null, 
		[MenuBar[]]$inputMenuBar = $null,
		[System.Windows.Forms.TabControl[]]$TabPage = $null,
		[int]$inputFormIndex = $null, 
		[int]$inputTabIndex = $null,
		[MarginClass]$inputMargins = $null, 
		[hashtable]$inputComponents = $null, 
		[WindowState]$inputState = $null
	) {
		$this.SetWindow($inputName, $inputForms, $inputMenuBar, $TabPage, $inputFormIndex, 0, $inputMargins, $inputComponents, $inputState)
	}
			
	[void] SetWindow(
		[string]$inputName = $null,
		[System.Windows.Forms.Form[]]$inputForms = $null,
		[MenuBar[]]$inputMenuBar = $null, 
		[System.Windows.Forms.TabControl[]]$inputTabPage = $null, 
		[int]$inputFormIndex = $null, 
		[int]$inputTabIndex = $null,
		[MarginClass]$inputMargins = $null, 
		[hashtable]$inputComponents = $null, 
		[WindowState]$inputState = $null
	) {
		try {
			# Forms
			if ($inputName -and $inputName -is [string]) {
				$this.Name = $inputName
			} elseif ($inputForms) {
				$Message = "WFWindow constructor received an invalid Name. String required."
				Add-LogText -Messages $Message -IsError
			}
			if ($inputForms -and $inputForms -is [System.Windows.Forms.Form[]]) {
				$this.Forms = $inputForms
				$this.MenuBar = $inputMenuBar
			} elseif ($inputForms) {
				$Message = "WFWindow constructor received an invalid Forms array."
				Add-LogText -Messages $Message -IsError
			}
			if (-not ($this.Forms)) { $this.Forms = @() }
			if (-not ($this.MenuBar)) {
				this.MenuBar = @( [MenuBar]::new() )
			}
			# Form Index
			if ($inputFormIndex -ge 0 -and $inputFormIndex -lt $this.Forms.Count) {
				$this.FormIndex = $inputFormIndex
			} else {
				if ($this.Forms.Count -ne 0) {
					Write-IndexOutOfBounds -Name "WFWindow Forms" -indexCurr $inputFormIndex -IndexMax $this.Forms.Count -DoLog
				}
				$this.FormIndex = 0
			}
			# Tabs
			if ($inputTabPage -and $inputTabPage -is [System.Windows.Forms.TabControl[]]) {
				$this.TabPage = $inputTabPage
			} elseif ($inputTabPage) {
				$Message = "WFWindow constructor received an invalid Tab Pages array."
				Add-LogText -Messages $Message -IsError
			}
			# Tab Index
			if ($inputTabIndex -ge 0 -and $inputTabIndex -lt $this.TabIndex.Count) {
				$this.TabIndex = $inputTabIndex
			} else {
				if ($this.TabIndex.Count -ne 0) {
					Write-IndexOutOfBounds -Name "WFWindow Tabs" -indexCurr $inputTabIndex -IndexMax $this.Forms.Count -DoLog
				}
				$this.TabIndex = 0
			}
			# Margins
			if ($inputMargins -and $inputMargins -is [MarginClass]) {
				$this.Margins = $inputMargins
			} else {
				if (-not $this.Margins -or -not $this.Margins -is [MarginClass]) {
					$this.Margins = [MarginClass]::new()
				}
			}
			# Components
			if ($inputComponents -and $inputComponents -is [hashtable]) {
				$this.Components = $inputComponents
			} else {
				$this.Components = @{}
			}
			# State
			if ($inputState -and $inputState -is [WindowState]) {
				$this.State = $inputState
			} else {
				$this.State = [WindowState]::new()
			}
		} catch {
			Add-LogText -IsError -ErrorPSItem $_ -Message "WFWindow SetWindow had an error."
		}
	}

	[System.Windows.Forms.Form] GetCurrentForm() {
		if (-not ($this.FormIndex -ge 0 -and $this.FormIndex -lt $this.Forms.Count)) {
			Write-IndexOutOfBounds -Name "WFWindow" -indexCurr $this.FormIndex -IndexMax $this.Forms.Count -DoLog
			$this.FormIndex = 0
			return $null
		} else { 
			return $this.Forms[$this.FormIndex]
		}
	}

	[System.Windows.Forms.Form] GetForm([int]$formIndex = 0) {
		if ($formIndex -ge 0 -and $formIndex -lt $this.Forms.Count) {
			return $this.Forms[$formIndex]
		} else { 
			Write-IndexOutOfBounds -Name "WFWindow" -indexCurr $formIndex -IndexMax $this.Forms.Count -DoLog
			return $null
		}
	}

	[MenuBar] GetMenuBar([int]$formIndex = 0) {
		if ($formIndex -ge 0 -and $formIndex -lt $this.Forms.Count) {
			return $this.MenuBar[$formIndex]
		} else { 
			Write-IndexOutOfBounds -Name "WFWindow" -indexCurr $formIndex -IndexMax $this.Forms.Count -DoLog
			return $null
		}
	}

	[System.Windows.Forms.Form] SetForm([int]$formIndex, [System.Windows.Forms.Form]$newForm = $null, [MenuBar]$newMenuBar = $null) {
		if ($formIndex -ge 0 -and $formIndex -lt $this.Forms.Count) {
			$this.FormIndex = $formIndex
			if ($newForm) { 
				$this.Forms[$this.FormIndex] = $newForm
			}
			if ($newMenuBar) {
				$this.MenuBar[$this.FormIndex] = $newMenuBar
			}
			return $this.Forms[$this.FormIndex]
		} else { 
			Write-IndexOutOfBounds -Name "WFWindow" -indexCurr $formIndex -IndexMax $this.Forms.Count -DoLog
			return $null
		}
	}

	[void] Show([int]$formIndex = 0) {
		if ($formIndex -ge 0 -and $formIndex -lt $this.Forms.Count) {
			Show-WFForm([System.Windows.Forms.Form]$this.Forms[$formIndex])
		} else { 
			Write-IndexOutOfBounds -Name "WFWindow" -indexCurr $formIndex -IndexMax $this.Forms.Count -DoLog
		}
	}

	[void] ShowAll() {
		for ($currentFormIndex = 0; $currentFormIndex -lt $this.Forms.Count; $currentFormIndex++) {
			$this.Show($currentFormIndex)
			# Show-WFForm([System.Windows.Forms.Form]$this.Forms[$currentFormIndex])
		}
	}
}
class WindowState {
	$data
	[CommandResult]$CommandResult
	[DisplayElement]$Display
	[int]$x
	[int]$y

	WindowState() {
		# Write-Host "WindowState Warning, default constructor invoked."
		$this.data = $this.WindowStateDefault()
		$this.CommandResult = [CommandResult]::new()
		$this.Display = [DisplayElement]::new()
		$this.x = -1; $this.y = -1
	}
	WindowState([hashtable]$inputData = $null) {
		# Initialize Data with default values if no data is provided
		if ($null -eq $inputData) {
			$this.data = $this.WindowStateDefault()
		} else {
			$this.data = $inputData
		}
		$this.CommandResult = [CommandResult]::new()
		$this.Display = [DisplayElement]::new()
		$this.x = -1; $this.y = -1
	}
	WindowState($inputData = $null, [CommandResult]$inputCommandResult) {
		# Initialize Data with default values if no data is provided
		if ($null -eq $inputData) {
			$this.data = $this.WindowStateDefault()
		} else {
			$this.data = $inputData
		}
		if ($null -eq $inputCommandResult) {
			$this.CommandResult = [CommandResult]::new()
		} else {
			$this.CommandResult = $inputCommandResult
		}
		$this.Display = [DisplayElement]::new()
		$this.x = -1; $this.y = -1
	}
	WindowState($inputData = $null, [CommandResult]$inputCommandResult, [DisplayElement]$inputDisplayElement) {
		# Initialize Data with default values if no data is provided
		if ($null -eq $inputData) {
			$this.data = $this.WindowStateDefault()
		} else {
			$this.data = $inputData
		}
		if ($null -eq $inputCommandResult) {
			$this.CommandResult = [CommandResult]::new()
		} else {
			$this.CommandResult = $inputCommandResult
		}
		if ($null -eq $inputDisplayElement) {
			$this.Display = [DisplayElement]::new()
		} else {
			$this.Display = $inputDisplayElement
		}
		$this.x = -1; $this.y = -1
	}
	[hashtable] WindowStateDefault() {
		return @{
			Package            = "MacroDM"
			Module             = ""
			ScriptName         = ""
			Version            = ""
			FunctionName       = ""
			MenuName           = ""
			ScriptLineNumber   = 0
			ScriptColumnNumber = 0
			FormName           = ""
			Options            = [PSCustomObject]@{
				Options = $false
			}
			# [CommandResult]$CommandResult = [CommandResult]::new()
		}
	}
}
function Test-WFWindow {
	param (
		$window
	)
	process {
		# Usage example
		$form1 = New-Object System.Windows.Forms.Form
		$form2 = New-Object System.Windows.Forms.Form

		# Create an array of forms
		$formsArray = @($form1, $form2)

		# Create a new WFWindow instance with the array of forms and default data
		if (-not $window) { $window = [WFWindow]::new($formsArray) }

		# Accessing the forms and default data
		$window.Forms[0].Text = "Form 1"
		$window.Forms[1].Text = "Form 2"
		Write-Output $window.Data.Package  # Output: MacroDM

		# Create a new WFWindow instance with custom data
		$customData = @{
			Package    = "CustomPackage"
			Module     = "CustomModule"
			ScriptName = "CustomScript"
			FormName   = "CustomForm"
			Options    = [PSCustomObject]@{
				Options = $true
			}
		}
		$stateData = [WindowState]::new($customData)
		$stateData1 = [WindowState]::new(@{
				Package    = "CustomPackage"
				Module     = "CustomModule"
				ScriptName = "CustomScript"
				FormName   = "CustomForm"
				Options    = [PSCustomObject]@{
					Options = $true
				}
			})

		$windowWithCustomData = [WFWindow]::new($formsArray, $stateData)

		# Accessing the forms and custom data
		Write-Output $windowWithCustomData.state.data.Package  # Output: CustomPackage    }
	}
	# WindowClass
	# $path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\Mdm_WinFormPS\Public\WindowClass.psm1"
	# Write-Output "Exists: $(Test-Path "$path"): $path"
	# . "$path"
	# Import-Module -Name $path
}
#endregion
# Module Folder Processing
# Get public and private function definition files.
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)
$Classes = @(Get-ChildItem -Path $PSScriptRoot\Classes\*.ps1 -ErrorAction SilentlyContinue)
#Dot source the files
Foreach ($import in @($Public + $Private + $Classes)) {
	TRY {
		. $import.fullname
	} CATCH {
		Add-LogText -IsError -ErrorPSItem $_ -Message "Failed to import function $($import.fullname)."
	}
}
# Create Aliases
New-Alias -Name Load-WFListBox -value Import-WFListBox -Description "SAPIEN Name"
New-Alias -Name Load-WFDataGridView -value Import-WFDataGridView -Description "SAPIEN Name"
New-Alias -Name Refresh-WFDataGridView -value Update-WFDataGridView -Description "SAPIEN Name"
# Export all the functions
Export-ModuleMember -Function $Public.Basename -Alias *
Export-ModuleMember -Variable @(
	"DisplayElement"
    "WFWindow", 
	"WindowState", 
	"MarginClass"
)
