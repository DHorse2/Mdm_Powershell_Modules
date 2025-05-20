
# DevEnv_Install_Modules_Win
function DevEnv_Install_Modules_Win {
    <#    
    .SYNOPSIS
        Install or update Mdm Modules.
    .DESCRIPTION
        This installs the libraries to the live system using Robocopy.
    .PARAMETER source
        default: "$global:projectRootPath\src\Modules" 
    .PARAMETER destination
        default: "$env:PROGRAMFILES\\WindowsPowerShell\Modules"

        .PARAMETER logFilePath
        default: "$global:projectRootPath\log\"
    .PARAMETER logFileName
        default: "Mdm_Installation_Log.txt"
    .PARAMETER LogOneFile
        Switch to not create separate file with the date in the file name.

        .PARAMETER SkpHelp
        Switch to skip generating the help documentation.
    .PARAMETER SkpRegistry
        Skip updating the registry.
    .PARAMETER DoNewWindow
        Switch to execute copy commands in a separate shell window.
    .PARAMETER copyOptions
        These are RoboCopy options.
        Currently: "/E /FP /nc /ns /np /TEE"

    .PARAMETER nameFilter
        Default is "Mmd_*". IE. These modules.
        You could override it if you had other local modules to install
    .PARAMETER companyName
        MacroDM currently. It's optional.
    .PARAMETER DoPause
        Switch to pause at each step/page.
    .PARAMETER DoVerbose
        Provide detailed information.
    .PARAMETER DoDebug
        Debug this script.
   .NOTES
        The above defaults appear again in the code below. 
        One or the other clearly.
        There are huge amounts of notes in this script.
        This is not best practices but whatever.
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        DevEnv_Install_Modules_Win    
#>


    [CmdletBinding()]
    param (
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [string]$source,
        [string]$destination = "C:\Program Files\WindowsPowerShell\Modules",
        [string]$projectRootPath = "",
        [string]$moduleRootPath = "",
        [string]$logFilePath = "",
        [string]$logFileName = "",
        [switch]$LogOneFile,
        [string]$nameFilter = "",
        [switch]$SkipHelp,
        [switch]$SkipRegistry,
        [switch]$SkipCopy,
        [switch]$DoNewWindow,
        [string]$companyName = "MacroDM",
        [string]$copyOptions = "/E /FP /nc /ns /np /TEE"
    )
    # DevEnv_Install_Modules_Win
    #region Initialization
    try {
        # Prompt for run settings
        $path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Modules\Project.ps1"
        . "$path"
        # # Remove Mdm Modules
        # $importName = "Mdm_Modules"
        # Write-Host "Removing $importName"
        # $modulePath = "$global:moduleRootPath\$importName"
        # if (((Get-Module -Name $importName) -or $global:DoForce)) {
        #     Remove-Module -Name $importName `
        #         -Force `
        #         -ErrorAction SilentlyContinue `
        # }
        if (-not $source) { 
            $source = $sourceDefault
        } else {
            $source = Convert-Path $source
        }
        Set-StdGlobals
        # Project settings and paths
        # Get-ModuleRootPath
        $path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Modules\Project.ps1"
        . "$path"
        if (-not $moduleRootPath) { $moduleRootPath = $global:moduleRootPath }
        if (-not $projectRootPath) { $projectRootPath = $global:projectRootPath }

        if (-not $destination) { $destination = $destinationDefault }
        if (-not $destination) { $destination = "$env:PROGRAMFILES\WindowsPowerShell\Modules" }
        $destination = Convert-Path $destination
        if (-not $destination) { 
            Write-Error -Message "No destination for files!"
            exit 
        }
        $global:projectRootPath = $projectRootPath
        $global:moduleRootPath = $moduleRootPath
    } catch {
        Write-Error -Message "The module environment preparation failed. Error: $_"
        exit
    }
    try {
        # Import Mdm_Std_Library
        $importName = "Mdm_Std_Library"
        if (-not ((Get-Module -Name $importName) -or $global:DoForce)) {
            $modulePath = "$global:moduleRootPath\$importName"
            if ($DoVerbose) { Write-Output "Exists: $(Test-Path "$modulePath"): $modulePath" }
            Import-Module -Name $modulePath @global:importParameters
        }
        
        # Import-All
        # $path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Modules\Import-All.ps1"
        # . "$path"

        # # This works with uninstalled Modules (both)
        # $importName = "Mdm_Modules"
        # $modulePath = "$global:moduleRootPath\$importName"
        # $null = Get-Import -Name $modulePath @global:commonParams

        # $importName = "Mdm_Bootstrap"
        # $modulePath = "$global:moduleRootPath\$importName"
        # $null = Get-Import -Name $modulePath @global:commonParams

        # $importName = "Mdm_Std_Library"
        # $modulePath = "$global:moduleRootPath\$importName"
        # $null = Get-Import -Name $modulePath @global:commonParams

        # $importName = "Mdm_WinFormPS"
        # $modulePath = "$global:moduleRootPath\$importName"
        # $null = Get-Import -Name $modulePath @global:commonParams
        # #     Import-Module -Name $modulePath @global:commonParams
    } catch {
        Write-Error -Message "DevEnv_Install_Modules_Win: The module environment is unstable. Error: $_"
        Write-Error -Message "Run the DevEnv_Module_Reset script to reset it." 
        exit
    }
    # MAIN
    $global:timeStarted = Get-Date
    $global:timeStartedFormatted = "{0:yyyyMMdd_HHmmss}" -f $global:timeStarted
    $global:timeCompleted = $null
    if (-not $nameFilter) { $nameFilter = "$($global:companyNamePrefix)_*" }
    if (-not $companyName) { $companyName = $global:companyName }

    # Logging:
    # $global:logFileNameFull = 
    if (-not $logFilePath) { $logFilePath = "$global:projectRootPath\log" }
    if (-not $logFileName) { $logFileName = "$($global:companyNamePrefix)_Installation_Log" }
    # Sets the global log file name
    Open-LogFile -DoOpen -logFilePath $logFilePath -logFileName $logFileName
    $logFileNameFull = $global:logFileNameFull
    Write-Host "Log File: $global:logFileNameFull"
    #endregion
    # Start
    $Message = @(
        " ", `
            "==================================================================", `
            "Installing Mdm Modules at $global:timeStartedFormatted", `
            "==================================================================", `
            "Source:      $source", `
            "Destination: $destination", `
            "    Logfile: $global:logFileNameFull", `
            "Script Root: $PSScriptRoot"
    )
    Add-LogText -Message $Message $global:logFileNameFull `
        -ForegroundColor Green

    # TODO Codium setup
    # https://dev.to/opdev1004/how-to-add-open-with-vscodium-for-windows-3g0l
    if (-not $SkipRegistry) {
        try {
            Add-LogText "==================================================================" $global:logFileNameFull `
                -ForegroundColor Green
            Add-LogText "Updating Registry" $global:logFileNameFull
            Add-LogText "Updating: $regPath" $global:logFileNameFull
    
            # ================================= Registry (Language mode)
            # Notes: Meaning of %V
            #   %V: This placeholder is used to represent the full path of the file.
            #   It is specifically intended for use with file paths that include spaces. 
            #   When %V is used, it is automatically enclosed in quotes, 
            #       which helps ensure that the path is correctly interpreted
            #       by the application, even if it contains spaces.

            # Key: Computer\HKEY_CLASSES_ROOT\Directory\shell\Powershell\command
            # powershell.exe -noexit -command Set-Location -literalPath '%V'

            # ================================= Registry (codium)
            # Setup "Open with "
            # Method 1: 
            # Check if Codium is installed for single user.
            $appExePath = "$env:USERPROFILE\AppData\Local\Programs\VSCodium\VSCodium.exe"
            # Check if the path exists
            if (Test-Path $appExePath) {
                # Resolve the path
                $appExePath = Resolve-Path $appExePath | Select-Object -ExpandProperty Path
            } else {
                # Codium must be installed for all users.
                $appExePath = Resolve-Path "$env:Programfiles\VSCodium\VSCodium.exe"
                if (Test-Path $appExePath) {
                    # Resolve the path
                    $appExePath = Resolve-Path $appExePath | Select-Object -ExpandProperty Path
                } else {
                    # TODO Throw an error
                    Add-LogText "VSCodium not found." $global:logFileNameFull -IsError
                }
            }
            $commandString = "`"$appExePath`" `"%V`""
            # # Note on UserProfile: This method uses the user's account name:

            # Directory shell
            $regPath = "HKEY_CLASSES_ROOT\Directory\shell" 
            Add-LogText "Updating: $regPath" $global:logFileNameFull
            $regKey = "Open with VSCodium"
            $regProperty = "command"
            # Create registry key
            if (-not (Test-Path "Registry::$regPath\$regKey")) {
                New-Item -Path "Registry::$regPath" -Name $regKey -Force
            }
            # Set Default
            $regProperty = "(Default)"
            Set-ItemProperty -Path "Registry::$regPath\$regKey" -Name $regProperty -Value $regKey -Force

            # command subkey
            $regPath = "$regPath\$regKey"
            Add-LogText "Updating: $regPath" $global:logFileNameFull
            $regKey = "command"
            if (-not (Test-Path "Registry::$regPath\$regKey")) {
                New-Item -Path "Registry::$regPath" -Name $regKey -Force
            }
            # Set the command
            $regProperty = "(Default)"
            Set-ItemProperty -Path "Registry::$regPath\$regKey" -Name $regProperty -Value $commandString -Force

            # Directory Background Shell
            $regPath = "HKEY_CLASSES_ROOT\Directory\Background\shell"
            Add-LogText "Updating: $regPath" $global:logFileNameFull
            $regKey = "Open with VSCodium"
            if (-not (Test-Path "Registry::$regPath\$regKey")) {
                New-Item -Path "Registry::$regPath" -Name $regKey -Force
            }
            # Set Default
            $regProperty = "(Default)"
            Set-ItemProperty -Path "Registry::$regPath\$regKey" -Name $regProperty -Value $regKey -Force

            $regPath = "$regPath\$regKey"
            Add-LogText "Updating: $regPath" $global:logFileNameFull
            # command subkey
            $regKey = "command"
            if (-not (Test-Path "Registry::$regPath\$regKey")) {
                New-Item -Path "Registry::$regPath" -Name $regKey -Force
            }

            # Set the Command Path - Open with VSCodium
            $regProperty = "(Default)"
            Set-ItemProperty -Path "Registry::$regPath\$regKey" -Name $regProperty -Value $commandString -Force

            # Method 2:
            # https://www.thewindowsclub.com/change-registry-using-windows-powershell
            # Step 1: Type following and press Enter key to go to the Registry location:
            #   Set-Location -Path 'HKLM:\Software\Policies\Microsoft\Windows'
            # Step 2: Then execute the following cmdlet to create the new registry sub-key
            #   Get-Item -Path 'HKLM:\Software\Policies\Microsoft\Windows' | New-Item -Name 'Windows Search' -Force
            # Step 3: Now as the registry sub-key is created, I’ll now create a registry DWORD and execute the following code for this: 
            #   New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\Windows Search' -Name 'AllowIndexingEncryptedStoresOrItems' -Value "1" -PropertyType DWORD -Force
        
        } catch {
            $Message = "DevEnv_Install_Modules_Win: Registry update failure."
            Add-LogText -Message $Message -IsError -ErrorPSItem $_
        }
    }

    # ================================= Install modules:
    # ================================= Execute COPY command:
    if (-not $SkipCopy) {
        try {
            if (-not $copyOptions) { $copyOptions = "/E /FP /NC /NC /NP /TEE" }

            Add-LogText "Process file exclusions..." $global:logFileNameFull
            $originalExclusionFile = "$source\UpdateExclusions.txt"
            $newExclusionFile = "$source\UpdateExclusionsTemp.txt"
            $exclusionPaths = Get-Content -Path $originalExclusionFile
            $resolvedPaths = @()
            $exclusionList = ""
            foreach ($path in $exclusionPaths) {
                try {
                    $resolvedPath = Resolve-Path -Path $path -ErrorAction Stop
                    $resolvedPaths += $resolvedPath.Path  # Add the resolved path to the array
                    $exclusionList += " $resolvedPath"
                } catch {
                    try {
                        $path = "$global:projectRootPath\$path"
                        $resolvedPath = Resolve-Path -Path $path -ErrorAction Stop
                        $resolvedPaths += $resolvedPath.Path  # Add the resolved path to the array
                        $exclusionList += " $resolvedPath"
                    } catch {
                        if ($DoVerbose) {
                            Write-Warning -Message "Failed to resolve path: $path. Error: $_"
                        }
                    }
                }
            }
            $resolvedPaths | Out-File -FilePath $newExclusionFile -Encoding UTF8
            if ($resolvedPaths.Count) { 
                # $exclusionList = $resolvedPaths -join ' '
                # $copyOptions += " /XF $newExclusionFile"
                foreach ($exclusion in $resolvedPaths) {
                    $copyOptions += " /XF `"$exclusion`""
                }
            }
            # $copyOptions += " /EXCLUDE:`"$newExclusionFile`"" 

            $commandLine = "Robocopy `"$source`" `"$destination`" $copyOptions"
            $commandLine = "$commandLine /LOG+:`"$global:logFileNameFull`"" # :: output status to LOG file (append to existing log).
            # ================================= Reporting:
            # if ($DoVerbose) {
            Add-LogText "==================================================================" $global:logFileNameFull `
                -ForegroundColor Green
            $Message = @( `
                    "Copying SOURCE: ""$source""", `
                    "DESTINATION: ""$destination""", `
                    " ", `
                    "Command: $commandLine", `
                    " ", `
                    "Starting processing..."
            )
            Add-LogText -Message $Message $global:logFileNameFull
            # }

            Add-LogText "Remove modules if they exist..." $global:logFileNameFull
            Remove-Item "$destination\Mdm_*" `
                -Recurse -Force `
                -ErrorAction SilentlyContinue

            Add-LogText "Copy modules to destination..." $global:logFileNameFull
            # Prepare command
            $commandName = "Robocopy"
            $roboCopyOptions = @($source, $destination)
            $optionsArray = $copyOptions.split(" ")
            foreach ($option in $optionsArray) {
                $roboCopyOptions += $option
            }
            $roboCopyOptions += "/LOG+:$global:logFileNameFull"
            $commandOptions = $roboCopyOptions -join ' '
            [hashtable]$Command = @{
                CommandLine = $commandLine
                CommandName = $commandName
            }
            # -DoNewWindow ` TODO test this
            # $invokeResult = @()
            $invokeResult = New-Object System.Collections.ArrayList
            # ###############################
            $invokeResult += ($Command | Invoke-Invoke -Options $commandOptions)
            if ($invokeResult -and $invokeResult.Count -ge 1) {
                $result = $invokeResult[1]
            } elseif ($invokeResult) { 
                $result = $invokeResult[0] 
            }
            if ($result -and $result -is [CommandResult]) {
                # Do relevant processing
            } else {
                $resultDefault = New-Object CommandResult
                $resultDefault.CommandName = $commandName
                $resultDefault.CommandLine = $commandLine
                $resultDefault.errorOutPut = "Results are missing or is not a CommandResult."
                $resultDefault.result = $result
                $invokeResult = $resultDefault
            }
            if (Get-RobocopyExitMessage $result.exitCode -IsError) {
                # if ($result.exitCode -ne 1 -or $result.errorOutput) {
                $Message = "Robocopy error in Command $($result.CommandName), Result: $($result.exitCode) - $(Get-RobocopyExitMessage($result.exitCode))."
                if ($result.errorOutput) { $Message += "`nDetails:`n $($result.errorOutput)" }
                Add-LogText -Message $Message -IsError
            } elseif ($result.result) {
                if ($DoVerbose) {
                    Add-LogText -Message $result.result -ForegroundColor Blue
                    # if ($result.errorOutput) { Add-LogText -Message $result.errorOutPut -ForegroundColor Red }
                }
            } else {
                $Message = "Robocopy completed normally for Command $($result.CommandName), Result: $($result.exitCode) - $(Get-RobocopyExitMessage($result.exitCode))."
                if ($result.result) { $Message += "`nDetails:`n $($result.result)" }
                Add-LogText -Message $Message -ForegroundColor Blue
            }

        } catch {
            $Message = "DevEnv_Install_Modules_Win: Copy files failure."
            Add-LogText -Message $Message -IsError -ErrorPSItem $_
        }
    }
    # ================================= Help files
    if (-not $SkipHelp) {
        try {
            Add-LogText "==================================================================" $global:logFileNameFull `
                -ForegroundColor Green
            Add-LogText " " $global:logFileNameFull
            Add-LogText "Updating Help for Mdm Modules." $global:logFileNameFull
            # Export-Help
            try {
                Export-Help `
                    -projectRootPath $projectRootPath `
                    -moduleRootPath $source `
                    `
                    -NameFilter $nameFilter
            } catch {
                $Message = "Export-Help Failed."
                Add-LogText -Message $Message -IsError -ErrorPSItem $_
            }
            # # Generate-Documentation - Write-Mdm_Help (redundant)
            # $importName = "Mdm_Modules"
            # try {
            #     # Remove-Module $importName `
            #     # -ErrorAction SilentlyContinue
            #     # Import-Module -Name $importName `
            #     # -Force -ErrorAction Stop
            #     Add-LogText "==================================================================" $global:logFileNameFull `
            #         -ForegroundColor Green
            #     Add-LogText "Performing Write-Mdm_Help..." $global:logFileNameFull `
            #         -ForegroundColor Green
            #     Write-Mdm_Help
            # }
            # catch {
            #     $Message = @( `
            #             "Write-Mdm_Help Failed." `
            #     )
            #     Add-LogText $Message $global:logFileNameFull -IsError
            # }
            # Export-Mdm_Help
            try {
                Remove-Module -Name $importName -ErrorAction SilentlyContinue
                $null = Get-Import -Name "Mdm_Modules" `
                    `
                    @global:commonParams
                -Force -ErrorAction Stop
                # Import-Module -Name $importName -Force -ErrorAction Stop
            } catch {
                $Message = "DevEnv_Install_Modules_Win, Export-Mdm_Help file to import $importName."
                Add-LogText -Message $Message -IsError -ErrorPSItem $_
            }
            try {
                Add-LogText "==================================================================" $global:logFileNameFull `
                    -ForegroundColor Green
                Add-LogText "Performing Export-Mdm_Help..." $global:logFileNameFull `
                    -ForegroundColor Green

                Export-Mdm_Help -moduleRootPath $moduleRootPath
            } catch {
                $Message = "DevEnv_Install_Modules_Win, Export-Mdm_Help failed."
                Add-LogText -Message $Message -IsError -ErrorPSItem $_
            }
            # Get-AllCommands
            try {
                Add-LogText "==================================================================" $global:logFileNameFull `
                    -ForegroundColor Green
                Add-LogText "Performing Get-AllCommands..." $global:logFileNameFull `
                    -ForegroundColor Green
                Get-AllCommands
            } catch {
                $Message = "DevEnv_Install_Modules_Win, Get-AllCommands Failed."
                Add-LogText -Message $Message -IsError -ErrorPSItem $_
            }
            # Install Help files
            $helpSource = "$source\Mdm_Bootstrap\help"
            $helpDestination = "$destination\Mdm_Bootstrap\help"
            # $helpFileName = "$Mdm_Help.html"  # Update the path
            $commandLine = "Robocopy `"$helpSource`" `"$helpDestination`" $copyOptions"
            $commandLine = "$commandLine /LOG+:`"$global:logFileNameFull`"" # :: output status to LOG file (append to existing log).
            Add-LogText "==================================================================" $global:logFileNameFull `
                -ForegroundColor Green
            $Message = @( `
                    "Install Help Files:"
            )
            Add-LogText -Message $Message $global:logFileNameFull
            # Copy files
            try {
                # New Shell
                if ($DoNewWindow) {
                    $roboCopyOptions = @($helpSource, $helpDestination)
                    $optionsArray = $copyOptions.split(" ")
                    foreach ($option in $optionsArray) {
                        $roboCopyOptions += $Option
                    }
                    $roboCopyOptions += "/LOG+:$global:logFileNameFull"
                    # $installProcess = 
                    Add-LogText "NOTE: Opening new window..." $global:logFileNameFull `
                        -ForegroundColor Red
                    Start-Process -FilePath "robocopy" -ArgumentList $roboCopyOptions -Verb RunAs
                }
                # this Shell
                else {
                    Add-LogText $commandLine $global:logFileNameFull
                    Invoke-Expression $commandLine
                }
            } catch {
                $Message = "Failed to install help files."
                Add-LogText -Message $Message -IsError -ErrorPSItem $_
            }
            # Update system folders
        } catch {
            $Message = "DevEnv_Install_Modules_Win: Update failure."
            Add-LogText -Message $Message -IsError -ErrorPSItem $_
        }
    }

    # ================================= Test stability
    # $moduleName = "Mdm_Modules"
    # Add-LogText "==================================================================" $global:logFileNameFull `
    #     -ForegroundColor Green
    # Add-LogText " " $global:logFileNameFull
    # Add-LogText "==================" $global:logFileNameFull
    # Add-LogText "Reloading Mdm Modules." $global:logFileNameFull
    # Add-LogText "Standard import ($moduleName) test..."
    # Add-LogText "==================================================================" $global:logFileNameFull `
    #     -ForegroundColor Green
    
    # # Reset
    # Add-LogText "Resetting Mdm Modules for bootstrap use." $global:logFileNameFull
    # Invoke-DevEnv_Module_Reset
    Initialize-StdGlobals

    # Invoke-Expression DevEnv_Module_Reset

    # Remove Modules
    # try {
    #     Remove-Module -Name "$moduleRootPath\$moduleName\$moduleName" `
    #         -Force `
    #         -ErrorAction Stop
    #     # -Verbose `
    # } catch {
    #     $Message = "No need to remove module: $moduleName."
    #     Write-Host $Message
    #     # Add-LogText -Message $Message -IsWarning -SkipScriptLineDisplay -ErrorPSItem $_
    # }
    # # Import Modules
    # try {
    #     Import-Module -Name "$moduleRootPath\$moduleName\$moduleName" `
    #         -Force `
    #         -ErrorAction Stop
    #     # Get-Import crashes VsCodium PS extension and ISE.
    #     # $null = Get-Import -Name $moduleName `
    #     #     -DoForce `
    #     #     -ErrorAction Stop `
    #     #     @global:commonParams
    #     # -Verbose `
    # } catch {
    #     $Message = "Failed to import module: $moduleName."
    #     Add-LogText -Message $Message -IsError -ErrorPSItem $_
    # }
    # Export-ModuleMemberScan
    try {
        Add-LogText "==================================================================" $global:logFileNameFull `
            -ForegroundColor Green
        Add-LogText "Automatic Function Imports Test (Export-ModuleMemberScan $moduleName)" $global:logFileNameFull
        Add-LogText "Export-ModuleMemberScan: $moduleRootPath" $global:logFileNameFull
        $null = Export-ModuleMemberScan "$moduleRootPath\$moduleName"
    } catch {
        $Message = "Export-ModuleMemberScan failed."
        Add-LogText -Message $Message -IsError -ErrorPSItem $_
    }
    # ================================= Wrapup
    $global:timeCompleted = "{0:G}" -f (get-date)
    $Message = @( `
            "==================================================================", `
            "Installation completed at $global:timeCompleted", `
            "started at $global:timeStartedFormatted", `
            "Source: $source", `
            "Destination: $destination", `
            "Logfile: $global:logFileNameFull", `
            "==================================================================", `
            "" `
    )
    Add-LogText -Message $Message $global:logFileNameFull `
        -ForegroundColor Green

    Add-LogText "==================================================================" $global:logFileNameFull `
        -ForegroundColor Green
}
