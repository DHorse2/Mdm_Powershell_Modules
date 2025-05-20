# Language Modes
Installing and running the bootstrap module requires elevated privileges. These include being "run as" an administrator. However, in addition, Powershell's language mode must be set correctly in the registry.

There is an environment variable "__PSLockDownPolicy" that may need to be set to "8". Mine was set at "4" on a Win 10 Home system.

**Registry key:**

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment]


__PSLockDownPolicy

**Setting:**

FullLanguage = 8 & ConstrainedLanguage = 4.

I set this to FullLanguage (8).


**Searches and code:**

```
Remove-Item Env:__PSLockDownPolicy
Set-ExecutionPolicy Unrestricted -Scope CurrentUser
$ExecutionContext.SessionState.LanguageMode = “FullLanguage”
```

The folder includes two registry import files:

* regEnvLanguageModeConstrained.reg
* regEnvLanguageModeFull.reg

If you have permissions you can import regEnvLanguageModeFull" to the registry.

This command will also set it.
```
DevEnv_LanguageMode "Full"
```

This will display options and documentation on the topic.
```
DevEnv_LanguageMode ?
```

## Bootstrapping the Mdm Modules

The bootstrap command will install all the modules:
```powershell
DevEnv_Install_Modules_Win
```

## Global options and switches

These are found at the top of the Mdm_Std_Library.psm1 file after the module member exports:

    ```powershell
    [string]$global:companyName = "MacroDM"
    [string]$global:companyNamePrefix = "Mdm"
    [string]$global:author = "David G. Horsman"
    [string]$global:copyright = $global:author
    [string]$global:copyright = "&copy; $global:copyright. All rights reserved."
    [string]$global:license = "MIT"
    [string]$global:title = ""
    # Modules array
    [array]$global:moduleNames = @("Mdm_Bootstrap", "Mdm_Std_Library", "Mdm_DevEnv_Install", "Mdm_Modules")
    [array]$global:moduleAddons = @("Mdm_Nightroman_PowerShelf", "Mdm_Springcomp_MyBox", "DevEnv_LanguageMode")

    # Error display handling options:
    [bool]$global:UseTrace = $true
    [bool]$global:UseTraceDetails = $true
    [bool]$global:UseTraceStack = $true
    [bool]$global:DebugProgressFindName = $true
    [int]$global:debugTraceStep = 0
    [string]$global:debugSetting = ""
    # include debug info with warnings
    [bool]$global:UseTraceWarning = $true
    # include full details with warnings
    [bool]$global:UseTraceWarningDetails = $false
    # Built in Powershell based Method:
    [bool]$global:UsePsBreakpoint = $true

    # Set-PSBreakpoint
    # pause on this cmdlet/function name
    [bool]$global:DebugProgressFindName = $true
    [array]$global:debugFunctionNames = @()
    # [array]$global:debugFunctionNames = @("Get-Vs", "Get-DevEnvVersions")
    # [array]$global:debugFunctionNames = @("Get-Vs", "Get-DevEnvVersions", "Add-RegistryPath", "Assert-RegistryValue")
    [string]$global:debugFunctionName = ""
    [bool]$global:DebugInScriptDebugger = $false
    [int]$global:debugFunctioLineNumber = 0
    [string]$global:debugWatchVariable = ""
    [string]$global:debugMode = "Write"
    
    # Control and defaults
    [bool]$global:DoVerbose = $false
    [bool]$global:DoPause = $false
    [bool]$global:DoDebug = $false
    [bool]$global:DoForce = $false
    [string]$global:msgAnykey = ""
    [string]$global:msgYorN = ""
    
    # Color of error and warning text
    $global:opt = (Get-Host).PrivateData
    $global:messageBackgroundColor = [System.ConsoleColor]::Black
    $global:messageForegroundColor = [System.ConsoleColor]::White
    $messageWarningBackgroundColor = [System.ConsoleColor]::Black
    $messageWarningForegroundColor = [System.ConsoleColor]::DarkYellow
    # $messageWarningForegroundColor = [System.ConsoleColor]::White
    $messageErrorBackgroundColor = [System.ConsoleColor]::Black
    $messageErrorForegroundColor = [System.ConsoleColor]::Red

    $global:timeStarted = Get-Date
    $global:timeStartedFormatted = "{0:yyyyMMdd_HHmmss}" -f $global:timeStarted
    $global:timeCompleted = $null
    $global:lastError = $null
    ```
