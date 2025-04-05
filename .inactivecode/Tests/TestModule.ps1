function TestModule {
    param (
        [string]$moduleName
    )
    # Set the path to your module directory
    $modulePath = "G:\Script\Powershell\src"

    # Get a list of all the .psm1 files in the module directory
    $modules = Get-ChildItem -Path $modulePath -Filter *.psm1

    # Loop through each module and test its functionality
    foreach ($module in $modules) {
        Write-Host "Testing $($module.getfilename()) ..."

        # Load the module into the current PowerShell session
        Import-Module -Path $module.FullName

        # Use a try/catch block to handle any exceptions that may occur when testing the module's functionality
        try {
            # Insert your module's test code here
            Write-Host "The $($module.getfilename()) module passed its tests."
        } catch ($exception) { 
            Write-Host "The $($module.getfilename()) module failed its tests with the following error message:
$_.Exception.Message"
        }
        # Unload the module from the current PowerShell session
        Remove-Module -Name (Split-Path $module.FullName | Select-Object -ExpandProperty Parent)
    }
}