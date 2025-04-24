function DevEnv_Install_Modules_Win {
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
        DevEnv_Install_Modules_Win    
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
    # DevEnv_Install_Modules_Win
    # ================================= Initialization
    try {
        if (-not $source) { $source = (get-item $PSScriptRoot).parent.FullName }
        if (-not $source.Length -le 0) { $source = (get-item $PSScriptRoot).parent.FullName }
        $source = Convert-Path $source
        $moduleRoot = $source

        $destination = Convert-Path $destination
        if (-not $destination) { $destination = Convert-Path "$env:PROGRAMFILES\WindowsPowerShell\Modules" }

        # This works with uninstalled Modules (both)
        $importName = "Mdm_Std_Library"
        # if (-not $global:scriptPath) { $global:scriptPath = (get-item $PSScriptRoot ).parent.FullName }
        Import-Module -Name "$moduleRoot\$importName\$importName" -Force -ErrorAction Stop
        $global:scriptPath = $moduleRoot
    }
    catch {
        Write-Host " "
        Write-Host "The module environment is unstable." -ForegroundColor Red
        Write-Host "Run the DevEnv_Module_Reset script to reset it." -ForegroundColor Red
        Write-Host " "
        Exit
    }
    # MAIN
    $global:timeStarted = "{0:yyyymmdd_hhmmss}" -f (get-date)
    $global:timeCompleted = $global:timeStarted

    # Logging:
    # $global:logFileNameFull = 
    Get-LogFileName
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
    Add-LogText $logMessage $global:logFileNameFull `
        -foregroundColor Green

    # ================================= Codium setup
    # https://dev.to/opdev1004/how-to-add-open-with-vscodium-for-windows-3g0l

    if (-not $SkipRegistry) {
        Add-LogText "==================================================================" $global:logFileNameFull `
            -foregroundColor Green
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
                Add-LogText "VSCodium not found." $global:logFileNameFull -isError
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
    }

    # ================================= Install modules:

    # ================================= Execute COPY command:
    if (-not $copyOptions) { $copyOptions = "/E /FP /nc /ns /np /TEE" }
    $commandLine = "Robocopy `"$source`" `"$destination`" $copyOptions"
    $commandLine = "$commandLine /LOG+:`"$global:logFileNameFull`"" # :: output status to LOG file (append to existing log).
    # ================================= Reporting:
    # if ($DoVerbose) {
    Add-LogText "==================================================================" $global:logFileNameFull `
        -foregroundColor Green
    $logMessage = @( `
            "Copying SOURCE: ""$source""", `
            "DESTINATION: ""$destination""", `
            " ", `
            "Command: $commandLine", `
            " ", `
            "Starting processing..."
    )
    Add-LogText $logMessage $global:logFileNameFull
    # }

    Add-LogText "Remove modules if they exist" $global:logFileNameFull
    Remove-Item "$destination\Mdm_*" `
        -Recurse -Force `
        -ErrorAction SilentlyContinue

    Add-LogText "Copy modules to destination" $global:logFileNameFull
    if ($DoNewWindow) {
        $roboCopyOptions = @($source, $destination)
        $optionsArray = $copyOptions.split(" ")
        foreach ($option in $optionsArray) {
            $roboCopyOptions += $Option
        }
        $roboCopyOptions += "/LOG+:$global:logFileNameFull"
        # $installProcess = 
        Add-LogText -logMessages "NOTE: Opening new window..." `
            -localLogFileNameFull $global:logFileNameFull `
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
        Add-LogText "==================================================================" $global:logFileNameFull `
            -foregroundColor Green
        Add-LogText " " $global:logFileNameFull
        Add-LogText "Updating Help for Mdm Modules." $global:logFileNameFull
        # Export-Help
        try {
            Export-Help `
                -moduleRoot $source `
                -localLogFileNameFull $global:logFileNameFull `
                -nameFilter $nameFilter
        }
        catch {
            $logMessage = "Export-Help Failed."
            Add-LogText -logMessages $logMessage -isError -localLogFileNameFull $global:logFileNameFull -ErrorPSItem $_
        }
        # # Generate-Documentation - Get-Mdm_Help (redundant)
        # $importName = "Mdm_Modules"
        # try {
        #     # Remove-Module $importName `
        #     # -ErrorAction SilentlyContinue
        #     # Import-Module -Name $importName `
        #     # -Force -ErrorAction Stop
        #     Add-LogText "==================================================================" $global:logFileNameFull `
        #         -foregroundColor Green
        #     Add-LogText "Performing Get-Mdm_Help..." $global:logFileNameFull `
        #         -foregroundColor Green
        #     Get-Mdm_Help
        # }
        # catch {
        #     $logMessage = @( `
        #             "Get-Mdm_Help Failed." `
        #     )
        #     Add-LogText $logMessage $global:logFileNameFull -isError
        # }
        # Write-Mdm_Help
        try {
            # Remove-Module $importName `
            # -ErrorAction SilentlyContinue
            # Import-Module -Name $importName `
            # -Force -ErrorAction Stop
            Add-LogText "==================================================================" $global:logFileNameFull `
                -foregroundColor Green
            Add-LogText "Performing Write-Mdm_Help..." $global:logFileNameFull `
                -foregroundColor Green
            Write-Mdm_Help -moduleRoot $moduleRoot
        }
        catch {
            $logMessage = "Write-Mdm_Help Failed."
            Add-LogText -logMessages $logMessage -isError -localLogFileNameFull $global:logFileNameFull -ErrorPSItem $_
        }
        # Get-AllCommands
        try {
            # Remove-Module $importName `
            # -ErrorAction SilentlyContinue
            # Import-Module -Name $importName `
            # -Force -ErrorAction Stop
            Add-LogText "==================================================================" $global:logFileNameFull `
                -foregroundColor Green
            Add-LogText "Performing Get-AllCommands..." $global:logFileNameFull `
                -foregroundColor Green
            Get-AllCommands
        }
        catch {
            $logMessage = "Get-AllCommands Failed."
            Add-LogText -logMessages $logMessage -isError -localLogFileNameFull $global:logFileNameFull -ErrorPSItem $_
        }
        # Install Help files
        $helpSource = "$source\Mdm_Bootstrap\help"
        $helpDestination = "$destination\Mdm_Bootstrap\help"
        # $helpFileName = "$Mdm_Help.html"  # Update the path
        $commandLine = "Robocopy `"$helpSource`" `"$helpDestination`" $copyOptions"
        $commandLine = "$commandLine /LOG+:`"$global:logFileNameFull`"" # :: output status to LOG file (append to existing log).
        Add-LogText "==================================================================" $global:logFileNameFull `
            -foregroundColor Green
        $logMessage = @( `
                "Install Help Files:"
        )
        Add-LogText $logMessage $global:logFileNameFull
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
        }
        catch {
            $logMessage = "Failed to install help files."
            Add-LogText -logMessages $logMessage -isError -localLogFileNameFull $global:logFileNameFull -ErrorPSItem $_
        }
        # Update system folders
    }

    # ================================= Test stability
    Add-LogText "==================================================================" $global:logFileNameFull `
        -foregroundColor Green
    Add-LogText " " $global:logFileNameFull
    Add-LogText "==================" $global:logFileNameFull
    Add-LogText "Reloading Mdm Modules." $global:logFileNameFull
    $moduleName = "Mdm_Modules"
    Add-LogText "Standard import ($moduleName) test..."
    # Import Modules
    try {
        # Import-Module -name $moduleName `
        Remove-Module -Name "$moduleRoot\$moduleName\$moduleName" `
            -Force `
            -ErrorAction Stop
        # -Verbose `
        # Import-Module -name Mdm_Modules -Force >> $global:logFileNameFull
    }
    catch {
        $logMessage = "No need to remove module: $moduleName."
        Add-LogText -logMessages $logMessage -isWarning -SkipScriptLineDisplay -localLogFileNameFull $global:logFileNameFull -ErrorPSItem $_
    }
    # Import Modules
    try {
        # Import-Module -name $moduleName `
        Import-Module -Name "$moduleRoot\$moduleName\$moduleName" `
            -Force `
            -ErrorAction Stop
        # -Verbose `
        # Import-Module -name Mdm_Modules -Force >> $global:logFileNameFull
    }
    catch {
        $logMessage = "Failed to import module: $moduleName."
        Add-LogText -logMessages $logMessage -isError -localLogFileNameFull $global:logFileNameFull -ErrorPSItem $_ -isError
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
        #     Add-LogText $logMessage $global:logFileNameFull -isError
        # }
    }
    # Export-ModuleMemberScan
    try {
        Add-LogText "==================" $global:logFileNameFull
        Add-LogText "Automatic Function Imports Test (Export-ModuleMemberScan $moduleName)" $global:logFileNameFull
        Add-LogText "Export-ModuleMemberScan $moduleRoot" $global:logFileNameFull
        Export-ModuleMemberScan "$moduleRoot\$moduleName"
    }
    catch {
        $logMessage = "Export-ModuleMemberScan failed."
        Add-LogText -logMessages $logMessage -isError -localLogFileNameFull $global:logFileNameFull -ErrorPSItem $_
    }
    # ================================= Wrapup
    # if ($DoVerbose) { Add-LogText " " $global:logFileNameFull }
    $global:timeCompleted = "{0:G}" -f (get-date)
    $logMessage = @( `
            "==================================================================", `
            "Installation completed at $global:timeCompleted", `
            "started at $global:timeStarted", `
            "Source: $source", `
            "Destination: $destination", `
            "Logfile: $global:logFileNameFull", `
            "==================================================================", `
            "" `
    )
    Add-LogText $logMessage $global:logFileNameFull
    Add-LogText "==================================================================" $global:logFileNameFull `
        -foregroundColor Green
    Add-LogText "Resetting Mdm Modules for bootstrap use." $global:logFileNameFull
    Invoke-Expression DevEnv_Module_Reset
}
