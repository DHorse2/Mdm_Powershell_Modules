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
        [Margins]$margins,
        [string]$Title,
        [string]$TextInput,
        [string]$OkButton,
        [string]$CancelButton,
        [switch]$DoMenuBar,
        [switch]$DoControls,
        [switch]$DoTabIndex,
        $state = $null

    )
    process {
        try {
            $widthMax = 200 # or something
            if ($Target -eq "Tabs" -and -not $tabPage -and $DoControls) {
                $tabControls = New-Object System.Windows.Forms.TabControl
                $tabPage = New-Object System.Windows.Forms.TabPage
            }
            if (-not $margins) { $margins = [Margins]::new() }
            $yCurr = 10
            if (-not $form -and $window.Forms.Count -gt 0) {
                if ($formIndex) { $window.FormIndex = $formIndex }
                $form = $window.Forms[$window.FormIndex]
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
            $ok = $null
            $cancel = $null
            $text = $null

            if ($DoMenuBar) {
                [MenuBar]$menuBar = New-WFMenuStrip
                if ($null -ne $form.MainMenuStrip) {
                    Write-Host "The form has a MainMenuStrip."
                } else {
                    Write-Host "The form does not have a MainMenuStrip."
                    $form.MainMenuStrip = [System.Windows.Forms.MenuStrip]::new()
                }
                $form.MainMenuStrip = [System.Windows.Forms.MenuStrip]$menuBar.MenuStrip
                $yCurr += $form.MainMenuStrip.Size.Height
            }
            # if ($menuBar.MenuStrip) {
            #     $form.MainMenuStrip = $menuBar.MenuStrip
            #     $form.Controls.Add($menuBar.MenuStrip)
            # }
            if ($groupBox) {
                if ($window -and $jsonData) {
                    $groupBox = Build-WFCheckBoxList -jsonData $jsonData `
                        -form $window.forms[$formIndex]
                } else {
                    $groupBox = New-Object System.Windows.Forms.groupBoxBox
                    $groupBox.Text = $groupBoxLabel
                    $groupBox.Location = New-Object System.Drawing.Point($margins.Left, $yCurr)
                    $groupBox.Size = New-Object System.Drawing.Size(365, 20)
                }
                $yCurr += $groupBox.Size.Height
                $widthMax = [Math]::Max($groupBox.Size.Width, $widthMax)
            }
            if ($Target -eq "Tab" -and $DoControls) {
                $tabPage.Controls.Add($groupBox)
            }
            if ($TextInput) {
                # $label = New-Object System.Windows.Forms.Label
                # $label.Location = New-Object System.Drawing.Point(10, 10)
                # $label.Size = New-Object System.Drawing.Size(380, 20)
                # $label.Text = $Prompt
                $text = New-Object System.Windows.Forms.TextBox
                $text.Text = $TextInput
                $text.Location = New-Object System.Drawing.Point($margins.Left, $yCurr)
                $text.Size = New-Object System.Drawing.Size(365, 20)
                $yCurr += $text.Size.Height
                $widthMax = [Math]::Max($text.Size.Width, $widthMax)
            }
            $buttonPosY = $yCurr
            if ($OkButton) {
                $ok = New-Object System.Windows.Forms.Button
                $xTmp = $margins.Left + 200; $yTmp = $buttonPosY
                $ok.Location = New-Object System.Drawing.Point($xTmp, $yTmp)
                $ok.Size = New-Object System.Drawing.Size(75, 23)
                $ok.Text = $OkButton
                # $ok.DialogResult = 'Ok'
                $ok.DialogResult = [System.Windows.Forms.DialogResult]::OK
                $form.AcceptButton = $ok
            }
            if ($CancelButton) {
                $cancel = New-Object System.Windows.Forms.Button
                $xTmp = $margins.Left + 300; $yTmp = $buttonPosY
                $cancel.Location = New-Object System.Drawing.Point($xTmp, $yTmp)
                $cancel.Size = New-Object System.Drawing.Size(75, 23)
                $cancel.Text = $CancelButton
                $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            }
            # TODO NextButton
            # TODO PreviousButton (Back)
            if ($OkButton -or $CancelButton) {
                $yCurr += [Math]::Max($OkButton.Size.Height, $CancelButton.Size.Height)
                $form.Add_Resize({
                    if ($OkButton) {
                        $xTmp = $margins.Left + 200; $yTmp = $window.ClientSize.Height - $ok.Height - $margins.Bottom
                        $ok.Location = New-Object System.Drawing.Point($xTmp, $yTmp)
                    }
                    if ($CancelButton) {
                        $xTmp = $margins.Left + 300; $yTmp = $window.ClientSize.Height - $cancel.Height - $margin.Bottom
                        $cancel.Location = New-Object System.Drawing.Point($xTmp, $yTmp)
                    }
                })
                
            }
            if ($DoMenuBar) {
                # Add the ToolStrip and MenuStrip from the menuBar to the form
                if ($DoControls -and $null -ne $menuBar.ToolStrip) {
                    $form.Controls.Add($menuBar.ToolStrip)
                }
                if ($DoControls -and $null -ne $menuBar.MenuStrip) {
                    $form.Controls.Add($menuBar.MenuStrip)
                }
            }
            if ($DoControls) {
                if ($groupBox) { $form.Controls.Add($groupBox) }
                # $form.Controls.Add($label)
                if ($TextInput) { $form.Controls.Add($text) }
                if ($OkButton) { $form.Controls.Add($ok) }
                if ($CancelButton) { $form.Controls.Add($cancel) }
            }
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
