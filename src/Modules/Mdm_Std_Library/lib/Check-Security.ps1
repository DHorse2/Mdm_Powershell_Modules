
# Check-Security
# CodeAction is used. Caution: This can exit on failure.
# Therefore use cautiously. This is part of the boot/load.
if (-not $global:moduleCoreLoaded) {
    # Project Parameters
    $inArgs = $args
    # Get-Parameters
    $path = "$($(get-item $PSScriptRoot).FullName)\Get-ParametersLib.ps1"
    . $path
    # Project settings and paths
    # projectLib.ps1
    $path = "$($(get-item $PSScriptRoot).FullName)\ProjectLib.ps1"
    . $path @global:combinedParams
}
# $global:CodeActionError = $true; $global:CodeActionError = $null
# $global:CodeActionLogFile = "$($(get-item $PSScriptRoot).FullName)\src\Modules\Mdm_Std_Library\log\CheckSecurity_Start.txt"
# Import and process results enclosure
try {
    $importName = "Microsoft.PowerShell.Security"
    $global:CodeActionError = $false; $global:CodeActionErrorInfo = @(); $global:CodeActionErrorMessage = @()
    # Error handling
    # Update-StdHeader
    if (-not $global:CodeActionLogFile) {
        $global:CodeActionLogFile = "$($(get-item $PSScriptRoot).Parent.FullName)\log\CheckSecurityLog.txt"
    }
    $now = Get-Date
    $displayHeader = "$global:now - Check-Security - $importName. "
    $displayHeader | Out-File -FilePath $global:CodeActionLogFile -Encoding UTF8
    # $displayHeader2 | Out-File -FilePath $global:CodeActionLogFile -Append -Encoding UTF8
    if ($DoVerbose) { Write-Host $displayHeader -ForegroundColor Yellow }
    try {
        # Security Module
        if (-not ((Get-Module -Name $importName) -or $DoForce)) {
            try {
                Import-Module -Name $importName -ErrorAction Stop | Out-File -FilePath $global:CodeActionLogFile -Append
                $Message = "Check-Security: Import Okay. "
            } catch {
                $global:CodeActionError = $true
                $Message = "Check-Security: Import Errors occured. Details skipped."
                $errorCategory = [Management.Automation.ErrorCategory]::PermissionDenied
                if ($DoVerbose) { Write-Host "Check-Security: New error" }
                $null = Get-ErrorNew -Message $Message -ErrorCategory $errorCategory -DoReturn -logFileNameFull $logFileNameFull
                $CodeActionErrorData = $global:errorRecord
                $global:CodeActionErrorInfo += @{
                    Message = ""
                    Error   = $CodeActionErrorData
                }
        }
        } else { $Message = "Check-Security: Module already loaded." }
        $Message | Out-File -FilePath $global:CodeActionLogFile -Append -Encoding UTF8
        # Language Mode
        if ($DoVerbose) { Write-Host "Check-Security: Language Mode" }
        $global:LanguageMode = $ExecutionContext.SessionState.LanguageMode
        if ($global:LanguageMode -ne "FullLanguage") {
            try {
                # Language Mode
                $Message = "Check-Security: DevEnv_LanguageMode `"Full`". "
                $Message | Out-File -FilePath $global:CodeActionLogFile -Append -Encoding UTF8

                # DevEnv_LanguageMode "Full" -ErrorAction SilentlyContinue | Out-File -FilePath $global:CodeActionLogFile -Append -Encoding UTF8
                # DevEnv_LanguageMode.ps1
                $path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Bootstrap\Public\DevEnv_LanguageMode.ps1"
                . $path "Full" -ErrorAction SilentlyContinue | Out-File -FilePath $global:CodeActionLogFile -Append -Encoding UTF8

                # Check results
                $global:LanguageMode = $ExecutionContext.SessionState.LanguageMode
                if ($global:LanguageMode -ne "FullLanguage") {
                    $global:CodeActionError = $true
                    $Message = "Check-Security: Your Session language mode ($($ExecutionContext.SessionState.LanguageMode)) can require `"FullLanguage`" mode. "
                    $errorCategory = [Management.Automation.ErrorCategory]::PermissionDenied
                    $null = Get-ErrorNew -Message $Message -ErrorCategory $errorCategory -DoReturn -logFileNameFull $logFileNameFull
                    # if ($CodeActionErrorData[1]) { $CodeActionErrorData = $CodeActionErrorData[1] }
                    $CodeActionErrorData = $global:errorRecord
                    $global:CodeActionErrorInfo += @{
                        Message = ""
                        Error   = $CodeActionErrorData
                    }
                    # $Message | Out-File -FilePath $global:CodeActionLogFile -Append -Encoding UTF8
                }
            } catch {
                $global:CodeActionError = $true
                $Message = "Check-Security: Language Mode Error in Module $importName. "
                $global:CodeActionErrorInfo += @{
                    Message = $Message
                    Error   = $_
                }
                # $CodeActionErrorMessage | Out-File -FilePath $global:CodeActionLogFile -Append -Encoding UTF8
            }
        }
        # Set ExecutionPolicy
        if ($DoVerbose) { Write-Host "Check-Security: Set ExecutionPolicy" }
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser | Out-File -FilePath $global:CodeActionLogFile -Append -Encoding UTF8
            $global:ExecutionPolicy = $(Get-ExecutionPolicy).ToString()
            if ($global:ExecutionPolicy -ne "RemoteSigned") {
                $global:CodeActionError = $true
                $Message = "Check-Security: Unable to set execution policy ($global:ExecutionPolicy) to `"RemoteSigned`". "
                $errorCategory = [Management.Automation.ErrorCategory]::PermissionDenied
                $null = Get-ErrorNew -Message $Message -ErrorCategory $errorCategory -DoReturn -logFileNameFull $logFileNameFull
                $CodeActionErrorData = $global:errorRecord
                $global:CodeActionErrorInfo += @{
                    Message = ""
                    Error   = $CodeActionErrorData
                }
                # $CodeActionErrorMessage | Out-File -FilePath $global:CodeActionLogFile -Append -Encoding UTF8
            }
        } catch {
            $global:CodeActionError = $true
            $Message = "Check-Security: Set ExecutionPolicy Error in Module $importName. "
            $global:CodeActionErrorInfo += @{
                Message = $Message
                Error   = $_
            }
            # $CodeActionErrorMessage | Out-File -FilePath $global:CodeActionLogFile -Append -Encoding UTF8
        }
    } catch {
        $global:CodeActionError = $true
        $Message = "Check-Security: Import Error in Module $importName. "
        $global:CodeActionErrorInfo += @{
            Message = $Message
            Error   = $_
        }
        # $CodeActionErrorMessage | Out-File -FilePath $global:CodeActionLogFile -Append -Encoding UTF8
    }
} catch {
    $global:CodeActionError = $true
    $Message = "Check-Security: Processing Error in Module $importName."
    $global:CodeActionErrorInfo += @{
        Message = $Message
        Error   = $_
    }
    # $CodeActionErrorMessage | Out-File -FilePath $global:CodeActionLogFile -Append -Encoding UTF8
}
Write-Host "Check-Security: Reporting..."
# It didn't fail in the manner where it jump up to the calling script.
# There may have been an error regardless or Verbose output may be on.
$UseTraceStack = $false
$path = "$($(get-item $PSScriptRoot).FullName)\Could-Fail.ps1"
. $path @global:combinedParams
