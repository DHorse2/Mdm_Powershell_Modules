
# Mdm_Std.ps1
function Initialize-StdGlobals {
    # TODO Hold NOTE: Notes for help in the params
    # Initialize-StdGlobals -InitForce -InitStd -InitLogFile -InitGui `
    # -appName $appName -appDirectory $appDirectory `
    # -DoSetGlobal -Title $title `
    # -logFilePath "$appDirectory\log" -DoOpen -DoCheckState -DoSetGlobal
    [CmdletBinding()]
    param (
        [CommandApp]$app = $null,
        [string]$appDirectory = ".",
        [string]$companyName = "",
        [string]$title = "",
        # Will force Std, Gui and LogFile:
        [switch]$InitForce,
        [switch]$InitStd,
        [switch]$InitGui,
        [switch]$InitLogFile,
        # Logfile values from here:
        [string]$logFilePath = "",
        [string]$logFileName = "",
        [string]$logFileExtension = "",
        [switch]$LogOneFile,
        # State Control
        [switch]$DoCheckState,
        [switch]$DoOpen,
        [switch]$SkipCreate,
        # Globals
        [switch]$DoClearGlobal,
        # DoClear redundant when true:
        [switch]$DoSetGlobal,
        # Std params:
        # Applies to OS commands (i.e. Import-) and not the InitXxx
        [string]$appName = "",
        [int]$actionStep = 0,
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [string]$logFileNameFull = ""
    )
    begin {
        # Session and Global Management
        try {
            # Session Arrays
            if (-not $global:moduleArray) {
                $global:moduleArray = @{}
                $global:moduleSequence = 0
            }
            if (-not $global:appArray) {
                $global:appArray = @{}
                $global:appSequence = 0
            }
            if (-not $global:logFileNames) { $global:logFileNames = @{} }
            $global:appName = "Global"
            $global:appLogFileNameFull = ""
            $global:appExists = $false
            $global:now = [System.DateTime]::Now
            $appArrayUpdate = $false
            #region Global Management
            # Global is a singleton to control state.
            # One app will generally take ownership of this.
            # This can be be overridden/overwritten, 
            # such as with the DevEnvGui (or a similar) GUI user interface.
            # DevEnvGui maintains the modules and what gets installed on the system.
            if (-not $global:app -or $global:app -isnot [CommandApp]) {
                try {
                    $global:app = $global:appArray[$global:appName]
                } catch { $null }
                if (-not $global:app) {
                    if ($DoVerbose) {
                        Add-LogText -Message "Initialize: $global:appName State Creation." -ForegroundColor Yellow -logFileNameFull $logFileNameFull
                        if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
                    }
                    if (-not $title) { $title = "Global Session Management Object" }
                    $global:appSequence++
                    $timeStarted = [System.DateTime]::Now
                    $timeCompleted = [System.DateTime]::MinValue
                    [CommandApp]$global:app = [CommandApp]::new(
                        $global:appName,
                        $appDirectory,
                        $title,
                        $global:appSequence,
                        -1,
                        $null,
                        $null,
                        $logFileNameFull,
                        $timeStarted,
                        $timeCompleted,
                        @{}
                    )
                    $appArrayUpdate = $true
                    $global:appArray[$global:appName] = $global:app
                } else { $global:appExists = $true }
            } else { $global:appExists = $true }
            if ($global:appExists) {
                if (-not $global:appArray[$global:appName]) { $global:appArray[$global:appName] = $global:app }
                $timeStarted = $global:app.timeStarted
                $timeCompleted = $global:app.timeCompleted
                if (-not $appDirectory) { $appDirectory = $global:app.appDirectory }
                if (-not $companyName) { $companyName = $global:app.companyName }
                if (-not $title) { $title = $global:app.title }
                # if (-not $logFileNameFull) { $logFileNameFull = $global:app.logFileNameFull }
            }
            if (-not $appDirectory) { $appDirectory = "$($(get-item $PSScriptRoot).Parent.FullName)" }
            $timeStartedFormatted = "{0:yyyyMMdd_HHmmss}" -f $timeStarted
            # The $global:app now exists
            # Now do Gatekeeping. Do not execute twice
            # if (-not $DoForce -and $DoCheckState -and $global:app.InitDone) { return }
            # Script Path - module and projectRootPath
            if (-not $global:moduleRootPath) {
                $folderName = Split-Path ((get-item $PSScriptRoot ).FullName) -Parent
                if ( $folderName -eq "Public" -or $folderName -eq "Private" ) {
                    $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.Parent.FullName
                } else { $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.FullName }
            }
            if (-not $global:projectRootPath) { $global:projectRootPath = (get-item $global:moduleRootPath).Parent.Parent.FullName }
            $global:app.moduleRootPath = $global:moduleRootPath
            $global:app.projectRootPath = $global:projectRootPath
            if ($global:app.InitStdDone -and $global:app.InitGuiDone -and $global:app.InitLogFileDone) { $global:app.InitDone = $true }

            # Application Log File Name Full
            if (-not $global:app.LogFileNameFull) { $global:app.LogFileNameFull = "$($(get-item $PSScriptRoot).Parent.FullName)\log\Application_Log.ps1" }
            if (-not $logFileNameFull) { $logFileNameFull = $global:app.logFileNameFull }
            #endregion
        } catch {
            $Message = "Initialize-Std Globals Error initializing Global information."
            Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
            if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
            if ($DoVerbose) { Add-LogText -Message "Initialize continuing..." -ForegroundColor Yellow -logFileNameFull $logFileNameFull }
        }
    }
    process {
        try {
            # Prepare data
            # Initialize Standard Library Global Data
            if ($InitStd -and ($InitForce -or -not $app -or -not $app.InitStdDone)) {
                # if (-not $DoForce -and $DoCheckState -and $app.InitDone) { return }
                if ($DoClearGlobal -and $global:appExists) {
                    if ($DoVerbose) {
                        Add-LogText -Message "Initialize: State: Clear Global Data." -ForegroundColor Yellow -logFileNameFull $logFileNameFull
                        if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
                    }
                    Clear-StdGlobals # $global:app
                    $global:appName = "Global"
                    $global:appArray[$global:appName] = $global:app
                } # -DoDispose would remove modules
            }
            # Setting (passing) $appName triggers
            # a lookup and possible creation of a new $app Object
            # Note that a previously loaded $app may have been passed.
            # It would take precedence.
            # Use the passed state if available. Global when no App.
            if (-not $app -or $app -isnot [CommandApp]) {
                # $app was not passed.
                try {
                    # No $appName means this is an Import, 
                    # not an app initialization.
                    # The global CommandApp state always exists. 
                    # Each app has a CommandApp state.
                    # Use the Global state is not an AppName caller.
                    if (-not $appName) {
                        if ($DoVerbose) {
                            Add-LogText -Message "Initialize: using Global state. No App present." -ForegroundColor Yellow -logFileNameFull $logFileNameFull
                            if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
                        }
                        $appName = "Global"
                    }
                    # Load the state if it exists.
                    # $app = $global:appArray[$appName]
                    try {
                        $app = $global:appArray[$appName]
                        # Note. Global can have two pointers to it now.
                    } catch { $null }
                    # If it doesn't exist create a named $appName state
                    if (-not $app) {
                        if ($DoVerbose) {
                            Add-LogText -Message "Initialize: $appName State Creation." -ForegroundColor Yellow -logFileNameFull $logFileNameFull
                            if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
                        }
                        $global:appSequence++
                        [CommandApp]$app = [CommandApp]::new(
                            $appName,
                            $appDirectory,
                            $title,
                            $global:appSequence,
                            -1,
                            $null,
                            $null,
                            $logFileNameFull,
                            $timeStarted,
                            $timeCompleted,
                            @{}
                        )
                        $appArrayUpdate = $true
                        $app.moduleRootPath = $global:moduleRootPath
                        $app.projectRootPath = $global:projectRootPath
                        # $global:appName = $appName
                        $global:appArray[$appName] = $app
                        $Message = "Application: $($app.appName) started $($app.timeStarted)"
                        Write-FileFromText -Message $Message -Append -logFileNameFull "$($(get-item $PSScriptRoot).Parent.FullName)\log\Application_Log.ps1"
                    }
                    
                } catch {
                    $Message = "Initialize-StdGlobals error initializing Application Control information."
                    Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
                    if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
                    if ($DoVerbose) { Add-LogText -Message "Initialize continuing..." -ForegroundColor Yellow -logFileNameFull $logFileNameFull }
                }
            }
            # Now do Gatekeeping. Do not execute twice
            # if (-not $InitForce -and $($DoCheckState -and $app.InitDone)) { return }

            # Standard Library Objects
            if ($InitStd -and ($InitForce -or ($DoCheckState -and -not $app.InitStdDone))) {
                try {
                    $Message = "Initialize: State: Standard Library."
                    if ($DoVerbose) {
                        Add-LogText -Message $Message -ForegroundColor Yellow -logFileNameFull $logFileNameFull
                        if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
                    } elseif ($DoPause -or ($KeepOpen -and -not $Silent)) { Wait-AnyKey -Message "$Message Enter any key to continue..." }
                    # This indicates that the modules have not been previously imported. 
                    # $app.InitDone = $false
                    # $app.InitDone = $false
                    # $app.InitStdDone = $false
                    # $app.InitGuiDone = $false
                    # $app.InitLogFileDone = $false
                    #
                    # Module Control and defaults
                    # Anyone can turn on these settings without the if,
                    # That questionable. It's has to be opinionated.
                    if ($DoSetGlobal) {
                        $global:app.DoVerbose = $DoVerbose
                        $global:app.DoPause = $DoPause
                        if (-not $DoDebug) { $DoDebug = Assert-Debug -ErrorAction SilentlyContinue }
                        $global:app.DoDebug = $DoDebug
                        $global:app.DoForce = $DoForce
                    }
                    # Modules array. These will be auto documented
                    [array]$global:moduleCoreNames = @(
                        "Mdm_Bootstrap", 
                        "Mdm_Std_Library", 
                        "Mdm_WinFormPS",
                        "Mdm_DevEnv_Install", 
                        "Mdm_Modules"
                    )
                    # Modules array. These are imported external product
                    [array]$global:moduleNames = @(
                        "Mdm_Bootstrap", 
                        "Mdm_Std_Library", 
                        "Mdm_WinFormPS",
                        "Mdm_DevEnv_Install", 
                        "Mdm_Modules", 
                        "Mdm_Nightroman_PowerShelf", 
                        "Mdm_Springcomp_MyBox"
                    )

                    $global:sourceDefault = "G:\Script\Powershell\Mdm_PowershelModules\src\Modules"
                    $global:destinationDefault = "C:\Program Files\WindowsPowerShell\Modules"
                    $global:folderPath = "$((get-item $PSScriptRoot).Parent.FullName)\data" # Now \Mdm_Std_Library\data\
                    $global:folderName = Split-Path $global:folderPath -Parent 
        
                    if ($InitForce -or $DoSetGlobal -or -not $global:jobActionTimer) {
                        # Data Storage
                        [string]$global:dataSourceName = "Application"
                        [string]$global:dataSet = "Data"
                        [string]$global:dataSetState = "Current"
                        [string]$global:dataSetDirectory = "$($(Get-Item $PSScriptRoot).Parent.FullName)\data"
                        [bool]$global:dataSetBusy = $false

                        [hashtable]$global:appDataArray = New-Object System.Collections.Hashtable
                        [bool]$global:appDataChanged = $false

                        # AutoSave
                        [bool]$global:DoTimer = $true
                        [System.Windows.Forms.Timer]$global:autoSaveTimer = $null
                        [int]$global:autoSaveTimerInterval = 30000
                        [bool]$global:autoSaveBusy = $false

                        # Job and Invoke Handling
                        [System.Management.Automation.Job]$global:job = $null
                        [bool]$global:jobActionMethodNewWindow = $false
                        [string]$global:jobActionMethod = "Invoke-Command" # "Start-Process" # vs "Invoke-Command"
                        [int]$global:jobActionId = 0
                        [System.Windows.Forms.Timer]$global:jobActionTimer = $null
                        [int]$global:jobActionTimerInterval = 500
                        [bool]$global:jobActionTimerBusy = $false

                        # Parameters
                        # [hashtable]$global:commonParamsPrelude = @{}
                        # [hashtable]$global:commonParams = @{}
                        # [hashtable]$global:combinedParams = @{}
                        # [hashtable]$global:mdmParams = @{}
                        # also @importParams or any special case
                    }
                    #region Error Control, display and handling options:
                    [bool]$global:UseTrace = $true
                    [bool]$global:UseTraceDetails = $true
                    [bool]$global:UseTraceStack = $true
                    [bool]$global:DebugProgressFindName = $true
                    [int]$global:debugTraceStep = 0
                    [string]$global:debugSetting = ""
                    # include debug info with warnings
                    [bool]$global:UseTraceWarning = $true
                    # include full details with warnings
                    [bool]$global:UseTraceWarningDetails = $false
                    # Built in Powershell based Method:
                    [bool]$global:UsePsBreakpoint = $true
        
                    # Set-PSBreakpoint
                    # pause on this cmdlet/function name
                    [bool]$global:DebugProgressFindName = $true
                    [array]$global:debugFunctionNames = @()
                    # [array]$global:debugFunctionNames = @("Get-Vs", "Get-DevEnvVersions")
                    # [array]$global:debugFunctionNames = @("Get-Vs", "Get-DevEnvVersions", "Add-RegistryPath", "Assert-RegistryValue")
                    [string]$global:debugFunctionName = ""
                    [bool]$global:DebugInScriptDebugger = $false
                    [int]$global:debugFunctioLineNumber = 0
                    [string]$global:debugWatchVariable = ""
                    [string]$global:debugMode = "Write"
            
                    # Built in Powershell based Method:
                    if ($global:UsePsBreakpoint) {
                        try {
                            #PSDebug
                            if ($global:debugSetting.Length -ge 1) {
                                $commandNext = "Set-PSDebug -$global:debugSetting"
                            } else {
                                $commandNext = "Set-PSDebug -Off"
                            }
                            Invoke-Expression $commandNext
                            #PSBreakpoint
                            #  TODO Get-PSBreakpoint | Remove-PSBreakpoint
                            Set-PSBreakPoint -Command "Debug-Script" -Action { 
                                Add-LogText -Message "<*>" -ForegroundColor Red -logFileNameFull $logFileNameFull
                                # Debug-Script -Break;
                            }
                            if ($global:debugFunctionName.Length -ge 1) {
                                Set-PSBreakPoint -Command $global:debugFunctionName -Action { Debug-Script -Break; }
                                Add-LogText -Message "Break set up for $global:debugFunctionName" -ForegroundColor Green -logFileNameFull $logFileNameFull
                                if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
                            }
                            foreach ($functionName in $global:debugFunctionNames) {
                                Set-PSBreakpoint -Command $functionName -Action { Debug-Script -Break; }
                                Add-LogText -Message "Break set up for $functionName" -ForegroundColor Green -logFileNameFull $logFileNameFull
                                if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
                            }
                        } catch {
                            Add-LogText -Message "Initialize-StdGlobals Error in PSBreakpoint ($global:UsePsBreakpoint) zone. $global:NL$_" `
                                -ForegroundColor Red -logFileNameFull $logFileNameFull
                            if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
                            #  -ErrorRecord $_
                            Add-LogText -Message "Powershell debug features are currently unavailable in the Mdm Standard Library" `
                                -ForegroundColor Red -logFileNameFull $logFileNameFull
                        }
                        # This doesn't work:
                        # Source : https://stackoverflow.com/questions/20912371/is-there-a-way-to-enter-the-debugger-on-an-error/
                        # Get the current session using Get-PSSession
                        # $currentSession = New-PSSession
                        # $currentSession = Get-PSSession
                        # $currentSession = Get-PSSession | Where-Object { $_.Id -eq $session.Id }
        
                        # Extract relevant properties from the existing session
                        # $computerName = $currentSession.ComputerName
                        # $credential = $currentSession.Credential
                        # $newSession = New-PSSession -ComputerName $computerName -Credential $credential
                        # Invoke-Command -Session $currentSession -ScriptBlock {
                        # Set-PSBreakPoint -Command Debug-Script -Action { break; }
                        # Break on LINE
                        # Set-PSBreakpoint -Script "C:\Path\To\YourScript.ps1" -Line 10
                        # }
                    }
                    [string]$global:debugErrorActionPreference = "Continue"
                    [string]$global:msgAnykey = ""
                    [string]$global:msgYorN = ""
                    #endregion
                    #region PrivateData:
                    $global:PrivateData = (Get-Host).PrivateData
                    $global:appHostData = (Get-Host)
                    $global:PrivateDataTest1 = Get-ModulePrivateData
                    $global:PrivateDataItem = [PrivateDataInfo]::new("Mdm_Std_Library", "")
                    # $global:PrivateData1 = [PrivateDataInfo]::Load("Mdm_Std_Library","")
                    if ($DoVerbose -and $global:PrivateDataItem) {
                        if ($DoVerbose) {
                            Add-LogText -Message $($global:PrivateDataItem.Display()) -logFileNameFull $logFileNameFull
                            if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
                        }
                    }
                    # PrivateData included Color of error and warning text
                    #    # Colors: These are Media Colors (vs ConsoleColor)
                    #       BackgroundColor: The background color of the console.
                    #       ForegroundColor: The foreground (text) color of the console.
                    #       WarningBackgroundColor
                    #       WarningForegroundColor
                    #       ErrorBackgroundColor
                    #       ErrorForegroundColor

                    #     WindowTitle: The title of the console window.
                    #     MaxWindowWidth: The maximum width of the console window.
                    #     MaxWindowHeight: The maximum height of the console window.
                    #     WindowWidth: The current width of the console window.
                    #     WindowHeight: The current height of the console window.
                
                    #     BufferWidth: The width of the buffer.
                    #     BufferHeight: The height of the buffer.
                    #     CursorSize: The size of the cursor.
                    #     KeyDown: A method to handle key down events.
                    #     KeyUp: A method to handle key up events.
                    #     CursorVisible: A boolean indicating whether the cursor is visible.
                    # List of fields present in Host PrivateData
                    # (Get-Host).PrivateData | Get-Member
                    #endregion
                    #region Meta Data:
                    $global:scriptData = [ScriptState]::new()
                    $global:invocation = $MyInvocation
                    $global:scriptData.Package = "Mdm_Modules"
                    $global:scriptData.Module = $global:invocation.MyCommand.ModuleName
                    $global:moduleArray[$global:scriptData.Module] = $global:invocation.MyCommand.Module
                    $global:scriptData.Statement = $global:invocation.Statement
                    $global:scriptData.ScriptName = $global:invocation.ScriptName
                    $global:scriptData.FunctionName = $global:invocation.FunctionName
                    $global:scriptData.CommandType = $global:invocation.MyCommand.CommandType
                    $global:scriptData.Version = $global:invocation.MyCommand.Version
                    $global:scriptData.ScriptLineNumber = $global:invocation.ScriptLineNumber
                    $global:scriptData.ScriptColumnNumber = $global:invocation.OffsetInLine
                    $global:scriptData.Arguments = $global:invocation.MyCommand.Parameters
                    if ($DoVerbose) {
                        Add-LogText -Message $($global:scriptData.Display()) -logFileNameFull $logFileNameFull
                        if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
                    }
                    # Menu
                    # Form
                    #endregion
                    $app.displayHeader = Update-StdHeader -appName $app.appName
                    $app.InitStdDone = $true
                    # $appArrayUpdate = $false
                } catch {
                    $Message = "Initialize-StdGlobals error initializing Standard Library information."
                    Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
                    if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
                    if ($DoVerbose) { Add-LogText -Message "Initialize continuing..." -ForegroundColor Yellow -logFileNameFull $logFileNameFull }
                }
            }
            # Initialize Log File Data
            if ($InitLogFile -and ($InitForce -or ($DoCheckState -and -not $app.InitLogFileDone))) {
                try {
                    $Message = "Initialize: State: Log File Data."
                    if ($DoVerbose) {
                        Add-LogText -Message $Message -ForegroundColor Yellow -logFileNameFull $logFileNameFull
                        if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
                    } elseif ($DoPause -or ($KeepOpen -and -not $Silent)) { Wait-AnyKey -Message "$Message Enter any key to continue..." }
                    # Log
                    # The log file name is set.
                    if (-not $global:app.logFileNames) { $global:app.logFileNames = @() }
                    if ($app.logFileNameFull -and -not $DoOpen) {
                        $logFileNameFull = $app.logFileNameFull
                        $global:logFileNameFullResult = $logFileNameFull
                    } else {
                        $localParams = @{}
                        if ($app.appName) { $localParams['appName'] = $app.appName }
                        if ($app.companyName) { $localParams['companyName'] = $app.companyName }
                        if ($app.appDirectory) { $localParams['appDirectory'] = $app.appDirectory }

                        if ($DoForce) { $localParams['DoForce'] = $true }
                        if ($DoVerbose) { $localParams['DoVerbose'] = $true }
                        if ($DoDebug) { $localParams['DoDebug'] = $true }
                        if ($DoPause) { $localParams['DoPause'] = $true }
                        # But by default (previously) it won't be created until Add-LogText is called.
                        if ($DoOpen) { $localParams['DoOpen'] = $true }
                        if ($SkipCreate) { $localParams['SkipCreate'] = $true }
                        # $localParams['$DoSetGlobal'] = $true
                        if ($InitForce) { $localParams['InitForce'] = $true }
                        if ($DoCheckState) { $localParams['DoCheckState'] = $true }
                        if ($logFilePath) { $localParams['logFilePath'] = $logFilePath }
                        if ($logFileName) { $localParams['logFileName'] = $logFileName }
                        if ($logFileNameFull) { $localParams['logFileNameFull'] = $logFileNameFull }
                        # if ($logFilePath) { 
                        #     if ($logFilePath) { $localParams['logFilePath'] = $logFilePath }
                        #     if ($logFileName) { $localParams['logFileName'] = $logFileName }
                        # } else {
                        #     if ($logFileNameFull) { $localParams['logFileNameFull'] = $logFileNameFull }
                        # }
                        if ($logFileExtension) { $localParams['logFileExtension'] = $logFileExtension }
                        if ($LogOneFile) { $localParams['LogOneFile'] = $true }
                        if ($DoSetGlobal) { $localParams['DoSetGlobal'] = $true }
                        if ($DoClearGlobal) { $localParams['DoClear'] = $true }

                        $null = Open-LogFile @localParams
                        $logFileNameFull = $global:logFileNameFullResult
                        $global:logFileNameFullReady = $false
                    }
                    if (-not $global:logFileNames) { $global:logFileNames = @{} }
                    $global:logFileNames[$appName] = $logFileNameFull
                    # $global:logFileNameFull = $logFileNameFull
                    $app.logFileNameFull = $logFileNameFull
                    $app.InitLogFileDone = $true
                    
                    if ($DoSetGlobal) {
                        $global:app.logFileNameFull = $logFileNameFull
                        $global:app.logFilePath = Split-Path $logFileNameFull -Parent 
                        $global:app.logFileName = Split-Path $logFileNameFull -Leaf
                        $global:app.logOneFile = $LogOneFile
                        $global:app.logFileExtension = [System.IO.Path]::GetExtension($logFileNameFull)
                        $global:app.logFileCreated = $false
                        if (-not $global:app.logFileNames) { $global:app.logFileNames = @{} }
                        $global:app.logFileNames[$appName] = $logFileNameFull
                    }
                } catch {
                    $Message = "Initialize-StdGlobals error initializing Log File information."
                    Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
                    if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
                    if ($DoVerbose) { Add-LogText -Message "Initialize continuing..." -ForegroundColor Yellow -logFileNameFull $logFileNameFull }
                }
            }
            # Initialize GUI Application Data
            if ($InitGui -and ($InitForce -or ($DoCheckState -and -not $app.InitGuiDone))) {
                try {
                    $Message = "Initialize: State: GUI Application Data."
                    if ($DoVerbose) {
                        Add-LogText -Message $Message -ForegroundColor Yellow -logFileNameFull $logFileNameFull
                        if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
                    } elseif ($DoPause -or ($KeepOpen -and -not $Silent)) { Wait-AnyKey -Message "$Message Enter any key to continue..." }
                    $guiParams = @{}
                    $guiParams['app'] = $app
                    if ($InitForce) { $guiParams['InitForce'] = $true }
                    if ($DoCheckState) { $guiParams['DoCheckState'] = $true }
                    if ($DoForce) { $guiParams['DoForce'] = $true }
                    if ($DoVerbose) { $guiParams['DoVerbose'] = $true }
                    if ($DoDebug) { $guiParams['DoDebug'] = $true }
                    if ($DoPause) { $guiParams['DoPause'] = $true }
                    if ($logFileNameFull) { $guiParams['logFileNameFull'] = $logFileNameFull }
                    Initialize-StdGui @guiParams
                    
                } catch {
                    $Message = "Initialize-StdGlobals error initializing GUI information."
                    Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
                    if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
                    if ($DoVerbose) { Add-LogText -Message "Initialize continuing..." -ForegroundColor Yellow -logFileNameFull $logFileNameFull }
                }
            }
            # Auto-setting of Log File
            if ($logFileNameFull) {
                if (-not $global:app.logFileNames) { $global:app.logFileNames = @{} }
                $global:app.logFileNames[$appName] = $logFileNameFull
                $app.logFileNameFull = $logFileNameFull
                $app.InitLogFileDone = $true
            }
            if ($DoSetGlobal -and ($InitForce -or ($DoCheckState -and -not $app.InitDone))) { 
                if ($DoVerbose) {
                    Add-LogText -Message "Initialize: State: Set Global Data." -ForegroundColor Yellow -logFileNameFull $logFileNameFull
                    if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
                }
                $global:app = $app
                $global:appName = $appName
                $global:logFileNameFull = $logFileNameFull
                # $global:app.appName = $appName
                # $global:app.logFileNameFull = $logFileNameFull
                # $global:app.displayHeader = $displayHeader
                # $global:app.timeStarted = $timeStarted
                # $global:app.timeStartedFormatted = $timeStartedFormatted
                # $global:app.timeCompleted = $timeCompleted
                # $global:app.logFileNames[$appName] = $logFileNameFull
                if (-not $SkipCreate) { $global:logFileCreated = $true }
                $global:PrivateData = (Get-Host).PrivateData
            }
            # Headers with complete data
            $null = Update-StdHeader -appName $appName -DoSetGlobal
            # A lot of variations exists.
            # TODO Hold Using -> "$global:displayHeader = " can cause the PS result Error
            # this -> $null = Update-StdHeader -appName $appName -Title $title `
            #     -timeStarted $timeStarted -timeCompleted $timeCompleted `
            #     -logFileNameFull $logFileNameFull
            # or -> $displayHeader = Update-StdHeader -app $app
        } catch {
            $Message = "Initialize-StdGlobals error initializing information."
            Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
            if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
            if ($DoVerbose) { Add-LogText -Message "Initialize continuing..." -ForegroundColor Yellow -logFileNameFull $logFileNameFull }
        }
    }
    end { 
        if ($app -and $app.InitStdDone -and $app.InitGuiDone -and $app.InitLogFileDone) { $app.InitDone = $true }
        if ($app.displayHeader) { 
            $Message = "Application $($app.appName) Initialzed: $($app.displayHeader)"
            Add-LogText -Message $Message -logFileNameFull $logFileNameFull
            if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
        }
        if ($DoVerbose -and ($global:app.DoPause -or $global:app.DoVerbose -or $global:app.DoDebug -or $global:app.DoForce)) {
            Add-LogText -Message $app.displayHeader -logFileNameFull $logFileNameFull
            if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFullResult }
            Add-LogText -Message "Initialize: State finished for $($appName). State:" -ForegroundColor Yellow -logFileNameFull $logFileNameFull
            Add-LogText -Message "Application: Pause: $($app.DoPause), Verbose: $($app.DoVerbose), Debug: $($app.DoDebug), Force: $($app.DoForce)" -ForegroundColor Yellow -logFileNameFull $logFileNameFull
            Add-LogText -Message "     Global: Pause: $($global:app.DoPause), Verbose: $($global:app.DoVerbose), Debug: $($global:app.DoDebug), Force: $($global:app.DoForce)" -ForegroundColor Yellow -logFileNameFull $logFileNameFull
            Add-LogText -Message "      Local: Pause: $($local:DoPause), Verbose: $($local:DoVerbose), Debug: $($local:DoDebug), Force: $($local:DoForce)" -ForegroundColor Yellow -logFileNameFull $logFileNameFull
            Add-LogText -Message "    Default prompt: $($global:msgAnykey)" -ForegroundColor Yellow -logFileNameFull $logFileNameFull
            # Add-LogText -Message "   Silent Mode: $Silent" -ForegroundColor Yellow -logFileNameFull $logFileNameFull
            # Add-LogText -Message "     Keep Open: $KeepOpen" -ForegroundColor Yellow -logFileNameFull $logFileNameFull
            # if ($global:app.DoPause -or ($DoPause -or ($KeepOpen -and -not $Silent))) { Wait-AnyKey }
            if ($DoPause -or $global:app.DoPause -or $global:app.DoDebug) { Wait-AnyKey }
        }
        $global:appResult = $app
    }
}
function Initialize-StdGui {
    [CmdletBinding()]
    param (
        [CommandApp]$app,
        [switch]$DoCheckState,
        [switch]$InitForce,

        [string]$appName = "",
        [int]$actionStep = 0,
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [string]$logFileNameFull = ""
    )
    begin {
        # Gatekeeping. Do not execute twice
        if (-not $InitForce -and $DoCheckState -and $app.InitGuiDone) { return }
    }
    process {
        if ($InitForce -or -not $app.InitGuiDone) {
            # WFFormGlobal
            $path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\lib\WFFormGlobal.ps1"
            . $path @global:combinedParams
        }
    }
    
    end {
        $app.InitGuiDone = $true
        if ($app.InitStdDone -and $app.InitGuiDone) { $app.InitDone = $true }
        # Update-StdHeader
        $null = Update-StdHeader -appName $app.appName -Title $app.title `
            -timeStarted $app.timeStarted -timeCompleted $app.timeCompleted `
            -logFileNameFull $app.logFileNameFull
    }
}
function Update-StdHeader {
    [CmdletBinding()]
    param (
        [string]$appDirectory = "",
        [string]$companyName = "",
        [string]$title = "",
        $timeStarted, # = [System.DateTime]::MinValue,
        $timeCompleted, # = [System.DateTime]::MinValue,
        # Globals
        [switch]$DoUseGlobal, # overrides the above
        [switch]$DoClearGlobal,
        # DoClear redundant when true:
        [switch]$DoSetGlobal,
        # Will force Std, Gui and LogFile:
        [switch]$DoSetApp,
        [switch]$InitForce,
        [switch]$InitStd,
        [switch]$InitGui,
        [switch]$InitLogFile,

        [string]$appName = "",
        [int]$actionStep = 0,
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [string]$logFileNameFull = ""
    )
    $now = Get-Date
    if (-not $timeStarted) {
        [System.DateTime]$timeStarted = [System.DateTime]::MinValue
        [System.DateTime]$timeCompleted = [System.DateTime]::MinValue
    }
    $global:now = $now
    if ($DoUseGlobal -and $global:app) {
        $app = $global:app
    } elseif ($appName -and $global:appArray -and $global:appArray[$appName]) {
        $app = $global:appArray[$appName]
    }
    if ($app) {
        $appName = $app.appName
        if (-not $appDirectory) { $appDirectory = $app.appDirectory }
        if (-not $companyName) { $companyName = $app.companyName }
        if (-not $title) { $title = $app.title } else {
            $timeStarted = $app.timeStarted 
            $timeCompleted = $app.timeCompleted
            $logFileNameFull = $app.logFileNameFull
        }
        $DoSetApp = $true
    }
    $displayHeader = @()
    $displayHeader1 = ""
    $displayHeader2 = ""
    $timeStartedFormatted = "{0:yyyyMMdd_HHmmss}" -f $timeStarted
    # Header line 1
    $displayHeader1 = "$displayHeader1$appName - $title - Started: $timeStartedFormatted"
    # Header line 2..4
    if ($companyName) {
        $displayHeader2 = "$($displayHeader2)$global:companyName "
    }
    if ($appDirectory) {
        $displayHeader2 = "$($displayHeader2)Directory: $appDirectory "
    }
    if ($displayHeader2.Length -ge 80) { $displayHeader2 = "$($displayHeader2)$global:NL" }
    
    if ($logFileNameFull) {
        $displayHeader2 = "$($displayHeader2)Time: $now - Log File: $logFileNameFull - Completed: $timeCompleted"
    }
    if ($displayHeader2.Length -ge 80) { $displayHeader2 = "$($displayHeader2)$global:NL" }
    # Combine lines, set return values and globals.
    $displayHeader += $displayHeader1
    if ($displayHeader2) { $displayHeader += $displayHeader2 }
    if ($DoSetApp -and $app) {
        $app.displayHeader = $displayHeader
    }
    if ($DoSetGlobal -and $global:app) {
        $global:app.now = $now
        $global:app.displayHeader = $displayHeader
    }
    $global:displayHeaderReturn = $displayHeader
    return $displayHeader
}
function Reset-StdGlobals {
    <#
    .SYNOPSIS
        Resets the global state.
    .DESCRIPTION
        This equates to, and uses, 
            automatic variables, 
            $PS variables, 
            module metadata and
            state.
    .PARAMETER msgAnykey
        The prompt for "Enter any key".
    .PARAMETER msgYorN
        The prompt for "Enter Y, N, or Q to quit".
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .PARAMETER initDone
        Switch: indicates initialization is done.
    .OUTPUTS
        none.
    .EXAMPLE
        Reset-StdGlobals
#>


    [CmdletBinding()]
    param (
        [string]$logFileNameFull = "",
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [string]$msgAnykey = "",
        [string]$msgYorN = "",
        [switch]$initDone
    )
    process {
        $global:msgAnykey = $msgAnykey
        $global:msgYorN = $msgYorN
        $global:app.InitDone = $false
        $global:app.InitStdDone = $false
        $global:app.InitGuiDone = $false
        $global:app.InitLogFileDone = $false
        # TODO: Hold validation syntax error with params
        $localParams = @{}
        if ($DoForce) { $localParams['DoForce'] = $true }
        if ($DoVerbose) { $localParams['DoVerbose'] = $true }
        if ($DoDebug) { $localParams['DoDebug'] = $true }
        if ($DoPause) { $localParams['DoPause'] = $true }
        Set-StdGlobals @localParams
    }
}
function Set-StdGlobals {
    <#
    .SYNOPSIS
        Checks global variables and state.
    .DESCRIPTION
        This will set globals to the passed values without validation.
    .PARAMETER message
        The system message. Not used.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        none.
    .EXAMPLE
        Set-StdGlobals -DoPause -DoVerbose -DoDebug
    .NOTES
        none.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Message = "",
        [string]$logFileNameFull = "",
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [switch]$SkipClear,
        [switch]$Preserve
    )
    if (-not $Preserve) {
        $global:app.DoForce = $local:DoForce
        $global:app.DoPause = $local:DoPause
        $global:app.DoVerbose = $local:DoVerbose
        $global:app.DoDebug = $local:DoDebug
        $global:Message = $local:message
    } else {
        # What this means is that 
        # if they are on, they won't be turned off.
        if (-not $SkipClear) {
            $global:app.DoForce = $false
            $global:app.DoPause = $false
            $global:app.DoVerbose = $false
            $global:app.DoDebug = $false
            $global:Message = ""
        }
        # However they can be turned on.
        if ($local:DoForce) { $global:app.DoForce = $local:DoForce }
        if ($local:DoPause) { $global:app.DoPause = $local:DoPause }
        if ($local:DoVerbose) { $global:app.DoVerbose = $local:DoVerbose }
        if ($local:DoDebug) { $global:app.DoDebug = $local:DoDebug }
        if ($local:message.Length -gt 0) { $global:Message = $Message }
    }
    # Parameters
    $path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\lib\Get-ParametersLib.ps1"
    . $path @global:combinedParams
    # Output the current settings
    Write-Debug "Set-StdGlobals: Debug Mode: $DoDebug. Preference: $DebugPreference"
    Write-Verbose "Set-StdGlobals: Verbose Mode: $DoVerbose. Preference: $VerbosePreference"
}
function Get-StdGlobals {
    <#
    .SYNOPSIS
        Gets global variables and state.
    .DESCRIPTION
        This will get globals to be returned without validation.
    .PARAMETER message
        The system message. Not used.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        none.
    .EXAMPLE
        Set-StdGlobals -DoPause -DoVerbose -DoDebug
    .NOTES
        none.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$DoClearGlobal
    )
    if ($DoClearGlobal) {
        $global:app.DoPause = $false
        $global:app.DoVerbose = $false
        $global:app.DoDebug = $false
        $global:app.DoForce = $false
        $global:Message = ""
    }
    return @($global:app.DoPause, $global:app.DoVerbose, $global:app.DoDebug, $global:app.DoForce, $global:Message)
}
function Show-StdGlobals {
    param (
        $something
    )
    process {
        $outputBuffer = @()
        $outputBuffer += " "
        $outputBuffer += "Folders:"
        $outputBuffer += "Project Root: Exists: $(Test-Path "$global:projectRootPath"): $global:projectRootPath"
        $outputBuffer += " Module Root: Exists: $(Test-Path "$global:moduleRootPath"): $global:moduleRootPath"
        $outputBuffer += "Execution at: Exists: $(Test-Path "$global:projectRootPathActual"): $global:projectRootPathActual"
        $outputBuffer += " "
        $outputBuffer += "Modules:"
        $importName = "Mdm_Std_Library"
        $modulePath = "$global:moduleRootPath\$importName"
        # $outputBuffer += "Module 1: $importName"
        $outputBuffer += "1. Exists: $(Test-Path "$modulePath"): $importName"
        $importName = "Mdm_Bootstrap"
        $modulePath = "$global:moduleRootPath\$importName"
        # $outputBuffer += "Module 2: $importName"
        $outputBuffer += "2. Exists: $(Test-Path "$modulePath"): $importName"
        $outputBuffer += "3. Available empty slot"
        $importName = "Mdm_WinFormPS"
        $modulePath = "$global:moduleRootPath\$importName"
        # $outputBuffer += "Module 4: $importName"
        $outputBuffer += "4. Exists: $(Test-Path "$modulePath"): $importName"
        $importName = "Mdm_Nightroman_PowerShelf"
        $modulePath = "$global:moduleRootPath\$importName"
        # $outputBuffer += "Module 5: $importName"
        $outputBuffer += "5. Exists: $(Test-Path "$modulePath"): $importName"
        $importName = "Mdm_DevEnv_Install"
        $modulePath = "$global:moduleRootPath\$importName"
        # $outputBuffer += "Module 6: $importName"
        $outputBuffer += "6. Exists: $(Test-Path "$modulePath"): $importName"
        $importName = "Mdm_PoshFunctions"
        $modulePath = "$global:moduleRootPath\$importName"
        # $outputBuffer += "Module 7: $importName"
        $outputBuffer += "7. Exists: $(Test-Path "$modulePath"): $importName"
        $importName = "Mdm_Springcomp_MyBox"
        $modulePath = "$global:moduleRootPath\$importName"
        # $outputBuffer += "Module 8: $importName"
        $outputBuffer += "8. Exists: $(Test-Path "$modulePath"): $importName"
        $outputBuffer += " "
        $outputBuffer += "Project: Exists: $(Test-Path "$global:projectRootPath"): $global:projectRootPath"
        $outputBuffer += " Module: Exists: $(Test-Path "$global:moduleRootPath"): $global:moduleRootPath"
        $outputBuffer += " Actual: Exists: $(Test-Path "$global:projectRootPathActual"): $global:projectRootPathActual"
        $outputBuffer += " "
        $outputBuffer += " Log File Name: $global:app.logFileName"
        $outputBuffer += " Log File Path: $global:app.logFilePath"
        $outputBuffer += " Log File Name Full: $global:app.logFileNameFull"
        $outputBuffer += " Log One File: $global:app.logOneFile"

        $outputBuffer += " "
        $outputBuffer += "Run Control:"
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal] $identity
        $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
        $global:developerMode = Test-Path -Path "$global:projectRootPath\IsDevMode.txt"
        $Message = "Developer mode: $global:developerMode, "
        $Message += "$(if ($principal.IsInRole($adminRole)) { '[Admin] ' } else { '' }) "
        $Message += "$(if (Test-Path Variable:/PSDebugContext) { '[DBG] ' } else { '' })"
        Write-Host $Message
        $outputBuffer += "  Initialized: $InitStdDone"
        $outputBuffer += "  Local Pause: $local:DoPause, Verbose: $local:DoVerbose, Debug: $local:DoDebug, Force: $local:DoForce"
        $outputBuffer += " Global Pause: $global:app.DoPause, Verbose: $global:app.DoVerbose, Debug: $global:app.DoDebug, Force: $global:app.DoForce"
        $outputBuffer += "       Prompt: $global:msgAnykey"
        $headingDone = $false
        foreach ($paramItem in $commonParameters.GetEnumerator()) {
            if (-not $headingDone) {
                $headingDone = $true
                $outputBuffer += "Common Parameters:"
            }
            $outputBuffer += "    Param: $($paramItem.Key): $($paramItem.Value)"
        }
        $outputBuffer += " "
        $outputBuffer
    }
}
# ###############################
function Initialize-Std {
    <#
    .SYNOPSIS
        Initializes a script..
    .DESCRIPTION
        This processes switches, automatic variables, state.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        Global variables are set.
    .EXAMPLE
        Initialize-Std -DoPause -DoVerbose
    .EXAMPLE
        Reset-StdGlobals
        Initialize-Std -DoPause -DoVerbose
    .NOTES
        none.
#>


    [CmdletBinding()]
    param (
        [string]$logFileNameFull = "",
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [string]$errorActionValue,
        [string]$debugPreference
    )
    process {
        # Show-StdGlobals
        Write-Verbose "Initialize-Std"
        if ($DoForce -or -not $global:app.InitStdDone) {
            Write-Verbose " initializing..."
            # $global:app.DoPause = $local:DoPause; $global:app.DoVerbose = $local:DoVerbose
            $global:app.InitStdDone = $true
            # Validation
            # Default messages
            if ($global:msgAnykey.Length -le 0) { 
                $global:msgAnykey = "Press any key to continue" 
                Write-Debug "Anykey: $global:msgAnykey"
            }
            if ($global:msgYorN.Length -le 0) { 
                $global:msgYorN = "Enter Y to continue, Q to quit or N to exit" 
                Write-Debug "YorN: $global:msgYorN"
            }

            # Pause
            if ($local:DoPause) { $global:app.DoPause = $true } else { $global:app.DoPause = $false }
            Write-Debug "Global pause: $global:app.DoPause"

            # Debug
            if ($local:DoDebug) { $global:app.DoDebug = $true } else { $global:app.DoDebug = $false }
            # TODO PowerShell setting for -Debug (Issue 2: doesn't work)
            if ($DebugPreference -and $DebugPreference -ne 'SilentlyContinue') { 
                Write-Verbose "Preference: $DebugPreference"
                $global:app.DoDebug = $true 
            } else {
                if ($local:DoDebug) {
                    $global:app.DoDebug = $true
                    $DebugPreference = 'Continue'
                    if ($global:app.DoPause) { $DebugPreference = 'Inquire' }
                } else { $global:app.DoDebug = $false }
            }
            if ($global:app.DoDebug) { Write-Verbose "Debugging." } else { Write-Verbose "Debug off." }

            # Verbosity TODO syntax errors
            if ($local:DoVerbose) {
                $global:app.DoVerbose = $true 
                $VerbosePreference = $true
            } else {
                $global:app.DoVerbose = $false
                $VerbosePreference = $false
            }

            # Error Action
            # could check PS values. debugPreference
            # The possible values for $PSDebugPreference are:
            $debugPreferenceSet = $true
            switch ($PSDebugPreference) {
                "Continue" { 
                    # This is the default value. 
                    # It allows the script to continue running even if there are errors. 
                    # It will display error messages in the console. 
                }
                "Stop" { 
                    # Will stop execution when an error occurs. 
                }
                "SilentlyContinue" { 
                    # Suppresses (ignore) error messages.
                    # Allows the script to continue running without interruption.
                    # It is useful when you want to ignore errors. 
                }
                "Inquire" { 
                    # When set to Inquire, PowerShell will prompt the user for input when an error occurs, allowing the user to decide how to proceed. 
                }
                "Ignore" { 
                    # This value ignores errors and continues execution without displaying any messages. 
                }
                Default {
                    # Continue
                    $debugPreferenceSet = $false
                    $debugPreference = $PSDebugPreference
                }
            }
            if ($debugPreferenceSet) { 
                $PSDebugPreference = $debugPreference
                $global:errorActionValue = $debugPreference
            }
            if ($errorActionValue) { $global:errorActionValue = $errorActionValue }

            # Check automatic parameters 
            # TODO Add-LogText -Message "PSBoundParameters: $PSBoundParameters" (Issue 1: doesn't work)
            # TODO Add-LogText -Message "PSBoundParameters Verbose: $($PSCmdlet.Get-Invocation.BoundParameters['Verbose'])" (Issue 1: doesn't work)
            # TODO Add-LogText -Message "VerbosePreference: $VerbosePreference" # (Issue 1: doesn't work)

            # PowerShell setting
            # return $VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue    
            if ($PSBoundParameters.ContainsKey('Verbose')) { 
                # $PSCmdlet.Get-Invocation.BoundParameters["Verbose"]
                # VerbosePreference
                # Command line specifies -Verbose
                $b = $PsBoundParameters.Get_Item('Verbose')
                $global:app.DoVerbose = $b
                Add-LogText -Message "Bound Param Verbose $b" -logFileNameFull $logFileNameFull
                # $global:app.DoVerbose = $false
                if ($null -eq $b) { $global:app.DoVerbose = $false }
                Write-Debug "Verbose from Bound Param: $global:app.DoVerbose"
            } else { 
                Write-Debug "Verbose key not present."
            }
            # Verbosity via -verbose produces output.
            $outputBuffer = ""
            Write-Verbose "Verbose" > $outputBuffer
            if ($outputBuffer.Length -gt 0) { $global:app.DoVerbose = $true }
            if ($global:app.DoVerbose) {
                Write-Verbose "Verbose."
            } else { Write-Debug "Shhhhh......" }

            $global:developerMode = Test-Path -Path "$global:projectRootPath\IsDevMode.txt"

            # ??? Maybe
            # Set-prompt
        }
        if ($global:app.DoVerbose) {
            Add-LogText -Message "" -logFileNameFull $logFileNameFull
            Add-LogText -Message "Init end  Local Pause: $local:DoPause, Verbose: $local:DoVerbose, Debug: $local:DoDebug" -logFileNameFull $logFileNameFull
            Add-LogText -Message "Init end Global Pause: $global:app.DoPause, Verbose: $global:app.DoVerbose, Debug: $global:app.DoDebug, Force: $global:app.DoForce Init: $global:app.InitStdDone" -logFileNameFull $logFileNameFull
        }
        $null = Set-CommonParametersGlobal

        # $importName = "Mdm_Std_Library"
        # $modulePath = "$global:moduleRootPath\$importName"
        # if (-not ((Get-Module -Name $importName) -or $global:app.DoForce)) {
        #     Import-Module -Name $modulePath @global:commonParamsStd
        # }
    }
}
function Start-Std {
    <#
    .SYNOPSIS
        Reset and initialize.
    .DESCRIPTION
        This resets the global values and call the initializations.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        none.
    .EXAMPLE
        Start-Std -DoVerbose
    .NOTES
        This serves little purpose.
#>


    [CmdletBinding()]
    param (
        [string]$appDirectory = ".",
        [string]$companyName = "",
        [string]$title = "",
        [switch]$InitForce,
        [switch]$InitStd,
        [switch]$InitGui,
        [switch]$InitLogFile,

        [switch]$DoCheckState,
        [switch]$DoOpen,
        [switch]$SkipCreate,
        [switch]$DoClearGlobal,
        # DoClear redundant when true:
        [switch]$DoSetGlobal,

        [string]$appName = "",
        [int]$actionStep = 0,
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [string]$logFileNameFull = ""
        )
    process {
        # Check state
        # if (-not $appName) { $appName = "UserApp" }
        if (-not $DoForce -and $DoCheckState -and $global:app.InitDone) { return }
        # Declarative syntax
        $startParams = @{}
        if ($appName) { $startParams['appName'] = $appName }
        if ($companyName) { $startParams['companyName'] = $companyName }
        if ($appDirectory) { $startParams['appDirectory'] = $appDirectory }

        if ($DoForce) { $startParams['DoForce'] = $true }
        if ($DoVerbose) { $startParams['DoVerbose'] = $true }
        if ($DoDebug) { $startParams['DoDebug'] = $true }
        if ($DoPause) { $startParams['DoPause'] = $true }

        if ($InitForce) { $startParams['InitForce'] = $true }
        if ($InitStd) { $startParams['InitStd'] = $true }
        if ($InitGui) { $startParams['InitGui'] = $true }
        if ($InitLogFile) { $startParams['InitLogFile'] = $true }

        if ($DoCheckState) { $startParams['DoCheckState'] = $true }
        if ($logFileNameFull) { $startParams['logFileNameFull'] = $logFileNameFull }
        
        if ($InitForce) { $startParams['InitForce'] = $true }
        if ($InitStd) { $startParams['InitStd'] = $true }
        if ($InitGui) { $startParams['InitGui'] = $true }
        if ($InitLogFile) { $startParams['InitLogFile'] = $true }

        if ($DoCheckState) { $startParams['DoCheckState'] = $true }
        if ($logFileNameFull) {
            $startParams['logFileNameFull'] = $logFileNameFull
        } else {
            $startParams['logFilePath'] = "$appDirectory\log"
        }
        if ($DoOpen) { $startParams['DoOpen'] = $true }
        
        if ($SkipCreate) { $startParams['SkipCreate'] = $true }
        if ($DoClearGlobal) { $startParams['DoClear'] = $true }
        if ($DoSetGlobal) { $startParams['DoSetGlobal'] = $true }
        
        Initialize-StdGlobals @startParams
        # Old:
        # Reset-StdGlobals @startParams
        # Initialize-Std @startParams
        # Import-Module Mdm_Std_Library -Force is redundant
        # Less verbose method/usage:
        # Initialize-StdGlobals -InitForce -InitStd -InitLogFile -InitGui `
        #     -appName $appName -appDirectory $appDirectory `
        #     -logFilePath "$appDirectory\log" -DoOpen -DoSetGlobal
        if ($global:app.DoVerbose) { Add-LogText -Message "Script Started." -logFileNameFull $logFileNameFull }
    }
}
function Set-CommonParametersGlobal {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline)]
        [hashtable]$commonParameters = @{}
    )
    begin {
        # Faulty. Old code.
        # Initialize outputParams as a hashtable
        [hashtable]$outputParams = @{}
        if (-not $commonParameters) { $commonParameters = $PSBoundParameters }
    }
    process {
        # Copy each key-value pair from the incoming hashtable
        foreach ($key in $commonParameters.Keys) {
            $outputParams[$key] = $commonParameters[$key]
        }
    }
    end {
        # Add global parameters based on conditions
        if ($global:app.DoForce) { $outputParams['Force'] = $true }
        if ($global:app.DoVerbose) { $outputParams['Verbose'] = $true }
        if ($global:app.DoDebug) { $outputParams['Debug'] = $true }
        # if ($global:app.DoPause) { $outputParams['Pause'] = $true }
        $outputParams['ErrorAction'] = if ($global:errorActionValue) { $global:errorActionValue } else { 'Continue' }

        # Combine with global prelude
        [hashtable]$global:commonParams = @{}
        foreach ($key in $global:commonParamsPrelude.Keys) {
            $commonParameters[$key] = $global:commonParamsPrelude[$key]
        }
        foreach ($key in $outputParams.Keys) {
            $commonParameters[$key] = $outputParams[$key]
        }

        # Return the combined parameters
        return [hashtable]$global:commonParams
    }
}
# TODO Hold Get-StdStatus
function Get-StdStatus {
    [CmdletBinding()]
    param (
        
    )
    begin {
        
    }
    process {
        
    }
    end {
        
    }
}