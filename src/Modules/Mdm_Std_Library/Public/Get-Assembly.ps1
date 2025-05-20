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
            Add-LogText -IsError -ErrorPSItem $_ -Message $_.Exception.Message
            # Add-LogText -IsError -ErrorPSItem $_

        }
    }
    end { }
}
