function Set-WFButtonLocation {
    param($sender, $e, $controlItem, $x, $y)
    # if (-not $controlItem) { return }
    if ($controlItem) {
        $controlItem.Location = New-Object System.Drawing.Point($x, $y)
        $controlItem.BringToFront()
    }
    # return @{
    #     x = $x
    #     y = $y
    # }
}
function Set-WFButtonLocationBottom {
    param($sender, $e, $x, $y)
    $controlItem = $sender.Controls["ButtonBar"]
    if (-not $controlItem) { $controlItem = $sender.Controls["OkButton"] }
    $x = $global:displayMargins.Left + 10
    $y = $sender.ClientSize.Height - $controlItem.Height - $global:displayMargins.Bottom - $global:displayMargins.Top - 10 # $margins.Bottom
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
            $y = $sender.ClientSize.Height - $controlItem.Height - $global:displayMargins.Bottom - $global:displayMargins.Top - 10 # $margins.Bottom
        }

        $buttonBar = $sender.Controls["ButtonBar"]
        if (-not $buttonBar) {
            $previous = $sender.Controls["PreviousButton"]
            if ($previous) { 
                Set-WFButtonLocation -sender $sender -e $e -controlItem $previous -x $x -y $y
            }
            $ok = $sender.Controls["OkButton"]
            if ($ok) { 
                Set-WFButtonLocation -sender $sender -e $e -controlItem $ok -x $x -y $y 
                $x += 50
            }
            $cancel = $sender.Controls["CancelButton"]
            if ($cancel) { 
                $x += 50
                Set-WFButtonLocation -sender $sender -e $e -controlItem $cancel -x $x -y $y 
            }
            $apply = $sender.Controls["ApplyButton"]
            if ($apply) { 
                $x += 50
                Set-WFButtonLocation -sender $sender -e $e -controlItem $apply -x $x -y $y 
                $x = $result.x; $y = $result.y
            }
            $reset = $sender.Controls["ResetButton"]
            if ($reset) { 
                $x += 50
                Set-WFButtonLocation -sender $sender -e $e -controlItem $reset -x $x -y $y 
                $x = $result.x; $y = $result.y
            }
            $next = $sender.Controls["NextButton"]
            if ($next) { 
                $x += 50
                Set-WFButtonLocation -sender $sender -e $e -controlItem $next -x $x -y $y 
            }
        } else {
            Set-WFButtonLocation -sender $sender -e $e -controlItem $buttonBar -x $x -y $y
        }
        return @{
            x = $x
            y = $y
        }
    }
}
