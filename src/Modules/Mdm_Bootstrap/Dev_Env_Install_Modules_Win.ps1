<#
    .SYNOPSIS
        Install or update Mdm Modules.
    .DESCRIPTION
        This installs the libraries to the live system using Robocopy.
    .PARAMETER source
        default: "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules" 
    .PARAMETER destination
        default: "$env:PROGRAMFILES\\WindowsPowerShell\Modules"
    .PARAMETER logFileNameFull
        default: "G:\Script\Powershell\Mdm_Powershell_Modules\log\Mdm_Installation_Log.txt"
    .PARAMETER DoPause
        Switch to pause at each step/page.
    .PARAMETER DoVerbose
        Provide detailed information.
    .PARAMETER DoDebug
        Debug this script.
    .PARAMETER SkpHelp
        Skip generating the help documentation.
    .PARAMETER SkpRegistry
        Skip updating the registry.
    .NOTES
        The above defaults appear again in the code below. 
        One or the other clearly.
        There are huge amounts of notes in this script.
        This is not best practices but whatever.
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Dev_Env_Install_Modules_Win    
#>
[CmdletBinding()]
param (
    [switch]$DoVerbose,
    [switch]$DoPause,
    [switch]$DoDebug,
    [string]$source = "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules",
    [string]$destination = "$env:PROGRAMFILES\WindowsPowerShell\Modules",
    [string]$logFilePath = "G:\Script\Powershell\Mdm_Powershell_Modules\log",
    [string]$logFileName = "Mdm_Installation_Log",
    [switch]$logOneFile,
    [string]$nameFilter = "Mdm_*",
    [switch]$SkipHelp,
    [switch]$SkipRegistry,
    [switch]$DoNewWindow,
    [string]$companyName = "MacroDM",
    [string]$copyOptions = "/E /FP /nc /ns /np /TEE"

)
# Dev_Env_Install_Modules_Win
# ================================= Initialization
# Import-Module Microsoft.PowerShell.Security
# Set-ExecutionPolicy Unrestricted -Scope CurrentUser
# [string]$global:logData = ""
[string]$global:logFileNameFull = ""
[string]$global:scriptPath = (get-item $PSScriptRoot ).parent.FullName

# Help text extraction
function extractText {
    param (
        [Parameter(Mandatory = $true)]
        $textIn
    )
    # Initialize description text
    $textOut = @()
    if ($textIn) {
        $textInType = $textIn.GetType().FullName
        # Output the structure of the detailed description for inspection
        # $textIn | Get-Member
        switch ( $textInType ) {
            "hashtable" {
                # Access the description property
                if ($textIn.ContainsKey('Text')) {
                    if ($textIn.text -is [System.Collections.IEnumerable] `
                            -and -not ($textIn.text -is [string])) {
                        # If the description is an array, join it into a single string
                        # $textOut = $textIn.text -join "`n"
                        $textOut += $textIn.text
                    }
                    else {
                        $textOut += $textIn.text
                    }
                }
            }
            "System.Object[]" {
                # Create the output string, including all properties and avoiding empty strings
                $textOut += ($textIn | ForEach-Object {
                        # Create a formatted string for each property
                        $formattedProperties = @()

                        # Loop through each property in the object
                        foreach ($property in $_.PSObject.Properties) {
                            if (-not [string]::IsNullOrWhiteSpace($property.Value)) {
                                $formattedProperties += "$($property.Name): $($property.Value)"
                            }
                        }

                        # # Create a formatted string for each property
                        # $formattedProperties = $_.GetEnumerator() | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Value) } | 
                        # ForEach-Object { "$($_.Key): $($_.Value)" }

                        # Join the formatted properties with a comma and space
                        $formattedString = $formattedProperties -join ", "

                        # Return the formatted string
                        $formattedString
                    }
                ) # -join "`n"  # Join each object's output with a new line
            }            
            "System.Management.Automation.PSObject[]" {
                # If it's an array of PSObjects, join their 'text' properties
                # Create the output string, including all properties and avoiding empty strings
                $textOut += ($textIn | ForEach-Object {
                        # Create a formatted string for each property
                        $formattedProperties = @()

                        # Loop through each property in the object
                        foreach ($property in $_.PSObject.Properties) {
                            if (-not [string]::IsNullOrWhiteSpace($property.Value)) {
                                $formattedProperties += "$($property.Name): $($property.Value)"
                            }
                        }

                        # # Create a formatted string for each property
                        # $formattedProperties = $_.GetEnumerator() | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Value) } | 
                        # ForEach-Object { "$($_.Key): $($_.Value)" }
    
                        # Join the formatted properties with a comma and space
                        $formattedString = $formattedProperties -join ", "
    
                        # Return the formatted string
                        $formattedString
                    }
                ) # -join "`n"  # Join each object's output with a new line

                # $textIn | ForEach-Object { 
                #     if (-not [string]::IsNullOrWhiteSpace($_)) {
                #     $textOut += $_.Text + "`n"
                #     }
                # }

                # $textOut = ($textIn | ForEach-Object { 
                #     $_.name
                # } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) -join "`n"
                # $textOut = ($textIn | ForEach-Object { $textIn.text }) -join "`n"
                # $textOut = ($textIn | ForEach-Object { $textIn.text }) -join ", "

            }
            "System.Management.Automation.PSObject" {
                # Handle the case where $textIn is a single PSObject
                $properties = $textIn.PSObject.Properties
                $formattedProperties = @()

                foreach ($property in $properties) {
                    $formattedProperties += "$($property.Name): $($property.Value)"
                }

                $textOut += $formattedProperties -join "`n"  # Join with new line for better readability            
            }
            "System.Collections.IEnumerable" {
                # Access the Text property if it exists
                $textOut += ($textIn | ForEach-Object {
                        if ($textIn.PSObject.Properties['Text']) { $textInType.Text } 
                    }) -join "`n"

            }
            "System.Management.Automation.PSCustomObject" {
                # Create a formatted string of properties
                $properties = $textIn.PSObject.Properties
                # $formattedProperties = @()

                # foreach ($property in $properties) {
                #     $formattedProperties += "$($property.Name): $($property.Value)"
                # }
                # $textOut = $formattedProperties -join "`n"  # Join with new line for better readability
                $textOutExtra = @()
                foreach ($property in $properties) {
                    if ($property.Name -eq "Name") {
                        $textOut += "$($property.Name): $($property.Value)`n"
                    }
                    elseif ($propery.Name -eq "description") {
                        $textOut += "$($property.Name): $($property.Value)`n"
                    }
                    else {
                        $textOutExtra += "$($property.Name): $($property.Value)`n"
                    }
                }
                $textOut += $textOutExtra
            }
            "System.String" { 
                # If it's a string, just use it directly
                $textOut += $textIn            
            }
            default { 
                # Unknow object
                # todo throw warning
                $textOut += $textIn            
            }
        }
    }
    else { 
        $textOut += "No detailed description available."
    }
    $textOutType = $textOut.GetType()
    Write-Debug "Result: $textOut (type: $textOutType)"
    return $textOut
}
# escape text
function packTextArray {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [object[]]$InputObjects
    )
    # asked Jun 26, 2014 at 13:43 nlowe's
    BEGIN {
        $OutputObjects = New-Object System.Collections.ArrayList($null)
    }
    PROCESS {
        $OutputObjects.Add($_) | Out-Null
    }
    END {
        Write-Verbose "Passing off $($OutputObjects.Count) objects downstream" 
        # return ,$OutputObjects.ToArray()
        @(, $OutputObjects)
    }
}
function escapeText {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $textIn,
        $localLogFileNameFull = "",
        [switch]$keepWhitespace,
        [switch]$keepEscapes
    )
    # Initialize description text
    $textOut = $textIn
    if ($textOut) {
        $textInType = $textIn.GetType().FullName
        switch ( $textInType ) {
            # Create the output string, including all properties and avoiding empty strings
            "System.String" { 
                if (-not $keepWhitespace) { $textOut = $textOut.TrimEnd() }
                if (-not $keepEscapes) {
                    $textOut = $textOut `
                        -replace '&', '&amp;' `
                        -replace '<', '&lt;' `
                        -replace '>', '&gt;' `
                        -replace '"', '&quot;' `
                        -replace "'", '&apos;'    
                }
            }
            "System.Object[]" {
                # Recursive loop
                foreach ($textRow in $textOut) {
                    <# $textRow is the current item #>
                    $textRow = escapeText $textRow $localLogFileNameFull `
                        -keepEscapes:$keepEscapes `
                        -keepWhitespace:$keepWhitespace
                }
            }              
            default { 
                # Unknow object
                # todo throw warning
                $textOut += "Error. Cant handle type $textInType for $textIn"
                logText $textOut
            }
        }       
    }
    return $textOut
}
function trimText {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $textIn,
        $localLogFileNameFull = ""
    )
    return escapeText $textIn $localLogFileNameFull -keepEscapes
}
function logText {
    # per https://stackoverflow.com/questions/24432190/generic-parameter-in-powershell
    # (todo: Inprogress. Implement pipelines)
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
        $logMessages,
        $localLogFileNameFull = "",
        [switch]$keepWhitespace,
        [switch]$keepEscapes,
        [switch]$isError,
        [switch]$isWarning,
        $foregroundColor = "White",
        $backgroundColor = "Black"
    )
    process {
        foreach ($logMessage in $logMessages) {
            # pre-process message (for html)
            # todo. Should the log be html also?
            $logMessage = escapeText $logMessage -keepEscapes

            if (-not $localLogFileNameFull) {
                $localLogFileNameFull = $global:logFileNameFull
            }
            # Check if folder not exists, and create it
            $logFilePath = Split-Path -Path $localLogFileNameFull
            if (-not(Test-Path $logFilePath -PathType Container)) {
                New-Item -path $logFilePath -ItemType Directory
            }
            # Check if file exists, and create it
            if (-not(Test-Path $localLogFileNameFull -PathType Leaf)) {
                New-Item -path $localLogFileNameFull -ItemType File
            }
            # $global:logData += $logMessage
            $logMessage | Out-File -FilePath $localLogFileNameFull –Append
            # Display message to user
            if ($isError) { 
                Write-Error -Message $logMessage
            }
            elseif ($isWarning) { 
                Write-Warning -Message $logMessage
            }
            else { 
                Write-Host $logMessage `
                    -ForegroundColor:$foregroundColor -BackgroundColor:$backgroundColor
            }

        }
    }
}
function logTextOld {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $logMessage,
        $localLogFileNameFull = "",
        [switch]$keepWhitespace,
        [switch]$keepEscapes,
        [switch]$isError
    )
    process {
        # pre-process message (for html)
        # todo. Should the log be html also?
        $logMessage = escapeText $logMessage -keepEscapes

        if (-not $localLogFileNameFull) {
            $localLogFileNameFull = $global:logFileNameFull
        }
        # Check if folder not exists, and create it
        $logFilePath = Split-Path -Path $localLogFileNameFull
        if (-not(Test-Path $logFilePath -PathType Container)) {
            New-Item -path $logFilePath -ItemType Directory
        }
        # Check if file exists, and create it
        if (-not(Test-Path $localLogFileNameFull -PathType Leaf)) {
            New-Item -path $localLogFileNameFull -ItemType File
        }
        # $global:logData += $logMessage
        $logMessage | Out-File -FilePath $localLogFileNameFull –Append
        if ($isError) { Write-Error -Message $logMessage }
        else { Write-Host $logMessage }
    }
}
# Help
#Test Help
function Test-Help () {
    # Example hashtable
    $hashtableInput = @{ text = "This is a test." }
    $outText = extractText $hashtableInput
    logText $outText
    # Example array of PSObjects
    $arrayInput = @(
        [PSCustomObject]@{ text = "First item." },
        [PSCustomObject]@{ text = "Second item." }
    )
    $outText = extractText $arrayInput
    logText $outText

    # Example string
    $stringInput = "Just a simple string."
    $outText = extractText $stringInput
    logText $outText

    # Example enumerable collection
    $collectionInput = @(
        [PSCustomObject]@{ Text = "Item 1" },
        [PSCustomObject]@{ Text = "Item 2" }
    )
    $outText = extractText $collectionInput
    logText $outText
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
        $descriptionSynopsis = extractText $descriptionSynopsis
        $descriptionSynopsis = escapeText $descriptionSynopsis
        $htmlContentLocal += "<p><strong>Synopsis:</strong> $descriptionSynopsis</p>"

        # Access the detailed description
        $descriptionDetails = $helpInfo.Description
        $descriptionText = extractText $descriptionDetails
        $descriptionText = escapeText $descriptionText
        $htmlContentLocal += "<p><strong>Detailed Description:</strong> $descriptionText</p>"

        # Access the syntax
        $descriptionSyntax = $helpInfo.syntax
        $descriptionSyntax = extractText $descriptionSyntax
        $descriptionSyntax = escapeText $descriptionSyntax
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
                # $paramText = extractText $paramDetails
                # Write-Debug $paramText
                foreach ($paramItem in $paramDetails) {
                    <# $paramItem is the current item #>

                    # Access the properties from the nested hashtable
                    $paramName = if ($paramItem.name) { $paramItem.name } else { "N/A" }
                    $paramName = escapeText $paramName

                    $paramDescription = if ($paramItem.description) {
                        $paramItem.description 
                    } 
                    else { "N/A" }
                    $paramDescription = extractText $paramDescription
                    $paramDescription = escapeText $paramDescription
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
            $returnedValue = extractText $returnedValue
            $returnedValue = escapeText $returnedValue
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
                $exampleContent = escapeText $exampleContent
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
                logText "========================================================" $localLogFileNameFull `
                    -ForegroundColor Red
                logText "Module: $moduleName"  $localLogFileNameFull
                $htmlContent += "<h1>$($moduleName)</h1>"
                # Import the Module
                try {
                    # $global:scriptPath = (get-item $PSScriptRoot ).parent.FullName
                    Import-Module -Name "$global:scriptPath\$moduleName\$moduleName" `
                        -Force `
                        -ErrorAction Continue | logText $global:LogFileNameFull
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
                    logText $logMessage $localLogFileNameFull -isError
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
                    logText $logMessage $localLogFileNameFull -isWarning
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
                    logText $logMessage $localLogFileNameFull -isError
                    continue
                }
                # Loop through each cmdlet and get help information
                foreach ($cmdlet in $cmdlets) {
                    try {
                        logText $cmdlet.Name $localLogFileNameFull
                        $htmlContent += "<h2>$($cmdlet.Name)</h2>"
                        $helpInfo = Get-Help $cmdlet.Name -Full
                        $htmlContent += Get-HelpHtml $helpInfo
                    }
                    catch {
                        $logMessage = @( `
                                "There is no help for function: $($cmdlet.Name).", `
                                "Error: $_"
                        )
                        logText $logMessage $localLogFileNameFull -isWarning
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
                logText "Help documentation saved to: $outputFilePath" $localLogFileNameFull
            }
        }
    }
}
# MAIN
$timeStarted = "{0:yyyymmdd_hhmmss}" -f (get-date)
$timeCompleted = $timeStarted
$source = Convert-Path $source
if (-not $source) { $source = (get-item $PSScriptRoot).parent.FullName }

$destination = Convert-Path $destination
if (-not $destination) { $destination = Convert-Path "$env:PROGRAMFILES\WindowsPowerShell\Modules" }

# Logging:
if (-not $global:logFilePath) { $global:logFilePath = "G:\Script\Powershell\Mdm_Powershell_Modules\log" }
$global:logFilePath = Convert-Path $global:logFilePath
if (-not $global:logFilePath) { $global:logFilePath = Convert-Path ".\" }
# Check if folder not exists, and create it
if (-not(Test-Path $global:logFilePath -PathType Container)) {
    New-Item -path $global:logFilePath -ItemType Directory
}

if (-not $global:logFileName) { $global:logFileName = "Mdm_Installation_Log" }
$global:logFileNameFull = "$logFilePath\$logFileName"
if (-not $logOneFile) { $global:logFileNameFull += "_$timeStarted" }
$global:logFileNameFull += ".txt"
# Check if file exists, and create it
if (-not(Test-Path $global:logFileNameFull -PathType Leaf)) {
    New-Item -path $global:logFileNameFull -ItemType File
}

$logMessage = @(
    " ", `
        "==================================================================", `
        "Installing Mdm Modules at $timeStarted", `
        "==================================================================", `
        "Source: $source", `
        "Destination: $destination", `
        "Logfile: $global:logFileNameFull"
)
logText $logMessage $global:LogFileNameFull `
    -ForegroundColor Green

# ================================= Codium setup
# https://dev.to/opdev1004/how-to-add-open-with-vscodium-for-windows-3g0l

if (-not $SkipRegistry) {
    logText "==================================================================" $global:LogFileNameFull `
        -ForegroundColor Green
    logText "Updating Registry" $global:LogFileNameFull
    logText "Updating: $regPath" $global:LogFileNameFull
    
    # ================================= Registry (Language mode)
    # Notes: Meaning of %V
    #   %V: This placeholder is used to represent the full path of the file.
    #   It is specifically intended for use with file paths that include spaces. 
    #   When %V is used, it is automatically enclosed in quotes, 
    #       which helps ensure that the path is correctly interpreted
    #       by the application, even if it contains spaces.

    # Key: Computer\HKEY_CLASSES_ROOT\Directory\shell\Powershell\command
    # powershell.exe -noexit -command Set-Location -literalPath '%V'

    # ================================= Registry (codium)
    # Setup "Open with "
    # Method 1: 
    # Check if Codium is installed for single user.
    $appExePath = "$env:USERPROFILE\AppData\Local\Programs\VSCodium\VSCodium.exe"
    # Check if the path exists
    if (Test-Path $appExePath) {
        # Resolve the path
        $appExePath = Resolve-Path $appExePath | Select-Object -ExpandProperty Path
    }
    else {
        # Codium must be installed for all users.
        $appExePath = Resolve-Path "$env:Programfiles\VSCodium\VSCodium.exe"
        if (Test-Path $appExePath) {
            # Resolve the path
            $appExePath = Resolve-Path $appExePath | Select-Object -ExpandProperty Path
        }
        else {
            # Throw an error todo.
            logText "VSCodium not found." $global:LogFileNameFull -isError
        }
    }
    $commandString = "`"$appExePath`" `"%V`""
    # # Note on UserProfile: This method uses the user's account name:

    # Directory shell
    $regPath = "HKEY_CLASSES_ROOT\Directory\shell" 
    logText "Updating: $regPath" $global:LogFileNameFull
    $regKey = "Open with VSCodium"
    $regProperty = "command"
    # Create registry key
    if (-not (Test-Path "Registry::$regPath\$regKey")) {
        New-Item -Path "Registry::$regPath" -Name $regKey -Force
    }
    # Set Default
    $regProperty = "(Default)"
    Set-ItemProperty -Path "Registry::$regPath\$regKey" -Name $regProperty -Value $regKey -Force

    # command subkey
    $regPath += "\$regKey"
    logText "Updating: $regPath" $global:LogFileNameFull
    $regKey = "command"
    if (-not (Test-Path "Registry::$regPath\$regKey")) {
        New-Item -Path "Registry::$regPath" -Name $regKey -Force
    }
    # Set the command
    $regProperty = "(Default)"
    Set-ItemProperty -Path "Registry::$regPath\$regKey" -Name $regProperty -Value $commandString -Force

    # Directory Background Shell
    $regPath = "HKEY_CLASSES_ROOT\Directory\Background\shell"
    logText "Updating: $regPath" $global:LogFileNameFull
    $regKey = "Open with VSCodium"
    if (-not (Test-Path "Registry::$regPath\$regKey")) {
        New-Item -Path "Registry::$regPath" -Name $regKey -Force
    }
    # Set Default
    $regProperty = "(Default)"
    Set-ItemProperty -Path "Registry::$regPath\$regKey" -Name $regProperty -Value $regKey -Force

    $regPath += "\$regKey"
    logText "Updating: $regPath" $global:LogFileNameFull
    # command subkey
    $regKey = "command"
    if (-not (Test-Path "Registry::$regPath\$regKey")) {
        New-Item -Path "Registry::$regPath" -Name $regKey -Force
    }

    # Set the Command Path - Open with VSCodium
    $regProperty = "(Default)"
    Set-ItemProperty -Path "Registry::$regPath\$regKey" -Name $regProperty -Value $commandString -Force

    # Method 2:
    # https://www.thewindowsclub.com/change-registry-using-windows-powershell
    # Step 1: Type following and press Enter key to go to the Registry location:
    #   Set-Location -Path 'HKLM:\Software\Policies\Microsoft\Windows'
    # Step 2: Then execute the following cmdlet to create the new registry sub-key
    #   Get-Item -Path 'HKLM:\Software\Policies\Microsoft\Windows' | New-Item -Name 'Windows Search' -Force
    # Step 3: Now as the registry sub-key is created, I’ll now create a registry DWORD and execute the following code for this: 
    #   New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\Windows Search' -Name 'AllowIndexingEncryptedStoresOrItems' -Value "1" -PropertyType DWORD -Force
}

# ================================= Install modules:

# ================================= Execute COPY command:
$roboCopyOptions = @($helpSource, $helpDestination)
$optionsArray = $copyOptions.split(" ")
foreach ($option in $optionsArray) {
    $roboCopyOptions += $Option
}
$roboCopyOptions += "/LOG+:$global:logFileNameFull"
$commandLine = "Robocopy `"$source`" `"$destination`" $copyOptions"
$commandLine += " /LOG+:`"$global:logFileNameFull`"" # :: output status to LOG file (append to existing log).
# ================================= Reporting:
# if ($DoVerbose) {
logText "==================================================================" $global:LogFileNameFull `
    -ForegroundColor Green
$logMessage = @( `
        "Copying SOURCE: ""$source""", `
        "DESTINATION: ""$destination""", `
        " ", `
        "Command: $commandLine", `
        " ", `
        "Starting processing..."
)
logText $logMessage $global:LogFileNameFull
# }

logText "Remove modules if they exist" $global:LogFileNameFull
Remove-Item "$destination\Mdm_*" `
    -Recurse -Force `
    -ErrorAction SilentlyContinue

logText "Copy modules to destination" $global:LogFileNameFull
if ($DoNewWindow) {
    # $installProcess = 
    logText "NOTE: Opening new window..." `
        $global:LogFileNameFull `
        -ForegroundColor Red
    Start-Process -FilePath "robocopy" `
        -ArgumentList $roboCopyOptions `
        -Verb RunAs `
        -NoNewWindow
    # Start-Process cmd "/c `"$commandLine & pause `""
    # $installProcess = Start-Process powershell -ArgumentList "-NoProfile -Command $commandLine" -Verb RunAs -NoNewWindow
    # Start-Process powershell -ArgumentList "-NoProfile -Command `"$commandLine`"" -Verb RunAs
    # Start-Process powershell -ArgumentList "-NoExit -Command $commandLine" -Verb RunAs
    # Note: NoNewWindow might be preferred if output isn't captured.
    # ================================= Wait for completion
    # if you have a process:
    # $installProcess.WaitForExit()

}
else {
    Invoke-Expression $commandLine
}
# Notes on various ways to copy items:
# powershell -command $commandLine -Verb runas
# Copy-Item -Path $source -Destination $destination -Verbose -Force –PassThru | Where-Object{$_ -is [system.io.fileinfo]}
# Copy-Item -Path $source -Destination $destination -Verbose -Force –PassThru | ForEach-Object {
#     logText "$_.FullName copied."
# }
# (Copy-Item -Path $source -Destination $destination -Force -Verbose).Message

# ================================= Help files
if (-not $SkipHelp) {
    logText "==================================================================" $global:LogFileNameFull `
        -ForegroundColor Green
    logText " " $global:LogFileNameFull
    logText "Updating Help for Mdm Modules." $global:LogFileNameFull
    $helpSource = "$source\Mdm_Bootstrap\help"
    $helpDestination = "$destination\Mdm_Bootstrap\help"
    # $helpFileName = "$Mdm_Help.html"  # Update the path

    try {
        Export-Help $source $global:logFileNameFull
    }
    catch {
        $logMessage = @( `
                "Export-Help Failed.", `
                "Error: $_"
        )
        logText $logMessage $global:LogFileNameFull -isError
    }
    try {
        Get-Mdm_Help
    }
    catch {
        $logMessage = @( `
                "Get-Mdm_Help Failed.", `
                "Error: $_"
        )
        logText $logMessage $global:LogFileNameFull -isError
    }
}
if ($DoVerbose) { logText " " $global:LogFileNameFull }

# ================================= Reporting part 2
logText "==================================================================" $global:LogFileNameFull `
    -ForegroundColor Green
logText " " $global:LogFileNameFull
logText "Reloading Mdm Modules." $global:LogFileNameFull
if ($DoVerbose) {
    # Get-ChildItem "%userprofile%\Documents\PowerShell\Modules\*.*"
    Get-ChildItem -Path $destination
    # to display something?
}

# ================================= Reload Modules
$moduleName = "Mdm_Modules"
logText "Standard import ($moduleName) test..."
try {
    # Import-Module -name $moduleName `
    Import-Module -Name "$global:scriptPath\$moduleName\$moduleName" `
        -Force `
        -ErrorAction Continue | logText $global:LogFileNameFull
    # Import-Module -name Mdm_Modules -Force >> $global:logFileNameFull
}
catch {
    $logMessage = @( `
            " ", `
            "Failed to import module: $moduleName.", `
            "Error: $_"
    )
    logText $logMessage $global:LogFileNameFull -isError
}

try {
    logText "==================" $global:LogFileNameFull
    logText "Automatic Function Imports Test (Build-ModuleExports $moduleName)" $global:LogFileNameFull
    logText "Build-ModuleExports $global:scriptPath" $global:LogFileNameFull
    Build-ModuleExports "$global:scriptPath\$moduleName"
}
catch {
    $logMessage = @( `
            "Build-ModuleExports failed.", `
            "Error: $_"
    )
    logText $logMessage $global:logFileNameFull -isError
}

if (-not $SkipHelp) {
    logText "==================================================================" $global:LogFileNameFull `
        -ForegroundColor Green
    $logMessage = @( `
            "Updating System Help for Mdm Modules.", `
            "xxxxxxxxxxxxxxxxxx", `
            "Write-Mdm_Help" `
    )
    logText $logMessage $global:LogFileNameFull -isError
    Write-Mdm_Help
    $logMessage = @( `
            "==================", `
            "Get-Mdm_Help"
    )
    logText $logMessage $global:LogFileNameFull -isError
    Get-Mdm_Help
    # Generate-Documentation

    # Update system folders
    if ($DoNewWindow) {
        # $installProcess = 
        logText "NOTE: Opening new window..." `
            -ForegroundColor Red
        Start-Process -FilePath "robocopy" -ArgumentList $roboCopyOptions -Verb RunAs
    }
    else {
        logText "================================= Execute COPY command:"
        $commandLine = "Robocopy `"$helpSource`" `"$helpDestination`" $roboCopyOptions"
        $commandLine += " /LOG+:`"$global:logFileNameFull`"" # :: output status to LOG file (append to existing log).
        logText $commandLine
        Invoke-Expression $commandLine
    }
}
# ================================= Wrapup
$timeCompleted = "{0:G}" -f (get-date)
$logMessage = @( `
        "==================================================================", `
        "Installation completed at $timeCompleted", `
        "started at $timeStarted", `
        "Source: $source", `
        "Destination: $destination", `
        "Logfile: $global:logFileNameFull", `
        "==================================================================" `
)
logText $logMessage $global:LogFileNameFull

# ================================= Copy with progress %
# $source=ls c:\temp *.*
# $i=1
# $source| %{
#     [int]$percent = $i / $source.count * 100
#     Write-Progress -Activity "Copying ... ($percent %)" -status $_  -PercentComplete $percent -verbose
#     copy $_.fullName -Destination c:\test 
#     $i++
# }
#
# 2025/03/26 09:11:03 ERROR 5 (0x00000005) Accessing Destination Directory C:\Program Files\WindowsPowerShell\Modules\
# Access is denied.
# Waiting 30 seconds... Retrying...

# ================================= Robocopy documentation:
# /V - verbose
# /MIRror = /E /PURGE (cleans out depreciated files (scripts))
# /MIRror folder contents
# /FP : Include Full Pathname of files in the output.
# /NS : No Size - don’t log file sizes.
#
# Other Robocopy options:
# /L :: List only - don't copy, timestamp or delete any files.
# /X :: report all eXtra files, not just those selected.
# /V :: produce Verbose output, showing skipped files.
# /TS :: include source file Time Stamps in the output.
# /FP :: include Full Pathname of files in the output.
# /BYTES :: Print sizes as bytes.
# 
# /NS :: No Size - don't log file sizes.
# /NC :: No Class - don't log file classes.
# /NFL :: No File List - don't log file names.
# /NDL :: No Directory List - don't log directory names.
# 
# /NP :: No Progress - don't display percentage copied.
# /ETA :: show Estimated Time of Arrival of copied files.
# 
# /LOG:file :: output status to LOG file (overwrite existing log).
# /LOG+:file :: output status to LOG file (append to existing log).

