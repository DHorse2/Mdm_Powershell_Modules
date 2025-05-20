
# Get-ModuleValidated
$jsonFileName = "$global:moduleRootPath\Mdm_DevEnv_Install\Public\DevEnvModules.json"
$jsonData = Get-JsonData -jsonObject $jsonFileName
$moduleActive = Confirm-ModuleActive -Name $importName `
    -jsonData $jsonData `
    @global:combinedParams
if ($moduleActive) { 
    if ($DoVerbose) { 
        Write-Host "Module : $importName"
    }
    if (-not ((Get-Module -Name $importName) -or $global:DoForce)) {
        $modulePath = "$global:moduleRootPath\$importName"
        if ($DoVerbose) { Write-Output "Exists: $(Test-Path "$modulePath"): $modulePath" }
        if (-not (Confirm-ModuleScan -Name $importName `
                    -jsonData $jsonData @global:combinedParams)) {
            Import-Module -Name $modulePath @global:importParameters
        } else {
            if ($DoVerbose) { Write-Host "Scanning module: $importName" }
            $null = Export-ModuleMemberScan -moduleRootPath $modulePath -modulePublicFolder "bootstrap" @global:importParameters
        }

    } else {
        if ($DoVerbose) { Write-Host "Module already loaded: $importName" }
    }
}
