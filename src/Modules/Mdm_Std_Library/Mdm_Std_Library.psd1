@{
    RootModule           = "Mdm_Std_Library.psm1"
    ModuleVersion        = "1.0"
    Author               = "David G Horsman"
    Description          = "Standard functions libarary."
    GUID                 = "b024c60f-e202-4254-b278-eaf45d7c2483"

    # Modules
    # RequiredModules         = @()
    # ModuleList              = @()
    # NestedModules           = @() 
    # Scripts prior to importing this module.
    # ScriptsToProcess        = @()
    # ModuleToProcess         = @()
    RequiredAssemblies   = @(
        'System.Windows.Forms', # For Windows Forms
        'System.Drawing', # For drawing support
        'Microsoft.VisualBasic',
        'PresentationCore', # For WPF
        'System.Management.Automation.dll'
    )

    # Exports
    # Do not use wildcards. Use an empty array if there are no exports.
    # FunctionsToExport       = @()
    # CmdletsToExport         = @()
    # VariablesToExport       = @()
    # AliasesToExport         = @()
    # DscResourcesToExport    = @()
}