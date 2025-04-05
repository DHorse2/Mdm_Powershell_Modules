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

    # Mdm_Bootstrap
    "Initialize-Dev_Env_Win", 
    "Add-RegistryPath", 
    "Set-ScriptSecElevated",
    
    # Mdm_Dev_Env_Install
    "Get-Dev_Env_Versions",
    "Install-Dev_Env_Win",
    "Install-Dev_Env_IDE_Win", 
    "Install-Dev_Env_LLM_Win",
    "Install-Dev_Env_OS_Win",
    "Install-Dev_Env_Whisper_Win",

    # Mdm_Std_Library
    "Script_Initialize_Std",
    "Script_ResetStdGlobals",

    "Assert-ScriptSecElevated",
    "Assert-Verbose",
    "Build-ModuleExports",
    "Get-DirectoryNameFromSaved",
    "Get-FileNamesFromPath",
    "Save-DirectoryName",
    "Set-DisplayColors",
    "Set-LocationToPath",
    "Set-LocationToScriptRoot",
    "Set-ScriptSecElevated",
    #       Waiting & pausing
    "Wait-AnyKey",
    "Wait-CheckDoPause",
    "Wait-YorNorQ",

    #       This script:
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
    # More
    "Show-Data",
    "Search-Dir",
    "Script_DoStart",

    "Write-Mdm_Help",
    "Get-Mdm_Help"
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