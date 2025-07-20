
Get-Assembly -AssemblyName "System.Windows.Forms"
# Import-Module Mdm_Std_Library

# WindowClass
# $path = "$global:moduleRootPath\Mdm_WinFormPS\Public\WindowClass.psm1"
# $path = "$($(Get-Item $PSScriptRoot).FullName)\WindowClass.psm1"
# . $path @global:combinedParams
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
        [string]$Name = "",
        [string]$title = "",
        [string]$TextInput = "",
        [array]$Buttons,
        [System.Windows.Forms.ToolStripMenuItem[]]$formMenuActions,
        [object[]]$formToolStripActions,
        [MenuBar]$menuBar,
        [switch]$DoMenuBars,
        [switch]$DoAll,
        [switch]$DoControls,
        [switch]$DoEvents,
        # [switch]$DoTabIndex,
        [string]$logFileNameFull = "",
        $state = $null
    )
    begin {
        Get-Assembly -AssemblyName "System.Windows.Forms"
    }
    process {
        try {
            if (-not $formsArray) {
                # NOTE: Passing params requires a lot of boilerplate in PS
                $localParams = @{}
                if ($formMenuActions) { $localParams['formMenuActions'] = $formMenuActions }
                if ($formToolStripActions) { $localParams['formToolStripActions'] = $formToolStripActions }
                if (-not $menuBar) {
                    if ($formMenuActions) {
                        [MenuBar]$menuBar = New-WFMenuStrip `
                            -logFileNameFull $logFileNameFull `
                            @localParams

                    } else {
                        [MenuBar]$menuBar = New-WFMenuStrip -logFileNameFull $logFileNameFull
                    }
                }
                if ($DoAll -or $DoControls) { $localParams['DoControls'] = $true }
                if ($DoAll -or $DoEvents) { $localParams['DoEvents'] = $true }
                # Menu bar handled in this function
                if ($DoMenuBars) { $localParams['DoMenuBars'] = $true }
                if ($menuBar) { $localParams['menuBar'] = $menuBar }
                if ($title) { $localParams['Title'] = $title }
                if ($Name) { $localParams['Name'] = $Name }
                if ($margins) { $localParams['margins'] = $margins }
                if ($Buttons) { $localParams['Buttons'] = $Buttons }
                if ($state) { $localParams['state'] = $state }
                [System.Windows.Forms.Form]$form1 = New-WFForm @localParams
                # TODO Hold NOTE: This does not work in PS: # -Title:$title -margins:$margins `
                [System.Windows.Forms.Form[]]$formsArray = [System.Windows.Forms.Form[]] @([System.Windows.Forms.Form]$form1)
                [MenuBar[]]$menuBarArray = [MenuBar[]] @([MenuBar]$menuBar)
            }
            # if ($DoMenuBars) {
            if (-not $menuBarArray) {
                # This shouldn't be done regardless but skipping it could be a problem later if turned on.
                if (-not $menuBar) { 
                    if ($formMenuActions) {
                        [MenuBar]$menuBar = New-WFMenuStrip `
                            -logFileNameFull $logFileNameFull `
                            @localParams
                    } else {
                        [MenuBar]$menuBar = New-WFMenuStrip -logFileNameFull $logFileNameFull
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
                    $state,
                    $logFileNameFull
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
            $Message = "New-WFWindow: Unable to create window."
            Add-LogText -IsError -ErrorPSItem $_ -Message $Message -logFileNameFull $logFileNameFull
        }
    }
    end {
        return [WFWindow]$window
    }
}