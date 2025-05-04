
Write-Host "Building Modules"
$localPath = Get-Location
Write-Host "ExecutionPolicy:"
Get-ExecutionPolicy
# Set-ExecutionPolicy RemoteSigned

Write-Host "Go To Bootstrap"
. $localPath\GoToBootstrap.ps1
Get-Location

Write-Host "Dev Env Module Reset"
. $localPath\src\Modules\Mdm_Bootstrap\DevEnv_Module_Reset.ps1

Write-Host "Dev Env Install Modules Win"
. DevEnv_Install_Modules_Win
# . $localPath\src\Modules\Mdm_Bootstrap\Public\DevEnv_Install_Modules_Win.ps1
