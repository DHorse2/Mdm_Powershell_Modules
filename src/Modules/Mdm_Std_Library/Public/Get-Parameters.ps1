
# Get-Parameters
$commonParameters = $PSBoundParameters
# $commonParameters = @{}
if ($global:DoForce) { $commonParameters['Force'] = $true; Write-Verbose "Force" }
if ($global:DoVerbose) { $commonParameters['Verbose'] = $true; Write-Verbose "Verbose" }
if ($global:DoDebug) { $commonParameters['Debug'] = $true; Write-Verbose "Debug" }
if ($global:DoPause) { $commonParameters['Pause'] = $true; Write-Verbose "Pause" }
$commonParameters['ErrorAction'] = if ($global:errorActionValue) { $global:errorActionValue } else { 'Continue' }
$global:commonParameters = $commonParameters
