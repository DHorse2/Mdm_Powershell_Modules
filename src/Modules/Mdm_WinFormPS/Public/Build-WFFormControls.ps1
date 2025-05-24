function Build-WFFormControls {
    [CmdletBinding()]
    param (
        [string]$Target = "Window",
        [WFWindow]$window,
        [System.Windows.Forms.Form]$form,
        [int]$formIndex = 0,
        [System.Windows.Forms.TabPage]$tabPage,
        [int]$tabIndex = 0,
        [System.Windows.Forms.GroupBox]$groupBox,
        [string]$groupBoxLabel,
        [hashtable]$jsonData,
        [MarginClass]$margins,
        [string]$Title,
        [string]$TextInput,
        [array]$Buttons,
        [switch]$DoMenuBar,
        [switch]$DoControls,
        [switch]$DoEvents,
        [switch]$DoTabIndex,
        $state = $null
    )
    process {
        try {
            #region Initialize
            $widthMax = 200 # or something
            $yCurr = 10
            if ($Target -eq "Tabs" -and -not $tabPage -and $DoControls) {
                $tabControls = New-Object System.Windows.Forms.TabControl
                $tabPage = New-Object System.Windows.Forms.TabPage
            }
            if (-not $margins) { $margins = [MarginClass]::new() }
            $menuBar = $null
            if (-not $form -and $window.Forms.Count -gt 0) {
                if ($formIndex -and $formIndex -lt $window.Forms.Count) { $window.FormIndex = $formIndex }
                $form = $window.Forms[$window.FormIndex]
                $menuBar = $window.MenuBar[$window.FormIndex]
            }
            if ($state -is [WindowState]) {
                $formState = $state
            } else {
                $formState = [WindowState]::new()
            }
            if ($form) {
                # Styling
                $form.TopMost = $true
                $form.AutoSize = $true
                $form.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
                # $form.Size = New-Object System.Drawing.Size($global:displayWindow.Width, $global:displayWindow.Height)
                # $form.FormBorderStyle = 'FixedDialog'
                $form.FormBorderStyle = 'Sizable'
                # $form.FormBorderStyle = 'SizableToolWindow'
                if ($formState) {
                    if ($formState.x -ge 0 -and $formState.y -ge 0) {
                        $form.StartPosition = 'Manual'
                        $form.Location = New-Object System.Drawing.Point($formState.x, $formState.y)
                    } elseif ($formState -is [WindowState]) {
                        if ($formState.data.Display.Left -ge 0 -and $formState.data.Display.Top -ge 0) {
                            $form.StartPosition = 'Manual'
                            $form.Location = New-Object System.Drawing.Point($formState.data.Display.Left, $formState.data.Display.Top)
                        }
                    }
                } else {
                    # $form.StartPosition = 'CenterScreen'
                    $form.StartPosition = 'WindowsDefaultBounds'
                }
                $yCurr = $form.Location.Y # ignore default above.
                $widthMax = $form.PreferredSize.Width # use the default above.
            }
            #endregion
            # WFFormControls
            $path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\lib\WFFormControls.ps1"
            . $path
            # WFFormButtons
            $path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\lib\WFFormButtons.ps1"
            . $path
            # WFFormEvents
            $path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\lib\WFFormEvents.ps1"
            . $path
        } catch {
            $Message = "Build-WFFormControls: Error loading and creating form controls."
            Add-LogText -Message $Message -IsError
            return $null
        }
    }
    end {
        switch ($Target) {
            "Window" {
                if ($form -and $window.Forms.Count -gt 0) {
                    $window.Forms[$window.FormIndex] = $form
                    if ($DoMenuBar) {
                        $window.$MenuBar[$window.FormIndex] = $menuBar
                    }
                }
                return $window
            }
            "Form" { 
                return $form
            }
            "Tab" {
                $tabControls.TabPages.Add($tab1Page)
                return $tabControls
            }
            Default {
                $Message = "Target for where to place data is incorrect. Window, Form or Tab."
                Add-LogText -Message $Message -IsError
                return $null
            }
        }
    }
}
