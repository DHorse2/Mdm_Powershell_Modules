[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    $languageMode
)
# Imports
# Normal Import-Module
#     Import-Module Mdm_Std_Library
# This works with uninstalled Modules (both)
$importName = "Mdm_Std_Library"
$scriptPath = (get-item $PSScriptRoot ).parent.FullName
Import-Module -Name "$scriptPath\$importName\$importName" -Force -ErrorAction Stop

Write-Host " Language Mode: $ExecutionContext.SessionState.LanguageMode"
switch ($languageMode) {
    "Full" { $regValue = "8" }
    "Constrained" { $regValue = "4" }
    "Restricted" { $regValue = "1" }
    Default { 
        $logMessage = @( `
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
                "It is often used in environments where untrusted code needs to be executed with limited capabilities."
            " ", `
                "    Restricted - (1) RestrictedLanguage:", `
                "This mode allows only a limited subset of the PowerShell language.", `
                "It is primarily used in environments where security is a concern, and it restricts the use of certain features."
            " ", `
                "    Language (not allowed) - (2) LanguageMode: This is a general placeholder and is not commonly used.", `
                "It may not correspond to a specific mode in typical configurations.", `
                " ", `
                "    NoLanguage (not allowed) - (0) NoLanguage This would disable all scripts (like this one)."
            " " `
        )
        LogText $logMessage
        exit 
    }
}
# Set the command
$regKey = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
$regProperty = "__PSLockDownPolicy"
Set-ItemProperty -Path "Registry::$regPath\$regKey" -Name $regProperty -Value $regValue -Force
