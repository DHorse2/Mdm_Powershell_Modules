# Wait-CheckPauseDo

function Wait-CheckPauseDo ($variable) {
    # if ($null -eq $variable) {
    #     Write-Output "The variable is null."
    # }
    # else {
    #     Write-Output "The variable is not null."
    # }
    if ([bool] $Global:pauseDo -ne $null) {
        $null
    }
    else {
        $Global:pauseDo = $false
    }
}
#
#############################
#
