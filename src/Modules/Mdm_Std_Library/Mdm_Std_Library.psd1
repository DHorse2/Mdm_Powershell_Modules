@{
    RootModule = "Mdm_Std_Library.psm1"
    ModuleVersion = "1.0"
    Author = "David G Horsman"
    Description = "Standard functions libarary."
    # Exports
    # For best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    # Functions to export from this module.
    FunctionsToExport = 
        # Mdm_Std_Library
        "Script_Initialize_Std",
        "Script_ResetStdGlobals",
        "Script_DisplayStdGlobals",
        "Set-DisplayColors",

        "Assert-ScriptSecElevated",
        "Assert-Verbose",

        "Build-ModuleExports",
        "Get-FileNamesFromPath",
        
        "Save-DirectoryName",
        "Get-DirectoryNameFromSaved",

        "Set-LocationToPath",
        "Set-LocationToScriptRoot",
        # Waiting & pausing
        "Wait-AnyKey",
        "Wait-CheckDoPause",
        "Wait-YorNorQ",
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

        # More
        "Show-Data",
        "Search-Dir",
        "Script_DoStart",

        "Write-Mdm_Help",
        "Get-Mdm_Help"
    # )    
    # Cmdlets to export from this module.
    CmdletsToExport   = @()
    # Variables to export from this module.
    # VariablesToExport = "*"
    # Aliases to export from this module.
    AliasesToExport   = @()
    # DSC resources to export from this module.
    DscResourcesToExport = @()
    # List of all modules packaged with this module.
    ModuleList = @()
}