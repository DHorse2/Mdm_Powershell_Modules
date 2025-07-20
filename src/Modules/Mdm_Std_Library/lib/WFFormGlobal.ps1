
# WFFormGlobal
if ($InitGui -and ($InitForce -or (-not $app -or -not $app.InitGuiDone))) {
	# Application
	# [string]$global:appName = "UserApp"
	# [string]$global:dataSetDirectory = "."
	# [bool]$global:GuiActive = $false
	# [hashtable]$global:appDataArray = New-Object System.Collections.Hashtable
	# [bool]$global:appDataChanged = $false
	[string]$global:fileDialogInitialDirectory = "$($global:moduleRootPath)\$global:appName"
	[string]$global:fileDialogFilter = “Json files (*.json)|*.json|Text files (*.txt)|*.txt|All files (*.*)|*.*”

	# Margin, WFWindow, WindowState
	[WFWindow]$global:window = $null # used to access StatusBar
	[System.Windows.Forms.Form]$global:form = $null # not used anywhere
	[System.Windows.Forms.TabControl]$global:tabControls = $null
	[DisplayElement]$global:displayWindow = [DisplayElement]::new(10, 10, 50, 50)
	[MarginClass]$global:displayMargins = [MarginClass]::new(20, 20, 20, 20)
	$global:displayMargins.UpdatePadding(20, 20, 20, 20)
	[DisplayElement]$global:displaySizeMax = [DisplayElement]::new(0, 0, 800, 600)
	[DisplayElement]$global:displayButtonSize = [DisplayElement]::new(0, 0, 100, 23)
	[System.Windows.Forms.BorderStyle]$global:borderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D

	# Standard Buttons and Actions
	[array]$global:buttonBarUsed = @(
		"AutoSave", 
		"ButtonBar", 
		"PreviousButton", 
		"OkButton", 
		"CancelButton", 
		"ApplyButton", 
		"ResetButton", 
		"NextButton"
	)
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
		Open      = { DoOpenFile }
		Save      = { DoFileSave }
		SaveAs    = { DoFileSaveAs }
		Close     = { DoCloseForm }
		ShowAbout = { DoShowAbout }
		ShowHelp  = { DoShowHelp }
	}
	[hashtable]$global:buttonText = @{
		AutoSave       = "AutoSave"
		ButtonBar      = "ButtonBar"
		StatusBar      = "StatusBar"
		ButtonAction   = "ButtonAction"

		FileMenu       = "File"
		HelpMenu       = "Help"

		PreviousButton = "Previous"
		OkButton       = "Ok"
		CancelButton   = "Cancel"
		ApplyButton    = "Apply"
		ResetButton    = "Reset"
		NextButton     = "Next"
		Open           = "Open"
		Save           = "Save"
		SaveAs         = "Save As"
		Close          = "Close"
		ShowAbout      = "About"
		ShowHelp       = "Help"
	}
	# Menu Action Output
	[string]$global:outputBuffer = ""
	# The output text box of the form
	[System.Windows.Forms.TextBox]$global:ActionOutputTextBox = $null

	if ($app) { $app.InitGuiDone = $true } else { $global:app.InitGuiDone = $true }
}
