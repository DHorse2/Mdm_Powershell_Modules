
# Help
function Export-Mdm_Help {
    <#
    .SYNOPSIS
        Generates the extended help files for the Mdm Modules.
    .DESCRIPTION
        This runs Get-Modules and Get-Command functions to create help files.
        The general intent is to have function lists.
        To correctly run this command (showing which module it belongs to) enter:
        ```powershell
        Import-Module -Name Mdm_Std_Library -force
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
        Import-Module -Name Mdm_Std_Library -force
        Export-Mdm_Help -DoVerbose -DoPause
#>


    [CmdletBinding()]
    param (
        [string]$projectRootPath,
        [string]$moduleRootPath,
        $localModuleNames,
        [switch]$DoPause, 
        [switch]$DoVerbose, 
        [switch]$DoDebug
    )
    begin {
        $Message = "Write Mdm_Help help..."
        Add-LogText -Message $Message -SkipScriptLineDisplay -logFileNameFull $global:logFileNameFull
        if (-not $moduleRootPath) { $moduleRootPath = (get-item $PSScriptRoot).Parent.FullName }
        if (-not $projectRootPath) { $projectRootPath = (get-item $moduleRootPath).Parent.Parent.FullName }
        if (-not $localModuleNames) { $localModuleNames = $global:moduleNames }
    }
    process {
        #region Process modules
        foreach ($moduleName in $localModuleNames) {
            # Standard Functions
            $Message = "Write Mdm_Help: $moduleName"
            Add-LogText -Message $Message -SkipScriptLineDisplay -logFileNameFull $global:logFileNameFull
            # Remove Module
            try {
                Remove-Module -Name $moduleName `
                    -Force `
                    -ErrorAction Stop
            } catch { 
                $Message = "No need to remove module: $moduleName."
                Add-LogText -Message $Message `
                    -SkipScriptLineDisplay `
                    -logFileNameFull $global:logFileNameFull -ErrorPSItem $_
            }
            # Import Module -Name $moduleRootPath\$moduleName\$moduleName
            try {
                Import-Module -Name "$moduleRootPath\$moduleName\$moduleName" `
                    -Force `
                    -ErrorAction Stop
            } catch { 
                $Message = "Failed to import module in Export-Mdm_Help: $moduleName."
                Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $global:logFileNameFull
                continue            
            }
            # Output list of powershell commands in the module
            # Detailed
            try {
                # Detailed report
                Get-Module $moduleName -ListAvailable `
                | Sort-Object -Property CommandType, Name `
                | ForEach-Object { $_.ExportedCommands.Values } `
                | Select-Object Module, PSEdition, CommandType, Name `
                | Out-File -FilePath "$moduleRootPath\Mdm_Bootstrap\help\$($moduleName)_Commands.txt"
                #
                # Raw List
                Get-Module $moduleName -ListAvailable `
                | Sort-Object -Property CommandType, Name `
                | ForEach-Object { $_.ExportedCommands.Values.Name } `
                | Out-File -FilePath "$moduleRootPath\Mdm_Bootstrap\help\$($moduleName)_CommandList.txt"
                #
                Write-Host " "
            } catch { 
                $Message = "Error creating reports in Export-Mdm_Help for module: $moduleName."
                Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $global:logFileNameFull
                continue       
            }
        }
        # Aggragation
        try {
            Get-Content -Path "$moduleRootPath\Mdm_Bootstrap\help\*_Commands.txt" `
            | Out-File "$moduleRootPath\Mdm_Bootstrap\help\Commands.txt"
            Get-Content -Path "$moduleRootPath\Mdm_Bootstrap\help\*_CommandList.txt" `
            | Out-File "$moduleRootPath\Mdm_Bootstrap\help\CommandList.txt"
        } catch { 
            $Message = "Error aggragating files in Export-Mdm_Help."
            Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $global:logFileNameFull
            continue            
        }
        #endregion
        #region Process ReadMe template
        # Get-Template - Insert the html content into the html template
        try {
            $templateDoc = Get-Template `
                -templateNameFull "$projectRootPath\src\templates\TemplateReadmeRoot.md" `
                -ErrorAction Stop
        } catch {
            $Message = "Get-Template had an error in Export-Mdm_Help."
            Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
        }
        # ConvertFrom-Template
        try {
            # Create a hashtable for key-value pairs
            $templateData = Initialize-TemplateData
            # $templateData['{{ModuleName}}'] = $moduleName
            # $null = Debug-Script -DoPause 15 -functionName "Create Readme in Export-Mdm_Help" -logFileNameFull $logFileNameFull
            $DocFilled = ConvertFrom-Template `
                -templateDoc $templateDoc `
                -templateData $templateData `
                -ErrorAction Stop
        } catch {
            $Message = "Convert Readme Template had an error in Export-Mdm_Help."
            Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
        }
        # Out-File
        try {
            # Write HTML documentation to file
            # Update the path
            # Define the output HTML file path
            $outputFilePath = "$global:projectRootPath"
            $outputFileName = "readme.md"  # Update the path

            # Save the HTML to a file
            if (-not(Test-Path $outputFilePath -PathType Container)) {
                $Message = "The project path has been set incorrectly. Abnormal error."
                Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
                return
            }            
            $DocFilled | Out-File -FilePath "$outputFilePath\$outputFileName" -Encoding utf8

            # Output the path of the generated HTML file
            Add-LogText "Readme documentation saved to: $outputFilePath\$outputFileName`n + `
            Location: $outputFilePath\$outputFileName" $logFileNameFull
        } catch {
            $Message = "Unable to save Readme document to disk in Export-Mdm_Help."
            Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
        }
        #endregion
    }
    end {}
}
function Write-Module_Help {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$moduleName,
        [Parameter(Mandatory = $true)]
        [string]$moduleRootPath,
        [switch]$DoPause, 
        [switch]$DoVerbose, 
        [switch]$DoDebug
    )
    process {
        # Import Module
        try {
            $Message = "Write Mdm_Help: $moduleName"
            Add-LogText -Message $Message -SkipScriptLineDisplay -logFileNameFull $global:logFileNameFull
            Import-Module -Name $moduleName `
                -force `
                -ErrorAction Stop
        } catch {
            $Message = "Failed to import module: $moduleName."
            Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $global:logFileNameFull
        }
        # Get-Module
        try {
            Get-Module $moduleName -ListAvailable `
            | ForEach-Object { $_.ExportedCommands.Values } `
            | Out-File -FilePath "$moduleRootPath\Mdm_Bootstrap\help\$($moduleName)_ModuleCommands.txt"
    
            Get-Module $moduleName -ListAvailable `
            | ForEach-Object { $_.ExportedCommands.Values.Name } `
            | Out-File -FilePath "$moduleRootPath\Mdm_Bootstrap\help\$($moduleName)_ModuleCommandList.txt"
        } catch {
            $Message = "Failed to generate help for module: $moduleName."
            Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $global:logFileNameFull
        }
    }
}
function Write-Mdm_Help {
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
        Write-Mdm_Help -DoVerbose -DoPause
#>


    [CmdletBinding()]
    param (
        [switch]$DoPause, 
        [switch]$DoVerbose, 
        [switch]$DoDebug
    )
    process {
        # TODO Check path
        $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.FullName
        $outputDirectory = "$($global:moduleRootPath)\Mdm_Bootstrap\help"
        if (-not (Test-Path -Path $outputDirectory)) {
            New-Item -ItemType Directory -Path $outputDirectory -Force
        }
        # Process modules
        Write-Host "Generate Mdm_Help help..."
        foreach ($moduleName in $global:moduleNames) {
            # Remove-Module
            try {
                Write-Host "Generate Help: $moduleName"
                Remove-Module -Name $moduleName `
                    -ErrorAction Stop
            } catch { 
                $Message = "Failed to remove module: $moduleName."
                Add-LogText -Message $Message -IsWarning -ErrorPSItem $_ -logFileNameFull $global:logFileNameFull
            }
            # Import
            try {
                Import-Module -Name "$global:moduleRootPath\$moduleName\$moduleName" `
                    -Force `
                    -ErrorAction Stop
            } catch { 
                $Message = "Failed to import module: $moduleName."
                Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $global:logFileNameFull
                continue            
            }
            # Command Report
            try {
                $outputFileName = "$($outputDirectory)\$($moduleName)_Commands_Alt.txt"
                Get-Command -Module $moduleName -ListAvailable `
                | Sort-Object -Property CommandType, Name `
                | Select-Object Module, CommandType, Name `
                | Format-Table -GroupBy CommandType `
                | Out-File -FilePath $outputFileName
            } catch {
                $Message = "Mdm_Help Get-Command report failed for module: $moduleName."
                Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $global:logFileNameFull
                continue            
            }
            # Command List
            try {
                $outputFileName = "$($outputDirectory)\$($moduleName)_CommandList_Alt.txt"
                Get-Command -Module $moduleName -ListAvailable `
                | Sort-Object -Property CommandType, Name `
                | Select-Object Name `
                | Out-File -FilePath $outputFileName
            } catch {
                $Message = "Mdm_Help Get-Command names failed for module: $moduleName."
                Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $global:logFileNameFull
                continue            
            }
        }            
        # Mdm Modules (aggragation) TODO
        #
        # This might have an error on Std.
        # Import-Module -Name Mdm_Modules -force
    }
    end {}
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
function Build-HelpHtml {
    <#
     .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
     .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    
    .PARAMETER  helpInfoObject
         [System.Management.Automation.HelpInfo]
         Used to pass the help information that will be formatted into HTML.

    .PARAMETER  moduleObject
        [System.Management.Automation.PSModuleInfo]
        Accepts a cmdlet object. Used to generate help content specific to a module.

    .PARAMETER  cmdletObject
        Accepts a cmdlet object. Used to generate help content for a specific cmdlet.

    .PARAMETER  htmlContentLocal
        Used to hold the passed HTML content that will be appended to or modified within the function.

    .PARAMETER  SkipName
        [switch] Don't output the Name line.

    .PARAMETER  SkipType
        [switch] Don't output the command (object) type line.

     .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.

     .EXAMPLE
        $htmlContent += Build-HelpHtml `
            -helpInfoObject $helpInfo `
            -moduleObject $moduleInfo `
            -cmdletObject $cmdlet `
            -SkipName `
            -ErrorAction Stop        
        
        This function converts the PS objects to html help output.
#>
     
     
    [CmdletBinding()]
    # HelpInfo
    # [System.Management.Automation.HelpInfo]
    # [string]
    # [PSCustomObject]
    # Moduel and Command
    # [System.Management.Automation.PSModuleInfo]
    # [System.Management.Automation.CommandInfo]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        [object]$helpInfoObject,
        [object]$moduleObject,
        [object]$cmdletObject,
        [object[]]$htmlContentLocal,
        [switch]$SkipName,
        [switch]$SkipType
    )
    begin {
        try {
            $functionName = $($helpInfoObject.Name)
            if ($cmdletObject) { $functionName = $cmdletObject.Name }
            if (-not $functionName) { $functionName = Split-Path $PSScriptRoot -leaf }
            # $null = Debug-SubmitFunction -functionName $functionName -invocationFunctionName $($MyInvocation.MyCommand.Name) # Debug-Script
            # Output
            if (-not $htmlContentLocal) { $htmlContentLocal = @() }
            if (-not $SkipName) { $htmlContentLocal += "<p><strong>Name:</strong> $functionName</p>" }
            if (-not $SkipType) {
                if ($cmdletObject) {
                    if ($cmdletObject.CommandType -eq "Alias") {
                        $htmlContentLocal += "<p><strong>Type:</strong> $($cmdletObject.CommandType). Command: $($cmdletObject.Definition)  Type:$($helpInfoObject.Category)</p>"
                    } else {
                        $htmlContentLocal += "<p><strong>Type:</strong> $($cmdletObject.CommandType)</p>"
                    }
                } else {
                    $htmlContentLocal += "<p><strong>Type:</strong> $($helpInfoObject.Category)</p>"
                }
            }
        } catch {
            $Message = "Error in Headings. Begin block of Build-HelpHtml for $cmdlet.Name"
            Add-LogText $Message `
                -IsError -ErrorPSItem $_ `
                -logFileNameFull $logFileNameFull        
        }
    }
    process {
        try {
            # $htmlContentLocal += "<p>Cmdlet: $($cmdlet.Name)</p>"
            foreach ($helpInfo in $helpInfoObject) {
                <# $helpInfo is the current item #>
                $helpInfoType = $helpInfo.GetType().Name
                if ($helpInfoType -eq "String") {
                    # Write-Host "$helpInfoType - $helpInfo"
                    $htmlContentLocal += "<pre>$helpInfo</pre>"
                } elseif ($helpInfoType -eq "HelpInfo" -or $helpInfoType -eq "PsCustomObject") {
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
                        $htmlContentLocal += "<p><strong>Syntax:</strong> <pre>$descriptionSyntax</pre></p>"
                        $htmlContentLocal += "<p></p>"
                    }
                    # Display parameters
                    if ($helpInfo.parameters) {
                        $headingDone = $false
                        foreach ($param in $helpInfo.parameters) {
                            try {
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
                                        try {
                                            # Access the properties from the nested hashtable
                                            if ($paramItem.name) { 
                                                $paramName = $paramItem.name
                                                $paramName = ConvertTo-EscapedText $paramName
                                                # $paramDescription
                                                if ($paramItem.description) {
                                                    $paramDescription = $paramItem.description
                                                    $paramDescription = ConvertTo-Text $paramDescription
                                                    $paramDescription = ConvertTo-EscapedText $paramDescription
                                                    $paramItem.description 
                                                    # } else { "N/A" }
                                                    # $paramDescription = 
                                                    # if ($paramDetails.description -is [System.Management.Automation.PSObject[]]) {
                                                    #     # If the description is an array, join it into a single string
                                                    #     $paramDetails.description -join ", "
                                                    # }
                                                    # else {
                                                    #     $paramDetails.description
                                                    # }

                                                    $htmlContentLocal += "<p>  - <strong>$paramName</strong>: $paramDescription</p>"
                                                } else {
                                                    $htmlContentLocal += "<p>  - <strong>$paramName</strong></p>"
                                                }
                                            } else {
                                                $Message = "Parameter Name is NULL in Parameter Details."
                                                Add-LogText -Message $Message -IsWarning -logFileNameFull $global:logFileNameFull -ErrorPSItem $_
                                            }
                                        } catch {
                                            $Message = "Invalid ParamItem in Parameter Details."
                                            Add-LogText -Message $Message -IsError -logFileNameFull $global:logFileNameFull -ErrorPSItem $_
                                        }
                                    }
                                }
                            } catch {
                                $Message = "Invalid Parameter in Help Info."
                                Add-LogText -Message $Message -IsError -logFileNameFull $global:logFileNameFull -ErrorPSItem $_
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
                            $exampleContent = ""
                            $exampleItemDetails = $exampleItem.example
                            if ($exampleItemDetails) {
                                if (-not $headingDone) {
                                    $htmlContentLocal += "<p><strong>Examples</strong>:</p>"
                                    $headingDone = $true
                                } else { $exampleContent = "$exampleContent`n" }
                                $exampleContentItem = @()
                                if ($exampleItemDetails.title.Length) { $exampleContentItem += "Example: $($exampleItemDetails.title)" }
                                if ($exampleItemDetails.label.Length) { $exampleContentItem += "       Label: $($exampleItemDetails.label)" }
                                if ($exampleItemDetails.introduction.Length) { $exampleContentItem += "Introduction: $($exampleItemDetails.introduction)" }
                                if ($exampleItemDetails.code.Length) { $exampleContentItem += "      Syntax: $($exampleItemDetails.code)" }
                                if ($exampleItemDetails.remarks.Length) { $exampleContentItem += "     Remarks:$($exampleItemDetails.remarks)" }
                                $exampleContentItem = ConvertTo-EscapedText (($exampleContentItem) -join "`n")
                                $exampleContent = "$exampleContent$exampleContentItem"
                            }
                            $htmlContentLocal += "<pre>$exampleContent</pre>"
                        }
                    }
                } else {
                    $Message = "Unknown Type of HelpInfo in Build-HelpHtml for $cmdlet.Name`nObject type: $helpInfoType"
                    Add-LogText $Message `
                        -IsError `
                        -logFileNameFull $logFileNameFull        
                }
            }
        } catch {
            $Message = "Detail processing error in Build-HelpHtml for $cmdlet.Name"
            Add-LogText $Message `
                -IsError -ErrorPSItem $_ `
                -logFileNameFull $logFileNameFull        
        }
    }
    end {
        # return $htmlContentLocal -join "`n"
        return $htmlContentLocal
    }
}
# Export Help
function Export-Help {
    [CmdletBinding()]
    param (
        # $moduleName,
        $projectRootPath,
        $moduleRootPath,
        $logFileNameFull,
        $nameFilter,
        [switch]$DoPause, 
        [switch]$DoVerbose, 
        [switch]$DoDebug        
    )
    process {
        if (-not $moduleRootPath) { $moduleRootPath = (get-item $PSScriptRoot).Parent.FullName }
        if (-not $projectRootPath) { $projectRootPath = (get-item $moduleRootPath).Parent.Parent.FullName }
        if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFull }
        if (-not $nameFilter) { $nameFilter = "*" }
        # Process modules
        try {
            foreach ($moduleName in $global:moduleNames) {
                # Validate the module folder
                # Filter for YOUR company name. Default at top.
                if ($moduleName -like $nameFilter) {
                    # Build the HTML content
                    try {
                        # Initialize an array to hold the HTML content
                        $htmlContent = @()
                        # Get the Module name
                        # $moduleName = $moduleFolder.BaseName
                        Add-LogText "========================================================" $logFileNameFull `
                            -ForegroundColor Red
                        Add-LogText "Module: $moduleName"  $logFileNameFull
                        $htmlContent += "<h1>$($moduleName)</h1>"
                        # Import the Module
                        try {
                            # $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.FullName
                            Remove-Module `
                                -Name "$moduleRootPath\$moduleName\$moduleName" `
                                -ErrorAction Stop
                            # -Verbose
                            # | Add-LogText $logFileNameFull
                        } catch {
                            $Message = "Remove module skipped for: $moduleName."
                            # Write-Host "$Message"
                            # Add-LogText -Message $Message -IsWarning -logFileNameFull $logFileNameFull -ErrorPSItem $_
                            Add-LogText -Message $Message -ErrorPSItem $_ -logFileNameFull $logFileNameFull
                            # continue, the functions will have help defined.
                        }
                        # Get all cmdlets in the Module
                        try {
                            Import-Module -Name "$moduleRootPath\$moduleName\$moduleName" `
                                -Force `
                                -ErrorAction Stop
                            # -Verbose
                            # | Add-LogText -logFileNameFull $logFileNameFull
                        } catch {
                            $Message = "Failed to import module: $($moduleName)."
                            # Write-Host "$Message"
                            Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
                            $htmlContent += "<p<strong>>$Message</strong></p>"
                            continue      
                        }
                        # Get Module Help
                        try {
                            $moduleInfo = Get-Module $moduleName
                            $helpInfo = Get-Help $moduleName `
                                -Full `
                                -ErrorAction Stop
                            try {
                                if ($helpInfo) { 
                                    $helpInfoType = $helpInfo.GetType().Name
                                    # $htmlContent += "<h2>$($moduleName)</h2>"
                                    $htmlContent += Build-HelpHtml `
                                        -helpInfoObject $helpInfo `
                                        -moduleObject $moduleInfo `
                                        -SkipName -SkipType `
                                        -ErrorAction Stop
                                } else {
                                    $Message = "Build-HelpHtml is empty for module: $moduleName."
                                    # Write-Host "$Message"
                                    Add-LogText -Message $Message `
                                        -IsWarning -SkipScriptLineDisplay -ErrorPSItem $_ `
                                        -logFileNameFull $logFileNameFull
                                }
                            } catch {
                                $Message = "Build-HelpHtml failed for module: $moduleName."
                                # Write-Host "$Message"
                                Add-LogText -Message $Message `
                                    -IsWarning -SkipScriptLineDisplay -ErrorPSItem $_ `
                                    -logFileNameFull $logFileNameFull
                                # continue, the functions will have help defined.
                            }
                        } catch {
                            $Message = "Failed to get help for module: $moduleName."
                            # Write-Host "$Message"
                            Add-LogText -Message $Message `
                                -IsWarning -SkipScriptLineDisplay -ErrorPSItem $_ `
                                -logFileNameFull $logFileNameFull
                            $htmlContent += "<p<strong>>$Message</strong></p>"
                            # continue, the functions will have help defined.
                        }
                        # Get all cmdlets in the Module
                        try {
                            $cmdlets = Get-Command -Module $moduleName
                            # Loop through each cmdlet and get help information
                            foreach ($cmdlet in $cmdlets) {
                                # Get-Help
                                try {
                                    Add-LogText $cmdlet.Name $logFileNameFull
                                    $htmlContent += "<h2>$($cmdlet.Name)</h2>"
                                    # $null = Debug-SubmitFunction -functionName $cmdlet.Name -invocationFunctionName $($MyInvocation.MyCommand.Name) # Debug-Script
                                    $helpInfo = Get-Help $cmdlet.Name -Full `
                                        -ErrorAction Stop
                                } catch {
                                    $Message = "There is no help for function: $($cmdlet.Name)."
                                    # Write-Host "$Message $_"
                                    Add-LogText -Message $Message `
                                        -IsWarning -SkipScriptLineDisplay -ErrorPSItem $_ `
                                        -logFileNameFull $logFileNameFull
                                    $htmlContent += "<p><strong>$Message</strong></p>"
                                    continue      
                                }
                                # Build-HelpHtml
                                try {
                                    $helpInfoType = $helpInfo.GetType().Name
                                    $htmlContent += Build-HelpHtml `
                                        -helpInfoObject $helpInfo `
                                        -moduleObject $moduleInfo `
                                        -cmdletObject $cmdlet `
                                        -SkipName `
                                        -ErrorAction Stop
                                } catch {
                                    $Message = "Build-HelpHtml failed for function: $($cmdlet.Name)."
                                    # Write-Host "$Message $_"
                                    Add-LogText -Message $Message `
                                        -IsError -ErrorPSItem $_ `
                                        -logFileNameFull $logFileNameFull
                                    $htmlContent += "<p<strong>>$Message</strong></p>"
                                    # continue      
                                }
                                $htmlContent += "<p></p>"
                            }
                        } catch {
                            $Message - "Failed to get cmdlets (functions & commands) for module: $($moduleFolder.FullName)."
                            # Write-Host "$Message $_"
                            Add-LogText -Message $Message -IsError -SkipScriptLineDisplay -ErrorPSItem $_ -logFileNameFull $logFileNameFull
                            $htmlContent += "<p<strong>>$Message</strong></p>"
                            # continue # (over)writing with an empty or module only help items might be ill-advised.
                        }
                        if ($global:copyright) {
                            $htmlContent += "<footer><p>{{Copyright}}</p></footer>"
                        }
                        # Get-Template - Insert the html content into the html template
                        try {
                            $templateDoc = Get-Template `
                                -templateNameFull "$projectRootPath\src\templates\TemplateModuleHelpHtml.html" `
                                -UseDefault `
                                -ErrorAction Stop
                        } catch {
                            $Message = "Get-Template had an error."
                            Write-Host -Message "$Message $_"
                            $htmlContent += "<p<strong>>$Message</strong></p>"
                            Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
                        }
                        # ConvertFrom-Template
                        try {
                            # $null = Debug-Script -DoPause 5 -functionName "Convert HTML data" -logFileNameFull $logFileNameFull
                            # Create a hashtable for key-value pairs
                            $templateData = Initialize-TemplateData -ErrorAction Stop
                            $templateData['{{ModuleName}}'] = $moduleName
                            $htmlDocFilled = ConvertFrom-Template `
                                -templateDoc $templateDoc `
                                -templateContent $htmlContent `
                                -templateData $templateData `
                                -ErrorAction Stop
                        } catch {
                            $Message = "Convert Html Template had an error."
                            Write-Host "$Message $_"
                            $htmlContent += "<p<strong>>$Message</strong></p>"
                            Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
                        }
                        # Out-File
                        try {
                            # Write HTML documentation to file
                            # Update the path
                            # Define the output HTML file path
                            $outputFilePath = "$moduleRootPath\Mdm_Bootstrap\help"
                            $outputFileName = "$moduleName-Help.html"  # Update the path

                            # Save the HTML to a file
                            if (-not(Test-Path $outputFilePath -PathType Container)) {
                                New-Item -path $outputFilePath -ItemType Directory
                            }            
                            $htmlDocFilled | Out-File -FilePath "$outputFilePath\$outputFileName" -Encoding utf8

                            # Output the path of the generated HTML file
                            Add-LogText "Help documentation saved to: $outputFilePath\$outputFileName" $logFileNameFull
                        } catch {
                            $Message = "Unable to save html document to disk."
                            Write-Host "$Message $_"
                            $htmlContent += "<p<strong>>$Message</strong></p>"
                            Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
                        }
                    } catch {
                        $Message = "Unhandled exception processing help in Export-Help:"
                        Write-Host "$Message $_"
                        $htmlContent += "<p<strong>>$Message</strong></p>"
                        Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
                    }
                }
            }
        } catch {
            $Message = "Unhandled exception in Export-Help loop:"
            Write-Host "$Message $_"
            Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
            $htmlContent += "<p<strong>>$Message</strong></p>"
        }
        # Import-Module -Name $moduleName `
        try {
            $moduleName = "Mdm_Std_Library"
            Import-Module -Name "$moduleRootPath\$moduleName\$moduleName" `
                -Force `
                -ErrorAction Stop
            $Message = "Successful import module: $moduleRootPath\$moduleName."
            Add-LogText -Message $Message -logFileNameFull $logFileNameFull
        } catch {
            $Message = "Failed import of module: $moduleRootPath\$moduleName."
            Write-Host "$Message $_"
            Add-LogText -Message $Message -IsError -ErrorPSItem $_ -SkipScriptLineDisplay -logFileNameFull $logFileNameFull
            continue
        }
    }
}
function Get-Template {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $templateNameFull,
        [switch]$UseDefault
    )
    process {
        try {
            $templateDoc = Get-Content -Path $templateNameFull `
                -Raw `
                -ErrorAction Stop
        } catch {
            if ($UseDefault) {
                # By default this returns an HTML template
                # Define a template with placeholders
                $templateDoc = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{$Title}}</title>
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
<footer><p>{{Footer}}{{Copyright}}</p></footer>
</body>
</html>
"@
            } else {
                $Message = "Missing template file in Get-Template.`n`"$templateNameFull`" not found."
                Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
            }
        }
        return $templateDoc
    }
}
function Initialize-TemplateData {
    [CmdletBinding()]
    param (
        $templateData = @{ '{{TemplateDataState}}' = "default" }
    )
    $templateData['{{Date}}'] = Get-Date
    if ($global:companyName) { $templateData['{{CompanyName}}'] = $global:companyName }
    if ($global:timeStarted) { $templateData['{{DateStarted}}'] = $("{0:yyyy/mm/dd}" -f ($timeStarted)) }
    if ($global:timeStarted) { $templateData['{{TimeStarted}}'] = $global:timeStarted }
    if ($global:timeStartedFormatted) { $templateData['{{TimeStartedFormated}}'] = $global:timeStartedFormatted }
    if ($global:timeCompleted) { $templateData['{{DateCompleted}}'] = $("{0:yyyy/mm/dd}" -f ($timeCompleted)) }
    if ($global:timeCompleted) { $templateData['{{TimeCompleted}}'] = $global:timeCompleted }
    if ($global:author) { $templateData['{{Author}}'] = $global:author }
    if ($global:copyright) { $templateData['{{Copyright}}'] = $global:copyright }
    if ($global:license) { $templateData['{{License}}'] = $global:license }
    if ($global:title) { $templateData['{{Title}}'] = $global:title }
    if ($global:moduleRootPath) { $templateData['{{ModuleRootPath}}'] = $global:moduleRootPath }
    if ($global:projectRootPath) { $templateData['{{ProjectRootPath}}'] = $global:projectRootPath }
    return $templateData
}
function ConvertFrom-Template {
    [CmdletBinding()]
    param (
        $templateContent = "",
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $templateDoc,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $templateData
    )
    process {
        # Create the full HTML document
        # Replace placeholders with actual values
        try {
            $templateContentJoined = $templateContent -join "`n"
            $docFilled = Resolve-Variables $templateDoc
            $docFilled = $docFilled `
                -replace '{{TemplateContent}}', $templateContentJoined `
                -replace '{{Now}}', $now

            if ($templateData) {
                foreach ($key in $templateData.Keys) {
                    if ($key -like "{{File: *}}") {
                        # try {
                        #     $pattern = '\{\{File: \s*'
                        #     # Use -replace to remove the pattern and the closing braces
                        #     $fileNameFull = $key -replace $pattern, '' -replace '\}\}', ''
                        #     $templateInsertDoc = Get-Content -Path $fileNameFull -Raw
                        #     $docFilled = $docFilled -replace [regex]::Escape($key), $templateInsertDoc
                        # } catch {
                        #     $Message = "Unable to process document insert referenced in template."
                        #     Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
                        # }
                    } else {
                        $docFilled = $docFilled -replace [regex]::Escape($key), $templateData[$key]
                    }
                }        
            }
        } catch {
            $Message = "Error in Tempate File DATA processing."
            Add-LogText -Message $Message `
                -IsError -ErrorPSItem $_ `
                -logFileNameFull $global:logFileNameFull        
        }
        # Loop through $docFilled looking for "{{File: "
        try {
            $filePattern = '\{\{File: (.*?)\}\}'
            $fileMatches = [regex]::Matches($docFilled, $filePattern)

            foreach ($match in $fileMatches) {
                try {
                    $fileName = $match.Groups[1].Value.Trim()
                    $fileNameFull = "$($fileName)"
                    Write-Verbose "Found file reference: $fileName"
                    # Get the content of the file
                    $templateInsertDoc = Get-Content -Path $fileNameFull -Raw
                    # Replace the full match in $docFilled with the content of the file
                    $docFilled = $docFilled -replace [regex]::Escape($match.Value), $templateInsertDoc
                } catch {
                    $Message = "Unable to process document match $($match.Value[0]) insert for file: $fileName`n For match: $($match)"
                    Add-LogText -Message $Message `
                        -IsError -ErrorPSItem $_ `
                        -logFileNameFull $global:logFileNameFull        
                }
            }
        } catch {
            $Message = "Error in Template File TEXT processing."
            Add-LogText -Message $Message `
                -IsError -ErrorPSItem $_ `
                -logFileNameFull $global:logFileNameFull        
        }
        return $docFilled
    }
}
