# Install-Dev_Env_Win
# MacroDm - David G Horsman
# 23 Mar 25
#
$Global:pauseDo = $true

function Install-Dev_Env_Win {
    [CmdletBinding()]
    param ()
    Import-Module Mdm_Std_Library

    Write-Host "######################"
    Write-Host  "Set or verify the development environment..."
    Write-Host "Script Security Check and Elevate"
    Set-ScriptSecElevated

    # Init
    $msgAnykey = "Press any key to continue."
    $msgYorN = "Enter Y to setup, N to skip, Q to exit."
    # $Global:pauseDo = $true
    $component = "global"
    Set-LocationToPath

    # Start
    Wait-AnyKey -message "Set or verify the development environment. $msgAnykey"

    function ComponentDoOrSkip {
        # function ComponentDoOrSkip ($component, $scriptDo) {
        param ([string] $component)
        param ([string] $scriptDo)
        $prompt = "Setup $component Environment? $msgYorN"
        $response = Wait-YorNorQ -message $prompt
        if ($response -eq "Y") {
            & $scriptDo
        }
        else { Write-Host "$component setup skipped." }
    }

    $component = "OS"
    $prompt = "Setup $component Environment? $msgYorN"
    $response = Wait-YorNorQ -message $prompt
    if ($response -eq "Y") {
        & $PSScriptRoot/Install-Dev_Env_OS_Win.ps1
    }
    else { Write-Host "$component setup skipped." }
    #
    $component = "IDE"
    ComponentDoOrSkip $component "$PSScriptRoot\Install-Dev_Env_IDE_Win.ps1"
    #
    $component = "LLM"
    $response = Wait-YorNorQ -message $prompt
    if ($response -eq "Y") {
        & $PSScriptRoot/Install-Dev_Env_LLM_Win.ps1
    }
    else { Write-Host "$component setup skipped." }
    #
    $component = "VOICE"
    $prompt = "Setup $component Environment? $msgYorN"
    $response = Wait-YorNorQ -message $prompt
    if ($response -eq "Y") {
        & $PSScriptRoot/Install-Dev_Env_Whisper_Win.ps1
    }
    else { Write-Host "$component setup skipped." }
    #
    Wait-AnyKey $msgAnykey
    
}
