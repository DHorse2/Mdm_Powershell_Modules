@{
    RootModule          = "Mdm_DevEnv_Install.psm1"
    ModuleVersion       = "1.0"
    Author              = "David G Horsman"
    Description         = "MacroDm (Mdm) Development Platform Installation."
    GUID                = "9fc209b3-e0ff-4d67-ab9a-676432e47520"

    # Modules
    # RequiredModules         = @("Mdm_Std_Library")
    # ModuleList              = @("Mdm_Std_Library", "Mdm_Bootstrap")
    # NestedModules           = @() 
    # Scripts rior to importing this module.
    # ScriptsToProcess        = @()
    # ModuleToProcess         = @()

    # Exports
    # Do not use wildcards. Use an empty array if there are no exports.
    # Functions to export from this module.
    FunctionsToExport = 
        "Get-DevEnvVersions",
        "Install-DevEnvOsWin",
        "Install-DevEnvModules",
        "Install-DevEnvIdeWin",
        "Install-DevEnvLlmWin",
        "Install-DevEnvWhisperWin",
        "Install-DevEnvWin",
        "Install-DevEnv",
        "DevEnvGui",
        "Get-Assembly",
        "Get-JsonData"
    CmdletsToExport         = @()
    VariablesToExport       = @()
    AliasesToExport         =
        "Get-Vs",
        "IWinLlm",
        "IWinIde",
        "IWinOs",
        "IDevEnv",
        "IDevEnvWin"

    DscResourcesToExport    = @()
}