# Variables
$year = (Get-Date).Year
$moduleName = 'TestModule'
$templateString = 'Test Module'
$version = '1.0'

# Create the "TestModule" top-level directory
New-Item -ItemType Directory -Name $moduleName

# Create subdirectories
#    TestModule
#    |___ ...
#    |___ ...
#    |___Private
#    |___ ...

New-Item -Path "$PWD\$moduleName\Private" -ItemType Directory -Force

# Create subdirectories
#    TestModule
#    |___ ...
#    |___ ...
#    |___ ...
#    |___Public

New-Item -Path "$PWD\$moduleName\Public" -ItemType Directory -Force

# Create the script module
#    TestModule
#    |___ ...
#    |___ TestModule.psm1

New-Item -Path "$PWD\$moduleName\$moduleName.psm1" -ItemType File

# Create the module manifest
#    TestModule
#    |___TestModule.psd1
#    |___ ...

$moduleManifestParameters = @{
    Path = "$PWD\$moduleName\$moduleName.psd1"
    Author = $templateString
    CompanyName = $templateString
    Copyright = "$year $templateString by Benjamin Heater"
    ModuleVersion = $version
    Description = $templateString
    RootModule = "$moduleName.psm1"
}
New-ModuleManifest @moduleManifestParameters