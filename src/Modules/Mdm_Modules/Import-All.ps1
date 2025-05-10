
# Import-All
$path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\Mdm_Std_Library\Public\Get-Parameters.ps1"
. $path

$importName = "Mdm_Bootstrap"
if ($DoVerbose) { 
    Write-Host "Module 1: $importName"
    Write-Host "Project Root: $global:projectRootPath"
    Write-Host " Module Root: $global:moduleRootPath"
    Write-Host "Execution at: $global:projectRootPathActual"
}
if (-not ((Get-Module -Name $importName) -or $global:DoForce)) {
    $modulePath = "$global:moduleRootPath\$importName"
    Import-Module -Name $modulePath @commonParameters
}
# $null = Get-Import -Name "$global:moduleRootPath\$importName" `
#     -CheckImported -ErrorAction Continue  @commonParameters

$importName = "Mdm_Std_Library"
if ($DoVerbose) { 
    Write-Host "Module 2: $importName"
    Write-Host "Project Root: $global:projectRootPath"
    Write-Host " Module Root: $global:moduleRootPath"
    Write-Host "Execution at: $global:projectRootPathActual"
}
if (-not ((Get-Module -Name $importName) -or $global:DoForce)) {
    $modulePath = "$global:moduleRootPath\$importName"
    Import-Module -Name $modulePath @commonParameters
}

$importName = "Mdm_DevEnv_Install"
if ($DoVerbose) { 
    Write-Host "Module 3: $importName"
    Write-Host "Project Root: $global:projectRootPath"
    Write-Host " Module Root: $global:moduleRootPath"
    Write-Host "Execution at: $global:projectRootPathActual"
}
if (-not ((Get-Module -Name $importName) -or $global:DoForce)) {
    $modulePath = "$global:moduleRootPath\$importName"
    Import-Module -Name $modulePath @commonParameters
}

$importName = "Mdm_WinFormPS"
if ($DoVerbose) { 
    Write-Host "Module 4: $importName"
    Write-Host "Project Root: $global:projectRootPath"
    Write-Host " Module Root: $global:moduleRootPath"
    Write-Host "Execution at: $global:projectRootPathActual"
}
if (-not ((Get-Module -Name $importName) -or $global:DoForce)) {
    $modulePath = "$global:moduleRootPath\$importName"
    Import-Module -Name $modulePath @commonParameters
}

