# Using namespace System.Management.Automation.Host
# Using namespace System.Management.Automation.Host.InternalHostUserInterface
# Add-Type -AssemblyName System.Management.Automation.Host
# Add-Type -AssemblyName System.Management.Automation.Host.InternalHostUserInterface

# Mdm_Std_Script.ps1
function Invoke-Invoke {
    [CmdletBinding()]
    param($sender, $e,
        # [parameter(ValueFromPipeline = $true)]
        # One of these. In order or precedence.
        [Collections.ArrayList]$Commands = $null,
        [System.Management.Automation.ScriptBlock]$ScriptBlock = $null,
        [hashtable]$Command = $null,
        # Command
        # $CommandLine = $Command['CommandLine']
        # $CommandName = $Command['CommandName']
        # $ScriptBlock = $Command['ScriptBlock']
        # or
        [string]$CommandLineOnly = "",
        [string]$CommandActionOnly = "",

        [string]$Options,
        [switch]$jobActionSkipWait,
        [switch]$jobActionMethodNewWindow,
        [string]$logFileNameFull = "",
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [switch]$HandleError
    )

    begin {
        # $null = Debug-Script -DoPause 60 -functionName "Invoke-Invoke pause for interrupt" -logFileNameFull $logFileNameFull
        try {
            if ($sender -and ($sender -is [System.Windows.Forms.Control])) {
                $CommandName = [string]$sender.Name
            } else { 
                $sender = $global:window
                $CommandName = [string]$e
            }
    
            if (-not $Commands) {
                $Commands = New-Object Collections.ArrayList
                $CommandResults = New-Object Collections.ArrayList
                if (-not $Options) { $Options = "" }
                if (-not $jobActionMethodNewWindow) { $jobActionMethodNewWindow = $global:jobActionMethodNewWindow }
                if (-not $jobActionSkipWait) { $jobActionSkipWait = $global:jobActionSkipWait }
                if ($Command) {
                    # A piped command will ignore passed single values (Only's)
                    if ($Command -is [hashtable]) {
                        Write-Debug " Hashtable"
                        if (-not $Command.ContainsKey('CommandLine') -or -not $Command.ContainsKey('CommandName')) {
                            Write-Verbose " Bad Keys"
                            $Message = "Invoke-Invoke: The hashtable does not contain the required keys."
                            if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -IsError -logFileNameFull $logFileNameFull }
                            else { Add-LogText -Message $Message -IsError -logFileNameFull $logFileNameFull }
                            return
                        }
                    } else {
                        $Message = "Invoke-Invoke: The variable `Command` is not a hashtable."
                        if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -IsError -logFileNameFull $logFileNameFull }
                        else { Add-LogText -Message $Message -IsError -logFileNameFull $logFileNameFull }
                        return
                    }
                    $CommandLine = $Command['CommandLine']
                    $CommandName = $Command['CommandName']
                    $ScriptBlock = $Command['ScriptBlock']
                } elseif ($ScriptBlock) {
                    $CommandLine = ""
                    # $CommandName = ""
                    [hashtable]$Command = @{
                        CommandLine = $CommandLine
                        CommandName = $CommandName
                        ScriptBlock = $ScriptBlock
                    }
                } else {
                    $CommandLine = "$CommandLineOnly"
                    $CommandName = "$CommandActionOnly"
                    [hashtable]$Command = @{
                        CommandLine = $CommandLine
                        CommandName = $CommandName
                        ScriptBlock = $null
                    }
                }
                $commandSequence += 1
                if ($DoVerbose -or $Verbose) {
                    $Message = " Sequence: $commandSequence$global:NL"
                    # $Message += " Command: $command$global:NL"
                    $Message += "CommandName: $CommandName$global:NL"
                    $Message += "CommandLine: $CommandLine$global:NL"
                    $Message += "ScriptBlock: $ScriptBlock"
                    if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -logFileNameFull $logFileNameFull }
                    else { Add-LogText -Message $Message -logFileNameFull $logFileNameFull }
                }
                if (-not ($Command['CommandLine'] -or -not $Command['CommandName']) -and -not $ScriptBlock) {
                    $Message = "Invoke-Invoke: The hashtable must contain both 'CommandLine' and 'CommandName' keys. `nCommand: $Command"
                    if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -IsError -text $Message -logFileNameFull $logFileNameFull }
                    else { Add-LogText -IsError -Message $Message -logFileNameFull $logFileNameFull }
                    return
                }            
                if ($DoVerbose) {
                    if ($ScriptBlock) {
                        $Message = "Script block: $CommandName."
                    } else {
                        $Message = "Received Command: $($CommandName): $($Command | Out-String)"
                    }
                    if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -logFileNameFull $logFileNameFull }
                    else { Add-LogText -Message $Message -logFileNameFull $logFileNameFull }
                }
                if ((-not $CommandLine -or -not $CommandName) -and -not $ScriptBlock) {
                    $Message = "Invoke-Invoke: Both CommandLine and CommandName must be provided. `nCommandName($CommandName)- CommandLine($CommandLine)"
                    if ($global:ActionOutputTextBox) { Update-WFTextBox -IsError -textBox $global:ActionOutputTextBox -text $Message -logFileNameFull $logFileNameFull }
                    else { Add-LogText -IsError -Message $Message -logFileNameFull $logFileNameFull }
                    return
                }

                $null = $Commands.Add( @{
                        CommandName = $CommandName
                        CommandLine = $CommandLine
                        ScriptBlock = $ScriptBlock
                    }
                )
            }
        } catch {
            $Message = "Invoke-Invoke: An error occured preparing the command to perform. Command: $CommandName"
            if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull }
            else { Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull }
        }
    }
    process {
        if ($global:tabControls) { Set-WFTabPage -tabControl $global:tabControls -tabPageText "Output" }
        # Produces array of ($exitCode, $standardOutput, $errorOutput)
        # [CommandAction]$commandInvoke = [CommandAction]::new()
        $timeStarted = [System.DateTime]::MinValue
        $timeCompleted = [System.DateTime]::MinValue
        $commandSequence = -1
        $result = @()
        $standardOutput = @()
        $errorOutput = @()
        $logFileNames = @()
        $logFileNamesAll = @()
        $exitCode = 0
        $i = 0
        # if ($DoVerbose) { 
        #     $Message = "Starting command processing..."
        #     if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -logFileNameFull $logFileNameFull }
        #     else { Add-LogText -Message $Message -logFileNameFull $logFileNameFull }
        # }
        foreach ($Command in $Commands) {
            try {
                $timeStarted = Get-Date
                $i++
                $global:jobActionId++
                $CommandLine = $Command['CommandLine']
                $CommandName = $Command['CommandName']
                $ScriptBlock = $Command['ScriptBlock']
                if ($ScriptBlock) {
                    try {
                        if ($ScriptBlock -is [System.Management.Automation.ScriptBlock]) {
                            $Message = "Action $i) $($CommandName) at " + (Get-Date).ToString("HH:mm:ss") + " - $ScriptBlock"
                            if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -logFileNameFull $logFileNameFull }
                            else { Add-LogText -Message $Message -logFileNameFull $logFileNameFull }

                            # Check language mode
                            if ($ExecutionContext.SessionState.LanguageMode -ne "FullLanguage") {
                                try {
                                    $Message = "Running job $i) $CommandName, it cannont execute in the background. Cause is language mode: $($ExecutionContext.SessionState.LanguageMode)"
                                    if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message  -logFileNameFull $logFileNameFull }
                                    else { Add-LogText -Message $Message -logFileNameFull $logFileNameFull }

                                    $Message = "$global:jobActionMethod for command $i) $CommandName. Please wait..."
                                    if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message  -logFileNameFull $logFileNameFull }
                                    else { Add-LogText -Message $Message -logFileNameFull $logFileNameFull }

                                    if ($global:jobActionMethod -eq "Start-Process") {
                                        if ($global:jobActionMethodNewWindow) {
                                            $process = Start-Process -FilePath "powershell.exe" `
                                                -ArgumentList "-Command & { $ScriptBlock }"
                                            $result = "Running in external window."
                                            $standardOutput = $result
                                            $errorOutput = ""
                                            $exitCode = 1
                                        } else {
                                            # Run an external command and capture output to a file
                                            $outputFile = "$($(get-item $PSScriptRoot).Parent.FullName)\log\output$global:jobActionId.txt"
                                            $process = Start-Process -FilePath "powershell.exe" `
                                                -ArgumentList "-Command & { $ScriptBlock }" `
                                                -RedirectStandardOutput $outputFile `
                                                -NoNewWindow -Wait
                                            # Read the output from the file
                                            $result = Get-Content $outputFile
                                            # Remove-Item $outputFile -ErrorAction SilentlyContinue
                                            $standardOutput = $result
                                            $errorOutput = ""
                                            $exitCode = $LASTEXITCODE
                                        }
                                    } else {
                                        # $result = Invoke-Command -ScriptBlock $ScriptBlock
                                        # Execute the command and capture output and error
                                        $outputFile = "$($(get-item $PSScriptRoot).Parent.FullName)\log\output$global:jobActionId.txt"
                                        Invoke-Command -ScriptBlock $ScriptBlock *> $outputFile
                                        # Invoke-Expression "$CommandName $CommandLine *> $outputFile"
                                        $outputBuffer = Get-Content $outputFile
                                        # Remove-Item $outputFile -ErrorAction SilentlyContinue
                                        # This is extremely awful. It looks for the word "error"???
                                        # The word "error" only implies an actual error.
                                        $errorOutput = $outputBuffer | Where-Object { $_ -match "error" }
                                        # Don't corrupt $standardOutput by removing these lines.
                                        # $standardOutput = $outputBuffer | Where-Object { $_ -notmatch "error" }
                                        $standardOutput = $outputBuffer
                                        $logFileNames = $outputBuffer | Where-Object { $_ -match "LogFile:" } | Select-Object -Unique
                                        $result = $outputBuffer
                                        $exitCode = $LASTEXITCODE
                                    }
                                    if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $result -logFileNameFull $logFileNameFull }
                                    else { Add-LogText -Message $result -logFileNameFull $logFileNameFull }

                                    $Message = "Job $CommandName has finished."
                                    if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -logFileNameFull $logFileNameFull }
                                    else { Add-LogText -Message $Message -logFileNameFull $logFileNameFull }
                                } catch {
                                    $Message = "Invoke-Invoke ScriptBlock $($ExecutionContext.SessionState.LanguageMode) had an error performing the command. $i) $($CommandName): $ScriptBlock."
                                    if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull }
                                    else { Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull }
                                }
                            } else {
                                try {
                                    $Message = "Running ScriptBlock job $i) $CommandName in Full Language Mode: $($ExecutionContext.SessionState.LanguageMode)"
                                    # Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message
                                    if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -logFileNameFull $logFileNameFull }
                                    else { Add-LogText -Message $Message -logFileNameFull $logFileNameFull }
                                    # Start a background job to run the script block
                                    # Start the Button Action Timer
                                    if ($global:jobActionTimer) {
                                        $global:jobActionTimer.Start()
                                    }

                                    $global:job = Start-Job -ScriptBlock {
                                        param($scriptBlock, $args)
                                        & $scriptBlock @args
                                    } -ArgumentList $scriptBlock, @($sender, $e)
                                    $Message = "Job $CommandName was started."
                                    if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -logFileNameFull $logFileNameFull }
                                    else { Add-LogText -Message $Message -logFileNameFull $logFileNameFull }

                                    # Wait for the job to complete and capture output
                                    # while ($global:job.State -eq 'Running') {
                                    #     # Check for job output
                                    #     if ($global:job.HasMoreData) {
                                    #         $outputBuffer = Receive-Job -Job $global:job -Keep
                                    #         $global:outputBuffer += $outputBuffer
                                    # if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox }
                                    # else { Add-LogText -Message $global:outputBuffer }
                                    #     }
                                    #     Start-Sleep -Milliseconds 100
                                    # }
                                    # $result = Receive-Job -Job $global:job
                                    # $global:outputBuffer += "$result$global:NL"
                                    # if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox }
                                    # else { Add-LogText -Message $global:outputBuffer }
                                    # Clean up the job
                                    # Remove-Job -Job $global:job
                                    $standardOutput = @("$i) Not Waiting for job.")
                                    $errorOutput = @()
                                    $logFileNames = @()
                                    $exitCode = 1
                                } catch {
                                    $Message = "Invoke-Invoke ScriptBlock $($ExecutionContext.SessionState.LanguageMode) had an error performing the command. $i) $($CommandName): $ScriptBlock."
                                    if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull }
                                    else { Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull }
                                }
                            }
                        } else {
                            $Message = "Invoke-Invoke ScriptBlock is not an System.Management.Automation.ScriptBlock. $i) $($CommandName): $ScriptBlock."
                            if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull }
                            else { Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull }
                        }
                    } catch {
                        $Message = "Invoke-Invoke ScriptBlock had an error performing the command. $i) $($CommandName): $ScriptBlock."
                        if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull }
                        else { Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull }
                    }
                } else {
                    if ($jobActionMethodNewWindow) {
                        try {
                            $outOptions = $CommandLine
                            $optionsArray = $Options.split(" ")
                            foreach ($option in $optionsArray) {
                                $outOptions += $option
                            }
                            # $installProcess = 
                            if ($DoVerbose) { 
                                Add-LogText -Message "NOTE: $i) Opening new window..." `
                                    -ForegroundColor Red `
                                    -logFileNameFull $logFileNameFull
                            }
                            # Create a new process
                            $process = New-Object System.Diagnostics.Process
                            $process.StartInfo.FileName = $CommandName
                            $process.StartInfo.Arguments = $outOptions
                            $process.StartInfo.UseShellExecute = $false
                            $process.StartInfo.RedirectStandardOutput = $true
                            $process.StartInfo.RedirectStandardError = $true
                            $process.StartInfo.CreateNoWindow = $true
                            # Start the process
                            $process.Start() | Out-Null
                            if (-not $jobActionSkipWait) {
                                # Wait for the process to exit
                                $Message = "Invoke-Invoke Waiting form command to complete. $i) $($CommandName): $CommandLine."
                                if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -logFileNameFull $logFileNameFull }
                                else { Add-LogText -Message $Message -logFileNameFull $logFileNameFull }
    
                                $process.WaitForExit()
                                $standardOutput = $process.StandardOutput.ReadToEnd()
                                $errorOutput = $process.StandardError.ReadToEnd()
                                $logFileNames = $standardOutput | Where-Object { $_ -match "LogFile:" } | Select-Object -Unique
                                $exitCode = $process.ExitCode
                            } else {
                                $standardOutput = "Not Waiting for job $i."
                                $errorOutput = ""
                                $exitCode = 1
                            }
                        } catch {
                            $Message = "Invoke-Invoke Command Open New Window had an error performing the command. $i) $($CommandName): $CommandLine."
                            if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull }
                            else { Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull }
                        }
                    } else {
                        try {
                            # Execute the command and capture output and error
                            $outputFile = "$($(get-item $PSScriptRoot).Parent.FullName)\log\output$global:jobActionId.txt"
                            Invoke-Expression "$CommandName $CommandLine *> $outputFile"
                            $outputBuffer = Get-Content $outputFile
                            # Remove-Item $outputFile -ErrorAction SilentlyContinue
                            $errorOutput = $outputBuffer | Where-Object { $_ -match "error" }
                            $standardOutput = $outputBuffer # | Where-Object { $_ -notmatch "error" }
                            $logFileNames = $outputBuffer | Where-Object { $_ -match "LogFile:" } | Select-Object -Unique
                            $exitCode = $LASTEXITCODE
                        } catch {
                            $Message = "Invoke-Invoke Command and Wait had an error performing the command. $i) $($CommandName): $CommandLine."
                            if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull }
                            else { Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull }
                        }
                    }
                }
                try {
                    if (-not $standardOutput) { $standardOutput = @() }
                    if (-not $errorOutput) { $errorOutput = @() }
                    if (-not $logFileNames) { $logFileNames = @() }
                    if ($HandleError) {
                        if ($exitCode -ne 1 -or $errorOutput) {
                            $Message = "$CommandName error $exitCode - $(Get-RobocopyExitMessage($exitCode))."
                            if ($errorOutput) { $Message += "`nDetails: $errorOutput" }
                        } elseif ($standardOutput) {
                            if ($DoVerbose) {
                                $Message = "Output from $($CommandName): $global:NL$standardOutput"
                            } else {
                                $Message = "Ok"
                            }
                        }
                        if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -logFileNameFull $logFileNameFull }
                        else { Add-LogText -Message $Message -logFileNameFull $logFileNameFull }
                    }
                    $timeCompleted = Get-Date
                    # $CommandResults.Add("($i) [$exitCode] { $CommandLine } ### $outputBuffer")
                    # $logFileName += $global:app.logFileName
                    $logFileNamesAll = $logFileNames | Where-Object { $_ -match "LogFile:" } | Select-Object -Unique
                    if (-not $logFileNamesAll) { $logFileNamesAll = @() }
                    [CommandAction]$result = [CommandAction]::new(
                        $i,
                        $exitCode,
                        $CommandName,
                        $CommandLine,
                        $ScriptBlock,
                        $standardOutput,
                        $errorOutput,
                        $outputBuffer,
                        $null,
                        $logFileNamesAll,
                        $timeStarted,
                        $timeCompleted
                    )
                    $Message = $result.Display()
                    if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -logFileNameFull $logFileNameFull }
                    else { Add-LogText -Message $Message -logFileNameFull $logFileNameFull }
                    $CommandResults.Add($result)
                } catch {
                    $Message = "Invoke-Invoke Command error handling and completion had an error performing the command. $i) $($CommandName)."
                    if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull }
                    else { Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull }
                }
            } catch {
                $Message = "Invoke-Invoke had an error performing the command. $i) $($CommandName)."
                if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull }
                else { Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull }
            }
        }
    }
    end {
        if (-not $logFileNamesAll) { $logFileNamesAll = @() }
        if (-not $global:app.logFileNames) { $global:app.logFileNames = @() }
        $logFileNamesAll += "LogFile: $($global:app.logFileNameFull)"
        $logFileNamesAll = $logFileNamesAll | Where-Object { $_ -match "LogFile:" } | ForEach-Object { $_.Trim() } | Select-Object -Unique
        $global:app.logFileNames += $logFileNamesAll | Where-Object { $_ -match "LogFile:" } | ForEach-Object { $_.Trim() } | Select-Object -Unique
        # $global:app.logFileNames += $logFileNamesAll | Where-Object { $_ -match "LogFile:" } | Select-Object -Unique
        $Message = "LogFiles:"
        if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message }
        else { Add-LogText -Message $Message -logFileNameFull $logFileNameFull }
        foreach ($logFileName in $global:app.logFileNames) {
            $Message = $logFileName
            if ($global:ActionOutputTextBox) { Update-WFTextBox -textBox $global:ActionOutputTextBox -text $Message }
            else { Add-LogText -Message $Message -logFileNameFull $logFileNameFull }
        }
        [Collections.ArrayList]$CommandResults
    }
    # Execute the  command using cmd.exe
    # with /c which does the command and then terminates. 
    # The 2>&1 redirects standard error to standard output, 
    # allowing you to capture both in the $outputBuffer variable.
    # Execute the command and capture only the error output
    # $errorOutput = & cmd.exe /c $CommandLine 2>&1 1>$null
    # $errorOutput = & cmd.exe /c $CommandLine 1>$null 2>&1
    # $outputBuffer = & cmd.exe /c $CommandLine 2>&1
    # $outputBuffer = & cmd.exe /c $CommandLine 1>&1 2>&1
    # $outputBuffer = Invoke-Expression "$CommandLine 2>&1"
    # $outputBuffer = & cmd.exe /c "$CommandLine 1>&1 2>&1"
    # $outputBuffer = & cmd.exe /c "$CommandLine 2>&1"
}
function Update-ProcessTimer {
    [CmdletBinding()]
    param ($sender, $e,
        $job,
        [string]$logFileNameFull = ""
    )
    begin { 
        if ($global:jobActionTimerBusy) { return }
        $global:jobActionTimerBusy = $true
    }
    process {
        # Check for job output
        if ($global:job) {
            if ($global:job.State -eq 'Running') {
                if ($global:job.HasMoreData) {
                    $outputBuffer = Receive-Job -Job $global:job -Keep
                    $global:outputBuffer += $outputBuffer
                    Update-WFTextBox -logFileNameFull $logFileNameFull
                }
            } else {
                if ($global:jobActionTimer.Enabled) { $global:jobActionTimer.Stop() }
                $result = Receive-Job -Job $global:job
                $global:outputBuffer += "$result$global:NL"
                Update-WFTextBox -logFileNameFull $logFileNameFull
                $Message = "Job $buttonName has finished."
                Update-WFTextBox -Text $Message -logFileNameFull $logFileNameFull
                # Clean up the job
                Remove-Job -Job $global:job
                $Message = "Job $buttonName removed."
                Update-WFTextBox -Text $Message -logFileNameFull $logFileNameFull
            }
        } else {
            if ($global:jobActionTimer.Enabled) { $global:jobActionTimer.Stop() }
        }
    }
    end {
        $global:jobActionTimerBusy = $false
    }
}
function Invoke-ProcessWithExit {
    [CmdletBinding()]
    param (
        $newProcess,
        $newArguments,
        [switch]$RunAs,
        [switch]$DoExit
    )
    process {
        if (-not $newProcess) {
            # Create a new process object that starts PowerShell
            $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell"
        }
        if (-not $newArguments) {
            # Specify the current script path and name as a parameter
            $newProcess.Arguments = $myInvocation.MyCommand.Definition
            # $newProcess.Arguments = "& '" + $MyInvocation.MyCommand.Name + "'"            
        } else {
            $newProcess.Arguments = $newArguments
        }
            
        # Indicate that the process should be elevated
        if ($RunAs) { $newProcess.Verb = "runas" }
            
        # Start the new process
        [System.Diagnostics.Process]::Start($newProcess)
            
        # Exit from the current, unelevated, process
        if ($DoExit) { exit }
    }
}
function Invoke-ProcessWithTimeout {
    <#
    .SYNOPSIS
        Execute a command.
    .DESCRIPTION
        This executes the supplied command with a timeout.
    .PARAMETER command
        Command to execute.
    .PARAMETER timeout
        The timeout.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        Performs the command.
    .EXAMPLE
        Invoke-ProcessWithTimeout "notepad.exe" 30
#>


    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$command = "",
        [Parameter(Mandatory = $false)]
        [int]$timeout = 10,
        $logFileNameFull = ""
    )
    process {
        $process = Start-Process `
            -FilePath "$command" `
            -PassThru
        if ($process.WaitForExit($timeout)) {
            Add-LogText -Message "Process completed within timeout." -logFileNameFull $logFileNameFull
        } else {
            Add-LogText -Message "Process timed out and will be terminated." -logFileNameFull $logFileNameFull
            $process.Kill()
        }
    }
}
function Push-ShellPwsh {
    <# 
    .DESCRIPTION
        Note: Place [CmdletBinding()] above param(...) to make
            the script an *advanced* one, which then prevents passing
            extra arguments that don't bind to declared parameters.
        Issue: Example:
        @powershell -ExecutionPolicy Bypass -File "test.ps1" -stringParam "testing" -switchParam `
            > "output.txt" 2>&1
        The script I am calling requires PowerShell 7+, 
            so I need to restart the script by calling pwsh 
            with the current parameters. 
        I planned to accomplish this via the following:
        Invoke-Command { & pwsh -Command $MyInvocation.Line } -NoNewScope
        Unfortunately, $MyInvocation.Line does not return the correct result
            when a PowerShell script is called from a batch file.
            What alternatives exist that would work in this scenario?
#>


    [CmdletBinding()]
    param (
        [string] $stringParam,
        [switch] $switchParam
    )
    process {
        # If invoked via powershell.exe, re-invoke via pwsh.exe
        if ((Get-Process -Id $PID).Name -eq 'powershell') {
            # $PSCommandPath is the current script's full file path,
            # and @PSBoundParameters uses splatting to pass all 
            # arguments that were bound to declared parameters through.
            # Any extra arguments, if present, are passed through with @args
            pwsh -ExecutionPolicy Bypass -File $PSCommandPath @PSBoundParameters @args
            exit $LASTEXITCODE
        }
 
        # Getting here means that the file is being executed by pwsh.exe
 
        # Print the arguments received:
 
        if ($PSBoundParameters.Count) {
            "-- Bound parameters and their values:$global:NL"
            # !! Because $PSBoundParameters causes table-formatted
            # !! output, synchronous output must be forced to work around a bug.
            # !! See notes below.  
            $PSBoundParameters | Out-Host
        }
 
        if ($args) {
            "$global:NL-- Unbound (positional) arguments:$global:NL"
            $args
        }
 
        exit 0
    }
}
# ###############################
function Set-CommonParameters {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline)]
        [hashtable]$commonParameters = @{},
        [string]$logFileNameFull = "",
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause
    )
    begin {
        #  if (-not $outputParams) { $outputParams = New-Object System.Collections.ArrayList($null) }
        $outputParams = $PSBoundParameters
    }
    process {
        $outputParams.Add($_) | Out-Null
    }
    end {
        if ($DoForce -or $PSBoundParameters['Force']) { $outputParams['Force'] = $true; Write-Verbose "Force" }
        if ($DoVerbose -or $PSBoundParameters['Verbose'] -or $VerbosePreference -ne 'Continue') { $outputParams['Verbose'] = $true; Write-Verbose "Verbose" }
        # if ($DoDebug -or $PSBoundParameters['Debug']) { $outputParams['Debug'] = $true; Write-Verbose "Debug" }
        if (Assert-Debug) { $outputParams['Debug'] = $true; Write-Verbose "Debug" }
        # $DoPause can use PSBreakpoint actions. This is handled in some places.
        $outputParams['ErrorAction'] = if ($errorActionValue) { $errorActionValue } else { 'Continue' }
        # $outputParams += $global:commonParamsPrelude
        return $outputParams
    }
}
function Get-ScriptName { 
    <#
    .SYNOPSIS
        Get the Script Name.
    .DESCRIPTION
        Get $MyInvocation.Script_Name.
    .OUTPUTS
        $MyInvocation.Script_Name
    .EXAMPLE
        Get-ScriptName
#>


    [CmdletBinding()]
    param()
    process { return $MyInvocation.Script_Name }
}
function Get-ScriptPositionalParameters {
    <#
    .SYNOPSIS
        Get-ScriptPositionalParameters.
    .DESCRIPTION
        Get-ScriptPositionalParameters.
    .PARAMETER functionName
        The function name to examine.
    .OUTPUTS
        A list of positional parameters for that function.
    .NOTES
        Answered Jan 27, 2022 at 4:23 user16136127 StackOverflow
        "https://stackoverflow.com/questions/70853968/how-do-i-fix-this-positional-parameter-error-powershell"
        Alternatively, you might check if your cmdlet has any positional parameters. 
        You can search the documentation. But a quick way is to have PowerShell do the work. 
        Use the one-liner below. And just replace "Get-ChildItem" with the cmdlet you are interested in. 
        Remember, if the output only shows "Named"" then the cmdlet does not accept positional parameters.
        Below, there are two positional parameters: Path and Filter.
    .EXAMPLE
        Get-ScriptPositionalParameters
#>


    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$functionName
    )
    process {
        Get-Help -Name $functionName -Parameter * | 
            Sort-Object -Property position | 
                Select-Object -Property name, position | Write-Host
    }
}
# ###############################
function Get-PSCommandPath { 
    <#
    .SYNOPSIS
        Get-PSCommandPath.
    .DESCRIPTION
        Get-PSCommandPath.
        from stackoverflow
    .OUTPUTS
        $Script_PSCommandPath
    .EXAMPLE
        Get-PSCommandPath
#>


    [CmdletBinding()]
    param()
    process { return $Script_PSCommandPath }
}
function Get-MyCommand_InvocationName {
    <#
    .SYNOPSIS
        Get-MyCommand_InvocationName.
    .DESCRIPTION
        Get-MyCommand_InvocationName.
    .OUTPUTS
        $MyInvocation.InvocationName
    .EXAMPLE
        Get-MyCommand_InvocationName
#>


    [CmdletBinding()]
    param()
    process { return $MyInvocation.InvocationName }
}
function Get-MyCommand_Invocation {
    <#
    .SYNOPSIS
        Get-MyCommand_InvocationName.
    .DESCRIPTION
        Get-MyCommand_InvocationName.
    .OUTPUTS
        $MyInvocation.InvocationName
    .EXAMPLE
        Get-MyCommand_InvocationName
#>


    [CmdletBinding()]
    param()
    process { return $MyInvocation }
}
function Get-MyCommand_Origin {
    <#
    .SYNOPSIS
        Get-MyCommand_Origin
    .DESCRIPTION
        Get-MyCommand_Origin
    .OUTPUTS
        $MyInvocation.Get-MyCommand_.CommandOrigin 
    .EXAMPLE
        Get-MyCommand_Origin
#>


    [CmdletBinding()]
    param()
    process {
        return $MyInvocation.MyCommand_.CommandOrigin 
    }
}
function Get-MyCommand_Name {
    <#
    .SYNOPSIS
        Get-MyCommand_Name.
    .DESCRIPTION
        Get-MyCommand_Name.
    .OUTPUTS
        $MyInvocation.Get-MyCommand_.Name 
    .EXAMPLE
        Get-MyCommand_Name
#>


    [CmdletBinding()]
    param()
    process { return $MyInvocation.MyCommand_.Name }
}
function Get-MyCommand_Definition {
    <#
    .SYNOPSIS
        Get-MyCommand_Definition.
    .DESCRIPTION
        Get-MyCommand_Definition.
    .OUTPUTS
        $MyInvocation.Get-MyCommand_.Definition
    .EXAMPLE
        Get-MyCommand_Definition
#>


    [CmdletBinding()]
    param()
    # Begin of Get-MyCommand_Definition()
    # Note: output of this script shows the contents of this function, not the execution result
    process { return $MyInvocation.MyCommand_.Definition }
}
function Get-Invocation_PSCommandPath { 
    <#
    .SYNOPSIS
        Get-Invocation_PSCommandPath.
    .DESCRIPTION
        Get-Invocation_PSCommandPath.
    .OUTPUTS
        $MyInvocation.Get-PSCommandPath 
    .EXAMPLE
        Get-Invocation_PSCommandPath
#>


    [CmdletBinding()]
    param()
    process { return $MyInvocation.PSCommandPath }
}
# ###############################
function Confirm-SecElevated() {
    <#
    .SYNOPSIS
        Elevate script to Administrator.
    .DESCRIPTION
        Get the security principal for the Administrator role.
        Check to see if we are currently running "as Administrator",
        Create a new process object that starts PowerShell,
        Indicate that the process should be elevated ("runas"),
        Start the new process.
    .PARAMETER message
        Message to display when elevating.
    .EXAMPLE
        Set-SecElevated "Elevating myself."
    .NOTES
        This works but I think there are problems depending on the shell type.
        ISE for example.
    .OUTPUTS
        None. Returns or Executes current script in an elevated process.
#>


    [CmdletBinding()]
    param (
        # [switch]$DoPause,
        # [switch]$DoVerbose
    )
    process {
        # Confirm-SecElevated
        # Self-elevate the script if required
        if (-Not ([Security.Principal.WindowsPrincipal] `
                    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole( `
                    [Security.Principal.WindowsBuiltInRole] 'Administrator' `
            )) {
            return $false
            # if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
            #     $CommandLine = "-File `"" + $MyInvocation.MyCommand_.Path + "`" " + $MyInvocation.UnboundArguments
            #     Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
            #     Exit
            # }
        } else { return $true }
    }
}
function Set-SecElevated {
    <#
    .SYNOPSIS
        Elevate script to Administrator.
    .DESCRIPTION
        Get the security principal for the Administrator role.
        Check to see if we are currently running "as Administrator",
        Create a new process object that starts PowerShell,
        Indicate that the process should be elevated ("runas"),
        Start the new process.
    .PARAMETER message
        Message to display when elevating.
    .EXAMPLE
        Set-SecElevated "Elevating myself."
    .NOTES
        This works but I think there are problems depending on the shell type.
        ISE for example.
    .OUTPUTS
        None. Returns or Executes current script in an elevated process.
#>


    [CmdletBinding()]
    param ($Message)

    # Set-SecElevated
    # Get the ID and security principal of the current user account
    $myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myWindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
            
    # Get the security principal for the Administrator role
    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
            
    # Check to see if we are currently running "as Administrator"
    if ($myWindowsPrincipal.IsInRole($adminRole)) {
        Write-Verbose "We are running ""as Administrator""."
        # $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand_.Definition + "(Elevated)"
        $Host.UI.RawUI.WindowTitle = $Host.UI.RawUI.WindowTitle + " (Elevated)"
        # $Host.UI.RawUI.BackgroundColor = "DarkGray"
        # clear-host
    } else {
        Write-Verbose "We are not running ""as Administrator"" - relaunching as administrator."
        if ($DoVerbose) { 
            Write-Host -NoNewLine "Press any key to continue..." -NoNewline
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
        }
        Invoke-ProcessWithExit -RunAs -DoExit    
    }
    # Run your code that needs to be elevated here
    # Write-Verbose -NoNewLine "Press any key to continue..."
    # $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}