
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
        [String]$moduleRoot,
        $localModuleNames,
        [switch]$DoPause, 
        [switch]$DoVerbose, 
        [switch]$DoDebug
    )
    process {
        Write-Host "Write Mdm_Help help..."
        if (-not $moduleRoot) { $moduleRoot = $global:scriptPath }
        if (-not $localModuleNames) { $localModuleNames = $global:moduleNames }
        foreach ($moduleName in $localModuleNames) {
            # Standard Functions
            Write-Host "Write Mdm_Help: $moduleName"
            # Remove Module
            try {
                Remove-Module -Name $moduleName `
                    -ErrorAction Stop
            }
            catch { 
                $logMessage = "Failed to remove module: $moduleName."
                Add-LogText -logMessages $logMessage -localLogFileNameFull $global:logFileNameFull -ErrorPSItem $_ -isWarning
            }
            # Import-Module -name $moduleName `
            try {
                Import-Module -Name "$moduleRoot\$moduleName\$moduleName" `
                    -Force `
                    -ErrorAction Stop
            }
            catch { 
                $logMessage = "Failed to import module: $moduleName."
                Add-LogText -logMessages $logMessage -localLogFileNameFull $global:logFileNameFull -ErrorPSItem $_ -isError
                continue            
            }
            # Output list of powershell commands in the module
            # Detailed
            Get-Module $moduleName -ListAvailable `
            | ForEach-Object { $_.ExportedCommands.Values } `
            | Out-File -FilePath "$moduleRoot\Mdm_Bootstrap\help\$($moduleName)_Commands.txt"
            # Raw List
            Get-Module $moduleName -ListAvailable `
            | ForEach-Object { $_.ExportedCommands.Values.Name } `
            | Out-File -FilePath "$moduleRoot\Mdm_Bootstrap\help\$($moduleName)_CommandList.txt"
        }
        # Aggragation
        Get-Content "$moduleRoot\Mdm_Bootstrap\help\*_Commands.txt" `
        | Out-File "$moduleRoot\Mdm_Bootstrap\help\Commands.txt"
        Get-Content "$moduleRoot\Mdm_Bootstrap\help\*_CommandList.txt" `
        | Out-File "$moduleRoot\Mdm_Bootstrap\help\CommandList.txt"
    }
    end {
        
    }
}
function Write-Module_Help {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$moduleName,
        [switch]$DoPause, 
        [switch]$DoVerbose, 
        [switch]$DoDebug
    )
    process {
        try {
            Write-Host "Write Mdm_Help: $moduleName"
            Import-Module -name $moduleName `
                -force `
                -ErrorAction Stop
        }
        catch {
            $logMessage = "Failed to import module: $moduleName."
            Add-LogText -logMessages $logMessage -localLogFileNameFull $global:logFileNameFull -ErrorPSItem $_ -isError
        }
        try {
            Get-Module $moduleName -ListAvailable `
            | ForEach-Object { $_.ExportedCommands.Values } `
            | Out-File -FilePath "$moduleRoot\Mdm_Bootstrap\help\$($moduleName)_Commands.txt"
    
            Get-Module $moduleName -ListAvailable `
            | ForEach-Object { $_.ExportedCommands.Values.Name } `
            | Out-File -FilePath "$moduleRoot\Mdm_Bootstrap\help\$($moduleName)_CommandList.txt"
        }
        catch {
            $logMessage = "Failed to generate help for module: $moduleName."
            Add-LogText -logMessages $logMessage -localLogFileNameFull $global:logFileNameFull -ErrorPSItem $_ -isError
        }
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
    process {
        # Check path (todo)
        $global:scriptPath = (get-item $PSScriptRoot ).parent.FullName
        $outputDirectory = "$($global:scriptPath)\Mdm_Bootstrap\help"
        if (-not (Test-Path -Path $outputDirectory)) {
            New-Item -ItemType Directory -Path $outputDirectory -Force
        }
        # Process modules
        Write-Host "Generate Mdm_Help help..."
        foreach ($moduleName in $global:moduleNames) {
            try {
                Write-Host "Generate Help: $moduleName"
                Remove-Module -Name $moduleName `
                    -ErrorAction Stop
            }
            catch { 
                $logMessage = "Failed to remove module: $moduleName."
                Add-LogText -logMessages $logMessage -localLogFileNameFull $global:logFileNameFull -ErrorPSItem $_ -isWarning
            }
            # Import
            try {
                Import-Module -Name "$global:scriptPath\$moduleName\$moduleName" `
                    -Force `
                    -ErrorAction Stop
            }
            catch { 
                $logMessage = "Failed to import module: $moduleName."
                Add-LogText -logMessages $logMessage -localLogFileNameFull $global:logFileNameFull -ErrorPSItem $_ -isError
                continue            
            }
            # Command Report
            try {
                $outputFileName = "$($outputDirectory)\$($moduleName)_Commands_Alt.txt"        
                Get-Command -Module $moduleName -ListAvailable `
                    -CommandType Function `
                | Sort-Object -Property Name `
                | Select-Object Type, Version, Name `
                | Format-Table -GroupBy Type `
                | Out-File -FilePath $outputFileName
            }
            catch {
                # Write-Error $logMessage #  Error: $_"
                $logMessage = "Mdm_Help Get-Command report failed for module: $moduleName."
                Add-LogText -logMessages $logMessage -localLogFileNameFull $global:logFileNameFull -ErrorPSItem $_ -isError
                continue            
            }
            # Command List
            try {
                $outputFileName = "$($outputDirectory)\$($moduleName)_CommandList_Alt.txt"        
                Get-Command -Module $moduleName -ListAvailable `
                    -CommandType Function `
                | Sort-Object -Property Name `
                | Select-Object Name `
                | Out-File -FilePath $outputFileName
            }
            catch {
                $logMessage = "Mdm_Help Get-Command names failed for module: $moduleName."
                Add-LogText -logMessages $logMessage -localLogFileNameFull $global:logFileNameFull -ErrorPSItem $_ -isError
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
    $outText = ConvertTo-Text $hashtableInput
    Add-LogText $outText
    # Example array of PSObjects
    $arrayInput = @(
        [PSCustomObject]@{ text = "First item." },
        [PSCustomObject]@{ text = "Second item." }
    )
    $outText = ConvertTo-Text $arrayInput
    Add-LogText $outText

    # Example string
    $stringInput = "Just a simple string."
    $outText = ConvertTo-Text $stringInput
    Add-LogText $outText

    # Example enumerable collection
    $collectionInput = @(
        [PSCustomObject]@{ Text = "Item 1" },
        [PSCustomObject]@{ Text = "Item 2" }
    )
    $outText = ConvertTo-Text $collectionInput
    Add-LogText $outText
}
# Extracr-Help
function Get-HelpHtml {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $helpInfoObject,
        $htmlContentLocal
    )
    process {
        if (-not $htmlContentLocal) { $htmlContentLocal = @() }
        # $htmlContentLocal += "<p>Cmdlet: $($cmdlet.Name)</p>"
        $htmlContentLocal += "<p><strong>Name:</strong> $($helpInfoObject.Name)</p>"
        $htmlContentLocal += "<p><strong>Type:</strong> $($helpInfoObject.Category)</p>"
        foreach ($helpInfo in $helpInfoObject) {
            <# $helpInfo is the current item #>
            $helpInfoType = $helpInfo.GetType().Name
            if ($helpInfoType -eq "String") {
                # Write-Host "$helpInfoType - $helpInfo"
                $htmlContentLocal += "<pre>$helpInfo</pre>"
            }
            else {
                # Access the synopsis
                $descriptionSynopsis = $helpInfo.Synopsis
                if ($descriptionSynopsis) {
                    $descriptionSynopsis = ConvertTo-Text $descriptionSynopsis
                    $descriptionSynopsis = ConvertTo-EscapedText $descriptionSynopsis
                    $htmlContentLocal += "<p><strong>Synopsis:</strong> $descriptionSynopsis</p>"
                }
                # Access the detailed description
                $descriptionDetails = $helpInfo.Description
                if ($descriptionDetails) {
                    $descriptionText = ConvertTo-Text $descriptionDetails
                    $descriptionText = ConvertTo-EscapedText $descriptionText
                    $htmlContentLocal += "<p><strong>Detailed Description:</strong> $descriptionText</p>"
                }
                # Access the syntax
                $descriptionSyntax = $helpInfo.syntax
                if ($descriptionSyntax) {
                    $descriptionSyntax = ConvertTo-Text $descriptionSyntax
                    $descriptionSyntax = ConvertTo-EscapedText $descriptionSyntax
                    $htmlContentLocal += "<p><strong>Syntax:</strong> $descriptionSyntax</p>"
                    $htmlContentLocal += "<p></p>"
                }
                # Display parameters
                if ($helpInfo.parameters) {
                    $headingDone = $false
                    foreach ($param in $helpInfo.parameters) {
                        if ($param) {
                            $paramDetails = $param.parameter
                            if (-not $headingDone) {
                                $htmlContentLocal += "<p><strong>Parameters:</strong></p>"
                                $headingDone = $true
                            }
                            # $paramText = ConvertTo-Text $paramDetails
                            # Write-Debug $paramText
                            foreach ($paramItem in $paramDetails) {
                                <# $paramItem is the current item #>

                                # Access the properties from the nested hashtable
                                $paramName = if ($paramItem.name) { $paramItem.name } else { "N/A" }
                                $paramName = ConvertTo-EscapedText $paramName

                                $paramDescription = if ($paramItem.description) {
                                    $paramItem.description 
                                } 
                                else { "N/A" }
                                $paramDescription = ConvertTo-Text $paramDescription
                                $paramDescription = ConvertTo-EscapedText $paramDescription
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
                }
                $returnedValue = $helpInfo.returnValues
                if ($returnedValue) {
                    $returnedValue = ConvertTo-Text $returnedValue
                    $returnedValue = ConvertTo-EscapedText $returnedValue
                    $htmlContentLocal += "<p><strong>Return: </strong> $returnedValue</p>"
                    $htmlContentLocal += "<p></p>"
                }

                # Display examples
                if ($helpInfo.examples) {
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
                            $exampleContent = ConvertTo-EscapedText $exampleContent
                            $exampleContent = "<pre>$exampleContent</pre>"
                            $htmlContentLocal += $exampleContent
                        }
                    }
                }
            }
        }
        # return $htmlContentLocal -join "`n"
        return $htmlContentLocal
    }
}
# Export Help
function Export-Help {
    [CmdletBinding()]
    param (
        # $moduleName,
        $moduleRoot,
        $localLogFileNameFull,
        $nameFilter,
        [switch]$DoPause, 
        [switch]$DoVerbose, 
        [switch]$DoDebug        
    )
    process {
        # $moduleName = "YourModuleName"  
        # Import the module (if not already imported)
        # Import-Module $moduleName -ErrorAction Stop
        if (-not $moduleRoot) { $moduleRoot = (get-item $PSScriptRoot).parent.FullName }
        # $moduleDirectories = Get-ChildItem -Path $moduleRoot -Directory
        # Get the last directory name. This is (should be) the module name.
        # $nextDirectory = Split-Path -Path $moduleFolder.FullName -Leaf
        if (-not $localLogFileNameFull) { $localLogFileNameFull = $global:logFileNameFull }
        if (-not $nameFilter) { $nameFilter = "*" }

        try {
            foreach ($moduleName in $global:moduleNames) {
                # Validate the module folder
                # Filter for YOUR company name. Default at top.
                if ($moduleName -like $nameFilter) {
                    try {
                        # Initialize an array to hold the HTML content
                        $htmlContent = @()
                        # Get the Module name
                        # $moduleName = $moduleFolder.BaseName
                        Add-LogText "========================================================" $localLogFileNameFull `
                            -ForegroundColor Red
                        Add-LogText "Module: $moduleName"  $localLogFileNameFull
                        $htmlContent += "<h1>$($moduleName)</h1>"
                        # Import the Module
                        try {
                            # $global:scriptPath = (get-item $PSScriptRoot ).parent.FullName
                            Remove-Module `
                                -Name "$moduleRoot\$moduleName\$moduleName" `
                                -ErrorAction Stop
                            # -Verbose
                            # | Add-LogText $localLogFileNameFull
                        }
                        catch {
                            $logMessage = "Remove module skipped for: $moduleName."
                            # Write-Host "$logMessage"
                            # Add-LogText -logMessages $logMessage -localLogFileNameFull $localLogFileNameFull -ErrorPSItem $_ -isWarning
                            Add-LogText -logMessages $logMessage -localLogFileNameFull $localLogFileNameFull -ErrorPSItem $_
                            # continue, the functions will have help defined.
                        }
                        # Get all cmdlets in the Module
                        try {
                            Import-Module -Name "$moduleRoot\$moduleName\$moduleName" `
                                -Force `
                                -ErrorAction Stop
                            # -Verbose
                            # | Add-LogText -localLogFileNameFull $localLogFileNameFull
                        }
                        catch {
                            $logMessage = "Failed to import module: $($moduleName)."
                            # Write-Host "$logMessage"
                            Add-LogText -logMessages $logMessage -localLogFileNameFull $localLogFileNameFull -ErrorPSItem $_ -isError
                            continue      
                        }
                        # Get Module Help
                        try {
                            $helpInfo = Get-Help $moduleName `
                                -Full `
                                -ErrorAction Stop
                            try {
                                if ($helpInfo) { 
                                    $htmlContent += Get-HelpHtml $helpInfo `
                                        -ErrorAction Stop
                                }
                                else {
                                    $logMessage = "Get-HelpHtml is empty for module: $moduleName."
                                    # Write-Host "$logMessage"
                                    Add-LogText -logMessages $logMessage -localLogFileNameFull $localLogFileNameFull -ErrorPSItem $_ -isError
                                }
                            }
                            catch {
                                $logMessage = "Get-HelpHtml failed for module: $moduleName."
                                # Write-Host "$logMessage"
                                Add-LogText -logMessages $logMessage -localLogFileNameFull $localLogFileNameFull -ErrorPSItem $_ -isWarning
                                # continue, the functions will have help defined.
                            }
                    }
                    catch {
                        $logMessage = "Failed to get help for module: $moduleName."
                        # Write-Host "$logMessage"
                        Add-LogText -logMessages $logMessage -localLogFileNameFull $localLogFileNameFull -ErrorPSItem $_ -isWarning
                        # continue, the functions will have help defined.
                    }
                    # Get all cmdlets in the Module
                    try {
                        $cmdlets = Get-Command -Module $moduleName
                        # Loop through each cmdlet and get help information
                        foreach ($cmdlet in $cmdlets) {
                            try {
                                if ($cmdlet.Name -like $global:DebugFunctionName) {
                                    Script_Debugger -functionName $global:DebugFunctionName -Break -Trace
                                }
                                Add-LogText $cmdlet.Name $localLogFileNameFull
                                $htmlContent += "<h2>$($cmdlet.Name)</h2>"
                                $helpInfo = Get-Help $cmdlet.Name -Full `
                                    -ErrorAction Stop
                            }
                            catch {
                                $logMessage = "There is no help for function: $($cmdlet.Name)."
                                # Write-Host "$logMessage $_"
                                Add-LogText -logMessages $logMessage -localLogFileNameFull $localLogFileNameFull -ErrorPSItem $_ -isWarning
                                $htmlContent += "<p>$logMessage</p>"
                                continue      
                            }
                            try {
                                $htmlContent += Get-HelpHtml $helpInfo `
                                    -ErrorAction Stop
                            }
                            catch {
                                $logMessage = "Get-HelpHtml failed for function: $($cmdlet.Name)."
                                # Write-Host "$logMessage $_"
                                Add-LogText -logMessages $logMessage -localLogFileNameFull $localLogFileNameFull -ErrorPSItem $_ -isWarning
                                $htmlContent += "<p>$logMessage</p>"
                                # continue      
                            }
                            $htmlContent += "<p></p>"
                        }
                    }
                    catch {
                        $logMessage - "Failed to get cmdlets (functions & commands) for module: $($moduleFolder.FullName)."
                        # Write-Host "$logMessage $_"
                        Add-LogText -logMessages $logMessage -localLogFileNameFull $localLogFileNameFull -ErrorPSItem $_ -isError
                        # continue # (over)writing with an empty or module only help items might be ill-advised.
                    }
                    # Insert the html content into the html template
                    try {
                        $htmlDocTemplate = Get-HtmlTemplate `
                            -templateNameFull "$moduleRoot\Mdm_Bootstrap\TemplateScriptHelpHtml.html"
                    }
                    catch {
                        $logMessage = "Get-HtmlTemplate had an error."
                        Write-Host "$logMessage $_"
                        # Add-LogText -logMessages $logMessage -localLogFileNameFull $localLogFileNameFull -ErrorPSItem $_ -isError
                    }
                    try {
                        $htmlDocFilled = ConvertFrom-HtmlTemplate `
                            -htmlDocTemplate $htmlDocTemplate `
                            -htmlContent $htmlContent
                    }
                    catch {
                        $logMessage = "ConvertFrom-HtmlTemplate had an error."
                        Write-Host "$logMessage $_"
                        # Add-LogText -logMessages $logMessage -localLogFileNameFull $localLogFileNameFull -ErrorPSItem $_ -isError
                    }
                    try {
                        # Write HTML documentation to file
                        # Update the path
                        # Define the output HTML file path
                        $outputFilePath = "$moduleRoot\Mdm_Bootstrap\help"
                        $outputFileName = "$moduleName-Help.html"  # Update the path

                        # Save the HTML to a file
                        if (-not(Test-Path $outputFilePath -PathType Container)) {
                            New-Item -path $outputFilePath -ItemType Directory
                        }            
                        $htmlDocFilled | Out-File -FilePath "$outputFilePath\$outputFileName" -Encoding utf8

                        # Output the path of the generated HTML file
                        Add-LogText "Help documentation saved to: $outputFilePath" $localLogFileNameFull
                    }
                    catch {
                        $logMessage = "Unable to save html document to disk."
                        Write-Host "$logMessage $_"
                        # Add-LogText -logMessages $logMessage -localLogFileNameFull $localLogFileNameFull -ErrorPSItem $_ -isError
                    }
                }
                catch {
                    $logMessage = "Unhandled exception processing help in Export-Help:"
                    Write-Host "$logMessage $_"
                    # Add-LogText -logMessages $logMessage -localLogFileNameFull $localLogFileNameFull -ErrorPSItem $_ -isError
                }
            }
        }
    }
    catch {
        $logMessage = "Unhandled exception in Export-Help loop:"
        Write-Host "$logMessage $_"
        Add-LogText -logMessages $logMessage -localLogFileNameFull $localLogFileNameFull -ErrorPSItem $_ -isError
    }
    try {
        $moduleName = "Mdm_Std_Library"
        # Import-Module -Name $moduleName `
        Import-Module -Name "$moduleRoot\$moduleName\$moduleName" `
            -Force `
            -ErrorAction Stop
        $logMessage = "Successful import module: $moduleRoot\$moduleName."
        Add-LogText -logMessages $logMessage -localLogFileNameFull $localLogFileNameFull
    }
    catch {
        $logMessage = "Failed import of module: $moduleRoot\$moduleName."
        Write-Host "$logMessage $_"
        # Add-LogText -logMessages $logMessage -localLogFileNameFull $localLogFileNameFull -ErrorPSItem $_ -isError
        continue
    }
}
}
function Get-HtmlTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $templateNameFull
    )
    process {
        try {
            $htmlDocTemplate = Get-Content $templateNameFull -Raw
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
        return $htmlDocTemplate
    }
}
function ConvertFrom-HtmlTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $htmlContent,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $htmlDocTemplate
    )
    process {
        # Create the full HTML document
        # $htmlDocFilled = $htmlDocTemplate
        # Replace placeholders with actual values
        $htmlContentJoined = $htmlContent -join "`n"
        $htmlDocFilled = $htmlDocTemplate `
            -replace '{{ModuleName}}', $moduleName `
            -replace '{{HtmlContent}}', $htmlContentJoined `
            -replace '{{CompanyName}}', $companyName `
            -replace '{{Date}}', $now

        return $htmlDocFilled
    }
}
