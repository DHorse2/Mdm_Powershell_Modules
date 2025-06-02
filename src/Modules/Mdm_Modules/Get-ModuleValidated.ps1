
# Get-ModuleValidated
$moduleGroupName = "Modules"
$jsonFileName = "$global:moduleRootPath\Mdm_DevEnv_Install\data\DevEnvModules.json"
if (-not $global:moduleDataArray) { 
    [hashtable]$global:moduleDataArray = New-Object System.Collections.Hashtable
}
if (-not $global:moduleDataArray[$moduleGroupName]) {
    $jsonData = Get-JsonData -jsonItem $jsonFileName
    $global:moduleDataArray[$moduleGroupName] = $jsonData
} else {
    $jsonData = $global:moduleDataArray[$moduleGroupName]
}
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
            Import-Module -Name $modulePath @global:importParams
        } else {
            if ($DoVerbose) { Write-Host "Scanning module: $importName" }
            $null = Export-ModuleMemberScan -moduleRootPath $modulePath -modulePublicFolder "bootstrap" @global:importParams
        }

    } else {
        if ($DoVerbose) { Write-Host "Module already loaded: $importName" }
    }
}
