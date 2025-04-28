
## psd1 files

    ModuleToProcess
    NestedModules
    GUID
    Author
    CompanyName
    Copyright
    ModuleVersion
    Description
    PowerShellVersion
    PowerShellHostName
    PowerShellHostVersion
    CLRVersion
    DotNetFrameworkVersion
    ProcessorArchitecture
    RequiredModules
    TypesToProcess
    FormatsToProcess
    ScriptsToProcess
    PrivateData
    RequiredAssemblies
    ModuleList
    FileList
    FunctionsToExport
    VariablesToExport
    AliasesToExport
    CmdletsToExport
    DscResourcesToExport
    CompatiblePSEditions
    HelpInfoURI
    RootModule
    DefaultCommandPrefix


## GUID's

PS G:\Script\Powershell\Mdm_Powershell_Modules> [guid]::NewGuid().ToString()
>> 
35796121-0646-475d-a1bb-74d2c8652ee5
PS G:\Script\Powershell\Mdm_Powershell_Modules> [guid]::NewGuid().ToString()
>> 
b024c60f-e202-4254-b278-eaf45d7c2483
PS G:\Script\Powershell\Mdm_Powershell_Modules> [guid]::NewGuid().ToString()
>> 
9ec4db4f-6418-49e9-ad22-4d75ddd267de
PS G:\Script\Powershell\Mdm_Powershell_Modules> [guid]::NewGuid().ToString()
>>
9fc209b3-e0ff-4d67-ab9a-676432e47520
PS G:\Script\Powershell\Mdm_Powershell_Modules>

## Settings
G:\Script\Powershell\Mdm_Powershell_Modules

"C:\Users\{user}}\AppData\Roaming\VSCodium\User\globalStorage\storage.json"

C:\Users\{user}}\.vscode-oss\extensions\ms-vscode.powershell-2025.0.0-universal\modules\


# xml
To export all functions in PowerShell to a PSD (PowerShell Data) file, you can use the Export-Clixml cmdlet, which allows you to export objects to an XML file that can be imported later. However, if you specifically want to export functions, you can retrieve them and then export them.

Here's a step-by-step guide on how to do this:

    Get All Functions: Use the Get-Command cmdlet to retrieve all functions.

    Export to PSD: Use Export-Clixml to export the functions to a file.

Here’s a sample script that accomplishes this:

```powershell

# Get all functions
$functions = Get-Command -CommandType Function

# Export functions to a PSD file
$functions | Export-Clixml -Path "C:\Path\To\Your\Functions.psd"

Importing the Functions Back

To import the functions back from the PSD file, you can use the Import-Clixml cmdlet:

powershell

# Import functions from the PSD file
$importedFunctions = Import-Clixml -Path "C:\Path\To\Your\Functions.psd"

# Define the functions in the current session
foreach ($function in $importedFunctions) {
    $function | Out-Null
}
```

# Search
file to exclude:
help*,log*,.inactive*,doc*

# Help
This command gets the manifest as a hash table, so you can get the keys as properties. The command returns the value of the HelpInfoUri key.
```powershell
PS C:\ps-test>(Invoke-Expression (Get-Content (Get-Module -List NetQos).Path -Raw)).HelpInfoUri
```

# $ExecutionContext Language Mode

    ="FullLanguage"
InvalidOperation: Cannot set property. Property setting is supported only on core types in this language mode.

PS C:\Users\david\Documents\WindowsPowerShell> $ExecutionContext

Host           : System.Management.Automation.Internal.Host.InternalHost
Events         : System.Management.Automation.PSLocalEventManager
InvokeProvider : System.Management.Automation.ProviderIntrinsics
SessionState   : System.Management.Automation.SessionState
InvokeCommand  : System.Management.Automation.CommandInvocationIntrinsics

Set-WinUILanguageOverride -Language de-DE

Check for AppLocker, SRP, or WDAC policies causing the issue. 

Remove __PSLockDownPolicy with:
Remove-Item Env:__PSLockDownPolicy

Reset execution policy:
Set-ExecutionPolicy Unrestricted -Scope CurrentUser

PS> type c:\users\<user>\Documents\WindowsPowerShell\profile.ps1
[System.Console]::WriteLine("This can only run in FullLanguage!")

# Sign file so it is trusted and will run in FullLanguage mode
      Set-AuthenticodeSignature -FilePath .\Profile.ps1 -Certificate $myPolicyCert

# Start a new PowerShell session and run the profile script
C:\Users\<user>\Documents\WindowsPowerShell\profile.ps1 : 
Cannot dot-source this command because it was defined in a different language mode. 
To invoke this command without importing its contents, omit the '.' operator. (YOU CAN"T)

Well, the issue is that PowerShell dot-sources the profile.ps1 file into the default PowerShell session, which must run in ConstrainedLanguage because of the policy.
 
Troubleshoot further by exploring resources similar to the freecine app for managing scripts and settings.

      Get-ExecutionPolicy -List

# Profile

PowerShell profiles are stored in specific locations depending on the user and host application. For the current user and current host, the profile is typically located at 
$Ho on Windows, or 
 ~/.config/powershell/Microsoft.PowerShell_profile.ps1
  on Linux and macOS.

test-path $profile
New-Item -Path $profile -Type File -Force

=================================
Description
Path	
Command to open

Current user – Current host	
$Home\[My ]Documents\PowerShell\Microsoft.PowerShell_profile.ps1	
$profile

Current user – All hosts	
$Home\[My ]Documents\PowerShell\Profile.ps1	
$profile.CurrentUserAllHosts

All Users – Current Host	
$PSHOME\Microsoft.PowerShell_profile.ps1	
$profile.AllUsersCurrentHost

All Users – All Hosts	
$PSHOME\Profile.ps1	
$profile.AllUsersAllHosts
=================================

# Module verbs
Import-Module -name Mdm_Modules -verbose -force
Import-Module -name Mdm_Bootstrap -verbose -force
Import-Module -name Mdm_Std_Library -verbose -force
Import-Module -name Mdm_Dev_Env_Install -verbose -force

# File locations
cd G:\Script\Powershell\src\Mdm_Modules\Mdm_Dev_Env_Install
cd G:\Script\Powershell\src\Mdm_Modules\Mdm_Bootstrap
C:\Users\david\OneDrive\Documents\PowerShell\Modules
C:\Users\david\Documents\WindowsPowerShell\Modules
C:\Program Files\WindowsPowerShell\Modules
C:\Windows\system32\WindowsPowerShell\v1.0\Modules

# PsModulePath:
%ProgramFiles%\WindowsPowerShell\Modules;%ProgramFiles%\PowerShell\7\Modules;%SystemRoot%\system32\WindowsPowerShell\v1.0\Modules;%UserProfile%\Documents\Powershell\Modules;
%PROGRAMFILES(X86)%\WindowsPowerShell\Modules;

# Path:
%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SYSTEMROOT%\System32\OpenSSH\;%USERPROFILE%\AppData\Local\Programs\Ollama;C:\Program Files\Python312\Scripts\;C:\Program Files\Python312\;C:\Program Files\Microsoft VS Code\bin;C:\Program Files\dotnet\;%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\;C:\Program Files\Git\cmd;C:\Program Files\NVIDIA Corporation\NVIDIA app\NvDLISR;C:\Program Files (x86)\NVIDIA Corporation\PhysX\Common;C:\Program Files (x86)\Razer Chroma SDK\bin;C:\Program Files\Razer Chroma SDK\bin;C:\Program Files (x86)\Razer\ChromaBroadcast\bin;C:\Program Files\Razer\ChromaBroadcast\bin;C:\Windows\system32\config\systemprofile\AppData\Local\Microsoft\WindowsApps;C:\Program Files\ImageMagick-7.1.1-Q16-HDRI;C:\Program Files\Microsoft SQL Server\150\Tools\Binn\;C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\;C:\Program Files (x86)\Windows Kits\10\Windows Performance Toolkit\;C:\Program Files\PowerShell\7\;C:\Program Files (x86)\Natural Docs;%NVM_HOME%;%NVM_SYMLINK%;C:\Program Files (x86)\Microsoft Group Policy\Windows 11 October 2023 Update (23H2)\PolicyDefinitions\;

# Import-Module MyFunctions

Remove-Module -name Mdm_Modules -force -verbose
Import-Module -name Mdm_Modules -force -verbose

Remove-Module -name  Mdm_Bootstrap
Import-Module -name  Mdm_Bootstrap

## Help generation
# Module Commands List
Get-Module -ListAvailable
Get-Module -ListAvailable | select ModuleType, Version, Name
Get-Module –ListAvailable >> G:\Script\Powershell\ModuleList.txt
Get-Module –ListAvailable >> G:\Script\Powershell\Mdm_Powershell_Modules\doc\ModuleList.txt

# Get-InstalledModule ...
# Get-Command -module MyFunctions

# Name, type and version
Get-Module Mdm_Modules -ListAvailable | % { $_.ExportedCommands.Values }
# Name only (preferred)
Get-Module Mdm_Modules -ListAvailable | % { $_.ExportedCommands.Values.Name }
# Single line summary
Get-Module Mdm_Modules -ListAvailable | % { $_ }

# Generate help to file.
old (G:\Script\Powershell\Mdm_Powershell_Modules\doc\ModuleCommandList.txt)

Get-Module Mdm_Modules -ListAvailable | % { $_.ExportedCommands.Values } >> ..\Mdm_Modules\help\ModuleCommandList.txt

Get-Module Mdm_Modules -ListAvailable | % { $_.ExportedCommands.Values } >> ..\Mdm_Modules\help\ModuleCommandList_Mdm_Modules.txt

Get-Module Mdm_Std_Library -ListAvailable | % { $_.ExportedCommands.Values } >> ..\Mdm_Modules\help\ModuleCommandList_Mdm_Std_Library.txt 

Get-Module Mdm_Dev_Env_Install -ListAvailable | % { $_.ExportedCommands.Values } >> ..\Mdm_Modules\help\ModuleCommandList_Mdm_Dev_Env_Install.txt 

Get-Module Mdm_Bootstrap -ListAvailable | % { $_.ExportedCommands.Values } >> ..\Mdm_Modules\help\ModuleCommandList_Mdm_Bootstrap.txt 

# incorrect, lists one function
Get-Command -Module MyModule | Group-Object -Property CommandType

# Find all of the available command types
# Get-Command | Group-Object -Property CommandType

# Use this
Get-Command | Group-Object -Property Module

# Now, let’s inspect a function:
Get-Command -Name Add-BitLockerKeyProtector | select -ExpandProperty Definition

[CmdletBinding(SupportsShouldProcess = $True)]Param()
Write-Verbose "This is the common parameter usage -Version within our Helloworld-To-UpperCase function"
if ($PSCmdlet.ShouldContinue("Are you sure on making the helloworld all caps?", "Making uppercase with ToUpper")) {
    # code
}

# PROFILE Locations

PS G:\Script\Powershell> $PSHOME
C:\Program Files\PowerShell\7
PS G:\Script\Powershell> $PROFILE
C:\Users\david\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
PS G:\Script\Powershell> $PROFILE | Select-Object *

AllUsersAllHosts       : C:\Program Files\PowerShell\7\profile.ps1
AllUsersCurrentHost    : C:\Program Files\PowerShell\7\Microsoft.PowerShell_profile.ps1
CurrentUserAllHosts    : C:\Users\david\OneDrive\Documents\PowerShell\profile.ps1
CurrentUserCurrentHost : C:\Users\david\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
Length                 : 77

# Test Path
Test-Path -Path $PROFILE.AllUsersAllHosts
if (!(Test-Path -Path $PROFILE)) {
  New-Item -ItemType File -Path $PROFILE -Force
}

$PROFILE.AllUsersAllHosts
notepad $PROFILE.AllUsersAllHosts
if (!(Test-Path -Path $PROFILE.AllUsersAllHosts)) {
  New-Item -ItemType File -Path $PROFILE.AllUsersAllHosts -Force
}

Invoke-Command -Session $s -FilePath $PROFILE

## Misc
# ExecutionPolicy

[Environment]::SetEnvironmentVariable("YourNewVariableName", "TheStringValueForThisVariable", [System.EnvironmentVariableTarget]::Machine)
Get-ExecutionPolicy
Set-ExecutionPolicy Unrestricted -Scope Process -Force

# Configuration
'''
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Launch index.html",
            "type": "firefox",
            "request": "launch",
            "reAttach": true,
            "file": "${workspaceFolder}/index.html"
        }
    ]
}
$PSDebugPreference = "Continue"
'''

# RestartableSession

https://github.com/mdgrs-mei/RestartableSession
Install-Module -Name RestartableSession -Scope AllUsers
PS C:\Users\david> Install-Module -Name RestartableSession -Scope AllUsers

NuGet provider is required to continue
PowerShellGet requires NuGet provider version '2.8.5.201' or newer to interact with NuGet-based repositories. 
The NuGet provider must be available in 'C:\Program Files\PackageManagement\ProviderAssemblies' or
'C:\Users\david\AppData\Local\PackageManagement\ProviderAssemblies'. 

You can also install the NuGet provider by running

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

Do you want PowerShellGet to install and import the NuGet provider now?
[Y] Yes  [N] No  [S] Suspend  [?] Help (default is "Y"):


# Notes

There are three locations for Powershell Modules.
However this can be referenced using a number of different ways.
This script install to the %ProgramFiles% Module directory.

# Drive and Path:

NOTE on script location: 
This script is found and run in the "Mdm_Bootstrap" module of "Modules"
So the parent directory is the Root Root of this Project's Modules
$scriptPath = Split-Path -Path "$PSScriptRoot" -Parent
.\src\Mdm_Modules\Mdm_Bootstrap
$scriptPath = (get-item $PSScriptRoot ).parent.FullName
$scriptDrive = Split-Path -Path "$scriptPath" -Qualifier
Set-Location $scriptDrive
NOTE: Must be directories to invoke directory creation
NOTE: New-Item doesn't work in priveledged directories
New-Item -ItemType File -Path $destination -Force
Set-Location -Path "$scriptPath"

# Source

$source = "$scriptPath\"

# Destination

This user (CurrentUser);
$destination = "$Home\Documents\PowerShell\Modules"
$destination = "C:\Users\%username%\Documents\WindowsPowerShell\Modules"
C:\Users\david\Documents\WindowsPowerShell\Modules

All computer users (-Scope AllUsers);
$destination = "$Env:ProgramFiles\WindowsPowerShell\Modules"
$destination = "C:\%ProgramFiles%\WindowsPowerShell\Modules"
$destination = "C:\Program Files\WindowsPowerShell\Modules"
C:\Program Files\WindowsPowerShell\Modules

Default folder for built-in modules:
$destination = "C:\Windows\system32\WindowsPowerShell\v1.0\Modules"
$destination = "$PSHOME\Modules"
C:\Windows\system32\WindowsPowerShell\v1.0\Modules

Unknown
Copy-Item -Path ".\Modules\*.*" -Destination "$PSHOME\Modules" -Force

PS G:\Script\Powershell\Mdm_Powershell_Modules> help ?

Name                              Category  Module                    Synopsis
----                              --------  ------                    --------
%                                 Alias                               ForEach-Object
?                                 Alias                               Where-Object
h                                 Alias                               Get-History
r                                 Alias                               Invoke-History

# IDE RUN command
[Running] powershell -ExecutionPolicy ByPass -File "g:\Script\Powershell\Mdm_Powershell_Modules\src\Dev_Env_Install_Modules_Win.ps1"

# HTML

<!-- 
"@
# html { filter: invert(1) hue-rotate(180deg); }
# filter: invert(100%);
# img, picture, video { filter: invert(1) hue-rotate(180deg) }




        .wrapper {
            position: relative;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .circle {
            border-radius: 50%;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .btn {
            width: 15px;
            height: 15px;
            top: 50px;
            background-color: #9d87f5;
            color: #170514;
            border: none;
            padding: 8px 16px;
            border-radius: 50%;
            font-size: 18px;
            cursor: pointer;
        }

-->