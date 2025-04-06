@{
    RootModule           = "Mdm_Std_Library.psm1"
    ModuleVersion        = "1.0"
    Author               = "David G Horsman"
    Description          = "Standard functions libarary."
    # Exports
    # For best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    # Functions to export from this module.
    FunctionsToExport    = 
    # Mdm_Std_Library
    # Script:
    "Initialize_Std",
    "Script_DoStart",
    "Script_ResetStdGlobals",
    "Script_DisplayStdGlobals",
    "Set-DisplayColors",
    "Assert-ScriptSecElevated",
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
    "Set-DirectoryToScriptRoot",
    "Save-DirectoryName",
    "Get-DirectoryNameFromSaved",

    "Set-LocationToPath",
    "Set-LocationToScriptRoot",
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
    ModuleList           = @()
}