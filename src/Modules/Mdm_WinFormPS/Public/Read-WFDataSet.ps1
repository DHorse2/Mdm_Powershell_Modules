
# Read-WFDataSet
function Read-WFDataSet {
    [CmdletBinding()]
    param (
        $dataSet,
        $dataSetItem,
        $DoReset,
        $DoReturn
    )
    begin {
        if ($DoReset) {
            [hashtable]$global:moduleDataArray = New-Object System.Collections.Hashtable
        }
    }
    process {
        try {
            # Load Configuration
            $dataSetName = "Control"
            $formControlData = Get-JsonData -Name $dataSetName -UpdateGlobal -AddSource `
                -jsonObject ".\DevEnvGuiConfig.json"
            # Load components
            $dataSetName = "Modules"
            $moduleData = Get-JsonData -Name $dataSetName -UpdateGlobal -AddSource `
                -jsonObject ".\DevEnvModules.json"
            # $global:moduleDataArray += $modulesData
            # $global:moduleDataArray = Update-JsonData $componentsData $global:moduleDataArray
            #
            $dataSetName = "Components"
            $componentData = Get-JsonData -Name $dataSetName -UpdateGlobal -AddSource `
                -jsonObject ".\DevEnvComponents.json"
            #
            $dataSetName = "Categories"
            $categoryData = Get-JsonData -Name $dataSetName -UpdateGlobal -AddSource `
                -jsonObject ".\DevEnvCategories.json"
            # $global:moduleDataArray['changed'] = $false
        } catch {
            $Message = "DevEnvGui unable to load and create Tab Page objects."
            Add-LogText -Message $Message -IsCritical -IsError -ErrorPSItem $_
        }
    }
    end {
        if ($DoReturn) {
            return $global:moduleDataArray
        }
    }
}