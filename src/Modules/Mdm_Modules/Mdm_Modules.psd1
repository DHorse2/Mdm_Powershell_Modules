@{
    RootModule           = "Mdm_Modules.psm1"
    ModuleVersion        = "1.0"
    Author               = "David G Horsman"
    CompanyName          = "MacroDM"
    Copyright            = "(c) David G Horsman. All rights reserved."
    Description          = "MacroDm (Mdm) Bootstrap, Installation and Standard functions libarary."
    # Compatibility
    CompatiblePSEditions = @('Desktop', 'Core')
    PowerShellVersion    = '5.1'  # Minimum version for Desktop
    # You can also specify a minimum version for Core if needed
    GUID                 = "35796121-0646-475d-a1bb-74d2c8652ee5"

    # Modules
    # RequiredModules         = @("Mdm_Std_Library")
    # ModuleList              = @("Mdm_Std_Library", "Mdm_DevEnv_Install", "Mdm_Bootstrap")
    # NestedModules           = @("Mdm_Std_Library", "Mdm_DevEnv_Install", "Mdm_Bootstrap")
    # # Script files (.ps1) that are run in the caller"s environment.
    # Prior to importing this module.
    # ScriptsToProcess        = @()
    # ModuleToProcess         = @()

    # Data
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Development Environment', 'Development', 'Intialize', 'Powershell', 'Install')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/___/license'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/___/'

            # A URL to an icon representing this module.
            IconUri = 'https://github.com/___/icon.png'

            # ReleaseNotes of this module - our ReleaseNotes are in
            # the file ReleaseNotes.md
            ReleaseNotes = ''
        }

    }

    # Exports
    # Do not use wildcards. Use an empty array if there are no exports.
    # FunctionsToExport       = @()
    # CmdletsToExport         = @()
    # VariablesToExport       = @()
    # AliasesToExport         = @()
    # DscResourcesToExport    = @()
}