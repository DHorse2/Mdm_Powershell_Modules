## Mdm System Management Modules

# Order of script execution for a new system.
Initialize-Dev_Env_Win
Install-Dev_Env_Win

# Development Environment Install
CommandType     Name                         Version    Source
-----------     ----                         -------    ------
Function        Install-Dev_Env_Win          1.0        Mdm_Dev_Env_Install
Function        Install-Dev_Env_IDE_Win      1.0        Mdm_Dev_Env_Install
Function        Install-Dev_Env_LLM_Win      1.0        Mdm_Dev_Env_Install
Function        Install-Dev_Env_Whisper_Win  1.0        Mdm_Dev_Env_Install
Function        Get-Dev_Env_Versions         1.0        Mdm_Dev_Env_Install
Function        Install-Dev_Env_OS_Win       1.0        Mdm_Dev_Env_Install

# Standard Functions
CommandType     Name                         Version    Source
-----------     ----                         -------    ------
Function        Assert-ScriptSecElevated     1.0        Mdm_Std_Library
Function        Build-ModuleExports          1.0        Mdm_Std_Library
Function        Save-DirectoryName           1.0        Mdm_Std_Library
Function        Get-DirectoryNameFromSaved   1.0        Mdm_Std_Library
Function        Set-LocationToPath           1.0        Mdm_Std_Library
Function        Set-LocationToScriptRoot     1.0        Mdm_Std_Library
Function        Get-FileNamesFromPath        1.0        Mdm_Std_Library
Function        Set-ScriptSecElevated        1.0        Mdm_Std_Library
Function        Wait-AnyKey                  1.0        Mdm_Std_Library
Function        Wait-CheckDoPause            1.0        Mdm_Std_Library
Function        Wait-YorNorQ       

# Mdm Bootstrap
Loades all these PowerShell scripts

CommandType     Name                         Version    Source
-----------     ----                         -------    ------
Function        Add-RegistryPath             1.0        Mdm_Bootstrap
Function        Set-ScriptSecElevated        1.0        Mdm_Bootstrap
Function        Initialize-Dev_Env_Win       1.0        Mdm_Bootstrap
Function        Build-ModuleExports          1.0        Mdm_Bootstrap
Function        Set-DirectoryToScriptRoot    1.0        Mdm_Bootstrap



# Other stuff
Author: David G Horsman
Companies:
dba MacroDM (2010)
Macroscope Design Matrix (1986)
Axion Computer Software (1978)
Axion Computer Systems (1990)
