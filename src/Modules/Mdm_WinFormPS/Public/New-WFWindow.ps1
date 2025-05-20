
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
        [string]$Title,
        [string]$TextInput,
        [string]$OkButton,
        [string]$CancelButton,
        [switch]$DoMenuBar,
        [switch]$DoControls,
        [switch]$DoTabIndex,
        $state = $null
    )
    begin {
        Get-Assembly -AssemblyName "System.Windows.Forms"
    }
    process {
        try {
            if (-not $formsArray) {
                [System.Windows.Forms.Form]$form1 = New-WFForm -Title:$Title `
                    -OkButton:$OkButton -CancelButton:$CancelButton `
                    -DoMenuBar:$DoMenuBar -state $state
                [System.Windows.Forms.Form[]]$formsArray = [System.Windows.Forms.Form[]] @([System.Windows.Forms.Form]$form1)
                if ($DoMenuBar) {
                    if (-not $menuBarArray) {
                        # [MenuBar[]]$menuBarArray = @([MenuBar]::new((New-Object System.Windows.Forms.MenuStrip), (New-Object System.Windows.Forms.ToolStrip)))
                        [MenuBar[]]$menuBarArray = [MenuBar]::new()
                        $menuBarArray[0].MenuStrip = (New-Object System.Windows.Forms.MenuStrip)
                        $menuBarArray[0].ToolStrip = (New-Object System.Windows.Forms.ToolStrip)
                    }
                }
            }
            if (-not $window) {
                # $window = [WFWindow]::new($formsArray)
                $window = [WFWindow]::new(
                    [System.Windows.Forms.Form[]]$formsArray, 
                    [MenuBar[]]$menuBarArray,
                    $null,
                    $formIndex, 
                    0,
                    $null, 
                    $null, 
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