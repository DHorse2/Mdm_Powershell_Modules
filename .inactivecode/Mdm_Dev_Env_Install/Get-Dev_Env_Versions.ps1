# Get-Dev_Env_Versions

Function Get-Dev_Env_Versions {
    [CmdletBinding()]
    param (
        [bool]$pauseDo = $true
    )
    begin {}
    process {

        # Dev Env Tool Versions
        # Language mode: FullLanguage needed, Add cert
        # Set-ExecutionPolicy Unrestricted
        # $ExecutionContext.SessionState.LanguageMode = “FullLanguage”
        # $PSScriptRoot
        Write-Host "PSScriptRoot: " -NoNew line
        Write-Host $PSScriptRoot
        # Set-ScriptSecElevated

        # . "$PSScriptRoot\Std_Library.ps1"
        # . $PSScriptRoot\Std_Library.ps1
        # . ".\Std_Library.ps1"
        Import-Module Mdm_Std_Library
        if (Get-Command Wait-AnyKey -ErrorAction SilentlyContinue) {
            Write-Host "Wait-AnyKey loaded successfully." -ForegroundColor Green
        }
        else {
            Write-Host "Error: Wait-AnyKey function not loaded." -ForegroundColor Red
            Write-Host "Trying library path method." -ForegroundColor Red
            $stdLibraryPath = "$PSScriptRoot\Std_Library.ps1"
            if (Test-Path $stdLibraryPath) {
                Write-Host "Loading Std_Library.ps1..." -ForegroundColor Cyan
                . $stdLibraryPath
            }
            else {
                Write-Host "ERROR: Std_Library.ps1 NOT FOUND at $stdLibraryPath" -ForegroundColor Red
                exit
            }
            # exit
        }

        $msgAnykey = "Press any key to continue"
        $msgYorN = "Enter Y to continue or N to exit"
        Wait-YorNorQ $msgYorN

        # Write-Output "################################################################################"
        # Write-Output "Console Window"
        # Get-Host
        Write-Host "################################################################################"
        # $ThisWindow = Get-Host
        powershell -command "(Get-Host).Name"
        Write-Host "################################################################################"
        Write-Host "Path:"
        # Refresh environment PATH for the current session
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
        $env:Path -split ";"
        Write-Host "################################################################################"
        Wait-AnyKey $msgAnykey
        Write-Host "Environment:"
        Get-ChildItem env:
        Write-Host "################################################################################"
        Wait-AnyKey $msgAnykey

        # Powershell
        Write-Host "Powershell version: " -NoNewline
        # powershell -Command "$PSVersionTable.PSVersion"
        # powershell -command "(Get-Variable PSVersionTable -ValueOnly).Name"
        $PSVersionTable.PSVersion
        Write-Host

        # Python
        Write-Host "Python version: " -NoNewline
        python --version
        Write-Host

        # VsCodium 
        Write-Host "VsCodium version: " -NoNewline
        codium --version
        Write-Host

        # VsCode 
        Write-Host "VsCode version: " -NoNewline
        code --version
        Write-Host

        # NodeJs
        Write-Host "Node version: " -NoNewline
        node -v
        Write-Host

        # function Get-PSVersion {
        # Write-Host $PSVersionTable.PSVersion
        # (depreciated) Write-Host pwsh -Version
        # Write-Host $Host.Version
        # powershell -command "(Get-Variable PSVersionTable -ValueOnly).Name"

        #     if (test-path variable:psversiontable) {$psversiontable.psversion} else {[version]"1.0.0.0"}
        # }

        Write-Output "################################################################################"
        Wait-AnyKey $msgAnykey

    }
    end {}
    clean {}
}