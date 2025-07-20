Using namespace Microsoft.VisualBasic
Using namespace PresentationFramework
Using namespace PresentationCore
Using namespace WindowsBase
Using namespace System.Drawing
Using namespace System.Windows.Forms
Using namespace Microsoft.PowerShell.Security
Using namespace System.Management.Automation

Add-Type -AssemblyName Microsoft.PowerShell.Security
Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Management.Automation
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

# There is a large body of Standard Library functions
# The Exports are done with the component category they belong to.
# The categories are Mdm_Std_XxxCategory
# Export-ModuleMember -Function "Verb-XxxXxxNoun"
# Export-ModuleMember -Function "Verb-XxxXxxNoun"
# Export-ModuleMember -Function "Invoke-XxxVerbXxxNounScript"

$moduleName = "Mdm_Std_Library"
if ($DoVerbose) { Write-Host "== $moduleName ==" -ForegroundColor Green }
# Project Parameters
$inArgs = $args
if (-not $logFileNameFull) { $logFileNameFull = "$($(get-item $PSScriptRoot).FullName)\log\Mdm_Std_Library_Log.txt" }
# Get-Parameters
$path = "$($(get-item $PSScriptRoot).FullName)\lib\Get-ParametersLib.ps1"
. $path
# Project settings and paths
# Core: Minimum function to operate and boot.
# $global:moduleCoreLoaded
# Os: Dev Mode, Module Path and Registry init.
# $global:osCoreLoaded
# The Core gets immediately loaded by THIS module import.
$global:moduleCoreSkip = $true
# projectLib.ps1
$path = "$($(get-item $PSScriptRoot).FullName)\lib\ProjectLib.ps1"
. $path @global:combinedParams
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Declaring Classes." -ForegroundColor Green }
#region Classes
# Classes
# These were in an include but PS can't find the classes when it is used.
# It was done so that WinFormPS could be split off easily with a few file copies and changes,
# An Add-LogText function would be needed for it. It could Write-Host or Output.
# $path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\Mdm_Std_Library\lib\WFFormClasses.ps1"
# . $path @global:combinedParams

#region WFForm Classes
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Class DisplayElement." -ForegroundColor Yellow }
class DisplayElement {
	[string]$Name
	[string]$Text
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
		$this.Text = ""
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
	DisplayElement([string]$name, [string]$text, [string]$position, [int]$top, [int]$left, [int]$width, [int]$height, [string]$backgroundColor) {
		$this.Name = $name
		$this.Text = $text
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
		$this.Text = ""
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
	[string] Display([string]$type = "") {
		$outputBuffer = @()
		if (-not $type) { $type = "Display Element" }
		$outputBuff += "Name: $($this.Name), Text: $($this.Text)"
		$outputBuff += "Position: $($this.Position)"
		$outputBuff += "Top: $($this.Top), Left: $($this.Left), Width: $($this.Width), Height: $($this.Height)"
		$outputBuff += "Background Color: $($this.BackgroundColor)"
		$outputBuff += DisplaySize("Display Element", $this.Size)
		$outputBuff += DisplayPoint("Display Element", $this.Point)
		return $outputBuffer
	}
}
function DisplayElementTest () {
	# Example of creating an instance of the DisplayElement class using the default constructor
	$defaultElement = [DisplayElement]::new()
	$defaultElement.Display()

	# Example of creating an instance of the DisplayElement class using the parameterized constructor
	$customElement = [DisplayElement]::new("Bob", "Bob is home", "absolute", "100px", "150px", "200px", "100px", "lightblue")
	$customElement.Display()
}
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Class MarginClass." -ForegroundColor Yellow }
class MarginClass {
	[int]$Left
	[int]$Top
	[int]$Right
	[int]$Bottom
	[System.Windows.Forms.Padding]$Margin
	[System.Windows.Forms.Padding]$Padding

	MarginClass() {
		$this.Top = $global:displayWindow.Top
		$this.Bottom = $global:displayWindow.Bottom
		$this.Left = $global:displayWindow.Left
		$this.Right = $global:displayWindow.Right
		$this.Margin = New-Object System.Windows.Forms.Padding(
			$this.Left, 
			$this.Top, 
			$this.Right, 
			$this.Bottom
		)
		$this.Padding = New-Object System.Windows.Forms.Padding(
			$global:displayPadding.Left, 
			$global:displayPadding.Top, 
			$global:displayPadding.Right, 
			$global:displayPadding.Bottom
		)
	}
	MarginClass([int]$left = 0, [int]$top = 0, [int]$right = 0, [int]$bottom = 0) {
		$this.Left = $left
		$this.Top = $top
		$this.Right = $right
		$this.Bottom = $bottom
		$this.Margin = New-Object System.Windows.Forms.Padding($this.Left, $this.Top, $this.Right, $this.Bottom) # Left, Top, Right, Bottom
		$this.Padding = New-Object System.Windows.Forms.Padding(0, 0, 0, 0) # Left, Top, Right, Bottom
	}
	# Margin
	[System.Windows.Forms.Padding] GetMargin() {
		return $this.Margin
	}
	[void] SetMargin([System.Windows.Forms.Padding]$inputMargin) {
		$this.Margin = $inputMargin
		$this.Left = $this.Margin.Left
		$this.Top = $this.Margin.Top
		$this.Right = $this.Margin.Right
		$this.Bottom = $this.Margin.Bottom
	}
	[void] UpdateMargin([int]$left = 0, [int]$top = 0, [int]$right = 0, [int]$bottom = 0) {
		$this.Margin.Left = $left
		$this.Margin.Top = $top
		$this.Margin.Right = $right
		$this.Margin.Bottom = $bottom
		$this.Margin = New-Object System.Windows.Forms.Padding($this.Left, $this.Top, $this.Right, $this.Bottom) # Left, Top, Right, Bottom
	}
	# Padding
	[System.Windows.Forms.Padding] GetPadding() {
		return $this.Padding
	}
	[void] SetPadding([System.Windows.Forms.Padding]$inputPadding) {
		$this.Padding = $inputPadding
	}
	[void] UpdatePadding([int]$left = 0, [int]$top = 0, [int]$right = 0, [int]$bottom = 0) {
		$this.Padding.Left = $left
		$this.Padding.Top = $top
		$this.Padding.Right = $right
		$this.Padding.Bottom = $bottom
	}
	
	[string] Display([string]$type = "") {
		$outputBuffer = @()
		if (-not $type) { $type = "Margin" }
		$outputBuffer += "$($type): Left: $($this.Left), Top: $($this.Top), Right: $($this.Right), Bottom: $($this.Bottom)"
		$outputBuffer += DisplayPadding("Margin Object", $this.Margin)
		$outputBuffer += DisplayPadding("Padding Object", $this.Margin)
		return $outputBuffer
	}
}
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Class MenuBar." -ForegroundColor Yellow }
class MenuBar {
	[string]$Name
	[System.Windows.Forms.MenuStrip]$MenuStrip
	[System.Windows.Forms.ToolStrip]$ToolStrip
	[System.Windows.Forms.ToolStrip]$StatusBar

	MenuBar() {
		$this.Name = ""
		$this.MenuStrip = New-Object System.Windows.Forms.MenuStrip
		$this.ToolStrip = New-Object System.Windows.Forms.ToolStrip
		$this.StatusBar = New-Object System.Windows.Forms.ToolStrip
	}
	MenuBarSet($inputMenuStrip, $inputToolStrip, $inputStatusBar) {
		$this.Name = ""
		$this.MenuStrip = $inputMenuStrip
		$this.ToolStrip = $inputToolStrip
		$this.StatusBar = $inputStatusBar
	}

	[string] Display([string]$type = "") {
		$outputBuffer = @()
		if ($this.Name) {
			$outputBuffer += "$type  Menu Name: $($this.Name)"
		}
		if ($this.MenuStrip) {
			$outputBuffer += "$type Menu Strip: $global:NL$(DisplayMenuStrip($this.Name, $this.MenuStrip))"
		}
		if ($this.ToolStrip) {
			$outputBuffer += "$type Tool Strip: $global:NL$(DisplayToolStrip($this.Name, $this.ToolStrip))"
		}
		if ($this.StatusBar) {
			$outputBuffer += "$type Status Bar: $global:NL$(DisplayToolStrip($this.Name, $this.StatusBar))"
		}
		return $outputBuffer
	}
}
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Class WFWindow." -ForegroundColor Yellow }
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
	[string]$logFileNameFull

	# Default constructor
	WFWindow() {
		$this.SetWindow($null, $null, $null, $null, 0, 0, $null, $null, $null, $null)
		Write-Host "WFWindow Warning: Default constructor invoked."
	}

	# Constructor that accepts a form
	WFWindow(
		[System.Windows.Forms.Form[]]$inputForms
	) {
		$this.SetWindow($null, $inputForms, $null, $null, 0, 0, $null, $null, $null, $null)
	}
	# Constructor that accepts a form and menu strips
	WFWindow(
		[System.Windows.Forms.Form[]]$inputForms,
		[MenuBar[]]$inputMenuBar = $null,
		[System.Windows.Forms.TabControl[]]$TabPage
	) {
		$this.SetWindow($null, $inputForms, $inputMenuBar, $TabPage, 0, 0, $null, $null, $null, $null)
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
		[WindowState]$inputState = $null,
		[string]$inputLogFileNameFull = ""
	) {
		$this.SetWindow($inputName, $inputForms, $inputMenuBar, $TabPage, $inputFormIndex, 0, $inputMargins, $inputComponents, $inputState, $inputLogFileNameFull)
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
		[WindowState]$inputState = $null,
		[string]$inputLogFileNameFull = ""
	) {
		try {
			# Forms
			if ($inputName -and $inputName -is [string]) {
				$this.Name = $inputName
			} elseif ($inputForms) {
				$Message = "WFWindow constructor received an invalid Name. String required."
				Add-LogText -Message $Message -IsError -logFileNameFull $this.logFileNameFull
			}
			if ($inputForms -and $inputForms -is [System.Windows.Forms.Form[]]) {
				$this.Forms = $inputForms
				$this.MenuBar = $inputMenuBar
			} elseif ($inputForms) {
				$Message = "WFWindow constructor received an invalid Forms array."
				Add-LogText -Message $Message -IsError -logFileNameFull $this.logFileNameFull
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
				Add-LogText -Message $Message -IsError -logFileNameFull $this.logFileNameFull
			}
			# Tab Index
			if ($inputTabIndex -ge 0 -and $inputTabIndex -lt $this.TabIndex.Count) {
				$this.TabIndex = $inputTabIndex
			} else {
				if ($this.TabIndex.Count -ne 0) {
					Write-IndexOutOfBounds -Name "WFWindow Tabs" -indexCurr $inputTabIndex `
						-IndexMax $this.Forms.Count -DoLog -logFileNameFull $this.logFileNameFull
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
			$this.logFileNameFull = $inputLogFileNameFull
		} catch {
			$Message = "WFWindow SetWindow had an error."
			Add-LogText -IsError -ErrorPSItem $_ -Message $Message -logFileNameFull $this.logFileNameFull
		}
	}

	[System.Windows.Forms.Form] GetCurrentForm() {
		if (-not ($this.FormIndex -ge 0 -and $this.FormIndex -lt $this.Forms.Count)) {
			Write-IndexOutOfBounds -Name "WFWindow" -indexCurr $this.FormIndex `
				-IndexMax $this.Forms.Count -DoLog -logFileNameFull $this.logFileNameFull
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
			Write-IndexOutOfBounds -Name "WFWindow" -indexCurr $formIndex `
				-IndexMax $this.Forms.Count -DoLog -logFileNameFull $this.logFileNameFull
			return $null
		}
	}

	[MenuBar] GetMenuBar([int]$formIndex = 0) {
		if ($formIndex -ge 0 -and $formIndex -lt $this.Forms.Count) {
			return $this.MenuBar[$formIndex]
		} else { 
			Write-IndexOutOfBounds -Name "WFWindow" -indexCurr $formIndex `
				-IndexMax $this.Forms.Count -DoLog -logFileNameFull $this.logFileNameFull
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
			Write-IndexOutOfBounds -Name "WFWindow" -indexCurr $formIndex `
				-IndexMax $this.Forms.Count -DoLog -logFileNameFull $this.logFileNameFull
			return $null
		}
	}

	[void] Show([int]$formIndex = 0) {
		if ($formIndex -ge 0 -and $formIndex -lt $this.Forms.Count) {
			Show-WFForm([System.Windows.Forms.Form]$this.Forms[$formIndex])
		} else { 
			Write-IndexOutOfBounds -Name "WFWindow" -indexCurr $formIndex `
				-IndexMax $this.Forms.Count -DoLog -logFileNameFull $this.logFileNameFull
		}
	}

	[void] ShowAll() {
		for ($currentFormIndex = 0; $currentFormIndex -lt $this.Forms.Count; $currentFormIndex++) {
			$this.Show($currentFormIndex)
			# Show-WFForm([System.Windows.Forms.Form]$this.Forms[$currentFormIndex])
		}
	}
	[array] Display() {
		$outputBuffer = @()
		$outputBuffer += "Window $($this.Name)"
		$type = "Margin"
		$outputBuffer += "$($type): Left: $($this.Left), Top: $($this.Top), Right: $($this.Right), Bottom: $($this.Bottom)"
		$outputBuffer += DisplayPadding("Margin Object", $this.Margin)
		$outputBuffer += DisplayPadding("Padding Object", $this.Margin)

		# [string]$Name
		$outputBuffer += "Name: $($this.Name)"
		if ($this.Forms.Count) {
			# [System.Windows.Forms.Form[]]$Forms
			$outputBuffer += "Forms ($($this.Forms.Count)): "
			for ($i = 0; $i -lt $this.Forms.Count; $i++) {
				try {
					# [int]$FormIndex
					$form = $this.Forms[$i]
					$outputBuffer += "Window $($this.Name) Form $i) $($form.Name)"
					$outputBuffer += DisplayForm($this.Name, $form)
					# [MenuBar[]]$MenuBar

					$displayMenuBar = $this.MenuBar[$i]
					$displayMenuBar.Name = $this.Name
					$outputBuffer += $displayMenuBar.Display()
				} catch { $null }
			}
		}
		# [System.Windows.Forms.TabControl[]]$TabPage
		# [int]$TabIndex

		# [hashtable]$Components

		# [MarginClass]$Margins
		if ($this.Margins) { $outputBuffer += "Window Margins: $($this.Margins.Display())" }
		# [WindowState]$State
		if ($this.State) { $outputBuffer += "Window State: $($this.State.Display())" }
		# Log File
		if ($this.logFileNameFull) { $outputBuffer += "Window Log File: $($this.logFileNameFull)" }

		return $outputBuffer
	}
}
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Class WindowState." -ForegroundColor Yellow }
class WindowState {
	[ScriptState]$scriptState
	[CommandAction]$command
	[DisplayElement]$display
	[int]$x
	[int]$y

	WindowState() {
		# Write-Host "WindowState Warning, default constructor invoked."
		$this.scriptState = $this.ScriptDefault()
		$this.command = [CommandAction]::new()
		$this.display = [DisplayElement]::new()
		$this.x = -1; $this.y = -1
	}
	WindowState([hashtable]$inputScriptState = $null, $DoInit = $false) {
		# Initialize Data with default values if no data is provided
		# Script State
		if ($null -eq $inputScriptState -or $inputScriptState -isnot [ScriptState]) {
			if ($DoInit) { $this.scriptState = $this.ScriptDefault() }
			# Warning?
		} else {
			$this.scriptState = $inputScriptState
		}
		if ($DoInit) {
			$this.command = [CommandAction]::new()
			$this.display = [DisplayElement]::new()
			$this.x = -1; $this.y = -1
		}
	}
	WindowState($inputScriptState = $null, [CommandAction]$inputCommandResult, $DoInit = $false) {
		# Initialize Data with default values if no data is provided
		if ($null -eq $inputScriptState -or $inputScriptState -isnot [ScriptState]) {
			if ($DoInit) { $this.scriptState = $this.ScriptDefault() }
		} else {
			$this.scriptState = [ScriptState]$inputScriptState
		}
		# Command Result
		if ($null -eq $inputCommandResult -or $inputCommandResult -isnot [CommandAction]) {
			if ($DoInit) { $this.command = [CommandAction]::new() }
		} else {
			$this.command = $inputCommandResult
		}

		if ($DoInit) {
			$this.display = [DisplayElement]::new()
			$this.x = -1; $this.y = -1
		}
	}
	WindowState($inputScriptState = $null, [CommandAction]$inputCommandResult, [DisplayElement]$inputDisplayElement, $DoInit = $false) {
		# Initialize Data with default values if no data is provided
		if ($null -eq $inputScriptState -or $inputScriptState -isnot [ScriptState]) {
			if ($DoInit) { $this.scriptState = $this.ScriptDefault() }
		} else {
			$this.scriptState = $inputScriptState
		}
		# Command Result
		if ($null -eq $inputCommandResult -or $inputCommandResult -isnot [CommandAction]) {
			if ($DoInit) { $this.command = [CommandAction]::new() }
		} else {
			$this.command = $inputCommandResult
		}
		# [DisplayElement]
		if ($null -eq $inputDisplayElement -or $inputDisplayElement -isnot [DisplayElement]) {
			if ($DoInit) { $this.display = [DisplayElement]::new() }
		} else {
			$this.display = $inputDisplayElement
		}
		if ($DoInit) { $this.x = -1; $this.y = -1 }
	}
	[ScriptState] ScriptDefault() {
		$Package = "MacroDM"
		$Module = "" # TODO global?
		$ScriptName = ""
		$Version = ""
		$FunctionName = ""
		$CommandType = "function"
		$MenuName = ""
		$ScriptLineNumber = 0
		$ScriptColumnNumber = 0
		$FormName = ""
		$Options = [PSCustomObject]@{
			Options = $false
		}
		$Arguments = [PSCustomObject]@{}
		$newScriptState = [ScriptState]::new(
			$Package,
			$Module,
			$ScriptName,
			$Version,
			$FunctionName,
			$CommandType,
			$MenuName,
			$ScriptLineNumber,
			$ScriptColumnNumber,
			$FormName,
			$Options,
			$Arguments
		)
		return $newScriptState
	}
	[array] Display() {
		$outputBuffer = @()
		$outputBuffer += "__________________________________________"
		$outputBuffer += "Window State:"
		$outputBuffer += $this.displayHeader
		if ($this.scriptState) { $outputBuffer += $this.scriptState.Display() }
		if ($this.command) { $outputBuffer += $this.command.Display() }
		if ($this.display) { $outputBuffer += $this.display.Display() }
		$outputBuffer += "Window Postion X: $($this.x), Y: $($this.y)"
		return $outputBuffer
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
		Write-Output $window.scriptState.Package  # Output: MacroDM

		# TODO Hold Update this. Create a new WFWindow instance with custom data
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
		Write-Output $windowWithCustomData.state.scriptState.Package  # Output: CustomPackage    }
	}
	# WindowClass
	# $path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\Mdm_WinFormPS\Public\WindowClass.psm1"
	# Write-Host "Exists: $(Test-Path "$path"): $path"
	# . $path @global:combinedParams
	# Import-Module -Name $path
}
#endregion
#region Session, Application and Command Classes
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Class ModuleClass." -ForegroundColor Yellow }
class ModuleClass {
	[string]$Name
	[string]$Path
	[string]$Version
	[string]$Author
	[string]$Description
	[array]$ExportedFunctions
	[array]$ExportedCmdlets
	[array]$ExportedVariables
	[array]$RequiredModules

	# Default Constructor
	ModuleClass() {
		$this.Name = ""
		$this.Path = ""
		$this.Version = ""
		$this.Author = ""
		$this.Description = ""
		$this.ExportedFunctions = @()
		$this.ExportedCmdlets = @()
		$this.ExportedVariables = @()
		$this.RequiredModules = @()
	}

	ModuleClass($module) {
		try {
			$this.Name = $($module.Name)
			$this.Path = $($module.Path)
			$this.Version = $($module.Version)
			$this.Author = $($module.Author)
			$this.Description = $($module.Description)
			$this.ExportedFunctions = $($module.ExportedFunctions)
			$this.ExportedCmdlets = $($module.ExportedCmdlets)
			$this.ExportedVariables = $($module.ExportedVariables)
			$this.RequiredModules = $($module.RequiredModules)		
		} catch {
			Write-Error "Module import failed in $($module.ToString()). $_"
		}
	}

	[array] Display() {
		$outputBuffer = @()
		$outputBuffer += "__________________________________________"
		$outputBuffer += " Module Name: $($this.Name)"
		$outputBuffer += "        Path: $($this.Path)"
		$outputBuffer += "     Version: $($this.Version)"
		$outputBuffer += "      Author: $($this.Author)"
		$outputBuffer += " Description: $($this.Description)"
		$outputBuffer += "    ExportedFunctions: $($this.ExportedFunctions.ToString())"
		$outputBuffer += "    ExportedCmdlets: $($this.ExportedCmdlets.ToString())"
		$outputBuffer += "    ExportedVariables: $($this.ExportedVariables.ToString())"
		$outputBuffer += "    RequiredModules: $($this.RequiredModules.ToString())"
		return $outputBuffer
	}
}
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Class CommandApp." -ForegroundColor Yellow }
class CommandApp {
	# [string]$privateAppName
	[string]$AppName
	[string]$appDirectory
	[string]$title
	[int]$appSequence
	[int]$exitCode
	[string]$projectRootPath
	[string]$moduleRootPath
	[string]$projectRootPathActual
	[CommandAction]$state
	[WindowState]$windowState
	[System.Management.Automation.ErrorRecord]$lastError
	[PSCustomObject]$appArray = @{}
	[string]$logFileNameFull
	[string]$logFilePath
	[string]$logFileName
	[string]$logFileExtension
	[string]$logFileFormat
	[bool]$LogOneFile
	[bool]$logFileCreated
	[PSCustomObject]$logFileNames
	[System.DateTime]$timeStarted
	[System.DateTime]$timeCompleted
	[System.DateTime]$now
	[bool]$InitDone
	[bool]$InitStdDone
	[bool]$InitGuiDone
	[bool]$InitLogFileDone
	[string]$companyName
	[string]$companyNamePrefix
	[string]$author
	[string]$copyright
	[string]$license
	[hashtable]$jobParams
	[bool]$DoVerbose
	[bool]$DoPause
	[bool]$DoDebug
	[bool]$DoForce
	[string]$timeStartedFormatted
	[string[]]$displayHeader

	# Constructor to initialize the properties
	CommandApp() {
		# $this.privateAppName = ""
		$this.AppName = ""
		$this.appDirectory = ""
		$this.title = ""
		$this.appSequence = 0
		$this.exitCode = -1
		$this.projectRootPath = ""
		$this.moduleRootPath = ""
		$this.projectRootPathActual = ""
		$this.windowState = [WindowState]::new()
		$this.lastError = $null
		$this.appArray = @{}
		$this.logFileNameFull = ""
		$this.logFilePath = ""
		$this.logFileName = ""
		$this.logFileExtension = ""
		$this.logFileFormat = "text"
		$this.logOneFile = $false
		$this.logFileCreated = $false
		$this.logFileNames = @{}
		$this.timeStarted = [System.DateTime]::MinValue
		$this.timeStartedFormatted = "{0:yyyyMMdd_HHmmss}" -f $this.timeStarted
		$this.timeCompleted = [System.DateTime]::MinValue
		$this.now = [System.DateTime]::MinValue
		$this.InitDone = $false
		$this.InitStdDone = $false
		$this.InitGuiDone = $false
		$this.InitLogFileDone = $false
		# $this.companyName = "MacroDM"
		# $this.companyNamePrefix = "Mdm"
		# $this.author = "David G. Horsman"
		# $this.copyright = author
		# $this.copyright = "&Copy-Item; copyright. All rights reserved."
		# $this.license = "MIT"
		# Parameters
		# [hashtable]$global:commonParamsPrelude = @{}
		# [hashtable]$global:commonParams = @{}
		# [hashtable]$global:combinedParams = @{}
		# [hashtable]$global:mdmParams = @{}		
		$this.jobParams = @{}
		$this.DoVerbose = $false
		$this.DoPause = $false
		$this.DoDebug = $false
		$this.DoForce = $false
		$this.displayHeader = @()
		$this.CommandAppDefaults()
	}
	# Constructor to initialize the properties
	CommandApp(
		[string]$appName = "",
		[string]$appDirectory = "",
		[string]$title = "",
		[int]$appSequence = 0, 
		[int]$exitCode = -1,
		[WindowState]$windowState = $null,
		$lastError = $null,
		[string]$logFileNameFull = "",
		[System.DateTime]$timeStarted = [System.DateTime]::MinValue,
		[System.DateTime]$timeCompleted = [System.DateTime]::MinValue,
		[hashtable]$jobParams = @{}
	) {
		# $this.privateAppName = $appName
		$this.AppName = $appName
		$this.appDirectory = $appDirectory
		$this.title = $title
		$this.appSequence = $appSequence
		$this.exitCode = $exitCode
		$this.windowState = $windowState
		if (-not $this.windowState) { $this.windowState = [WindowState]::new() }
		$this.lastError = $lastError
		$this.appArray = @{}
		$this.logFileNameFull = $logFileNameFull
		$this.logFilePath = ""
		$this.logFileName = ""
		$this.logFileExtension = ""
		$this.logFileFormat = "text"
		$this.logOneFile = $false
		$this.logFileCreated = $false
		$this.logFileNames = @{}
		$this.timeStarted = $timeStarted
		$this.timeStartedFormatted = "{0:yyyyMMdd_HHmmss}" -f $this.timeStarted
		$this.timeCompleted = $timeCompleted
		$this.now = Get-Date
		$this.jobParams = $jobParams
		$this.DoVerbose = $false
		$this.DoPause = $false
		$this.DoDebug = $false
		$this.DoForce = $false
		$this.displayHeader = @()
		$this.CommandAppDefaults()
		# Public appName property with a getter and setter
	}

	# [string]appName() {
	# 	get {
	# 		return $this.privateAppName
	# 	}
	# 	Set-Variable {
	# 		# You can add validation or logic here if needed
	# 		if ($value -and $value.Length -gt 0) {
	# 			if ($value -ne $this.privateAppName -and $this.privateAppName) {
	# 				# Remove old value
	# 				if ($global:appArray) {
	# 					$global:appArray = $global:appArray | Where-Object { $_ -ne $this.privateAppName }
	# 				}
	# 			}
	# 			$this.privateAppName = $value
	# 			# Update array with new name (and index)
	# 			$global:appArray[$value] = $this
	# 		} else {
	# 			throw "Value cannot be null or empty."
	# 		}
	# 	}
	# 	return $this.privateAppName
	# }

	[void] CommandAppDefaults() {
		# Defaults
		$this.companyName = "MacroDM"
		$this.companyNamePrefix = "Mdm"
		$this.author = "David G. Horsman"
		$this.copyright = $global:author
		$this.copyright = "&Copy-Item; $global:copyright. All rights reserved."
		$this.license = "MIT"
		# $this.displayHeader = Update-StdHeader -app $this
	}

	# Method to display the properties
	[array] Display() {
		<# Action that will repeat until the condition is met #>
		$outputBuffer = @()
		# $outputBuffer += $this.displayHeader
		$outputBuffer += "__________________________________________"
		$outputBuffer += "App Control: $($this.AppName)"
		$outputBuffer += Update-StdHeader -appName $this.AppName
		$outputBuffer += "         Name: $($this.privateAppName)"
		$outputBuffer += " Company Name: $($this.companyName)"
		$outputBuffer += "        Title: $($this.title)"
		$outputBuffer += "     Sequence: $($this.appSequence): Exit Code: $($this.exitCode) Command Name: $($this.CommandName)"
		$outputBuffer += "App Directory: $($this.appDirectory)"
		$outputBuffer += "__________________________________________"
		$outputBuffer += " Command Line: $($this.CommandLine)"
		$outputBuffer += "     Log File: $($this.InitLogFileDone)"
		$outputBuffer += "   Log Exists: $($this.logFileCreated)"
		$outputBuffer += "Initialed: $($this.InitDone)"
		$outputBuffer += "      Std: $($this.InitStdDone)"
		$outputBuffer += "      Gui: $($this.InitGuiDone)"
		$outputBuffer += "      Started: $($this.timeStarted) $($this.timeStartedFormatted)"
		$outputBuffer += "    Completed: $($this.timeCompleted)"
		$outputBuffer += "     Last now: $($this.now)"
		$outputBuffer += "    Exit Code: $($this.exitCode)"
		$outputBuffer += " Project Root Path: $($this.projectRootPath)"
		$outputBuffer += "  Module Root Path: $($this.moduleRootPath)"
		$outputBuffer += "  Actual Root Path: $($this.projectRootPathActual)"
		if ($this.projectRootPathActual -ne $this.projectRootPath) {
			$outputBuffer += "ERROR: Project and Actutal do not match!!!"
		}
		$outputBuffer += $this.windowState.Display()
		$outputBuffer += "Debugging: Pause: $($this.DoPause), Verbose: $($this.DoVerbose), Debug: $($this.DoDebug), Force: $($this.DoForce)"
		$outputBuffer += "__________________________________________"
		$outputBuffer += "Company Name Prefix: $($this.companyNamePrefix)"
		$outputBuffer += "             Author: $($this.author)"
		$outputBuffer += "          Copyright: $($this.copyright)"
		$outputBuffer += "            License: $($this.license)"
		$outputBuffer += "         Last Error:$($this.lastError.ToString())"
	
		# $outputBuffer += "       Result: $($this.result)"
		if ($this.logFileNames) {
			$outputBuffer += "LogFiles:"
			foreach ($logFileNameFull in $this.logFileNames) {
				$outputBuffer += "    $logFileNameFull"
			}
		}
		if ($this.standardOutput) {
			$outputBuffer += "Standard Output:"
			foreach ($line in $this.standardOutput) {
				$outputBuffer += "    $line"
			}
		}
		if ($this.errorOutput) {
			$outputBuffer += "Error Output:"
			foreach ($line in $this.errorOutput) {
				$outputBuffer += "    $line"
			}
		}
		# if ($this.result) {
		#     $outputBuffer += "Original Output: $($this.result)"
		# }
		return $outputBuffer
	}
}
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Class ScriptState." -ForegroundColor Yellow }
class ScriptState {
	# TODO Hold
	[string]$Package
	[string]$Module
	[string]$ScriptName
	[string]$Version
	[string]$FunctionName
	[string]$CommandType
	[string]$MenuName
	[int]$ScriptLineNumber
	[int]$ScriptColumnNumber
	[string]$FormName
	[PSCustomObject]$Options
	[PSCustomObject]$Arguments
	[string]$Statement
	[string]$PositionMessage

	ScriptState() {
		$this.Package = "MacroDM"
		$this.Module = ""
		$this.ScriptName = ""
		$this.Version = ""
		$this.FunctionName = ""
		$this.CommandType = ""
		$this.MenuName = ""
		$this.ScriptLineNumber = 0
		$this.ScriptColumnNumber = 0
		$this.FormName = ""
		$this.Options = [PSCustomObject]@{
			Options = $false
		}
		$this.Arguments = @{}
		$this.Statement = ""
		$this.PositionMessage = ""
	}
	
	ScriptState(
		$Package = "MacroDM",
		$Module = "",
		$ScriptName = "",
		$Version = "",
		$FunctionName = "",
		$CommandType = "",
		$MenuName = "",
		$ScriptLineNumber = 0,
		$ScriptColumnNumber = 0,
		$FormName = "",
		$Options = [PSCustomObject]@{
			Options = $false
		},
		$Arguments = @{}
	) {
		$this.Package = $Package
		$this.Module = $Module
		$this.ScriptName = $ScriptName
		$this.Version = $Version
		$this.FunctionName = $FunctionName
		$this.CommandType = $CommandType
		$this.MenuName = $MenuName
		$this.ScriptLineNumber = $ScriptLineNumber
		$this.ScriptColumnNumber = $ScriptColumnNumber
		$this.FormName = $FormName
		$this.Options = $Options
		$this.Arguments = $Arguments
		$this.Statement = ""
		$this.PositionMessage = ""
	}
	[array] Display() {
		$outputBuffer = @()
		$outputBuffer += "__________________________________________"
		$outputBuffer += "Script State:"
		$outputBuffer += "         Script Name: $($this.ScriptName)"
		$outputBuffer += "       Function Name: $($this.FunctionName)"
		$outputBuffer += "                Type: $($this.CommandType)"
		$outputBuffer += "  Script Line Number: $($this.ScriptLineNumber)"
		$outputBuffer += "Script Column Number: $($this.ScriptColumnNumber)"
		$outputBuffer += "Arguments: $($this.Arguments.ToString())"
		$outputBuffer += "__________________________________________"
		$outputBuffer += " Statement: $($this.Statement)"
		$outputBuffer += "  Position: $($this.PositionMessage)"
		$outputBuffer += "__________________________________________"
		$outputBuffer += "Package: $($this.Package)"
		$outputBuffer += " Module: $($this.Module)"
		$outputBuffer += "Version: $($this.Version)"
		$outputBuffer += " Menu Name: $($this.MenuName)"
		$outputBuffer += " Form Name: $($this.FormName)"
		$outputBuffer += "   Options: $($this.Options.ToString())"
		return $outputBuffer
	}
}
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Class PrivateDataInfo." -ForegroundColor Yellow }
class PrivateDataInfo {
	[string]$Name
	[ConsoleColor]$BackgroundColor
	[ConsoleColor]$ForegroundColor
	[int]$CursorSize
	[string]$WindowTitle
	[int]$MaxWindowWidth
	[int]$MaxWindowHeight
	[int]$WindowWidth
	[int]$WindowHeight
	[int]$BufferWidth
	[int]$BufferHeight
	[bool]$CursorVisible
	[PSObject]$PSObject

	# Default Constructor
	PrivateDataInfo() {
		$this.Name = ""
		$this.BackgroundColor = [System.ConsoleColor]::Black
		$this.ForegroundColor = [System.ConsoleColor]::White
		$this.CursorSize = 0
		$this.WindowTitle = ""
		$this.MaxWindowWidth = 0
		$this.MaxWindowHeight = 0
		$this.WindowWidth = 0
		$this.WindowHeight = 0
		$this.BufferWidth = 0
		$this.BufferHeight = 0
		$this.CursorVisible = $false
		$this.PSObject = New-Object PSObject
	}	
	# Constructor that accepts a PrivateData object
	# [System.Management.Automation.Host.InternalHostUserInterface]
	# [System.Management.Automation.Host.PrivateData]
	# PrivateDataInfo([System.Management.Automation.Host.PrivateData]$privateData) {
	# 	$this.BackgroundColor = $privateData.BackgroundColor
	# 	$this.ForegroundColor = $privateData.ForegroundColor
	# 	$this.CursorSize = $privateData.CursorSize
	# 	$this.WindowTitle = $privateData.WindowTitle
	# 	$this.MaxWindowWidth = $privateData.MaxWindowWidth
	# 	$this.MaxWindowHeight = $privateData.MaxWindowHeight
	# 	$this.WindowWidth = $privateData.WindowWidth
	# 	$this.WindowHeight = $privateData.WindowHeight
	# 	$this.BufferWidth = $privateData.BufferWidth
	# 	$this.BufferHeight = $privateData.BufferHeight
	# 	$this.CursorVisible = $privateData.CursorVisible
	# }
	# could be vague/dynamic PrivateDataInfo($privateData)
	PrivateDataInfo([PrivateDataInfo]$privateData) {
		$this.Name = ""
		$this.BackgroundColor = $privateData.BackgroundColor
		$this.ForegroundColor = $privateData.ForegroundColor
		$this.CursorSize = $privateData.CursorSize
		$this.WindowTitle = $privateData.WindowTitle
		$this.MaxWindowWidth = $privateData.MaxWindowWidth
		$this.MaxWindowHeight = $privateData.MaxWindowHeight
		$this.WindowWidth = $privateData.WindowWidth
		$this.WindowHeight = $privateData.WindowHeight
		$this.BufferWidth = $privateData.BufferWidth
		$this.BufferHeight = $privateData.BufferHeight
		$this.CursorVisible = $privateData.CursorVisible
		$this.PSObject = New-Object PSObject
	}

	# # [System.Management.Automation.Host.InternalHostUserInterface]
	# SetFromInternalHostUserInterface([System.Management.Automation.Host.InternalHostUserInterface]$privateData) {
	# }
	# # [System.Management.Automation.Host.PrivateData]
	# SetFromPrivateData([System.Management.Automation.Host.PrivateData]$privateData) {
	# }

	PrivateDataInfo($ModuleName = "", $Filter = "") {
		# This is essential a static method
		# Create an instance of your class
		# Initialize with default values
		if ($global:DoVerbose) { Write-Host "PrivateData: $($ModuleName) $Filter" }
		try {
			# $myClassInstance = [PrivateDataInfo]::new()
			# $myClassInstance = $this
			$this.Name = $ModuleName
			$this.BackgroundColor = [System.ConsoleColor]::Black
			$this.ForegroundColor = [System.ConsoleColor]::White
			$this.CursorSize = 0
			$this.WindowTitle = ""
			$this.MaxWindowWidth = 0
			$this.MaxWindowHeight = 0
			$this.WindowWidth = 0
			$this.WindowHeight = 0
			$this.BufferWidth = 0
			$this.BufferHeight = 0
			$this.CursorVisible = $false
			$this.PSObject = New-Object PSObject
			$this.PSObject.Properties.Add((New-Object PSNoteProperty -ArgumentList "Name", $this.Name))
			# $this.PSObject.Properties = New-Object PSObject
			$modules = $null
			if ($ModuleName) {
				# Get the specified module
				$modules = Get-Module -Name $ModuleName
			}
			# if (-not $modules) {
			# 	# Use the current module
			# 	# -Name $MyInvocation.MyCommand.Module.Name
			# 	$curr1 = $MyInvocation
			# 	$curr2 = $curr1.MyCommand
			# 	$curr3 = $curr2.Module
			# 	$curr4 = $curr3.Name
			# 	$currentModule = Get-Module -Name $curr4
			# 	$modules = $currentModule
			# }
			if (-not $modules) {
				# Get all modules
				if ($global:DoVerbose) { Write-Host "Loading data for all modules." }
				$modules = Get-Module
			}
			# Session Arrays
			if (-not $global:moduleArray) {
				$global:moduleArray = @{}
				$global:moduleSequence = 0
			}
			if ($modules) {
				foreach ($module in $modules) {
					if (-not $global:moduleArray[$module.Name]) {
						$global:moduleSequence++
						$global:moduleArray[$module.Name] = $module
					}
					try {
						if ($module.PrivateData) {
							if ($global:DoVerbose) { Write-Host "Module $($module.Name) PrivateData:" }
							# Update the class properties directly
							foreach ($key in $module.PrivateData.PSObject.Properties.Name) {
								if ($global:DoVerbose) { Write-Host "    Item $($key): $($module.PrivateData.$key)." -ForegroundColor Yellow }
								if ($this.PSObject.Properties[$key]) {
									# If the property exists, update its value
									$this.PSObject.Properties[$key].Value = $module.PrivateData.$key
								} else {
									# If the property does not exist, create it
									$this.PSObject.Properties.Add((New-Object PSNoteProperty -ArgumentList $key, $module.PrivateData.$key))
								}
							}
						} else {
							if ($global:DoVerbose) { Write-Host "Module '$($module.Name)' does not have PrivateData." -ForegroundColor Yellow }
						}
					} catch {
						if ($global:DoVerbose) { Write-Host "Error in Private Data Load Module Data for $($module.Name). $($global:NL)$_" -ForegroundColor Red }
					}
				}
			}
			# Filter the properties based on the keys if a filter is provided
			if ($Filter) {
				$this.PSObject.Properties = $this.PSObject.Properties | Where-Object { $_.Name -like $Filter } | ForEach-Object { @{ $_.Name = $_.Value } }
			}
		} catch {
			if ($global:DoVerbose) { Write-Host "Error in Private Data Load Constructor. $($global:NL)$_" -ForegroundColor Red }
		}
	}
	# Method to display the properties
	[array] Display() {
		$outputBuffer = @()
		$outputBuffer += "__________________________________________"
		$outputBuffer += "PrivateData: $($this.Name)"
		$outputBuffer += "Background Color: $($this.BackgroundColor.ToString())"
		$outputBuffer += "Foreground Color: $($this.ForegroundColor.ToString())"
		$outputBuffer += "Cursor Size: $($this.CursorSize)"
		$outputBuffer += "Window Title: $($this.WindowTitle)"
		$outputBuffer += "Max Window Width: $($this.MaxWindowWidth)"
		$outputBuffer += "Max Window Height: $($this.MaxWindowHeight)"
		$outputBuffer += "Window Width: $($this.WindowWidth)"
		$outputBuffer += "Window Height: $($this.WindowHeight)"
		$outputBuffer += "Buffer Width: $($this.BufferWidth)"
		$outputBuffer += "Buffer Height: $($this.BufferHeight)"
		$outputBuffer += "Cursor Visible: $($this.CursorVisible)"
		return $outputBuffer
	}
}
function PrivateDataInfoTest() {
	# Example usage
	$privateData = (Get-Host).PrivateData
	$privateDataInfo = [PrivateDataInfo]::new($privateData)
	$privateDataInfo.Display()
}
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Class CommandAction." -ForegroundColor Yellow }
class CommandAction {
	[int]$sequence
	[int]$exitCode
	[string]$CommandName
	[string]$CommandLine
	[System.Management.Automation.ScriptBlock]$ScriptBlock
	[WFWindow]$window
	[string]$menuItem
	[string[]]$standardOutput
	[string[]]$errorOutput
	[string[]]$result
	[System.Management.Automation.ErrorRecord]$ErrorPSItem
	[string[]]$logFileName
	[System.DateTime]$timeStarted
	[System.DateTime]$timeCompleted


	# Constructor to initialize the properties
	CommandAction() {
		$this.sequence = 0
		$this.exitCode = -1
		$this.CommandName = $null
		$this.CommandLine = $null
		$this.ScriptBlock = $null
		$this.window = $null
		$this.menuItem = ""
		$this.standardOutput = @()
		$this.errorOutput = @()
		$this.result = @()
		$this.ErrorPSItem = $null
		$this.logFileName = @()
		$this.timeStarted = [System.DateTime]::MinValue
		$this.timeCompleted = [System.DateTime]::MinValue
	}
	# Constructor to initialize the properties
	CommandAction(
		[int]$sequence = 0, 
		[int]$exitCode = -1,
		[string]$CommandName = $null,
		[string]$CommandLine = $null,
		[System.Management.Automation.ScriptBlock]$ScriptBlock = $null,
		[string[]]$standardOutput = @(),
		[string[]]$errorOutput = @(),
		[string[]]$result = @(),
		$ErrorPSItem = $null,
		[string[]]$logFileName = @(),
		[System.DateTime]$timeStarted = [System.DateTime]::MinValue,
		[System.DateTime]$timeCompleted = [System.DateTime]::MinValue
	) {
		$this.sequence = $sequence
		$this.exitCode = $exitCode
		$this.CommandName = $CommandName
		$this.CommandLine = $CommandLine
		$this.ScriptBlock = $ScriptBlock
		$this.window = $null
		$this.menuItem = ""
		$this.standardOutput = $standardOutput
		$this.errorOutput = $errorOutput
		$this.result = $result
		$this.ErrorPSItem = $ErrorPSItem
		$this.logFileName = $logFileName
		$this.timeStarted = $timeStarted
		$this.timeCompleted = $timeCompleted
	}

	# Method to display the properties
	[array] Display() {
		$outputBuffer = @()
		$outputBuffer += "__________________________________________"
		$outputBuffer += "Command Action: $($this.CommandName) "
		$outputBuffer += "     Sequence: $($this.sequence): Exit Code: $($this.exitCode)"
		if ($this.CommandLine) { $outputBuffer += " Command Line: $($this.CommandLine)" }
		if ($this.ScriptBlock) { $outputBuffer += " Script Block: $($this.ScriptBlock)" }
		if ($this.menuItem) { $outputBuffer += "         Menu: $($this.menuItem)" }
		if ($this.window) { $outputBuffer += "       Window: $($this.window.Name)" }
		$outputBuffer += "      Started: $($this.timeStarted)"
		$outputBuffer += "    Completed: $($this.timeCompleted)"
		# $outputBuffer += "       Result: $($this.result)"
		if ($this.logFileName) {
			$outputBuffer += "LogFiles:"
			foreach ($logFileName in $this.logFileName) {
				$outputBuffer += $logFileName
			}
		}
		$outputBuffer += "Log File Name: $($this.logFileName)"
		if ($this.standardOutput) {
			$outputBuffer += "Standard Output:"
			foreach ($line in $this.standardOutput) {
				$outputBuffer += $line
			}
		}
		if ($this.errorOutput) {
			$outputBuffer += "Error Output:"
			foreach ($line in $this.errorOutput) {
				$outputBuffer += $line
			}
		}
		# if ($this.result) {
		#     $outputBuffer += "Original Output: $($this.result)"
		# }
		return $outputBuffer
	}
}
#endregion
#endregion
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Primitives and Local functions." -ForegroundColor Green }
#region local functions
#region System Primitives, Objects and Drawing Shapes Presentation
# [System.hashtable]$HashTable

function DisplayHashTable {
	[CmdletBinding()]
	param (
		[string]$type, 
		[hashtable]$inputHashTable,
		[string]$logFileNameFull = "",
		[switch]$DoForce,
		[switch]$DoVerbose,
		[switch]$DoDebug,
		[switch]$DoPause
	)
	return "Hash Table $($type): $($inputHashTable.ToString())"	
}
# [System.Windows.Forms.Padding]$Padding
function DisplayPadding {
	[CmdletBinding()]
	param (
		[string]$type = "Padding",
		[System.Windows.Forms.Padding]$inputPadding,
		[string]$logFileNameFull = "",
		[switch]$DoForce,
		[switch]$DoVerbose,
		[switch]$DoDebug,
		[switch]$DoPause
	)
	$outputBuffer = "$($type): Left: $($inputPadding.Left), Top: $($inputPadding.Top), Right: $($inputPadding.Right), Bottom: $($inputPadding.Bottom)"
	$outputBuffer
}
# [System.Drawing.Size]$Size
function DisplaySize {
	[CmdletBinding()]
	param (
		[string]$type = "Size",
		[System.Drawing.Size]$inputSize,
		[string]$logFileNameFull = "",
		[switch]$DoForce,
		[switch]$DoVerbose,
		[switch]$DoDebug,
		[switch]$DoPause
	)
	$outputBuffer = "$($type): Left: $($inputSize.Left), Top: $($inputSize.Top), Right: $($inputSize.Right), Bottom: $($inputSize.Bottom)"
	$outputBuffer
}
# [System.Drawing.Point]$Point
function DisplayPoint {
	[CmdletBinding()]
	param (
		[string]$type = "Location",
		[System.Drawing.Point]$inputPoint,
		[string]$logFileNameFull = "",
		[switch]$DoForce,
		[switch]$DoVerbose,
		[switch]$DoDebug,
		[switch]$DoPause
	)
	$outputBuffer = "$($type): X: $($inputPoint.X), Y: $($inputPoint.Y)"
	$outputBuffer
}
# [System.Windows.Forms.Form]$form
function DisplayForm {
	[CmdletBinding()]
	param (
		[string]$type = "Form",
		[System.Windows.Forms.Form]$form,
		[string]$logFileNameFull = "",
		[switch]$DoForce,
		[switch]$DoVerbose,
		[switch]$DoDebug,
		[switch]$DoPause
	)
	$type = "Form $($form.Name) - $($form.Title)"
	$outputBuffer += DisplaySize("Size", $form.Size)
	$type = "Form Location"
	$outputBuffer += DisplayPoint("Size", $form.Location)
	$outputBuffer
}
# [System.Windows.Forms.MenuStrip]$MenuStrip
function DisplayMenuStrip {
	[CmdletBinding()]
	param (
		[string]$type,
		[System.Windows.Forms.MenuStrip]$inputMenuStrip,
		[string]$logFileNameFull = "",
		[switch]$DoForce,
		[switch]$DoVerbose,
		[switch]$DoDebug,
		[switch]$DoPause
	)
	return "Menu Strip $($type): $($inputMenuStrip.ToString())"	
}
# [System.Windows.Forms.ToolStrip]$ToolStrip
function DisplayToolStrip {
	[CmdletBinding()]
	param (
		[string]$type,
		[System.Windows.Forms.ToolStrip]$inputToolStrip,
		[string]$logFileNameFull = "",
		[switch]$DoForce,
		[switch]$DoVerbose,
		[switch]$DoDebug,
		[switch]$DoPause
	)
	return "Tool Strip $($type): $($inputToolStrip.ToString())"	
}
# TODO Hold Etl here and for DisplayXxx() Forms Controls.
#endregion
function Confirm-Verbose {
	<#
    .SYNOPSIS
        Asserts verbose is on.
    .DESCRIPTION
        Should check state.
    .OUTPUTS
        True if verbose is on
    .EXAMPLE
        If (Confirm-Verbose) { $null }
    .NOTES
        I had to experiment to get automatic settings to work.
        Due to platform inconsistencies many admin maintain their own state.
#>
	[CmdletBinding()]
	param ()
	return $global:app.DoVerbose
}
## Customize the prompt
function Set-prompt {
	<#
    .SYNOPSIS
        Set command prompt.
    .DESCRIPTION
        Set command prompt to Module default.
    .OUTPUTS
        none.
    .EXAMPLE
        Set-prompt
#>
	[CmdletBinding()]
	param (
		$prefix = "",
		$body = "",
		$suffix = ""
	)    
	$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
	$principal = [Security.Principal.WindowsPrincipal] $identity
	$adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

	$prefix += if (Test-Path variable: / PSDebugContext) { '[DBG]: ' } else { '' }
	if ($principal.IsInRole($adminRole)) {
		$prefix = "'[ADMIN]':$prefix"
	}
	if (-not $body) { $body = '[MDM]PS ' + $PWD.path }
	$suffix += $(if ($NestedPromptLevel -ge 1) { '>>' }) + '> '
	$prefix = $prefix -join ""
	$suffix = $suffix -join ""
	"${prefix}${body}${suffix}"
}
function Set-DisplayColors {
	[CmdletBinding()]
	param (
		[System.ConsoleColor]$BackgroundColor, # = "Black",
		[System.ConsoleColor]$ForegroundColor, # = "White",
		[System.ConsoleColor]$WarningBackgroundColor, # = "Orange",
		[System.ConsoleColor]$WarningForegroundColor, # = "White",
		[System.ConsoleColor]$ErrorBackgroundColor, # = "Red",
		[System.ConsoleColor]$ErrorForegroundColor, # = "white"
		[switch]$DoUpdatePrivateData
	)
	process {
		Add-Type -AssemblyName PresentationCore
		# Change the color of error and warning text
		# https://sqljana.wordpress.com/2017/03/01/powershell-hate-the-error-text-and-warning-text-colors-change-it/
		if (-not $global:PrivateData) {
			$global:PrivateData = (Get-Host).PrivateData
		}
		if (-not $BackgroundColor -or $ForegroundColor) {
			if ($global:PrivateData.BackgroundColor) {
				[System.ConsoleColor]$global:messageBackgroundColor = Convert-MediaToConsoleColor($global:PrivateData.BackgroundColor)
				[System.ConsoleColor]$global:messageForegroundColor = Convert-MediaToConsoleColor($global:PrivateData.ForegroundColor)
			} else {
				[System.ConsoleColor]$global:messageBackgroundColor = [System.ConsoleColor]::Black
				[System.ConsoleColor]$global:messageForegroundColor = [System.ConsoleColor]::White
			}
		} else {
			[System.ConsoleColor]$global:messageBackgroundColor = $BackgroundColor
			[System.ConsoleColor]$global:messageForegroundColor = $ForegroundColor
		}
		if (-not $WarningBackgroundColor -or $WarningForegroundColor) {
			if ($global:PrivateData.WarningBackgroundColor) {
				[System.ConsoleColor]$global:messageWarningBackgroundColor = Convert-MediaToConsoleColor($global:PrivateData.WarningBackgroundColor)
				[System.ConsoleColor]$global:messageWarningForegroundColor = Convert-MediaToConsoleColor($global:PrivateData.WarningForegroundColor)
			} else {
				[System.ConsoleColor]$global:messageWarningBackgroundColor = [System.ConsoleColor]::Black
				[System.ConsoleColor]$global:messageWarningForegroundColor = [System.ConsoleColor]::Yellow
			}
		} else {
			[System.ConsoleColor]$global:messageWarningBackgroundColor = $messageWarningBackgroundColor
			[System.ConsoleColor]$global:messageWarningForegroundColor = $messageWarningForegroundColor
		}
		if (-not $messageErrorBackgroundColor -or $messageErrorForegroundColor) {
			if ($global:PrivateData.ErrorBackgroundColor) {
				[System.ConsoleColor]$global:messageErrorBackgroundColor = Convert-MediaToConsoleColor($global:PrivateData.ErrorBackgroundColor)
				[System.ConsoleColor]$global:messageErrorForegroundColor = Convert-MediaToConsoleColor($global:PrivateData.ErrorForegroundColor)
			} else {
				[System.ConsoleColor]$global:messageErrorBackgroundColor = [System.ConsoleColor]::Black
				[System.ConsoleColor]$global:messageErrorForegroundColor = [System.ConsoleColor]::Red
			}
		} else {
			[System.ConsoleColor]$global:messageErrorBackgroundColor = $messageErrorBackgroundColor
			[System.ConsoleColor]$global:messageErrorForegroundColor = $messageErrorForegroundColor
		}

		iF ($DoUpdatePrivateData) {
			$global:PrivateData.BackgroundColor = Convert-ConsoleToMediaColor([System.ConsoleColor]$global:messageBackgroundColor)
			$global:PrivateData.ForegroundColor = Convert-ConsoleToMediaColor([System.ConsoleColor]$global:messageForegroundColor)
			$global:PrivateData.WarningBackgroundColor = Convert-ConsoleToMediaColor([System.ConsoleColor]$global:messageWarningBackgroundColor)
			$global:PrivateData.WarningForegroundColor = Convert-ConsoleToMediaColor([System.ConsoleColor]$global:messageWarningForegroundColor)
			$global:PrivateData.ErrorBackgroundColor = Convert-ConsoleToMediaColor([System.ConsoleColor]$global:messageErrorBackgroundColor)
			$global:PrivateData.ErrorForegroundColor = Convert-ConsoleToMediaColor([System.ConsoleColor]$global:messageErrorForegroundColor)
		}
		[System.ConsoleColor]$global:messageStepForegroundColor = [System.ConsoleColor]::Green
		[System.ConsoleColor]$global:messageDetailForegroundColor = [System.ConsoleColor]::Yellow
		[System.ConsoleColor]$global:messageDataForegroundColor = [System.ConsoleColor]::Blue
		$global:global:colorSet = $true

		# Build a blob to return? No.
		# $messageBackgroundColor = $BackgroundColor
		# $messageForegroundColor = $ForegroundColor
		# $messageWarningBackgroundColor = $WarningBackgroundColor
		# $messageWarningForegroundColor = $WarningForegroundColor
		# $messageErrorBackgroundColor = $ErrorBackgroundColor
		# $messageErrorForegroundColor = $ErrorForegroundColor
	}
}
#endregion
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Invoke-XxxXxx functions." -ForegroundColor Green }
#region Invoke-Xxx Library Members
# Wrap Script \lib\script.ps1 files in an Invoke-XxxXxx function pattern
function Invoke-GetParameters {
	$functionParams = $PSBoundParameters
	. "$($(get-item $PSScriptRoot).FullName)\lib\Get-ParametersLib.ps1" @functionParams
	return $result
}
# Export-ModuleMember -Function "Invoke-GetParameters"
    
function Invoke-GetModuleValidated {
	$functionParams = $PSBoundParameters
	. "$($(get-item $PSScriptRoot).FullName)\lib\Get-ModuleValidatedLib.ps1" @functionParams
	return $result
}
# Export-ModuleMember -Function "Invoke-GetModuleValidated"
function Invoke-Project {
	$functionParams = $PSBoundParameters
	. "$($(get-item $PSScriptRoot).FullName)\lib\ProjectLib.ps1" @functionParams
	return $result
}
# Export-ModuleMember -Function "Invoke-Project"
function Invoke-ImportAll {
	$functionParams = $PSBoundParameters
	$actionStep = 0
	. "$($(get-item $PSScriptRoot).FullName)\lib\ImportAllLib.ps1" @functionParams
	return $result
}
# Export-ModuleMember -Function "Invoke-ImportAll"
#endregion
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray public functions." -ForegroundColor Green }
#region external functions
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Get-ErrorNew." -ForegroundColor Yellow }
. "$($(get-item $PSScriptRoot).FullName)\Public\Get-ErrorNew.ps1"
# Export-ModuleMember -Function "Get-ErrorNew"

if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Initialize-Project." -ForegroundColor Yellow }
. "$($(get-item $PSScriptRoot).FullName)\Public\Initialize-project.ps1"
# Export-ModuleMember -Function "Initialize-Project"

if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Import-All." -ForegroundColor Yellow }
. "$($(get-item $PSScriptRoot).FullName)\Public\Import-All.ps1"
# Export-ModuleMember -Function "Import-All"

if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Get-ModuleValidated." -ForegroundColor Yellow }
. "$($(get-item $PSScriptRoot).FullName)\Public\Get-ModuleValidated.ps1"
# Export-ModuleMember -Function "Get-ModuleValidated"

if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Clear-StdGlobals." -ForegroundColor Yellow }
. "$($(get-item $PSScriptRoot).FullName)\Public\Clear-StdGlobals.ps1"
# Export-ModuleMember -Function "Clear-StdGlobals"

if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Confirm-ModuleActive." -ForegroundColor Yellow }
. "$($(get-item $PSScriptRoot).FullName)\Public\Confirm-ModuleActive.ps1"
# Export-ModuleMember -Function "Confirm-ModuleActive"

if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Confirm-ModuleScan." -ForegroundColor Yellow }
. "$($(get-item $PSScriptRoot).FullName)\Public\Confirm-ModuleScan.ps1"
# Export-ModuleMember -Function "Confirm-ModuleScan"

if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Get-AllCommands." -ForegroundColor Yellow }
. "$($(get-item $PSScriptRoot).FullName)\Public\Get-AllCommands.ps1"
# Export-ModuleMember -Function "Get-AllCommands"

if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Get-Assembly." -ForegroundColor Yellow }
. "$($(get-item $PSScriptRoot).FullName)\Public\Get-Assembly.ps1"
# Export-ModuleMember -Function "Get-Assembly"

if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Get-Import." -ForegroundColor Yellow }
. "$($(get-item $PSScriptRoot).FullName)\Public\Get-Import.ps1"
# Export-ModuleMember -Function "Get-Import"

if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Get-JsonData." -ForegroundColor Yellow }
. "$($(get-item $PSScriptRoot).FullName)\Public\Get-JsonData.ps1"
# Export-ModuleMember -Function "Get-JsonData"

if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Join-Hashtable." -ForegroundColor Yellow }
. "$($(get-item $PSScriptRoot).FullName)\Public\Join-Hashtable.ps1"
# Export-ModuleMember -Function "Join-Hashtable"

if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Set-WFTabPage." -ForegroundColor Yellow }
. "$($(get-item $PSScriptRoot).FullName)\Public\Set-WFTabPage.ps1"
# Export-ModuleMember -Function "Set-WFTabPage"

if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Update-WFTextBox." -ForegroundColor Yellow }
. "$($(get-item $PSScriptRoot).FullName)\Public\Update-WFTextBox.ps1"
# Export-ModuleMember -Function "Update-WFTextBox"

#endregion
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray library components." -ForegroundColor Green }
#region Import Module Component files

if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Mdm_Std_Error." }
. "$($(get-item $PSScriptRoot).FullName)\Public\Mdm_Std_Error.ps1"
Export-ModuleMember -Function "Get-ErrorNew"
Export-ModuleMember -Function @(
	# Exceptions Handling
	"Assert-Debug"
	"Get-ErrorLast",
	"Set-ErrorBreakOnLine",
	"Set-ErrorBreakOnFunction",
	"Set-ErrorBreakOnVariable",
	"Get-CallStackFormatted",

	"Debug-Script",
	"Debug-AssertFunction",
	"Debug-SubmitFunction",
	"Write-IndexOutOfBounds"
)
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Mdm_Std_Input." }
. "$($(get-item $PSScriptRoot).FullName)\Public\Mdm_Std_Input.ps1"
Export-ModuleMember -Function @(
	# Waiting & pausing
	"Wait-ForKeyPress",
	"Wait-AnyKey",
	"Wait-CheckDoPause",
	"Wait-YorNorQ"
)
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Mdm_Std_Log." }
. "$($(get-item $PSScriptRoot).FullName)\Public\Mdm_Std_Log.ps1"
Export-ModuleMember -Function @(
	# Etl Log
	"Add-LogText",
	"Add-LogError",
	"Open-LogFile"
)
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Mdm_Std_Module." }
. "$($(get-item $PSScriptRoot).FullName)\Public\Mdm_Std_Module.ps1"
Export-ModuleMember -Function "Initialize-Project"
Export-ModuleMember -Function "Import-All"
Export-ModuleMember -Function "Confirm-ModuleActive"
Export-ModuleMember -Function "Confirm-ModuleScan"
Export-ModuleMember -Function "Get-Assembly"
Export-ModuleMember -Function "Get-Import"
Export-ModuleMember -Function "Get-ModuleValidated"
Export-ModuleMember -Function "PrivateDataInfo"
# Export-ModuleMember -Function "Invoke-GetModuleValidated"
# Export-ModuleMember -Function "Invoke-ImportAll"
Export-ModuleMember -Function @(
	# Scan and feature (cmdlet) selection
	"Export-ModuleMemberScan",
	"Import-These",
	# Module State
	"Confirm-Module",
	"Get-ModulePrivateData",
	"Set-ModulePrivateData",
	"Get-ModuleProperty",
	"Set-ModuleProperty",
	"Get-ModuleConfig",
	"Set-ModuleConfig",
	# Module Status
	"Get-ModuleStatus",
	"Set-ModuleStatus"
)
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Mdm_Std." }
. "$($(get-item $PSScriptRoot).FullName)\Public\Mdm_Std.ps1"
Export-ModuleMember -Function "Clear-StdGlobals"
Export-ModuleMember -Function "Confirm-Verbose"
Export-ModuleMember -Function "Invoke-Project"
Export-ModuleMember -Function @(
	# Mdm_Std_Library
	# Globals
	"Start-Std",
	"Initialize-Std",
	"Initialize-StdGui",
	"Initialize-StdGlobals",
	"Get-StdGlobals",
	"Get-StdStatus", # TODO
	"Set-CommonParametersGlobal",
	"Set-StdGlobals",
	"Reset-StdGlobals",
	"Show-StdGlobals",
	"Update-StdHeader"
)
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Mdm_Std_Script." }
. "$($(get-item $PSScriptRoot).FullName)\Public\Mdm_Std_Script.ps1"
Export-ModuleMember -Function "Get-AllCommands"
Export-ModuleMember -Function "Invoke-GetParameters"
Export-ModuleMember -Function @(
	# This script:
	"Get-Invocation_PSCommandPath",
	"Get-MyCommand_Definition",
	"Get-MyCommand_Invocation",
	"Get-MyCommand_InvocationName",
	"Get-MyCommand_Name",
	"Get-MyCommand_Origin",
	"Get-PSCommandPath",
	"Get-ScriptName",

	# Invoke
	"Invoke-ProcessWithExit",
	"Invoke-ProcessWithTimeout",
	"Invoke-Invoke",
	"Push-ShellPwsh"
	"Update-ProcessTimer",

	# Params
	"Get-ScriptPositionalParameters",
	"Set-CommonParametersGlobal",
	"Set-CommonParameters",

	# Script:
	"Confirm-SecElevated"
	"Set-SecElevated"
)
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Mdm_Std_Convert." }
. "$($(get-item $PSScriptRoot).FullName)\Public\Mdm_Std_Convert.ps1"
Export-ModuleMember -Function @(
	# Etl Transform - Convert
	"ConvertFrom-HashValue",
	"ConvertTo-Text",
	"Get-LineFromFile",
	"ConvertTo-ObjectArray",
	"ConvertTo-EscapedText",
	"ConvertTo-TrimmedText",
	# Convert Colors
	"Convert-ConsoleToMediaColor",
	"Convert-MediaToConsoleColor",
	"Convert-NameToConsoleColor"
)
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Mdm_Std_Etl." }
. "$($(get-item $PSScriptRoot).FullName)\Public\Mdm_Std_Etl.ps1"
Export-ModuleMember -Function "Get-JsonData"
Export-ModuleMember -Function "Join-Hashtable"
Export-ModuleMember -Function @(
	# Etl
	# Etl Load - Path and directory
	"Get-SavedDirectoryName",
	"Set-SavedDirectoryName",
	"Get-FileNamesFromPath",
	"Get-UriFromPath",
	"Set-LocationToPath",
	"Set-LocationToScriptRoot",
	"Set-DirectoryToScriptRoot",
	"Copy-ItemWithProgressDisplay",
	# Scope
	"Get-VariableScoped",
	"Resolve-Variables",
	# Etl Html
	"Write-HtlmData",
	"Get-RobocopyExitMessage"
	# Etl Other
)
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Mdm_Std_Help." }
. "$($(get-item $PSScriptRoot).FullName)\Public\Mdm_Std_Help.ps1"
Export-ModuleMember -Function @(
	# Help
	"Export-Mdm_Help",
	"Export-Help",
	"Write-Mdm_Help",
	"Write-Module_Help",
	"New-HelpHtml",
	# Templates
	"Initialize-TemplateData",
	"Get-Template",
	"ConvertFrom-Template"
)
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Mdm_Std_Search." }
. "$($(get-item $PSScriptRoot).FullName)\Public\Mdm_Std_Search.ps1"
Export-ModuleMember -Function @(
	# Help
	"Search-Directory",
	"Find-FileInDirectory",
	"Search-FileUpDirectory",
	"Search-FileInDirectory",
	"Find-File",
	"Search-StringInFiles"
)
# Mdm_Std_Gui.ps1
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Mdm_Std_Gui." }
Export-ModuleMember -Function "Set-WFTabPage"
Export-ModuleMember -Function "Update-WFTextBox"
Export-ModuleMember -Function @(
	# Mdm_Std_Library
	"Set-DisplayColors",
	"Set-prompt",
	# Form Primitives
	"DisplayPadding",
	"DisplaySize",
	"DisplayPoint",
	"DisplayForm",
	"DisplayMenuStrip",
	"DisplayToolStrip",
	"DisplayHashTable"
)

#endregion
#endregion
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray inline functions." -ForegroundColor Green }
#region local (this) Exports of functions and Classes (here)
# Export-ModuleMember -Function @(
# 	# Mdm_Std_Library
# 	"Set-DisplayColors",
# 	"Set-prompt",
# 	"Confirm-Verbose",
# 	# Form Primitives
# 	"DisplayPadding",
# 	"DisplaySize",
# 	"DisplayPoint",
# 	"DisplayForm",
# 	"DisplayMenuStrip",
# 	"DisplayToolStrip",
# 	"DisplayHashTable"
# )
if ($DoVerbose) {
	Write-Host "Mdm_Std_Libaray Export Classes." -ForegroundColor Green
	$Message = @(
		"CommandApp",
		"CommandAction",
		"DisplayElement",
		"MarginClass",
		"MenuBar",
		"ScriptState",
		"WFWindow",
		"WindowState",
		"PrivateDataInfo"
	)
	Write-Host $Message -ForegroundColor Yellow
}
# Classes
Export-ModuleMember -Variable @(
	"CommandApp",
	"CommandAction",
	"DisplayElement",
	"MarginClass",
	"MenuBar",
	"ScriptState",
	"WFWindow",
	"WindowState",
	"PrivateDataInfo"
)
#endregion
# MAIN
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray initializing globals..." -ForegroundColor Green }
$global:moduleCoreSkip = $false; $global:osCoreLoaded = $true; $global:moduleCoreLoaded = $true
#region Globals:
Set-DisplayColors
# Global settings
if (-not $global:app -or -not $global:app.InitDone) {
	Initialize-StdGlobals -InitStd -DoCheckState -DoSetGlobal -LogOneFile @global:combinedParams
}

# Log
# if (-not $global:app.logFileNameFull) { Open-LogFile -logFileNameFull $logFileNameFull -SkipCreate -DoClear }

# GUI Global Module Members
# WFFormGlobal
# $path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\Mdm_Std_Library\lib\WFFormGlobal.ps1"
# . $path @global:combinedParams
# if (-not $global:app.InitGuiDone) { Initialize-StdGui -DoCheckState }
#endregion
# end { }
if ($DoVerbose) { Write-Host "Mdm_Std_Libaray initialization completed." -ForegroundColor Green }
# Session Arrays
if (-not $global:moduleArray) {
	$global:moduleArray = @{}
	$global:moduleSequence = 0
}
if (-not $global:moduleArray['Mdm_Std_Library']) { $global:moduleArray['Mdm_Std_Library'] = "Imported" }
