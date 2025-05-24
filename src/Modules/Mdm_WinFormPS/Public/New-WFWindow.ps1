
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
        [string]$Title,
        [string]$TextInput,
        [array]$Buttons,
        [switch]$DoMenuBar,
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
                $functionParams = @{}
                if ($DoControls) { $functionParams['DoControls'] = $true }
                if ($DoEvents) { $functionParams['DoEvents'] = $true }
                # Menu bar handled in this function
                if ($DoMenuBar) { 
                    $functionParams['DoMenuBar'] = $true 
                    $menuBar = New-WFMenuStrip
                    $menuBar.MenuStrip = (New-Object System.Windows.Forms.MenuStrip)
                    $menuBar.ToolStrip = (New-Object System.Windows.Forms.ToolStrip)
                    $functionParams['menuBar'] = $menuBar 
                }
                if ($Title) { $functionParams['Title'] = $Title }
                if ($margins) { $functionParams['margins'] = $margins }
                if ($Buttons) { $functionParams['Buttons'] = $Buttons }
                if ($state) { $functionParams['state'] = $state }
                [System.Windows.Forms.Form]$form1 = New-WFForm @functionParams
                # -DoControls:$DoControls `
                # -Title:$Title -margins:$margins `
                # -OkButton:$OkButton -CancelButton:$CancelButton `
                # -DoMenuBar:$DoMenuBar -state $state
                [System.Windows.Forms.Form[]]$formsArray = [System.Windows.Forms.Form[]] @([System.Windows.Forms.Form]$form1)
            }
            # if ($DoMenuBar) {
            if (-not $menuBarArray) {
                # [MenuBar[]]$menuBarArray = @([MenuBar]::new((New-Object System.Windows.Forms.MenuStrip), (New-Object System.Windows.Forms.ToolStrip)))
                # [MenuBar[]]$menuBarArray = [MenuBar]::new()
                [MenuBar[]]$menuBarArray = [MenuBar[]] @([MenuBar]$menuBar)
            }
            # }
            if (-not $window) {
                # $window = [WFWindow]::new($formsArray)
                $window = [WFWindow]::new(
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
            # if ($DoMenuBar) {
                # if (-not $menuBar) { [MenuBar]$menuBar = $window.MenuBar[0] }
                # if (-not $menuBar) { [MenuBar]$menuBar = New-WFMenuStrip }
                # $window.MenuBar[0] = [MenuBar]$menuBar
                #      if ($DoControls) {
                #         $window.Forms[0].MainMenuStrip = [System.Windows.Forms.MenuStrip]$window.MenuBar[0].MenuStrip
                #         $window.Forms[0].Controls.Add([System.Windows.Forms.ToolStrip]$window.MenuBar[0].ToolStrip)
                #         $window.Forms[0].Controls.Add([System.Windows.Forms.MenuStrip]$window.MenuBar[0].MenuStrip)
                #     }
            # }
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