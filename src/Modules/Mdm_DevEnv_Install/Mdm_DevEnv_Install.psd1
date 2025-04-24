@{
    RootModule = "Mdm_DevEnv_Install.psm1"
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
        "Get-DevEnvVersions",
        "Install-DevEnvModules",
        "Install-DevEnvWin",
        "Install-DevEnvIdeWin",
        "Install-DevEnvLlmWin",
        "Install-DevEnvOsWin",
        "Install-DevEnvWhisperWin"
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
    # ScriptsToProcess = "Get-DevEnvVersions"
}