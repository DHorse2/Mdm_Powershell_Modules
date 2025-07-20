# Mdm System Management Modules

## Order of script execution for a new system.

First, from the root directory (here) you can run:
```powershell
. .\Public\GoToBootstrap
```
This will make Mdm_Bootstrap the current directory.

You need to be in the Bootstrap Module Directory.

If the Powershell Language Mode is not Full this can set it:
```powershell
DevEnv_LanguageMode
```

Then to install these modules:  
```powershell
DevEnv_Install_Modules_Win
```

If you encounter any conflicts,
for example with local vs previously installed modules,
you can reset the environment with this command:
```powershell
. .\DevEnv_Module_Reset
```
You then run the module install again if it failed. It shouldn't.

This command will prepare windows for the development environment:
```powershell
Initialize-Dev_Env_Win
```

Finally you can install all components:
```powershell
Install-DevEnvWin
```

## Modules

### Development Environment Install

```text

Module             PSEdition CommandType Name
------             --------- ----------- ----
Mdm_DevEnv_Install              Function Get-DevEnvVersions
Mdm_DevEnv_Install              Function Install-DevEnvOsWin
Mdm_DevEnv_Install              Function Install-DevEnvModules
Mdm_DevEnv_Install              Function Install-DevEnvIdeWin
Mdm_DevEnv_Install              Function Install-DevEnvLlmWin
Mdm_DevEnv_Install              Function Install-DevEnvWhisperWin
Mdm_DevEnv_Install              Function Install-DevEnvWin
Mdm_DevEnv_Install              Function Install-DevEnv
Mdm_DevEnv_Install              Function DevEnvGui
Mdm_DevEnv_Install              Function Get-JsonData
Mdm_DevEnv_Install                 Alias Get-Vs
Mdm_DevEnv_Install                 Alias IWinLlm
Mdm_DevEnv_Install                 Alias IWinIde
Mdm_DevEnv_Install                 Alias IWinOs
Mdm_DevEnv_Install                 Alias IDevEnv
Mdm_DevEnv_Install                 Alias IDevEnvWin
Mdm_DevEnv_Install              Function Get-DevEnvVersions
Mdm_DevEnv_Install              Function Install-DevEnvOsWin
Mdm_DevEnv_Install              Function Install-DevEnvModules
Mdm_DevEnv_Install              Function Install-DevEnvIdeWin
Mdm_DevEnv_Install              Function Install-DevEnvLlmWin
Mdm_DevEnv_Install              Function Install-DevEnvWhisperWin
Mdm_DevEnv_Install              Function Install-DevEnvWin
Mdm_DevEnv_Install              Function Install-DevEnv
Mdm_DevEnv_Install              Function DevEnvGui
Mdm_DevEnv_Install              Function Get-JsonData
Mdm_DevEnv_Install                 Alias Get-Vs
Mdm_DevEnv_Install                 Alias IWinLlm
Mdm_DevEnv_Install                 Alias IWinIde
Mdm_DevEnv_Install                 Alias IWinOs
Mdm_DevEnv_Install                 Alias IDevEnv
Mdm_DevEnv_Install                 Alias IDevEnvWin


```

### Standard Functions

```text

Module          PSEdition CommandType Name
------          --------- ----------- ----
Mdm_Std_Library              Function Set-prompt
Mdm_Std_Library              Function Set-DisplayColors
Mdm_Std_Library              Function Confirm-Verbose
Mdm_Std_Library              Function Invoke-GetParameters
Mdm_Std_Library              Function Set-prompt
Mdm_Std_Library              Function Set-DisplayColors
Mdm_Std_Library              Function Confirm-Verbose
Mdm_Std_Library              Function Invoke-GetParameters


```

### Mdm Bootstrap

```text

Module        PSEdition CommandType Name
------        --------- ----------- ----
Mdm_Bootstrap              Function DevEnv_LanguageMode
Mdm_Bootstrap              Function Invoke-DevEnv_Module_Reset
Mdm_Bootstrap              Function Get-ModuleRootPath
Mdm_Bootstrap              Function Enter-ModuleRoot
Mdm_Bootstrap              Function Add-RegistryPath
Mdm_Bootstrap              Function DevEnv_Install_Modules_Win
Mdm_Bootstrap              Function Invoke-Update
Mdm_Bootstrap              Function Initialize-Dev_Env_Win
Mdm_Bootstrap              Function Enter-GoToBootstrap
Mdm_Bootstrap              Function Enter-ProjectRoot
Mdm_Bootstrap              Function Invoke-Build
Mdm_Bootstrap              Function Assert-RegistryValue
Mdm_Bootstrap                 Alias Build
Mdm_Bootstrap                 Alias Update
Mdm_Bootstrap                 Alias GoProject
Mdm_Bootstrap                 Alias DevEnvReset
Mdm_Bootstrap                 Alias IDevEnvModules
Mdm_Bootstrap                 Alias GoBootstrap
Mdm_Bootstrap                 Alias GoModule
Mdm_Bootstrap              Function Add-RegistryPath
Mdm_Bootstrap              Function Enter-ProjectRoot
Mdm_Bootstrap              Function Initialize-Dev_Env_Win
Mdm_Bootstrap              Function Enter-GoToBootstrap
Mdm_Bootstrap              Function Enter-ModuleRoot
Mdm_Bootstrap              Function Invoke-DevEnv_Module_Reset
Mdm_Bootstrap              Function Invoke-Build
Mdm_Bootstrap              Function Get-ModuleRootPath
Mdm_Bootstrap              Function Assert-RegistryValue
Mdm_Bootstrap              Function Invoke-Update


```


## Other stuff
Author: David G. Horsman
Companies:
dba MacroDM (2010)  
Macroscope Design Matrix (1986)  
Axion Computer Software (1978)  
Axion Computer Systems (1990)  

