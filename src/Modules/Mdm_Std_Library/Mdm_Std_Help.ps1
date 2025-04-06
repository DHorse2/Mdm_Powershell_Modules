
# Help
function Write-Mdm_Help {
    <#
    .SYNOPSIS
        Generates the extended help files for the Mdm Modules.
    .DESCRIPTION
        This runs Get-Modules and Get-Command functions to create help files.
        The general intent is to have function lists.
        To correctly run this command (showing which module it belongs to) enter:
        ```powershell
        Import-Module -name Mdm_Std_Library -force
        ```
        This function re-imports the other module in the correct order.
        Note: It should not need to be run unless changes were made to the Mdm Modules.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .NOTES
        none.
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Import-Module -name Mdm_Std_Library -force
        Write-Mdm_Help -DoVerbose -DoPause
#>
    [CmdletBinding()]
    param (
        [String]$moduleRoot = "",
        [switch]$DoPause, 
        [switch]$DoVerbose, 
        [switch]$DoDebug
    )
    begin {
        
    }
    process {
        # Check path (todo)
        if (-not $moduleRoot) {
            $moduleRoot = (get-item $PSScriptRoot).parent.FullName
        }
        # Standard Functions
        Import-Module -name Mdm_Std_Library `
            -verbose:$DoVerbose `
            -force `
            -ErrorAction Continue
        Get-Module Mdm_Std_Library -ListAvailable `
        | ForEach-Object { $_.ExportedCommands.Values } `
            > "$moduleRoot\Mdm_Bootstrap\help\ModuleCommandList_Mdm_Std_Library.txt"
        Get-Module Mdm_Std_Library -ListAvailable `
        | ForEach-Object { $_.ExportedCommands.Values.Name } `
            > "$moduleRoot\Mdm_Bootstrap\help\ModuleCommandList_Mdm_Std_Library_List.txt"
        
        # Bootstrap
        Import-Module -name Mdm_Bootstrap `
            -verbose:$DoVerbose `
            -force `
            -ErrorAction Continue
        Get-Module Mdm_Bootstrap -ListAvailable `
        | ForEach-Object { $_.ExportedCommands.Values } `
            > "$moduleRoot\Mdm_Bootstrap\help\ModuleCommandList_Mdm_Bootstrap.txt"
        Get-Module Mdm_Bootstrap -ListAvailable `
        | ForEach-Object { $_.ExportedCommands.Values.Name } `
            > "$moduleRoot\Mdm_Bootstrap\help\ModuleCommandList_Mdm_Bootstrap_List.txt"
        
        # Development Environment Install
        Import-Module -name Mdm_Dev_Env_Install `
            -verbose:$DoVerbose `
            -force `
            -ErrorAction Continue
        Get-Module Mdm_Dev_Env_Install -ListAvailable `
        | ForEach-Object { $_.ExportedCommands.Values } `
            > "$moduleRoot\Mdm_Bootstrap\help\ModuleCommandList_Mdm_Dev_Env_Install.txt"
        Get-Module Mdm_Dev_Env_Install -ListAvailable `
        | ForEach-Object { $_.ExportedCommands.Values.Name } `
            > "$moduleRoot\Mdm_Bootstrap\help\ModuleCommandList_Mdm_Dev_Env_Install_List.txt"

        # Mdm Modules (aggragation)
        #

        # This might have an error on Std.
        Import-Module -name Mdm_Modules `
            -verbose:$DoVerbose `
            -force `
            -ErrorAction Continue

        # Aggragation
        Get-Content "$moduleRoot\Mdm_Bootstrap\help\ModuleCommandList_Mdm_*.txt" `
        | Out-File "$moduleRoot\Mdm_Bootstrap\help\ModuleCommandList_All.txt"
    }
    end {
        
    }
}
function Get-Mdm_Help {
    <#
    .SYNOPSIS
        Displays the help files for the Mdm Modules.
    .DESCRIPTION
        You can display the help Using DoPause and DoVerbose for detailed help.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .NOTES
        none.
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Get-Mdm_Help -DoVerbose -DoPause
#>
    [CmdletBinding()]
    param (
        [switch]$DoPause, 
        [switch]$DoVerbose, 
        [switch]$DoDebug
    )
        
    begin {
            
    }
        
    process {
        # Check path (todo)
        $scriptPath = (get-item $PSScriptRoot ).parent.FullName
        $moduleNames = @("Mdm_Dev_Env_Install", "Mdm_Bootstrap", "Mdm_Std_Library")
        # Process modules
        foreach ($moduleName in $moduleNames) {
            try {
                Import-Module `
                    -Name "$scriptPath\$moduleName\$moduleName" `
                    -Force `
                    -verbose:$DoVerbose `
                    -ErrorAction Stop
            }
            catch { 
                $logMessage = @( `
                        "Failed to import module: $moduleName.", `
                        "Error: $_"
                )
                LogText $logMessage $global:logFileNameFull -isError
                continue            
            }
            try {
                Get-Module moduleName -ListAvailable `
                | ForEach-Object { $_.ExportedCommands.Values } `
                    > ..\Mdm_Bootstrap\help\ModuleCommandList_Mdm_Bootstrap.txt 

                Get-Module moduleName -ListAvailable `
                | ForEach-Object { $_.ExportedCommands.Values.Name } `
                    > ..\Mdm_Bootstrap\help\ModuleCommandList_Mdm_Bootstrap_List.txt 
            }
            catch {
                $logMessage = @( `
                        "Get-Module failed for module: $moduleName.", `
                        "Error: $_"
                )
                LogText $logMessage $global:logFileNameFull -isError
                continue            
            }
        }            
        # Mdm Modules (aggragation)
        #
        # This might have an error on Std.
        # Import-Module -name Mdm_Modules -force
    }
        
    end {
            
    }
}
#Test Help
function Test-Help () {
    # Example hashtable
    $hashtableInput = @{ text = "This is a test." }
    $outText = ExtractText $hashtableInput
    LogText $outText
    # Example array of PSObjects
    $arrayInput = @(
        [PSCustomObject]@{ text = "First item." },
        [PSCustomObject]@{ text = "Second item." }
    )
    $outText = ExtractText $arrayInput
    LogText $outText

    # Example string
    $stringInput = "Just a simple string."
    $outText = ExtractText $stringInput
    LogText $outText

    # Example enumerable collection
    $collectionInput = @(
        [PSCustomObject]@{ Text = "Item 1" },
        [PSCustomObject]@{ Text = "Item 2" }
    )
    $outText = ExtractText $collectionInput
    LogText $outText
}
# Extracr-Help
function Get-HelpHtml {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $helpInfo,
        $htmlContentLocal = @()
    )
    process {
        # $htmlContentLocal += "<p>Cmdlet: $($cmdlet.Name)</p>"
        $htmlContentLocal += "<p><strong>Type:</strong> $($helpInfo.Category)</p>"

        # Access the synopsis
        $descriptionSynopsis = $helpInfo.Synopsis
        $descriptionSynopsis = ExtractText $descriptionSynopsis
        $descriptionSynopsis = EscapeText $descriptionSynopsis
        $htmlContentLocal += "<p><strong>Synopsis:</strong> $descriptionSynopsis</p>"

        # Access the detailed description
        $descriptionDetails = $helpInfo.Description
        $descriptionText = ExtractText $descriptionDetails
        $descriptionText = EscapeText $descriptionText
        $htmlContentLocal += "<p><strong>Detailed Description:</strong> $descriptionText</p>"

        # Access the syntax
        $descriptionSyntax = $helpInfo.syntax
        $descriptionSyntax = ExtractText $descriptionSyntax
        $descriptionSyntax = EscapeText $descriptionSyntax
        $htmlContentLocal += "<p><strong>Syntax:</strong> $descriptionSyntax</p>"
        $htmlContentLocal += "<p></p>"
            
        # Display parameters
        $headingDone = $false
        foreach ($param in $helpInfo.parameters) {
            if ($param) {
                $paramDetails = $param.parameter
                if (-not $headingDone) {
                    $htmlContentLocal += "<p><strong>Parameters:</strong></p>"
                    $headingDone = $true
                }
                # $paramText = ExtractText $paramDetails
                # Write-Debug $paramText
                foreach ($paramItem in $paramDetails) {
                    <# $paramItem is the current item #>

                    # Access the properties from the nested hashtable
                    $paramName = if ($paramItem.name) { $paramItem.name } else { "N/A" }
                    $paramName = EscapeText $paramName

                    $paramDescription = if ($paramItem.description) {
                        $paramItem.description 
                    } 
                    else { "N/A" }
                    $paramDescription = ExtractText $paramDescription
                    $paramDescription = EscapeText $paramDescription
                    # $paramDescription = if ($paramDetails.description -is [System.Management.Automation.PSObject[]]) {
                    #     # If the description is an array, join it into a single string
                    #     $paramDetails.description -join ", "
                    # }
                    # else {
                    #     $paramDetails.description
                    # }

                    $htmlContentLocal += "<p>  - <strong>$paramName</strong>: $paramDescription</p>"
                }
            }
        }
        $htmlContentLocal += "<p></p>"
        $returnedValue = $helpInfo.returnValues
        if ($returnedValue) {
            $returnedValue = ExtractText $returnedValue
            $returnedValue = EscapeText $returnedValue
            $htmlContentLocal += "<p><strong>Return: </strong> $returnedValue</p>"
            $htmlContentLocal += "<p></p>"
        }

        # Display examples
        $headingDone = $false
        foreach ($exampleItem in $helpInfo.examples) {
            $exampleItemDetails = $exampleItem.example
            if ($exampleItemDetails) {
                if (-not $headingDone) {
                    $htmlContentLocal += "<p><strong>Examples</strong>:</p>"
                    $headingDone = $true
                }
                $exampleContent = @()
                if ($exampleItemDetails.title.Length) { $exampleContent += "Example: $($exampleItemDetails.title)" }
                if ($exampleItemDetails.label.Length) { $exampleContent += "       Label: $($exampleItemDetails.label)" }
                if ($exampleItemDetails.introduction.Length) { $exampleContent += "Introduction: $($exampleItemDetails.introduction)" }
                if ($exampleItemDetails.code.Length) { $exampleContent += "      Syntax: $($exampleItemDetails.code)" }
                if ($exampleItemDetails.remarks.Length) { $exampleContent += "     Remarks:$($exampleItemDetails.remarks)" }
                $exampleContent = EscapeText $exampleContent
                $exampleContent = "<pre>$exampleContent</pre>"
                $htmlContentLocal += $exampleContent
            }
        }
        return $htmlContentLocal
    }
}
# Export Help
function Export-Help {
    [CmdletBinding()]
    param (
        # $moduleName,
        $moduleFolderPath = "",
        $localLogFileNameFull = ""
    )
    process {

        # $moduleName = "YourModuleName"  
        # Import the module (if not already imported)
        # Import-Module $moduleName -ErrorAction Stop
        if (-not $moduleFolderPath) { $moduleFolderPath = (get-item $PSScriptRoot).parent.FullName }
        $moduleDirectories = Get-ChildItem -Path $moduleFolderPath -Directory

        if (-not $localLogFileNameFull) { $localLogFileNameFull = $global:logFileNameFull }
        foreach ($moduleFolder in $moduleDirectories) {
            # Validate the module folder
            # Get the last directory name. This is (should be) the module name.
            $nextDirectory = Split-Path -Path $moduleFolder.FullName -Leaf
            # Filter for YOUR company name. Default at top.
            if ($nextDirectory -like $nameFilter) {
                # Initialize an array to hold the HTML content
                $htmlContent = @()
                # Get the Module name
                $moduleName = $moduleFolder.BaseName
                LogText "========================================================" $localLogFileNameFull `
                    -ForegroundColor Red
                LogText "Module: $moduleName"  $localLogFileNameFull
                $htmlContent += "<h1>$($moduleName)</h1>"
                # Import the Module
                try {
                    # $global:scriptPath = (get-item $PSScriptRoot ).parent.FullName
                    Import-Module -Name "$global:scriptPath\$moduleName\$moduleName" `
                        -Force `
                        -ErrorAction Continue | LogText $global:LogFileNameFull
                    # -Verbose `
                    # -ErrorAction Stop
                    # Import-Module -Name $moduleFolder.FullName `
                    #     -Force -ErrorAction Stop
                    # Import-Module -Name $moduleFolder.FullName -Force -ErrorAction Stop
                    # Import-Module -Name $moduleFolder.FullName -Force -ErrorAction Stop
                }
                catch {
                    $logMessage = @( `
                            "Failed to import module: $($moduleFolder.FullName).", `
                            "Error: $_"
                    )
                    LogText $logMessage $localLogFileNameFull -isError
                    continue      
                }
                # Get Module Help
                try {
                    # $helpInfo = Get-Help $moduleFolder.FullName -Full -ErrorAction Stop
                    $helpInfo = Get-Help $moduleName `
                        -Full `
                        -ErrorAction Stop
                    if ($helpInfo) { $htmlContent += Get-HelpHtml $helpInfo }
                }
                catch {
                    $logMessage = @( `
                            "Failed to get help for module: $($moduleFolder.FullName).", `
                            "Failed to import module: $($moduleFolder.FullName).", `
                            "Error: $_"
                    )
                    LogText $logMessage $localLogFileNameFull -isWarning
                    # continue, the functions will have help defined.
                }
                # Get all cmdlets in the Module
                try {
                    $cmdlets = Get-Command -Module $moduleName
                }
                catch {
                    $logMessage = @( `
                            "Failed to get cmdlets (functions & commands) for module: $($moduleFolder.FullName).", `
                            "Error: $_"
                    )
                    LogText $logMessage $localLogFileNameFull -isError
                    continue
                }
                # Loop through each cmdlet and get help information
                foreach ($cmdlet in $cmdlets) {
                    try {
                        LogText $cmdlet.Name $localLogFileNameFull
                        $htmlContent += "<h2>$($cmdlet.Name)</h2>"
                        $helpInfo = Get-Help $cmdlet.Name -Full
                        $htmlContent += Get-HelpHtml $helpInfo
                    }
                    catch {
                        $logMessage = @( `
                                "There is no help for function: $($cmdlet.Name).", `
                                "Error: $_"
                        )
                        LogText $logMessage $localLogFileNameFull -isWarning
                        $htmlContent += "<p>$logMessage</p>"
                        # continue      
                    }
                    $htmlContent += "<p></p>"
                }

                # Write HTML documentation to file
                try {
                    $htmlDocTemplate = Get-Content "$moduleFolderPath\Mdm_Bootstrap\TemplateScriptHelpHtml.html" `
                        -Raw
                }
                catch {
                    # Define a template with placeholders
                    $htmlDocTemplate = @"
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>PowerShell Help - {{$ModuleName}}</title>
        <style>
            body { background-color: white; }
            body {
                font-family: Arial, sans-serif;
                margin: 20px;
            }
            h2 { color: #2c3e50; }
            pre {
                background-color: #f4f4f4;
                padding: 10px;
                border: 1px solid #ddd;
            }
            pre { white-space: pre-wrap; }
        </style>
    </head>
    <body>
        <h1>Help for Module: {{$ModuleName}}</h1>
        {{$htmlContent}}
    </body>
    </html>
"@
                }
                # Create the full HTML document
                # $htmlDocFilled = $htmlDocTemplate
                # Replace placeholders with actual values
                $htmlContentJoined = $htmlContent -join "`n"
                $htmlDocFilled = $htmlDocTemplate `
                    -replace '{{ModuleName}}', $moduleName `
                    -replace '{{HtmlContent}}', $htmlContentJoined `
                    -replace '{{CompanyName}}', $companyName `
                    -replace '{{Date}}', $now

                # Update the path
                # Define the output HTML file path
                $outputFilePath = "$moduleFolderPath\Mdm_Bootstrap\help"
                $outputFileName = "$moduleName-Help.html"  # Update the path

                # Save the HTML to a file
                if (-not(Test-Path $outputFilePath -PathType Container)) {
                    New-Item -path $outputFilePath -ItemType Directory
                }            
                $htmlDocFilled | Out-File -FilePath "$outputFilePath\$outputFileName" -Encoding utf8

                # Output the path of the generated HTML file
                LogText "Help documentation saved to: $outputFilePath" $localLogFileNameFull
            }
        }
    }
}
