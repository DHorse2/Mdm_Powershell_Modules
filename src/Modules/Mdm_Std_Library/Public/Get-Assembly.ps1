function Get-Assembly {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$assemblyName
    )
    begin { }
    process {
        try {
            # Load the Assembly
            $assembly = Add-Type -AssemblyName $assemblyName -ErrorAction 'SilentlyContinue' -ErrorVariable ErrorBeginAddType
            if ($ErrorBeginAddType) {
                Write-Warning -Message "Get-Assembly failed to load assembly $assemblyName."
            } else {
                Write-Verbose -Message "Get-Assembly successfully loaded assembly: $assemblyName"
            }
            return $assembly
        } catch {
            Write-Warning -Message "Get-Assembly: Something went wrong while loading assembly $assemblyName. $_"
            Add-LogError -IsError -ErrorPSItem $ErrorPSItem -Message $_.Exception.Message
            # Add-LogError -IsError -ErrorPSItem $ErrorPSItem

        }
    }
    end { }
}
