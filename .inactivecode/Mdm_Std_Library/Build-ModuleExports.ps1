# Build-ModuleExports

Function Build-ModuleExports {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$scriptRoot,
        [Parameter(Mandatory = $false)]
        [string]$scriptPublic = "$scriptRoot\Public",
        [Parameter(Mandatory = $false)]
        [string]$scriptPrivate = "$scriptRoot\Private"
    )
    # begin {}
    process {
        #Get public and private function definition files.
        $Flat = @( Get-ChildItem -Path $scriptRoot\*.ps1 -ErrorAction SilentlyContinue )
        $Public  = @( Get-ChildItem -Path $scriptPublic\*.ps1 -ErrorAction SilentlyContinue )
        $Private = @( Get-ChildItem -Path $scriptPrivate\*.ps1 -ErrorAction SilentlyContinue )
        # -ErrorAction Break
        Write-Host "Loading..."
        #Dot source the files
        Foreach($import in @($Public + $Private + $Flat)) {
        # Foreach ($import in @($Flat)) {
            Try {
                # Bring function/cmdlet into scope
                . $import.fullname

                # Export Public and Root functions
                # Export-ModuleMember -Function $import.fullname
                if ($import.fullname.IndexOf("Private") -lt 0) {
                    Export-ModuleMember $import.fullname
                    Write-Host -Message "Public Component: $($import.fullname)"
                } else { 
                    Write-Host -Message "Private Component: $($import.fullname) skipped."
                }
            }
            Catch {
                Write-Error -Message "Failed to import component $($import.fullname): $_"
            }
        }

        # Read in or create an initial config file and variable
        # Export Public functions ($Public.BaseName) for WIP modules
        # Set variables visible to the module and its functions only
        # Export-ModuleMember -Function $Public.Basename
        # Export-ModuleMember -Function * -Alias * -Cmdlet *
        Write-Host "Ready."

    }
    # end {}
    # clean {}
}