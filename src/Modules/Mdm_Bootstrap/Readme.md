# Language Modes

There is an environment variable "__PSLockDownPolicy" that may need to be set to "8". Mine was set at "4" on a Win 10 Home system.

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment]

__PSLockDownPolicy
FullLanguage = 8 & ConstrainedLanguage = 4.

Remove-Item Env:__PSLockDownPolicy
Set-ExecutionPolicy Unrestricted -Scope CurrentUser
$ExecutionContext.SessionState.LanguageMode = “FullLanguage”

The folder includes two registry import files:
    regEnvLanguageModeConstrained.reg
    regEnvLanguageModeFull.reg
If you have permissions you can import "regEnvLanguageModeFull" to the registry.

DevEnv_LanguageMode "Full" will also set it.
DevEnv_LanguageMode ? will display options and documentation on the topic.

## Bootstrapping the Mdm Modules

The bootstrap command will install all the modules:
```powershell
DevEnv_Install_Modules_Win
```

## It has numerous options and switches:
    ```powershell
    [switch]$DoVerbose,
    [switch]$DoPause,
    [switch]$DoDebug,

    [string]$source = "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules",
    [string]$destination = "$env:PROGRAMFILES\WindowsPowerShell\Modules",
    [string]$logFilePath = "G:\Script\Powershell\Mdm_Powershell_Modules\log",
    [string]$logFileName = "Mdm_Installation_Log",
    [switch]$LogOneFile,

    [switch]$SkipHelp,
    [switch]$SkipRegistry,
    [switch]$DoNewWindow,

    [string]$nameFilter = "Mdm_*",
    [string]$companyName = "MacroDM",
    [string]$copyOptions = "/E /FP /nc /ns /np /TEE"
    ```
