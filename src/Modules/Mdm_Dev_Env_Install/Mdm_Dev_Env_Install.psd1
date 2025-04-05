@{
    RootModule = "Mdm_Dev_Env_Install.psm1"
    ModuleVersion = "1.0"
    Author = "David G Horsman"
    Description = "MacroDm (Mdm) Development Platform Installation."
    # Exports
    # FunctionsToExport       = '*'
    # CmdletsToExport         = '*'
    # VariablesToExport       = '*'
    # AliasesToExport         = '*'
    # For best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    # Functions to export from this module.
    FunctionsToExport = 
        "Get-Dev_Env_Versions",
        "Install-Dev_Env_Win",
        "Install-Dev_Env_IDE_Win",
        "Install-Dev_Env_LLM_Win",
        "Install-Dev_Env_OS_Win",
        "Install-Dev_Env_Whisper_Win"
    # Cmdlets to export from this module.
    # CmdletsToExport   = @()
    # Variables to export from this module.
    # VariablesToExport = "*"
    # Aliases to export from this module.
    AliasesToExport   = "Get-Vs"
    # DSC resources to export from this module.
    # DscResourcesToExport = @()
    # List of all modules packaged with this module.
    # ModuleList = @()

    # # Script files (.ps1) that are run in the caller"s environment prior to importing this module.
    # ScriptsToProcess = "Get-Dev_Env_Versions"
}