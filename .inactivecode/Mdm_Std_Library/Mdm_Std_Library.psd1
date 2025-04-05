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
        "Assert-ScriptSecElevated",
        "Build-ModuleExports",
        "Save-DirectoryName",
        "Get-DirectoryNameFromSaved",
        "Set-DirectoryToScriptRoot",
        "Get-FileNamesFromPath",
        "Set-ScriptSecElevated",
        "Wait-AnyKey",
        "Wait-CheckPauseDo",
        "Wait-YorNorQ"
    # )    
    # Cmdlets to export from this module.
    CmdletsToExport   = @(
            # "Assert-ScriptSecElevated" +
            # "Build-ModuleExports"
            # "Save-DirectoryName", +
            # "Get-DirectoryNameFromSaved", +
            # "Set-DirectoryToScriptRoot", +
            # "Get-FileNamesFromPath", +
            # "Set-ScriptSecElevated", +
            # "Wait-AnyKey", +
            # "Wait-CheckPauseDo", +
            # "Wait-YorNorQ"
    )
    # Variables to export from this module.
    # VariablesToExport = "*"
    # Aliases to export from this module.
    AliasesToExport   = @()
    # DSC resources to export from this module.
    DscResourcesToExport = @()
    # List of all modules packaged with this module.
    ModuleList = @()
}