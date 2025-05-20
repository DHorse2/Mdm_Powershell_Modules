
# Import-All
Using namespace Microsoft.VisualBasic
Using namespace PresentationFramework
Using namespace System.Drawing
Using namespace System.Windows.Forms
Using namespace System.Web
Using namespace Microsoft.PowerShell.Security
Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Web
Add-Type -AssemblyName Microsoft.PowerShell.Security

# Import-All
try {
    # Get-Parameters
    $path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\Mdm_Std_Library\Public\Get-Parameters.ps1"
    . $path
    # Load Security
    $path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\Mdm_Std_Library\Public\Check-Security.ps1"
    . "$path"
    # CommandResultClass
    # MarginClass
    # WindowClass
    # $global:importParameters['Force'] = $true
    $global:importParameters['ErrorAction'] = 'Continue'

    $importName = "Mdm_Std_Library"
    if ($DoVerbose) { 
        Write-Host "Module: $importName"
        Write-Host "Project Root: Exists: $(Test-Path "$global:projectRootPath"): $global:projectRootPath"
        Write-Host " Module Root: Exists: $(Test-Path "$global:moduleRootPath"): $global:moduleRootPath"
        Write-Host "Execution at: Exists: $(Test-Path "$global:projectRootPathActual"): $global:projectRootPathActual"
    }
    if (-not ((Get-Module -Name $importName) -or $global:DoForce)) {
        $modulePath = "$global:moduleRootPath\$importName"
        if ($DoVerbose) { Write-Output "Exists: $(Test-Path "$modulePath"): $modulePath" }
        Import-Module -Name $modulePath @global:importParameters
    } else {
        if ($DoVerbose) { Write-Host "Module already loaded: $importName" }
    }

    # Get-Import. Not Used, crashes the shell
    # Add $DoXxxxx params
    # $global:MdmParams.GetEnumerator() | ForEach-Object {
    #     $global:importParameters[$_.Key] = $_.Value
    # }
    # $global:importParameters['CheckActive'] = $true
    # $global:importParameters['CheckImported'] = $false
    # $importName = "Mdm_Bootstrap"
    # Import-Module -Name $importName
    # $null = Get-Import -Name $importName @global:importParameters
    #
    # $importName = "Mdm_WinFormPS"
    # Get-Import -Name $importName @global:importParameters
    #
    # $importName = "Mdm_Nightroman_PowerShelf"
    # $null = Get-Import -Name $importName -DoModuleScan @global:importParameters
    #
    # $importName = "Mdm_DevEnv_Install"
    # $null = Get-Import -Name $importName @global:importParameters
    #
    # $importName = "Mdm_PoshFunctions"
    # $null = Get-Import -Name $importName @global:importParameters
    #
    # $importName = "Mdm_Springcomp_MyBox"
    # $null = Get-Import -Name $importName -DoModuleScan @global:importParameters

    $importName = "Mdm_Bootstrap"
    $path = "$($(Get-Item $PSScriptRoot).FullName)\Get-ModuleValidated.ps1"
    . $path
    # $moduleActive = Confirm-ModuleActive -Name $importName `
    #     -jsonFileName "$global:moduleRootPath\Mdm_DevEnv_Install\Public\DevEnvModules.json" `
    #     @global:combinedParams
    # if ($moduleActive) { 

    #     if ($DoVerbose) { 
    #         Write-Host "Module 2: $importName"
    #     }
    #     if (-not ((Get-Module -Name $importName) -or $global:DoForce)) {
    #         $modulePath = "$global:moduleRootPath\$importName"
    #         if ($DoVerbose) { Write-Output "Exists: $(Test-Path "$modulePath"): $modulePath" }
    #         Import-Module -Name $modulePath @global:importParameters
    #     }
    # }

    if ($DoVerbose) { 
        Write-Host "Module 3: Available empty slot"
    }

    $importName = "Mdm_WinFormPS"
    $path = "$($(Get-Item $PSScriptRoot).FullName)\Get-ModuleValidated.ps1"
    . $path
    # $null = Get-Import -Name $importName ` !!! This crashed
    # -CheckActive -CheckImported -ErrorAction Continue  @global:importParameters
    # $moduleActive = Confirm-ModuleActive -Name $importName `
    #     -jsonFileName "$global:moduleRootPath\Mdm_DevEnv_Install\Public\DevEnvModules.json" `
    #     @global:combinedParams
    # if ($moduleActive) { 
    #     if ($DoVerbose) { 
    #         Write-Host "Module 4: $importName"
    #     }
    #     if (-not ((Get-Module -Name $importName) -or $global:DoForce)) {
    #         $modulePath = "$global:moduleRootPath\$importName"
    #         if ($DoVerbose) { Write-Output "Exists: $(Test-Path "$modulePath"): $modulePath" }
    #         Import-Module -Name $modulePath @global:importParameters
    #     }
    # }

    $importName = "Mdm_Nightroman_PowerShelf"
    $path = "$($(Get-Item $PSScriptRoot).FullName)\Get-ModuleValidated.ps1"
    . $path
    # $null = Get-Import -Name $importName `
    #     -CheckActive -CheckImported -ErrorAction Continue  @global:importParameters
    # $moduleActive = Confirm-ModuleActive -Name $importName `
    #     -jsonFileName "$global:moduleRootPath\Mdm_DevEnv_Install\Public\DevEnvModules.json" `
    #     @global:combinedParams
    # if ($moduleActive) { 
    #     if ($DoVerbose) { 
    #         Write-Host "Module 5: $importName"
    #     }
    #     if (-not ((Get-Module -Name $importName) -or $global:DoForce)) {
    #         $modulePath = "$global:moduleRootPath\$importName"
    #         if ($DoVerbose) { Write-Output "Exists: $(Test-Path "$modulePath"): $modulePath" }
    #         $null = Export-ModuleMemberScan -moduleRootPath $modulePath @global:importParameters
    #     }
    # }

    $importName = "Mdm_DevEnv_Install"
    $path = "$($(Get-Item $PSScriptRoot).FullName)\Get-ModuleValidated.ps1"
    . $path
    # $null = Get-Import -Name $importName `
    #     -CheckActive -CheckImported -ErrorAction Continue  @global:importParameters
    # $moduleActive = Confirm-ModuleActive -Name $importName `
    #     -jsonFileName "$global:moduleRootPath\Mdm_DevEnv_Install\Public\DevEnvModules.json" `
    #     @global:combinedParams
    # if ($moduleActive) { 
    #     if ($DoVerbose) { 
    #         Write-Host "Module 6: $importName"
    #     }
    #     if (-not ((Get-Module -Name $importName) -or $global:DoForce)) {
    #         $modulePath = "$global:moduleRootPath\$importName"
    #         if ($DoVerbose) { Write-Output "Exists: $(Test-Path "$modulePath"): $modulePath" }
    #         Import-Module -Name $modulePath @global:importParameters
    #     }
    # }

    $importName = "Mdm_PoshFunctions"
    $path = "$($(Get-Item $PSScriptRoot).FullName)\Get-ModuleValidated.ps1"
    . $path
    # $null = Get-Import -Name $importName `
    #     -CheckActive -CheckImported -ErrorAction Continue  @global:importParameters
    # $moduleActive = Confirm-ModuleActive -Name $importName `
    #     -jsonFileName "$global:moduleRootPath\Mdm_DevEnv_Install\Public\DevEnvModules.json" `
    #     @global:combinedParams
    # if ($moduleActive) { 
    #     if ($DoVerbose) { 
    #         Write-Host "Module 7: $importName"
    #     }
    #     if (-not ((Get-Module -Name $importName) -or $global:DoForce)) {
    #         $modulePath = "$global:moduleRootPath\$importName"
    #         if ($DoVerbose) { Write-Host "Exists: $(Test-Path "$modulePath"): $modulePath" }
    #         Import-Module -Name $modulePath @global:importParameters
    #     } else {
    #         if ($DoVerbose) { Write-Host "Module already loaded: $modulePath" }
    #     }
    # }

    $importName = "Mdm_Springcomp_MyBox"
    $path = "$($(Get-Item $PSScriptRoot).FullName)\Get-ModuleValidated.ps1"
    . $path
    # $null = Get-Import -Name $importName `
    #     -CheckActive -CheckImported -ErrorAction Continue  @global:importParameters
    # $moduleActive = Confirm-ModuleActive -Name $importName `
    #     -jsonFileName "$global:moduleRootPath\Mdm_DevEnv_Install\Public\DevEnvModules.json" `
    #     @global:combinedParams
    # if ($moduleActive) { 
    #     if ($DoVerbose) { 
    #         Write-Host "Module 8: $importName"
    #     }
    #     if (-not ((Get-Module -Name $importName) -or $global:DoForce)) {
    #         $modulePath = "$global:moduleRootPath\$importName"
    #         if ($DoVerbose) { Write-Output "Exists: $(Test-Path "$modulePath"): $modulePath" }
    #         $null = Export-ModuleMemberScan -moduleRootPath $modulePath -modulePublicFolder "bootstrap" @global:importParameters
    #     }
    # }

} catch {
    Write-Error -Message "Import-All had a processing error. $_"
}

if ($DoVerbose) { 
    Write-Host "Project Root: Exists: $(Test-Path "$global:projectRootPath"): $global:projectRootPath"
    Write-Host " Module Root: Exists: $(Test-Path "$global:moduleRootPath"): $global:moduleRootPath"
    Write-Host "Execution at: Exists: $(Test-Path "$global:projectRootPathActual"): $global:projectRootPathActual"
}
