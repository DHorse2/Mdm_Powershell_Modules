# Mdm System Management Modules

## Order of script execution for a new system.

First, from the root directory (here) you can run:
```powershell
. .\GoToBootstrap
```
This will make Mdm_Bootstrap the current directory.

You need to be in the Bootstrap Module Directory.

If the Powershell Language Mode is not Full this can set it:
```powershell
Dev_Env_LanguageMode
```

Then to install these modules:  
```powershell
Dev_Env_Install_Modules_Win
```

If you encounter any conflicts,
for example with local vs previously installed modules,
you can reset the environment with this command:
```powershell
. .\Dev_Module_Import
```
You then run the module install again if it failed. It shouldn't.

This command will prepare windows for the development environment:
```powershell
Initialize-Dev_Env_Win
```

Finally you can install all components:
```powershell
Install-Dev_Env_Win
```

## Modules

### Development Environment Install
```text
CommandType     Name                         Version    Source
-----------     ----                         -------    ------
Function        Install-Dev_Env_Win          1.0        Mdm_Dev_Env_Install
Function        Install-Dev_Env_IDE_Win      1.0        Mdm_Dev_Env_Install
Function        Install-Dev_Env_LLM_Win      1.0        Mdm_Dev_Env_Install
Function        Install-Dev_Env_Whisper_Win  1.0        Mdm_Dev_Env_Install
Function        Get-Dev_Env_Versions         1.0        Mdm_Dev_Env_Install
Function        Install-Dev_Env_OS_Win       1.0        Mdm_Dev_Env_Install
```

### Standard Functions

```text
CommandType     Name                         Version    Source
-----------     ----                         -------    ------
Function        Assert-SecElevated     1.0        Mdm_Std_Library
Function        Build-ModuleExports          1.0        Mdm_Std_Library
Function        Save-DirectoryName           1.0        Mdm_Std_Library
Function        Get-DirectoryNameFromSaved   1.0        Mdm_Std_Library
Function        Set-LocationToPath           1.0        Mdm_Std_Library
Function        Set-LocationToScriptRoot     1.0        Mdm_Std_Library
Function        Get-FileNamesFromPath        1.0        Mdm_Std_Library
Function        Set-SecElevated        1.0        Mdm_Std_Library
Function        Wait-AnyKey                  1.0        Mdm_Std_Library
Function        Wait-CheckDoPause            1.0        Mdm_Std_Library
Function        Wait-YorNorQ       
```

### Mdm Bootstrap

```text
CommandType     Name                         Version    Source
-----------     ----                         -------    ------
Function        Add-RegistryPath             1.0        Mdm_Bootstrap
Function        Set-SecElevated        1.0        Mdm_Bootstrap
Function        Initialize-Dev_Env_Win       1.0        Mdm_Bootstrap
Function        Build-ModuleExports          1.0        Mdm_Bootstrap
Function        Set-DirectoryToScriptRoot    1.0        Mdm_Bootstrap
```



## Other stuff
Author: David G Horsman  
Companies:  
dba MacroDM (2010)  
Macroscope Design Matrix (1986)  
Axion Computer Software (1978)  
Axion Computer Systems (1990)  
