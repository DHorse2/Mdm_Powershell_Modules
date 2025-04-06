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
    FunctionsToExport    = 
    # Mdm_Modules
    "Get-ModuleProperty", "Set-ModuleProperty",
    "Get-ModuleConfig", "Set-ModuleConfig",
    "Get-ModuleStatus", "Set-ModuleStatus",
    "Build-ModuleExports",

    # Mdm_Bootstrap
    "Initialize-Dev_Env_Win", 
    "Add-RegistryPath", 
    "Assert-RegistryValue",
    
    # Mdm_Dev_Env_Install
    "Get-Dev_Env_Versions",
    "Install-Dev_Env_Win",
    "Install-Dev_Env_IDE_Win", 
    "Install-Dev_Env_LLM_Win",
    "Install-Dev_Env_OS_Win",
    "Install-Dev_Env_Whisper_Win",
    "Install-Dev_Env_Modules",

    # Mdm_Std_Library
    # Script:
    "Initialize_Std",
    "Script_DoStart",
    "Script_ResetStdGlobals",
    "Script_DisplayStdGlobals",
    "Set-DisplayColors",
    "Assert-ScriptSecElevated",
    "Set-ScriptSecElevated",
    "Assert-Verbose",
    # This script:
    "My_PSCommandPath",
    "Script_Name",
    "My_Command_InvocationName",
    "My_Command_Orgin",
    "My_Command_Name",
    "My_Command_Definition",
    "My_InvocationMy_PSCommandPath",
    "Script_List_Positional_Parameters",
    "Script_Last_Error",
    "Script_Write_Error",

    # Path and directory
    "Get-FileNamesFromPath",
    "Set-LocationToPath",
    "Set-LocationToScriptRoot",
    "Save-DirectoryName",
    "Get-DirectoryNameFromSaved",

    "Set-LocationToPath",
    "Set-LocationToScriptRoot",
    "Set-DirectoryToScriptRoot",
    # Waiting & pausing
    "Wait-AnyKey",
    "Wait-CheckDoPause",
    "Wait-YorNorQ",

    # Etl
    "ExtractText",
    "PackTextArray",
    "EscapeText",
    "TrimText",
    "LogText",
    "Write-HtlmData",
    "Search-Dir",

    # Help
    "Write-Mdm_Help",
    "Get-Mdm_Help",
    "Get-HelpHtml",
    "Export-Help"
    # )

    # Cmdlets to export from this module.
    CmdletsToExport      = @()

    # Variables to export from this module.
    # VariablesToExport = "*"

    # Aliases to export from this module.
    AliasesToExport      = @()

    # DSC resources to export from this module.
    DscResourcesToExport = @()

    # List of all modules packaged with this module.
    # Specifies all the modules that are packaged with this module. 
    # ModuleList           = @("Mdm_Bootstrap", "Mdm_Std_Library", "Mdm_Dev_Env_Install")
    # Modules to import as nested modules of the module specified in ModuleToProcess

    # NestedModules        = @("Install-Dev_Env_Win.ps1","Mdm_Bootstrap", "Mdm_Std_Library", "Mdm_Dev_Env_Install")
    # NestedModules        = "Mdm_Bootstrap", "Mdm_Std_Library", "Mdm_Dev_Env_Install"

    # Modules that must be imported into the Global environment prior to importing this module
    # RequiredModules      = "Mdm_Bootstrap", "Mdm_Std_Library", "Mdm_Dev_Env_Install"
}