@{
    RootModule           = "Mdm_Modules.psm1"
    ModuleVersion        = "1.0"
    Author               = "David G Horsman"
    CompanyName          = "MacroDM"
    Copyright            = "(c) David G Horsman. All rights reserved."
    Description          = "MacroDm (Mdm) Bootstrap, Installation and Standard functions libarary."
    # GUID = ""
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Development Environment', 'Development', 'Intialize', 'Powershell', 'Install')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/___/license'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/___/'

            # A URL to an icon representing this module.
            IconUri = 'https://github.com/___/icon.png'

            # ReleaseNotes of this module - our ReleaseNotes are in
            # the file ReleaseNotes.md
            ReleaseNotes = '
    # # Mdm_Bootstrap

    # "Initialize-Dev_Env_Win", 
    # "Add-RegistryPath", 
    # "Assert-RegistryValue",
    
    # # Mdm_DevEnv_Install

    # "Get-DevEnvVersions",
    # "Install-DevEnvWin",
    # "Install-DevEnvIdeWin", 
    # "Install-DevEnvLlmWin",
    # "Install-DevEnvOsWin",
    # "Install-DevEnvWhisperWin",
    # "Install-DevEnvModules",

    # # Mdm_Std_Library

    # # Mdm_Modules
    # "Get-ModuleProperty", "Set-ModuleProperty",
    # "Get-ModuleConfig", "Set-ModuleConfig",
    # "Get-ModuleStatus", "Set-ModuleStatus",
    # "Export-ModuleMemberScan", "Import-These"

    # # Script:
    # "Get-AllCommands",
    # "Initialize-Std",
    # "Script_DoStart",
    # "Initialize-StdGlobalsReset",
    # "Show-StdGlobals",
    # "Set-DisplayColors",
    # "Assert-SecElevated",
    # "Set-SecElevated",
    # "Assert-Verbose",

    # # This script:
    # "Get-PSCommandPath",
    # "Get-ScriptName",
    # "Get-MyCommand_InvocationName",
    # "Get-MyCommand_Origin",
    # "Get-MyCommand_Name",
    # "Get-MyCommand_Definition",
    # "Get-Invocation_PSCommandPath",
    # "Get-ScriptPositionalParameters",
    # "Get-LastError",
    # "Get-NewError",

    # # Path and directory
    # "Get-FileNamesFromPath",
    # "Set-LocationToPath",
    # "Set-LocationToScriptRoot",
    # "Set-SavedToDirectoryName",
    # "Get-DirectoryNameFromSaved",
    # "Copy-ItemWithProgressDisplay",

    # "Set-LocationToPath",
    # "Set-LocationToScriptRoot",
    # "Set-DirectoryToScriptRoot",

    # # Waiting & pausing
    # "Wait-AnyKey",
    # "Wait-CheckDoPause",
    # "Wait-YorNorQ",

    # # Etl
    # "ConvertTo-Text",
    # "ConvertTo-ObjectArray",
    # "ConvertTo-EscapedText",
    # "ConvertTo-TrimedText",
    # "Add-LogText",
    # "Write-HtlmData",
    # "Search-Directory",

    # # Help
    # "Write-Mdm_Help",
    # "Get-Mdm_Help",
    # "Get-HelpHtml",
    # "Export-Help"

    # Exceptions Handling
    # "Get-LastError",
    # "Get-NewError",
    # "Set-ErrorBreakOnLine",
    # "Set-ErrorBreakOnFunction",
    # "Set-ErrorBreakOnVariable",
    # "Script_Debugger"
    # )
            
'

        }

    }

    # Functions to export
    # FunctionsToExport    = @(*)
    # Cmdlets to export from this module.
    # CmdletsToExport      = @(*)
    # Variables to export from this module.
    # VariablesToExport = "*"
    # Aliases to export from this module.
    # AliasesToExport      = @(*)
    # DSC resources to export from this module.
    # DscResourcesToExport = @()

    # Check this (dll)
    # ModuleToProcess = ""

    # List of all modules packaged with this module.
    # Specifies all the modules that are packaged with this module. 
    # ModuleList           = @("Mdm_Bootstrap", "Mdm_Std_Library", "Mdm_DevEnv_Install")

    # Modules to import as nested modules of the module specified in ModuleToProcess
    # NestedModules        = @("Install-DevEnvWin.ps1","Mdm_Bootstrap", "Mdm_Std_Library", "Mdm_DevEnv_Install")
    # NestedModules        = "Mdm_Bootstrap", "Mdm_Std_Library", "Mdm_DevEnv_Install"

    # Modules that must be imported into the Global environment prior to importing this module
    # RequiredModules      = "Mdm_Bootstrap", "Mdm_Std_Library", "Mdm_DevEnv_Install"
}