@{
    RootModule           = "Mdm_Modules.psm1"
    ModuleVersion        = "1.0"
    Author               = "David G Horsman"
    CompanyName          = "MacroDM"
    Copyright            = "(c) David G Horsman. All rights reserved."
    Description          = "MacroDm (Mdm) Bootstrap, Installation and Standard functions libarary."
    # GUID = ""
    # Exports
    # FunctionsToExport    = @("")
    # FunctionsToExport    = @(
    # # Mdm_Modules
    # "Get-ModuleProperty", "Set-ModuleProperty",
    # "Get-ModuleConfig", "Set-ModuleConfig",
    # "Get-ModuleStatus", "Set-ModuleStatus",
    # "Build-ModuleExports"
    # )

    # # Mdm_Bootstrap
    # "Initialize-Dev_Env_Win", 
    # "Add-RegistryPath", 
    # "Assert-RegistryValue",
    
    # # Mdm_Dev_Env_Install
    # "Get-Dev_Env_Versions",
    # "Install-Dev_Env_Win",
    # "Install-Dev_Env_IDE_Win", 
    # "Install-Dev_Env_LLM_Win",
    # "Install-Dev_Env_OS_Win",
    # "Install-Dev_Env_Whisper_Win",
    # "Install-Dev_Env_Modules",

    # # Mdm_Std_Library
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
    # "Script_Name",
    # "Get-Command_InvocationName",
    # "Get-Command_Origin",
    # "Get-Command_Name",
    # "Get-Command_Definition",
    # "Get-Invocation_PSCommandPath",
    # "Get-ScriptPositionalParameters",
    # "Get-LastError",
    # "Get-NewError",

    # # Path and directory
    # "Get-FileNamesFromPath",
    # "Set-LocationToPath",
    # "Set-LocationToScriptRoot",
    # "Save-DirectoryName",
    # "Get-DirectoryNameFromSaved",

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
    # )

    # Cmdlets to export from this module.
    # CmdletsToExport      = @()

    # Variables to export from this module.
    # VariablesToExport = "*"

    # Aliases to export from this module.
    # AliasesToExport      = @()

    # DSC resources to export from this module.
    # DscResourcesToExport = @()

    # List of all modules packaged with this module.
    # Specifies all the modules that are packaged with this module. 
    # ModuleList           = @("Mdm_Bootstrap", "Mdm_Std_Library", "Mdm_Dev_Env_Install")
    # Modules to import as nested modules of the module specified in ModuleToProcess

    # NestedModules        = @("Install-Dev_Env_Win.ps1","Mdm_Bootstrap", "Mdm_Std_Library", "Mdm_Dev_Env_Install")
    # NestedModules        = "Mdm_Bootstrap", "Mdm_Std_Library", "Mdm_Dev_Env_Install"

    # Modules that must be imported into the Global environment prior to importing this module
    # RequiredModules      = "Mdm_Bootstrap", "Mdm_Std_Library", "Mdm_Dev_Env_Install"
}