function Set-WFButtonLocation {
    param($sender, $e, $controlItem, $x, $y)
    # if (-not $controlItem) { return }
    if ($controlItem) {
        $controlItem.Location = New-Object System.Drawing.Point($x, $y)
        $controlItem.BringToFront()
    }
    return @{
        x = $x
        y = $y
    }
}
function Set-WFButtonLocationBottom {
    param($sender, $e, $x, $y)
    if ($sender -is [WFWindow]) {
        $form = $sender.Forms[$sender.FormIndex]
        $controlItem = $form.Controls["ButtonBar"]
        if (-not $controlItem) { $controlItem = $form.Controls["OkButton"] }
    } elseif ($sender -is [Form]) {
        $form = $sender
        $controlItem = $form.Controls["ButtonBar"]
        if (-not $controlItem) { $controlItem = $form.Controls["OkButton"] }
    } elseif ($sender -is [Control]) {
        $controlItem = $sender
    } elseif ($null -eq $sender) {
        $controlItem = $e
    } else {
        $controlItem = $sender
    }
    $x = $global:displayMargins.Left
    if (-not $form) { $form = Find-WFForm -sender $sender -e $e}    
    $y = $form.Controls['TabControls'].PreferredSize.Height + $global:displayMargins.Top + 10 + 60 # extra space
    # $y = $sender.ClientSize.Height - $controlItem.Height - $global:displayMargins.Bottom - $global:displayMargins.Top - 10 # $margins.Bottom
    $result = Set-WFButtonLocationAll -sender $sender -e $e -x $x -y $y
    return $result
}
function Set-WFButtonLocationAll {
    param($sender, $e, $x, $y)
    process {
        if (-not $x -and -not $y) {
            $controlItem = $sender.Controls["ButtonBar"]
            if (-not $controlItem) { $controlItem = $sender.Controls["OkButton"] }
            $x = $global:displayMargins.Left + 10
            # $y = $sender.Location.Y
            $y = $sender.ClientSize.Height - $global:displayButtonSize.Height - $global:displayMargins.Bottom - $global:displayMargins.Top - 10 # $margins.Bottom
        }
        $buttonBar = $sender.Controls["ButtonBar"]
        if (-not $buttonBar) {
            for ($buttonIndex = 0; $buttonIndex -lt $global:buttonBarUsed.Count; $buttonIndex++) {
                $buttonName = $global:buttonBarUsed[$buttonIndex]
                if ($buttonName -ne "AutoSave") {
                    $button = $sender.Controls[$buttonName]
                    if ($button) { 
                        $result = Set-WFButtonLocation -sender $sender -e $e -controlItem $button -x $x -y $y
                        $x += $global:displayMargins.Left + $global:displayButtonSize.Width + $global:displayMargins.Right

                    }
                }
            }
            # $x = $result.x; $y = $result.y
        } else {
            $result = Set-WFButtonLocation -sender $sender -e $e -controlItem $buttonBar -x $x -y $y
            # $x = $result.x; $y = $result.y
        }
        return $result
        # return @{
        #     x = $x
        #     y = $y
        # }
    }
}
