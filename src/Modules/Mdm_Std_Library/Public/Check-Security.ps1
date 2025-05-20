
# $importName = "Microsoft.PowerShell.Security"
try {
# if (-not ((Get-Module -Name $importName) -or $global:DoForce)) {
#     $modulePath = "$global:moduleRootPath\$importName"
    # if ($DoVerbose) { Write-Output "Exists: $(Test-Path "$modulePath"): $modulePath" }
    Import-Module Microsoft.PowerShell.Security -ErrorAction Stop
# }
}
catch {
    if ($DoDebug -or $DoVerbose) {
        Write-Warning "Error importing Microsoft.PowerShell.Security. $_"
    }
}
# Get-ExecutionPolicy
# Set-ExecutionPolicy RemoteSigned