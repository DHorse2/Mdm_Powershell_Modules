=============================================
Error in Script: Mdm_Std_Help.ps1, line 907, column 42
Error in Script: Mdm_Std_Help.ps1, line 907, column 42
Unable to process document match { insert for file: G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules\XXXXG:\Script\Powershell\Mdm_Powershell_Modules\src\Modules\Mdm_Std_Library
 For match: {{File: G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules\XXXXG:\Script\Powershell\Mdm_Powershell_Modules\src\Modules\Mdm_Std_Library}}
Details: 
Cannot find path 'G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules\XXXXG:\Script\Powershell\Mdm_Powershell_Modules\src\Modules\Mdm_Std_Library' because it does not exist.
ObjectNotFound: (G:\Script\Powershel…les\Mdm_Std_Library:String) [Get-Content], ItemNotFoundException

Stack trace: 
Function_Name                                   Link                                Calling_Function
-------------                                   ----                                ----------------
Frame[0]: Add-LogError, line 819.               Mdm_Std_Etl.ps1:819:                Mdm_Std_Etl.ps1 at line 760…
Frame[1]: Add-LogText, line 760.                Mdm_Std_Etl.ps1:760:                Mdm_Std_Help.ps1 at line 912…
Frame[2]: ConvertFrom-Template, line 912.       Mdm_Std_Help.ps1:912:               Mdm_Std_Help.ps1 at line 126…
Frame[3]: Export-Mdm_Help, line 126.            Mdm_Std_Help.ps1:126:               DevEnv_Install_Modules_Win.ps1 at line 336…
Frame[4]: DevEnv_Install_Modules_Win, line 336. DevEnv_Install_Modules_Win.ps1:336: None…
=============================================
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
{{File: G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules\XXXXG:\Script\Powershell\Mdm_Powershell_Modules\src\Modules\Mdm_Std_Library}}
```

```text

Module             PSEdition CommandType Name
------             --------- ----------- ----
Mdm_DevEnv_Install              Function Get-DevEnvVersions
Mdm_DevEnv_Install              Function Install-DevEnvModules
Mdm_DevEnv_Install              Function Install-DevEnvWin
Mdm_DevEnv_Install              Function Install-DevEnvIdeWin
Mdm_DevEnv_Install              Function Install-DevEnvLlmWin
Mdm_DevEnv_Install              Function Install-DevEnvOsWin
Mdm_DevEnv_Install              Function Install-DevEnvWhisperWin
Mdm_DevEnv_Install                 Alias Get-Vs


```

### Standard Functions

```text

Module          PSEdition CommandType Name
------          --------- ----------- ----
Mdm_Std_Library              Function Set-DirectoryToScriptRoot
Mdm_Std_Library              Function Get-LineFromFile
Mdm_Std_Library              Function Debug-Script
Mdm_Std_Library              Function Open-LogFile
Mdm_Std_Library              Function ConvertTo-ObjectArray
Mdm_Std_Library              Function Get-DirectoryNameFromSaved
Mdm_Std_Library              Function Get-PSCommandPath
Mdm_Std_Library              Function Set-DisplayColors
Mdm_Std_Library              Function Initialize-StdGlobalsReset
Mdm_Std_Library              Function ConvertTo-TrimmedText
Mdm_Std_Library              Function Get-ScriptName
Mdm_Std_Library              Function Set-ErrorBreakOnFunction
Mdm_Std_Library              Function Assert-Verbose
Mdm_Std_Library              Function Build-HelpHtml
Mdm_Std_Library              Function Get-MyCommand_Origin
Mdm_Std_Library              Function Set-LocationToScriptRoot
Mdm_Std_Library              Function Import-These
Mdm_Std_Library              Function Get-ModuleProperty
Mdm_Std_Library              Function Get-ModuleConfig
Mdm_Std_Library              Function Get-MyCommand_Definition
Mdm_Std_Library              Function Assert-SecElevated
Mdm_Std_Library              Function Export-ModuleMemberScan
Mdm_Std_Library              Function Wait-AnyKey
Mdm_Std_Library              Function Get-MyCommand_Name
Mdm_Std_Library              Function Wait-ForKeyPress
Mdm_Std_Library              Function Search-Directory
Mdm_Std_Library              Function Write-HtlmData
Mdm_Std_Library              Function Get-Template
Mdm_Std_Library              Function Get-Invocation_PSCommandPath
Mdm_Std_Library              Function Write-Mdm_Help
Mdm_Std_Library              Function Set-ModuleStatus
Mdm_Std_Library              Function Initialize-Std
Mdm_Std_Library              Function Set-ErrorBreakOnVariable
Mdm_Std_Library              Function Set-SavedToDirectoryName
Mdm_Std_Library              Function ConvertFrom-HashValue
Mdm_Std_Library              Function Export-Mdm_Help
Mdm_Std_Library              Function Copy-ItemWithProgressDisplay
Mdm_Std_Library              Function Export-Help
Mdm_Std_Library              Function Set-StdGlobals
Mdm_Std_Library              Function Get-MyCommand_InvocationName
Mdm_Std_Library              Function Get-ErrorNew
Mdm_Std_Library              Function Write-Module_Help
Mdm_Std_Library              Function ConvertTo-EscapedText
Mdm_Std_Library              Function Push-ShellPwsh
Mdm_Std_Library              Function Set-ErrorBreakOnLine
Mdm_Std_Library              Function Get-ModuleStatus
Mdm_Std_Library              Function Wait-YorNorQ
Mdm_Std_Library              Function Initialize-TemplateData
Mdm_Std_Library              Function Resolve-Variables
Mdm_Std_Library              Function Get-StdGlobals
Mdm_Std_Library              Function Set-prompt
Mdm_Std_Library              Function Set-ModuleConfig
Mdm_Std_Library              Function Get-ScriptPositionalParameters
Mdm_Std_Library              Function ConvertFrom-Template
Mdm_Std_Library              Function Show-StdGlobals
Mdm_Std_Library              Function Wait-CheckDoPause
Mdm_Std_Library              Function Debug-AssertFunction
Mdm_Std_Library              Function Get-UriFromPath
Mdm_Std_Library              Function Debug-SubmitFunction
Mdm_Std_Library              Function Start-Std
Mdm_Std_Library              Function Get-FileNamesFromPath
Mdm_Std_Library              Function Set-LocationToPath
Mdm_Std_Library              Function Set-ModuleProperty
Mdm_Std_Library              Function ConvertTo-Text
Mdm_Std_Library              Function Get-AllCommands
Mdm_Std_Library              Function Add-LogError
Mdm_Std_Library              Function Add-LogText
Mdm_Std_Library              Function Get-ErrorLast


```

### Mdm Bootstrap

```text

Module        PSEdition CommandType Name
------        --------- ----------- ----
Mdm_Bootstrap              Function Assert-RegistryValue
Mdm_Bootstrap              Function DevEnv_Module_Reset_Func
Mdm_Bootstrap              Function Add-RegistryPath
Mdm_Bootstrap              Function DevEnv_LanguageMode
Mdm_Bootstrap              Function DevEnv_Install_Modules_Win
Mdm_Bootstrap              Function Initialize-Dev_Env_Win


```


## Other stuff
Author: David G. Horsman
Companies:
dba MacroDM (2010)  
Macroscope Design Matrix (1986)  
Axion Computer Software (1978)  
Axion Computer Systems (1990)  

