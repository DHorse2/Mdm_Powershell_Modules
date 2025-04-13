function Dev_Env_Install_Modules_Win {
    <#
    .SYNOPSIS
        Install or update Mdm Modules.
    .DESCRIPTION
        This installs the libraries to the live system using Robocopy.
    .PARAMETER source
        default: "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules" 
    .PARAMETER destination
        default: "$env:PROGRAMFILES\\WindowsPowerShell\Modules"

        .PARAMETER logFilePath
        default: "G:\Script\Powershell\Mdm_Powershell_Modules\log\"
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
        Dev_Env_Install_Modules_Win    
#>
    [CmdletBinding()]
    param (
        [switch]$DoVerbose,
        [switch]$DoPause,
        [switch]$DoDebug,
        [string]$source = "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules",
        [string]$destination = "$env:PROGRAMFILES\WindowsPowerShell\Modules",
        [string]$logFilePath = "G:\Script\Powershell\Mdm_Powershell_Modules\log",
        [string]$logFileName = "Mdm_Installation_Log",
        [switch]$LogOneFile,
        [string]$nameFilter = "Mdm_*",
        [switch]$SkipHelp,
        [switch]$SkipRegistry,
        [switch]$DoNewWindow,
        [string]$companyName = "MacroDM",
        [string]$copyOptions = "/E /FP /nc /ns /np /TEE"

    )
    # Dev_Env_Install_Modules_Win
    # ================================= Initialization

    if (-not $source) { $source = (get-item $PSScriptRoot).parent.FullName }
    if (-not $source.Length -le 0) { $source = (get-item $PSScriptRoot).parent.FullName }
    $source = Convert-Path $source
    $moduleRoot = $source

    $destination = Convert-Path $destination
    if (-not $destination) { $destination = Convert-Path "$env:PROGRAMFILES\WindowsPowerShell\Modules" }

    # This works with uninstalled Modules (both)
    $importName = "Mdm_Std_Library"
    # if (-not $global:scriptPath) { $global:scriptPath = (get-item $PSScriptRoot ).parent.FullName }
    Write-Host "$($moduleRoot.Length) <<<"
    Import-Module -Name "$moduleRoot\$importName\$importName" -Force -ErrorAction Stop

    # MAIN
    $global:timeStarted = "{0:yyyymmdd_hhmmss}" -f (get-date)
    $global:timeCompleted = $global:timeStarted

    # Logging:
    # $global:logFileNameFull = 
    Get-LogFileNaame
    $global:logFileNameFull = Convert-Path $global:logFileNameFull
    Write-Host "Log File: $global:logFileNameFull"
    $logMessage = @(
        " ", `
            "==================================================================", `
            "Installing Mdm Modules at $global:timeStarted", `
            "==================================================================", `
            "Source: $source", `
            "Destination: $destination", `
            "Logfile: $global:logFileNameFull"
    )
    LogText $logMessage $global:logFileNameFull `
        -foregroundColor Green

    # ================================= Codium setup
    # https://dev.to/opdev1004/how-to-add-open-with-vscodium-for-windows-3g0l

    if (-not $SkipRegistry) {
        LogText "==================================================================" $global:logFileNameFull `
            -foregroundColor Green
        LogText "Updating Registry" $global:logFileNameFull
        LogText "Updating: $regPath" $global:logFileNameFull
    
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
        }
        else {
            # Codium must be installed for all users.
            $appExePath = Resolve-Path "$env:Programfiles\VSCodium\VSCodium.exe"
            if (Test-Path $appExePath) {
                # Resolve the path
                $appExePath = Resolve-Path $appExePath | Select-Object -ExpandProperty Path
            }
            else {
                # Throw an error todo.
                LogText "VSCodium not found." $global:logFileNameFull -isError
            }
        }
        $commandString = "`"$appExePath`" `"%V`""
        # # Note on UserProfile: This method uses the user's account name:

        # Directory shell
        $regPath = "HKEY_CLASSES_ROOT\Directory\shell" 
        LogText "Updating: $regPath" $global:logFileNameFull
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
        LogText "Updating: $regPath" $global:logFileNameFull
        $regKey = "command"
        if (-not (Test-Path "Registry::$regPath\$regKey")) {
            New-Item -Path "Registry::$regPath" -Name $regKey -Force
        }
        # Set the command
        $regProperty = "(Default)"
        Set-ItemProperty -Path "Registry::$regPath\$regKey" -Name $regProperty -Value $commandString -Force

        # Directory Background Shell
        $regPath = "HKEY_CLASSES_ROOT\Directory\Background\shell"
        LogText "Updating: $regPath" $global:logFileNameFull
        $regKey = "Open with VSCodium"
        if (-not (Test-Path "Registry::$regPath\$regKey")) {
            New-Item -Path "Registry::$regPath" -Name $regKey -Force
        }
        # Set Default
        $regProperty = "(Default)"
        Set-ItemProperty -Path "Registry::$regPath\$regKey" -Name $regProperty -Value $regKey -Force

        $regPath = "$regPath\$regKey"
        LogText "Updating: $regPath" $global:logFileNameFull
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
    }

    # ================================= Install modules:

    # ================================= Execute COPY command:
    if (-not $copyOptions) { $copyOptions = "/E /FP /nc /ns /np /TEE" }
    $commandLine = "Robocopy `"$source`" `"$destination`" $copyOptions"
    $commandLine = "$commandLine /LOG+:`"$global:logFileNameFull`"" # :: output status to LOG file (append to existing log).
    # ================================= Reporting:
    # if ($DoVerbose) {
    LogText "==================================================================" $global:logFileNameFull `
        -foregroundColor Green
    $logMessage = @( `
            "Copying SOURCE: ""$source""", `
            "DESTINATION: ""$destination""", `
            " ", `
            "Command: $commandLine", `
            " ", `
            "Starting processing..."
    )
    LogText $logMessage $global:logFileNameFull
    # }

    LogText "Remove modules if they exist" $global:logFileNameFull
    Remove-Item "$destination\Mdm_*" `
        -Recurse -Force `
        -ErrorAction SilentlyContinue

    LogText "Copy modules to destination" $global:logFileNameFull
    if ($DoNewWindow) {
        $roboCopyOptions = @($source, $destination)
        $optionsArray = $copyOptions.split(" ")
        foreach ($option in $optionsArray) {
            $roboCopyOptions += $Option
        }
        $roboCopyOptions += "/LOG+:$global:logFileNameFull"
        # $installProcess = 
        LogText "NOTE: Opening new window..." `
            $global:logFileNameFull `
            -ForegroundColor Red
        Start-Process -FilePath "robocopy" `
            -ArgumentList $roboCopyOptions `
            -Verb RunAs `
            -NoNewWindow
        # s/b -NoExit???
        # Start-Process cmd "/c `"$commandLine & pause `""
        # $installProcess = Start-Process powershell -ArgumentList "-NoProfile -Command $commandLine" -Verb RunAs -NoNewWindow
        # Start-Process powershell -ArgumentList "-NoProfile -Command `"$commandLine`"" -Verb RunAs
        # Start-Process powershell -ArgumentList "-NoExit -Command $commandLine" -Verb RunAs
        # Note: NoNewWindow might be preferred if output isn't captured.
        # ================================= Wait for completion
        # if you have a process:
        # $installProcess.WaitForExit()

    }
    else {
        Invoke-Expression $commandLine
    }

    # ================================= Help files
    if (-not $SkipHelp) {
        LogText "==================================================================" $global:logFileNameFull `
            -foregroundColor Green
        LogText " " $global:logFileNameFull
        LogText "Updating Help for Mdm Modules." $global:logFileNameFull
        # Export-Help
        try {
            Export-Help -moduleRoot $source -localLogFileNameFull $global:logFileNameFull
        }
        catch {
            $logMessage = "Export-Help Failed."
            LogText $logMessage $global:logFileNameFull -isError
        }
        # # Generate-Documentation - Get-Mdm_Help (redundant)
        # $importName = "Mdm_Modules"
        # try {
        #     # Remove-Module $importName `
        #     # -ErrorAction SilentlyContinue
        #     # Import-Module -Name $importName `
        #     # -Force -ErrorAction Stop
        #     LogText "==================================================================" $global:logFileNameFull `
        #         -foregroundColor Green
        #     LogText "Performing Get-Mdm_Help..." $global:logFileNameFull `
        #         -foregroundColor Green
        #     Get-Mdm_Help
        # }
        # catch {
        #     $logMessage = @( `
        #             "Get-Mdm_Help Failed." `
        #     )
        #     LogText $logMessage $global:logFileNameFull -isError
        # }
        # Write-Mdm_Help
        try {
            # Remove-Module $importName `
            # -ErrorAction SilentlyContinue
            # Import-Module -Name $importName `
            # -Force -ErrorAction Stop
            LogText "==================================================================" $global:logFileNameFull `
                -foregroundColor Green
            LogText "Performing Write-Mdm_Help..." $global:logFileNameFull `
                -foregroundColor Green
            Write-Mdm_Help -moduleRoot $moduleRoot
        }
        catch {
            $logMessage = "Write-Mdm_Help Failed."
            LogText $logMessage $global:logFileNameFull -isError
        }
        # Get-AllCommands
        try {
            # Remove-Module $importName `
            # -ErrorAction SilentlyContinue
            # Import-Module -Name $importName `
            # -Force -ErrorAction Stop
            LogText "==================================================================" $global:logFileNameFull `
                -foregroundColor Green
            LogText "Performing Get-AllCommands..." $global:logFileNameFull `
                -foregroundColor Green
            Get-AllCommands
        }
        catch {
            $logMessage = "Get-AllCommands Failed."
            LogText $logMessage $global:logFileNameFull -isError
        }
        # Install Help files
        $helpSource = "$source\Mdm_Bootstrap\help"
        $helpDestination = "$destination\Mdm_Bootstrap\help"
        # $helpFileName = "$Mdm_Help.html"  # Update the path
        $commandLine = "Robocopy `"$helpSource`" `"$helpDestination`" $copyOptions"
        $commandLine = "$commandLine /LOG+:`"$global:logFileNameFull`"" # :: output status to LOG file (append to existing log).
        LogText "==================================================================" $global:logFileNameFull `
            -foregroundColor Green
        $logMessage = @( `
                "Install Help Files:"
        )
        LogText $logMessage $global:logFileNameFull
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
                LogText "NOTE: Opening new window..." $global:logFileNameFull `
                    -ForegroundColor Red
                Start-Process -FilePath "robocopy" -ArgumentList $roboCopyOptions -Verb RunAs
            }
            # this Shell
            else {
                LogText $commandLine $global:logFileNameFull
                Invoke-Expression $commandLine
            }
        }
        catch {
            $logMessage = "Failed to install help files."
            LogText $logMessage $global:logFileNameFull -isError
        }
        # Update system folders
    }

    # ================================= Test stability
    LogText "==================================================================" $global:logFileNameFull `
        -foregroundColor Green
    LogText " " $global:logFileNameFull
    LogText "==================" $global:logFileNameFull
    LogText "Reloading Mdm Modules." $global:logFileNameFull
    $moduleName = "Mdm_Modules"
    LogText "Standard import ($moduleName) test..."
    # Import Modules
    try {
        # Import-Module -name $moduleName `
        Remove-Module -Name "$moduleRoot\$moduleName\$moduleName" `
            -Force `
            -Verbose `
            -ErrorAction SilentlyContinue
        # Import-Module -name Mdm_Modules -Force >> $global:logFileNameFull
    }
    catch {
        $logMessage = "Failed to remove module: $moduleName."
        LogText $logMessage $global:logFileNameFull -isError
    }
    # Import Modules
    try {
        # Import-Module -name $moduleName `
        Import-Module -Name "$moduleRoot\$moduleName\$moduleName" `
            -Force `
            -Verbose `
            -ErrorAction Stop
        # Import-Module -name Mdm_Modules -Force >> $global:logFileNameFull
    }
    catch {
        $logMessage = "Failed to import module: $moduleName."
        LogText $logMessage $global:logFileNameFull -isError
        # try {
        #     # Import-Module -name $moduleName `
        #     Import-Module -Name $moduleName `
        #         -Force `
        #         -Verbose `
        #         -ErrorAction Stop
        #     # Import-Module -name Mdm_Modules -Force >> $global:logFileNameFull
        # }
        # catch {
        #     $logMessage = "Failed retry to import module: $moduleName."
        #     LogText $logMessage $global:logFileNameFull -isError
        # }
    }
    # Build-ModuleExports
    try {
        LogText "==================" $global:logFileNameFull
        LogText "Automatic Function Imports Test (Build-ModuleExports $moduleName)" $global:logFileNameFull
        LogText "Build-ModuleExports $moduleRoot" $global:logFileNameFull
        Build-ModuleExports "$moduleRoot\$moduleName"
    }
    catch {
        $logMessage = "Build-ModuleExports failed."
        LogText $logMessage $global:logFileNameFull -isError
    }

    # ================================= Wrapup
    # if ($DoVerbose) { LogText " " $global:logFileNameFull }
    $global:timeCompleted = "{0:G}" -f (get-date)
    $logMessage = @( `
            "==================================================================", `
            "Installation completed at $global:timeCompleted", `
            "started at $global:timeStarted", `
            "Source: $source", `
            "Destination: $destination", `
            "Logfile: $global:logFileNameFull", `
            "==================================================================" `
    )
    LogText $logMessage $global:logFileNameFull
    if ($DoVerbose) { LogText " " $global:logFileNameFull }

    # ================================= Copy with progress %
    # $source=ls c:\temp *.*
    # $i=1
    # $source| %{
    #     [int]$percent = $i / $source.count * 100
    #     Write-Progress -Activity "Copying ... ($percent %)" -status $_  -PercentComplete $percent -verbose
    #     copy $_.fullName -Destination c:\test 
    #     $i++
    # }
    #
    # 2025/03/26 09:11:03 ERROR 5 (0x00000005) Accessing Destination Directory C:\Program Files\WindowsPowerShell\Modules\
    # Access is denied.
    # Waiting 30 seconds... Retrying...

    # ================================= Robocopy documentation:
    # /V - verbose
    # /MIRror = /E /PURGE (cleans out depreciated files (scripts))
    # /MIRror folder contents
    # /FP : Include Full Pathname of files in the output.
    # /NS : No Size - don’t log file sizes.
    #
    # Other Robocopy options:
    # /L :: List only - don't copy, timestamp or delete any files.
    # /X :: report all eXtra files, not just those selected.
    # /V :: produce Verbose output, showing skipped files.
    # /TS :: include source file Time Stamps in the output.
    # /FP :: include Full Pathname of files in the output.
    # /BYTES :: Print sizes as bytes.
    # 
    # /NS :: No Size - don't log file sizes.
    # /NC :: No Class - don't log file classes.
    # /NFL :: No File List - don't log file names.
    # /NDL :: No Directory List - don't log directory names.
    # 
    # /NP :: No Progress - don't display percentage copied.
    # /ETA :: show Estimated Time of Arrival of copied files.
    # 
    # /LOG:file :: output status to LOG file (overwrite existing log).
    # /LOG+:file :: output status to LOG file (append to existing log).
}