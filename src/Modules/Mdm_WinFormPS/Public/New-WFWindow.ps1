
Get-Assembly -AssemblyName "System.Windows.Forms"
# Import-Module Mdm_Std_Library

# WindowClass
# $path = "$global:moduleRootPath\Mdm_WinFormPS\Public\WindowClass.psm1"
# $path = "$($(Get-Item $PSScriptRoot).FullName)\WindowClass.psm1"
# . "$path"
# $path = "$global:moduleRootPath\Mdm_WinFormPS\Public\WindowClass.psm1"
# Import-Module -Name $path

function New-WFWindow {
    [CmdletBinding()]
    param (
        [WFWindow]$window = $null,
        [System.Windows.Forms.Form[]]$formsArray = $null,
        [MenuBar[]]$menuBarArray = $null,
        [int]$formIndex = 0,
        [MarginClass]$margins,
        [string]$Name,
        [string]$Title,
        [string]$TextInput,
        [array]$Buttons,
        [System.Windows.Forms.ToolStripMenuItem[]]$formMenuActions,
        [object[]]$formToolStripActions,
        [MenuBar]$menuBar,
        [switch]$DoMenuBars,
        [switch]$DoAll,
        [switch]$DoControls,
        [switch]$DoEvents,
        # [switch]$DoTabIndex,
        $state = $null
    )
    begin {
        Get-Assembly -AssemblyName "System.Windows.Forms"
    }
    process {
        try {
            if (-not $formsArray) {
                # NOTE: Passing params requires a lot of boilerplate in PS
                $functionParams = @{}
                if ($formMenuActions) { $functionParams['formMenuActions'] = $formMenuActions }
                if ($formToolStripActions) { $functionParams['formToolStripActions'] = $formToolStripActions }
                if (-not $menuBar) {
                    if ($formMenuActions) {
                        [MenuBar]$menuBar = New-WFMenuStrip `
                            -formMenuActions $formMenuActions `
                            -formToolStripActions $formToolStripActions `
                            @functionParams
                    } else {
                        [MenuBar]$menuBar = New-WFMenuStrip @functionParams
                    }
                }
                if ($DoAll -or $DoControls) { $functionParams['DoControls'] = $true }
                if ($DoAll -or $DoEvents) { $functionParams['DoEvents'] = $true }
                # Menu bar handled in this function
                if ($DoMenuBars) { $functionParams['DoMenuBars'] = $true }
                if ($menuBar) { $functionParams['menuBar'] = $menuBar }
                if ($Title) { $functionParams['Title'] = $Title }
                if ($Name) { $functionParams['Name'] = $Name }
                if ($margins) { $functionParams['margins'] = $margins }
                if ($Buttons) { $functionParams['Buttons'] = $Buttons }
                if ($state) { $functionParams['state'] = $state }
                [System.Windows.Forms.Form]$form1 = New-WFForm @functionParams
                # NOTE: This does not work in PS:
                # -Title:$Title -margins:$margins `
                [System.Windows.Forms.Form[]]$formsArray = [System.Windows.Forms.Form[]] @([System.Windows.Forms.Form]$form1)
                [MenuBar[]]$menuBarArray = [MenuBar[]] @([MenuBar]$menuBar)
            }
            # if ($DoMenuBars) {
            if (-not $menuBarArray) {
                # This shouldn't be done regardless but skipping it could be a problem later if turned on.
                if (-not $menuBar) { 
                    if ($formMenuActions) {
                        [MenuBar]$menuBar = New-WFMenuStrip `
                            -formMenuActions $formMenuActions `
                            -formToolStripActions $formToolStripActions `
                            @functionParams
                    } else {
                        [MenuBar]$menuBar = New-WFMenuStrip 
                    }
                }
                [MenuBar[]]$menuBarArray = [MenuBar[]] @([MenuBar]$menuBar)
            }
            # }
            if (-not $Name) { $Name = $global:appName }
            if (-not $window) {
                # $window = [WFWindow]::new($formsArray)
                $window = [WFWindow]::new(
                    $Name,
                    [System.Windows.Forms.Form[]]$formsArray, 
                    [MenuBar[]]$menuBarArray,
                    $null,
                    $formIndex, 
                    0,
                    $null, 
                    $margins, 
                    $state
                )
                
            } else {
                $window.Forms = $formsArray
                $window.MenuBar = $menuBarArray
            }
            if ($state -and $state -is [WindowState]) {
                $window.state = $state
            } elseif ($null -eq $window.state) {
                $window.state = [System.Windows.WindowState]::new()
            }
        } catch {
            Add-LogText -IsError -ErrorPSItem $_ -Message "New-WFWindow: Unable to create window."
        }
    }
    end {
        return [WFWindow]$window
    }
}