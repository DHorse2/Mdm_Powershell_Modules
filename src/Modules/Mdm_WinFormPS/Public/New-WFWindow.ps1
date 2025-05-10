# Define a wrapper class

Add-Type -AssemblyName "System.Windows.Forms" -ErrorAction 'SilentlyContinue' -ErrorVariable ErrorBeginAddType
Get-Assembly -AssemblyName "System.Windows.Forms"

function WindowStateDefault() {
    return @{
        Package            = "MacroDM"
        Module             = ""
        ScriptName         = ""
        Version            = ""
        FunctionName       = ""
        ScriptLineNumber   = 0
        ScriptColumnNumber = 0
        FormName           = ""
        Options            = [PSCustomObject]@{
            Options = $false
        }
    }
}
class WindowState {
    [hashtable]$data

    WindowState() {
        Write-Host "WindowState Warning, default constructor invoked."
        $this.data = WindowStateDefault
    }
    WindowState([hashtable]$data = $null) {
        # Initialize Data with default values if no data is provided
        if ($null -eq $data) {
            $this.data = WindowStateDefault
        } else {
            $this.data = $data
        }
    }
}
class WFWindow {
    [System.Windows.Forms.Form[]]$forms
    [WindowState]$state

    # Constructor that accepts a form and optional data
    WFWindow() {
        Write-Host "WFWindow Warning, default constructor invoked."
        $this.forms = @()
        $this.state = [WindowState]::new()
    }
    # Constructor that accepts a form and optional data
    WFWindow([System.Windows.Forms.Form[]]$forms, [hashtable]$state = $null) {
        $this.Forms = $forms
        
        # Initialize State with default values if no State is provided
        if ($null -eq $state) {
            $this.State = [WindowState]::new()
        } else {
            $this.State = $state
        }
    }
    Show() {
        foreach ($form in $this.forms) {
            Show-WFForm([System.Windows.Forms.Form]$form)
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
        $window.forms[0].Text = "Form 1"
        $window.forms[1].Text = "Form 2"
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
}
function New-WFWindow {
    [CmdletBinding()]
    param (
        [WFWindow]$window = $null,
        [System.Windows.Forms.Form[]]$formsArray = $null,
        [WindowState]$state = $null
    )
    begin {
        Get-Assembly -AssemblyName "System.Windows.Forms"
    }
    process {
        try {
            if (-not $formsArray) {
                [System.Windows.Forms.Form]$form1 = New-WFForm -OkButton -CancelButton
                [System.Windows.Forms.Form[]]$formsArray = [System.Windows.Forms.Form[]] @([System.Windows.Forms.Form]$form1)
            }
            if (-not $window) {
                $window = [WFWindow]::new($formsArray, $state)
            } else {
                $window.forms = $formsArray
                if ($state) {
                    $window.state = $state
                }
            }
        } catch {
            Add-LogError -IsError -ErrorPSItem $ErrorPSItem "New-WFWindow unable to create window. $_"
        }
    }
    end {
        return [WFWindow]$window
    }
}