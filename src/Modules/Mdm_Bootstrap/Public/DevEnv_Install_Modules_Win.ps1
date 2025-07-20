
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
        default: "$global:moduleRootPath\Mdm_DevEnv_Install\log\"
    .PARAMETER logFileName
        default: "Mdm_Installation_Log.txt"
    .PARAMETER LogOneFile
        Switch to not create separate file with the date in the file name.
    .PARAMETER SkipHelp
        Switch to skip generating the help documentation.
    .PARAMETER SkipRegistry
        Skip updating the registry.
    .PARAMETER jobActionMethodNewWindow
        Switch to execute copy commands in a separate shell window.
    .PARAMETER copyOptions
        These are RoboCopy options.
        Currently: "/E /FP /nc /ns /np /TEE"

    .PARAMETER nameFilter
        Default is "Mdm_*". IE. These modules.
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
        [switch]$DoHelp,
        [switch]$DoRegistry,
        [switch]$DoCopy,
        # files
        [string]$source,
        [string]$destination = "C:\Program Files\WindowsPowerShell\Modules",
        #
        [string]$nameFilter = "",
        [switch]$jobActionMethodNewWindow,
        [string]$companyName = "MacroDM",
        [string]$copyOptions = "/E /FP /nc /ns /np /TEE",

        [string]$appName = "",
        [int]$actionStep = 0,
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [string]$logFileNameFull = "",

        [string]$logFilePath = "",
        [switch]$LogOneFile
    )
    # DevEnv_Install_Modules_Win
    #region Initialization
    $appName = "DevEnv_Install_Modules_Win"
    try {
        try {
            # Project Parameters
            if (-not $logFileNameFull) {
                $logFileNameFull = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Std_Library\log\DevEnv_Install_Modules_Win.txt"
                $global:combinedParams['logFileNameFull'] = $logFileNameFull
            }
            $inArgs = $args
            # Get-Parameters
            $path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Std_Library\lib\Get-ParametersLib.ps1"
            . $path
            # Project settings and paths
            # projectLib.ps1
            $path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Std_Library\lib\ProjectLib.ps1"
            . $path
        } catch {
            <#Do this if a terminating exception happens#>
            exit
        }
        $appDirectory = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_DevEnv_Install"
        if (-not $source) { 
            $source = $sourceDefault
        } else {
            $source = Convert-Path $source
        }

        # Set-StdGlobals
        Initialize-StdGlobals `
            -InitForce -InitStd -InitLogFile `
            -appDirectory $appDirectory `
            -logFilePath "$appDirectory\log" `
            -logFileNameFull $logFileNameFull `
            -DoOpen -DoCheckState -DoSetGlobal
        $app = $global:appResult
        $logFileNameFull = $global:logFileNameFullResult
        # Logging:
        # Sets the log file name
        # if ($global:app.logFileNameFull) {
        #     $logFileNameFull = $global:app.logFileNameFull
        # } else { $logFileNameFull = $global:logFileNameFullResult }

        if (-not $destination) { $destination = $destinationDefault }
        if (-not $destination) { $destination = "$env:PROGRAMFILES\WindowsPowerShell\Modules" }
        $destination = Convert-Path $destination
        if (-not $destination) { 
            Write-Error -Message "No destination for files!"
            exit 
        }
        # $global:projectRootPath = $projectRootPath
        # $global:moduleRootPath = $moduleRootPath
    } catch {
        Write-Error -Message "The module environment preparation failed. Error: $_"
        exit
    }
    try {
        # Import Mdm_Std_Library
        $importName = "Mdm_Std_Library"; $global:actionStep = 1
        # Get-ModuleValidatedLib
        $path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Std_Library\lib\Get-ModuleValidatedLib.ps1"
        . $path -importName $importName -actionStep $actionStep @global:combinedParams
        # $importName = "Mdm_Std_Library"
        # if (-not ((Get-Module -moduleName $importName) -or $global:app.DoForce)) {
        #     $modulePath = "$global:moduleRootPath\$importName"
        #     if ($DoVerbose) { Write-Host "Exists: $(Test-Path "$modulePath"): $modulePath" }
        #     Import-Module -moduleName $modulePath @global:importParams
        # }
        
        # Import-All
        # $global:actionStep=0
        # $path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Std_Library\lib\ImportAllLib.ps1"
        # . $path @global:combinedParams

        # # This works with uninstalled Modules (both)
        # $importName = "Mdm_Modules"
        # $modulePath = "$global:moduleRootPath\$importName"
        # $null = Get-Import -moduleName $modulePath @global:commonParams

        # $importName = "Mdm_Bootstrap"
        # $modulePath = "$global:moduleRootPath\$importName"
        # $null = Get-Import -moduleName $modulePath @global:commonParams

        # $importName = "Mdm_Std_Library"
        # $modulePath = "$global:moduleRootPath\$importName"
        # $null = Get-Import -moduleName $modulePath @global:commonParams

        # $importName = "Mdm_WinFormPS"
        # $modulePath = "$global:moduleRootPath\$importName"
        # $null = Get-Import -moduleName $modulePath @global:commonParams
        # #     Import-Module -Name $modulePath @global:commonParams
    } catch {
        Write-Error -Message "DevEnv_Install_Modules_Win: The module environment is unstable. Error: $_"
        Write-Error -Message "Run the DevEnv_Module_Reset script to reset it." 
        exit
    }
    # MAIN
    $timeStarted = Get-Date
    $timeStartedFormatted = "{0:yyyyMMdd_HHmmss}" -f $timeStarted
    $timeCompleted = [System.DateTime]::MinValue
    if (-not $nameFilter) { $nameFilter = "$($global:companyNamePrefix)_*" }
    if (-not $companyName) { $companyName = $global:companyName }

    Write-Host "Log File: $logFileNameFull"
    #endregion
    # Start
    $Message = @(
        " ",
        "==================================================================",
        "Installing Mdm Modules at $timeStartedFormatted",
        "==================================================================",
        "Application: $appName",
        "Source:      $source",
        "Destination: $destination",
        "    Logfile: $logFileNameFull",
        "Script Root: $PSScriptRoot"
    )
    Add-LogText -Message $Message $logFileNameFull `
        -ForegroundColor Green

    # TODO: INST: Codium setup
    # https://dev.to/opdev1004/how-to-add-open-with-vscodium-for-windows-3g0l
    if ($DoRegistry) {
        try {
            Add-LogText "==================================================================" $logFileNameFull `
                -ForegroundColor Green
            Add-LogText "Updating Registry" $logFileNameFull
            Add-LogText "Updating: $regPath" $logFileNameFull
    
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
                    # TODO hold Throw an error
                    Add-LogText "VSCodium not found." $logFileNameFull -IsError
                }
            }
            $commandString = "`"$appExePath`" `"%V`""
            # # Note on UserProfile: This method uses the user's account name:

            # Directory shell
            $regPath = "HKEY_CLASSES_ROOT\Directory\shell" 
            Add-LogText "Updating: $regPath" $logFileNameFull
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
            Add-LogText "Updating: $regPath" $logFileNameFull
            $regKey = "command"
            if (-not (Test-Path "Registry::$regPath\$regKey")) {
                New-Item -Path "Registry::$regPath" -Name $regKey -Force
            }
            # Set the command
            $regProperty = "(Default)"
            Set-ItemProperty -Path "Registry::$regPath\$regKey" -Name $regProperty -Value $commandString -Force

            # Directory Background Shell
            $regPath = "HKEY_CLASSES_ROOT\Directory\Background\shell"
            Add-LogText "Updating: $regPath" $logFileNameFull
            $regKey = "Open with VSCodium"
            if (-not (Test-Path "Registry::$regPath\$regKey")) {
                New-Item -Path "Registry::$regPath" -Name $regKey -Force
            }
            # Set Default
            $regProperty = "(Default)"
            Set-ItemProperty -Path "Registry::$regPath\$regKey" -Name $regProperty -Value $regKey -Force

            $regPath = "$regPath\$regKey"
            Add-LogText "Updating: $regPath" $logFileNameFull
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
    if ($DoCopy) {
        try {
            if (-not $copyOptions) { $copyOptions = "/E /FP /NC /NC /NP /TEE" }

            Add-LogText "Process file exclusions..." $logFileNameFull
            $originalExclusionFile = "$source\UpdateExclusions.txt"
            $newExclusionFile = "$source\UpdateExclusionsTemp.txt"
            try {
                $exclusionPaths = Get-Content -Path $originalExclusionFile -ErrorAction Stop
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
                $resolvedPaths | Out-File -FilePath $newExclusionFile -Encoding UTF8 -ErrorAction Stop
                if ($resolvedPaths.Count) { 
                    # $exclusionList = $resolvedPaths -join ' '
                    # $copyOptions += " /XF $newExclusionFile"
                    foreach ($exclusion in $resolvedPaths) {
                        $copyOptions += " /XF `"$exclusion`""
                    }
                }
                # $copyOptions += " /EXCLUDE:`"$newExclusionFile`"" 
            } catch {
                    $Message = "DevEnv_Install_Modules_Win: No Exclusions processed (UpdateExclusions)."
                    Add-LogText -Message $Message -IsWarning -ErrorPSItem $_
            }

            Add-LogText "Remove modules if they exist..." $logFileNameFull
            Remove-Item "$destination\Mdm_*" `
                -Recurse -Force `
                -ErrorAction SilentlyContinue


            # Load Module Config Data
            $jsonFileName = "$global:moduleRootPath\Mdm_DevEnv_Install\data\DevEnvModules.json"
            $jsonData = Get-JsonData -Name "Modules" -jsonItem $jsonFileName -logFileNameFull $logFileNameFull
            # $jsonData = $global:jsonDataResult
            foreach ($moduleName in $global:moduleNames) {
                $moduleActive = Confirm-ModuleActive -moduleName $moduleName `
                    -jsonData $jsonData `
                    @global:combinedParams
                if ($moduleActive) {
                    try {
                        Add-LogText "Copy Module $moduleName to destination..." $logFileNameFull
                        $moduleSource = "$source\$moduleName"; $moduleDestination = "$destination\$moduleName"
                        $CommandLine = "`"$moduleSource`" `"$moduleDestination`" $copyOptions"
                        $CommandLine = "$CommandLine /LOG+:`"$logFileNameFull`"" # :: output status to LOG file (append to existing log).
                        # ================================= Reporting:
                        # if ($DoVerbose) {
                        Add-LogText "==================================================================" $logFileNameFull `
                            -ForegroundColor Green
                        $Message = @( `
                                "Copying SOURCE: ""$moduleSource""", `
                                "DESTINATION: ""$moduleDestination""", `
                                " ", `
                                "Command: Robocopy $CommandLine", `
                                " ", `
                                "Starting processing..."
                        )
                        Add-LogText -Message $Message $logFileNameFull
                        # }
                        # Active Module process
                        # Prepare command
                        $commandName = "Robocopy.exe"
                        $roboCopyOptions = @($moduleSource, $moduleDestination)
                        $optionsArray = $copyOptions.split(" ")
                        foreach ($option in $optionsArray) {
                            $roboCopyOptions += $option
                        }
                        $roboCopyOptions += "/LOG+:$logFileNameFull"
                        $commandOptions = $roboCopyOptions -join ' '

                        # Invoke Command
                        [hashtable]$Command = @{
                            CommandLine = $CommandLine
                            CommandName = $commandName
                            ScriptBlock = $null
                        }
                        # $invokeResult = @()
                        $invokeResult = New-Object System.Collections.ArrayList
                        # ###############################
                        $invokeResult += $(Invoke-Invoke -Command $Command -Options $commandOptions -logFileNameFull $logFileNameFull)
                        if ($invokeResult -and $invokeResult.Count -ge 1) {
                            $result = $invokeResult[1]
                        } elseif ($invokeResult) { 
                            $result = $invokeResult[0] 
                        }
                        if ($result -and $result -is [CommandAction]) {
                            # Do relevant processing
                        } else {
                            $resultDefault = New-Object CommandAction
                            $resultDefault.CommandName = $commandName
                            $resultDefault.CommandLine = $CommandLine
                            $resultDefault.errorOutPut = "Results are missing or is not a CommandAction."
                            $resultDefault.result = $result
                            $invokeResult = $resultDefault
                        }
                        if (Get-RobocopyExitMessage $result.exitCode -IsError) {
                            # if ($result.exitCode -ne 1 -or $result.errorOutput) {
                            $Message = "Robocopy error in Command $($result.CommandName), Result: $($result.exitCode) - $(Get-RobocopyExitMessage($result.exitCode))."
                            if ($result.errorOutput) { $Message += "`nDetails:$global:NL $($result.errorOutput)" }
                            Add-LogText -Message $Message -IsError
                        } elseif ($result.result) {
                            if ($DoVerbose) {
                                Add-LogText -Message $result.result -ForegroundColor Blue
                                # if ($result.errorOutput) { Add-LogText -Message $result.errorOutPut -ForegroundColor Red }
                            }
                        } else {
                            $Message = "Robocopy completed normally for Command $($result.CommandName), Result: $($result.exitCode) - $(Get-RobocopyExitMessage($result.exitCode))."
                            if ($result.result) { $Message += "`nDetails:$global:NL $($result.result)" }
                            Add-LogText -Message $Message -ForegroundColor Blue
                        }
                    } catch {
                        $Message = "DevEnv_Install_Modules_Win: Copy files failure in Module $moduleName."
                        Add-LogText -Message $Message -IsError -ErrorPSItem $_
                    }
                } else {
                    $Message = "Robocopy skipped Inactive Module $moduleName."
                    Add-LogText -Message $Message -ForegroundColor Blue
                }
            }
        } catch {
            $Message = "DevEnv_Install_Modules_Win: Copy files failure."
            Add-LogText -Message $Message -IsError -ErrorPSItem $_
        }
    }
    # ================================= Help files
    if ($DoHelp) {
        try {
            Add-LogText "==================================================================" $logFileNameFull `
                -ForegroundColor Green
            Add-LogText " " $logFileNameFull
            Add-LogText "Updating Help for Mdm Modules." $logFileNameFull
            # Export-Help
            try {
                Export-Help `
                    -projectRootPath $global:projectRootPath `
                    -moduleRootPath $source `
                    -NameFilter $nameFilter
            } catch {
                $Message = "Export-Help Failed."
                Add-LogText -Message $Message -IsError -ErrorPSItem $_
            }

            # Export-Mdm_Help
            try {
                Remove-Module -Name $importName -ErrorAction SilentlyContinue
                $null = Get-Import -moduleName "Mdm_Modules" `
                    `
                    @global:commonParams
                -Force -ErrorAction Stop
                # Import-Module -Name $importName -Force -ErrorAction Stop
            } catch {
                $Message = "DevEnv_Install_Modules_Win, Export-Mdm_Help file to import $importName."
                Add-LogText -Message $Message -IsError -ErrorPSItem $_
            }
            try {
                Add-LogText "==================================================================" $logFileNameFull `
                    -ForegroundColor Green
                Add-LogText "Performing Export-Mdm_Help..." $logFileNameFull `
                    -ForegroundColor Green

                Export-Mdm_Help -moduleRootPath $global:moduleRootPath
            } catch {
                $Message = "DevEnv_Install_Modules_Win, Export-Mdm_Help failed."
                Add-LogText -Message $Message -IsError -ErrorPSItem $_
            }
            # Get-AllCommands
            try {
                Add-LogText "==================================================================" $logFileNameFull `
                    -ForegroundColor Green
                Add-LogText "Performing Get-AllCommands..." $logFileNameFull `
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
            $CommandLine = "Robocopy `"$helpSource`" `"$helpDestination`" $copyOptions"
            $CommandLine = "$CommandLine /LOG+:`"$logFileNameFull`"" # :: output status to LOG file (append to existing log).
            Add-LogText "==================================================================" $logFileNameFull `
                -ForegroundColor Green
            $Message = @( `
                    "Install Help Files:"
            )
            Add-LogText -Message $Message $logFileNameFull
            # Copy files
            try {
                # New Shell
                if ($jobActionMethodNewWindow) {
                    $roboCopyOptions = @($helpSource, $helpDestination)
                    $optionsArray = $copyOptions.split(" ")
                    foreach ($option in $optionsArray) {
                        $roboCopyOptions += $Option
                    }
                    $roboCopyOptions += "/LOG+:$logFileNameFull"
                    # $installProcess = 
                    Add-LogText "NOTE: Opening new window..." $logFileNameFull `
                        -ForegroundColor Red
                    Start-Process -FilePath "robocopy" -ArgumentList $roboCopyOptions -Verb RunAs
                }
                # this Shell
                else {
                    Add-LogText $CommandLine $logFileNameFull
                    Invoke-Expression $CommandLine
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
    # Add-LogText "==================================================================" $logFileNameFull `
    #     -ForegroundColor Green
    # Add-LogText " " $logFileNameFull
    # Add-LogText "==================" $logFileNameFull
    # Add-LogText "Reloading Mdm Modules." $logFileNameFull
    # Add-LogText "Standard import ($moduleName) test..."
    # Add-LogText "==================================================================" $logFileNameFull `
    #     -ForegroundColor Green
    
    # # Reset
    # Add-LogText "Resetting Mdm Modules for bootstrap use." $logFileNameFull
    # Invoke-DevEnv_Module_Reset
    # Initialize-StdGlobals -DoCheckState

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
    #     # $null = Get-Import -moduleName $moduleName `
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
        $moduleName = "Mdm_Springcomp_MyBox"
        Add-LogText "==================================================================" $logFileNameFull `
            -ForegroundColor Green
        Add-LogText "Automatic Function Imports Test (Export-ModuleMemberScan $moduleName)" $logFileNameFull
        Add-LogText "Export-ModuleMemberScan: $global:moduleRootPath" $logFileNameFull
        $null = Export-ModuleMemberScan -TraceDetails "$global:moduleRootPath\$moduleName"
    } catch {
        $Message = "Export-ModuleMemberScan failed."
        Add-LogText -Message $Message -IsError -ErrorPSItem $_
    }
    # ================================= Wrap-up
    $global:app.timeCompleted = "{0:G}" -f (get-date)
    $Message = @( `
            "==================================================================", `
            "Installation completed at $global:app.timeCompleted", `
            "started at $global:app.timeStartedFormatted", `
            "Source: $source", `
            "Destination: $destination", `
            "Logfile: $logFileNameFull", `
            "==================================================================", `
            "" `
    )
    Add-LogText -Message $Message $logFileNameFull `
        -ForegroundColor Green -logFileNameFull $logFileNameFull

    $Message = "=================================================================="
    Add-LogText -Message $Message $logFileNameFull `
        -ForegroundColor Green -logFileNameFull $logFileNameFull
}
