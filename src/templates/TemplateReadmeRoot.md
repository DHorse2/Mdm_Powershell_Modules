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
{{File: {{ModuleRootPath}}\XXXX$PSScriptRoot}}
```

```text
{{File: {{ModuleRootPath}}\Mdm_Bootstrap\help\Mdm_DevEnv_Install_Commands.txt}}
```

### Standard Functions

```text
{{File: {{ModuleRootPath}}\Mdm_Bootstrap\help\Mdm_Std_Library_Commands.txt}}
```

### Mdm Bootstrap

```text
{{File: {{ModuleRootPath}}\Mdm_Bootstrap\help\Mdm_Bootstrap_Commands.txt}}
```


## Other stuff
Author: {{Author}}
Companies:
dba MacroDM (2010)  
Macroscope Design Matrix (1986)  
Axion Computer Software (1978)  
Axion Computer Systems (1990)  
