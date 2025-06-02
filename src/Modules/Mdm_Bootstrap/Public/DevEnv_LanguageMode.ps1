function DevEnv_LanguageMode {
    [CmdletBinding()]
    param (
        $languageMode
    )
    if (-not $languageMode) { $languageMode = "?" }
    # Imports
    # This works with uninstalled Modules
    $importName = "Mdm_Std_Library"
    # Project settings and paths
    # Get-ModuleRootPath
    $path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Modules\Project.ps1"
    . "$path"
    [string]$source = "$global:projectRootPath\src\Modules"
    $global:moduleRootPath = $source
    $global:projectRootPath = (get-item $global:moduleRootPath).Parent.Parent.FullName
    Import-Module -Name "$global:moduleRootPath\$importName" -Force -ErrorAction Continue

    Write-Host " Language Mode: $ExecutionContext.SessionState.LanguageMode"
    switch ($languageMode) {
        "Full" { $regValue = "8" }
        "Constrained" { $regValue = "4" }
        "Restricted" { $regValue = "1" }
        Default { 
            $Message = @( `
                    "Valid languge modes are: ", `
                    " ", `
                    "    Full - (8) FullLanguage:", `
                    "This mode allows the full use of the PowerShell language and all its features." , `
                    "It is the default mode in most environments where no restrictions are applied.", `
                    " ", `
                    "    Constrained - (4) ConstrainedLanguage:", `
                    "This is the Windows default. Using ""Full"" will reduce system security.", `
                    "This mode allows the execution of PowerShell commands,", `
                    "but restricts access to certain .NET types and members.", `
                    "It is often used in environments where untrusted code needs to be executed with limited capabilities.", `
                    " ", `
                    "    Restricted - (1) RestrictedLanguage:", `
                    "This mode allows only a limited subset of the PowerShell language.", `
                    "It is primarily used in environments where security is a concern, and it restricts the use of certain features.", `
                    " ", `
                    "    Language (not allowed) - (2) LanguageMode: This is a general placeholder and is not commonly used.", `
                    "It may not correspond to a specific mode in typical configurations.", `
                    " ", `
                    "    NoLanguage (not allowed) - (0) NoLanguage This would disable all scripts (like this one).", `
                    " " `
            )
            Add-LogText -Messages $Message
            exit 
        }
    }
    # Set the command
    $regKey = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
    $regProperty = "__PSLockDownPolicy"
    Set-ItemProperty -Path "Registry::$regPath\$regKey" -Name $regProperty -Value $regValue -Force
}
