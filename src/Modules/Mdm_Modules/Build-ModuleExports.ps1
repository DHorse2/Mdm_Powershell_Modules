    <#
    .SYNOPSIS
        The scans a module folder with a view to automatically load/import it.
    .DESCRIPTION
        It didn't work. The problem isn't clear.
    .PARAMETER scriptRoot
        Mandatory path to script files.
    .PARAMETER modulePublic
        Path for Public cmdlets to export.
    .PARAMETER modulePrivate
        Path for Private functions.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        Imports modules.
    .EXAMPLE
        Build-ModuleExports
#>
Function Build-ModuleExports {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$moduleRoot,
        [Parameter(Mandatory = $false)]
        [string]$modulePublic = "",
        [Parameter(Mandatory = $false)]
        [string]$modulePrivate = ""
    )
    if (-not $modulePublic) {$modulePublic = "$moduleRoot\Public" }
    if (-not $modulePrivate) {$modulePrivate = "$moduleRoot\Private" }
    # Build-ModuleExports
    #Get public and private function definition files.
    $Flat = @( Get-ChildItem -Path "$moduleRoot\*.ps1" -ErrorAction SilentlyContinue )
    $Public = @( Get-ChildItem -Path "$modulePublic\*.ps1" -ErrorAction SilentlyContinue )
    $Private = @( Get-ChildItem -Path "$modulePrivate\*.ps1" -ErrorAction SilentlyContinue )
    # -ErrorAction Break
    Write-Host "Loading..."
    #Dot source the files
    Foreach ($import in @($Public + $Private + $Flat)) {
        # Foreach ($import in @($Flat)) {
        Try {
            # Bring function/cmdlet into scope
            . $import.fullname

            # Export Public and Root functions
            if ($import.fullname.IndexOf("Private") -lt 0) {
                Export-ModuleMember $import.fullname
                Write-Host -Message "Public Component: $($import.fullname)"
            }
            else { 
                Write-Host -Message "Private Component: $($import.fullname) skipped."
            }
        }
        Catch {
            Write-Error -Message "Failed to import component $($import.fullname): $_"
        }
    }
}
