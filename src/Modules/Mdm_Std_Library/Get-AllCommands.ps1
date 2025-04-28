
function Get-AllCommands {
    [CmdletBinding()]
    param (
        $moduleRootPath = ""
    )
    process {
        if (-not $moduleRootPath) { $moduleRootPath = (get-item $PSScriptRoot).parent.FullName }
        
        # Collect all Cmdlets to a text file
        Get-Command `
        | Sort-Object -Property ModuleName `
        | Group-Object -Property Module `
        | Out-File -FilePath "$moduleRootPath\Mdm_Bootstrap\help\Commands.txt"

        Get-Command -Type Function, Cmdlet `
        | Sort-Object -Property Name `
        | Select-Object Name `
        | Out-File -FilePath "$moduleRootPath\Mdm_Bootstrap\help\CommandList.txt"

        Get-Module -ListAvailable `
        | Out-File -FilePath "$moduleRootPath\Mdm_Bootstrap\help\ModuleReportDetailed.txt"

        Get-Module `
        | Out-File -FilePath "$moduleRootPath\Mdm_Bootstrap\help\ModulesReport.txt"

        # Command by Module report
        # Adequate:
        # Get-Command -Type Function, Cmdlet `
        # | Sort-Object -Property ModuleName, Name `
        # | Select-Object ModuleName, Version, Name `
        # | Format-Table -GroupBy ModuleName `
        # | Out-File -FilePath "$moduleRootPath\Mdm_Bootstrap\help\CommandsByModule.txt"

        # Advanced with PSEdtion:
        $commands = Get-Command -Type Function, Cmdlet | 
            Select-Object ModuleName, Name
        $modules = Get-Module -ListAvailable | 
            Select-Object Name, Version, PSEdition
        # Join the two sets of information
        $results = $commands | 
            ForEach-Object {
                $module = $modules | Where-Object { $_.Name -eq $_.ModuleName }
                [PSCustomObject]@{
                    ModuleName  = $_.ModuleName
                    Version     = $module.Version
                    PSEdition   = $module.PSEdition
                    Name        = $_.Name
                    CommandType = $_.CommandType
                }
            }
        # Sort the results
        $sortedResults = $results | Sort-Object -Property ModuleName, CommandType, Name
        $formattedOutput = $sortedResults | Format-Table -AutoSize | Out-String
        $formattedOutput | Out-File -FilePath "$moduleRootPath\Mdm_Bootstrap\help\CommandsByModule.txt"
    }
}
