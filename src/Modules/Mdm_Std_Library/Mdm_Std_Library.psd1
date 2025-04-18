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
    "Get-AllCommands",
    "Initialize-Std",
    "Script_DoStart",
    "Initialize-StdGlobalsReset",
    "Show-StdGlobals",
    "Set-DisplayColors",
    "Assert-SecElevated",
    "Assert-Verbose",
    # This script:
    "Get-PSCommandPath",
    "Script_Name",
    "Get-MyCommand_InvocationName",
    "Get-MyCommand_Origin",
    "Get-MyCommand_Name",
    "Get-MyCommand_Definition",
    "Get-Invocation_PSCommandPath",
    "Get-ScriptPositionalParameters",
    "Get-LastError",
    "Get-NewError",

    # Path and directory
    "Get-FileNamesFromPath",
    "Set-LocationToPath",
    "Set-LocationToScriptRoot",
    "Set-DirectoryToScriptRoot",
    "Save-DirectoryName",
    "Get-DirectoryNameFromSaved",
    "Search-Directory",

    # Waiting & pausing
    "Wait-AnyKey",
    "Wait-CheckDoPause",
    "Wait-YorNorQ",

    # Etl
    "ConvertTo-Text",
    "ConvertTo-ObjectArray",
    "ConvertTo-EscapedText",
    "ConvertTo-TrimedText",
    # Etl Log
    "Add-LogText",
    "Add-LogError",
    "Get-LogFileName",
    # Etl Html
    "Write-HtlmData",

    # Help
    "Write-Mdm_Help",
    "Get-Mdm_Help",
    # "Write-Mdm_Help",
    "ConvertFrom-HtmlTemplate",
    "Get-HelpHtml",
    "Get-HtmlTemplate",
    "ConvertFrom-HtmlTemplate",
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