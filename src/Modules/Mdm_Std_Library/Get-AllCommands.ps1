
function Get-AllCommands {
    [CmdletBinding()]
    param (
        $moduleRoot = ""
    )
    process {
        if (-not $moduleRoot) { $moduleRoot = (get-item $PSScriptRoot).parent.FullName }
        
        # Collect all Cmdlets to a text file
        Get-Command `
        | Sort-Object -Property ModuleName `
        | Group-Object -Property Module `
        | Out-File -FilePath "$moduleRoot\Mdm_Bootstrap\help\CommandList.txt"

        # Get-Module -ListAvailable `
        # | Sort-Object -Property ModuleName, Name `
        # | Select-Object ModuleType, Version, Name `
        # | Out-File -FilePath "$moduleRoot\Mdm_Bootstrap\help\CommandList.txt"

        Get-Command -Type Function, Cmdlet `
        | Sort-Object -Property Name `
        | Select-Object Name `
        | Out-File -FilePath "$moduleRoot\Mdm_Bootstrap\help\CommandList.txt" -Append

        # Get-Command -Type Cmdlet | Sort-Object -Property Noun | Format-Table -GroupBy Noun `
        # Get-Command -CommandType Cmdlet `
        # $_ | Out-File -FilePath $localLogFileNameFull –Append
        # Get-Command -Type Cmdlet `
        # | Sort-Object -Property Noun, Name `
        # | Format-Table -GroupBy Noun `
        # | Out-File -FilePath "$moduleRoot\Mdm_Bootstrap\help\PowerShellCommands.txt"
        
        Get-Command -Type Function, Cmdlet `
        | Sort-Object -Property ModuleName, Name `
        | Select-Object ModuleName, Version, Name `
        | Format-Table -GroupBy ModuleName `
        | Out-File -FilePath "$moduleRoot\Mdm_Bootstrap\help\CommandsByModule.txt" -Append

    }
}
