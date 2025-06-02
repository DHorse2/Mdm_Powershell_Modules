#region Convert Text
function ConvertFrom-HashValue {
    [CmdletBinding()]
    param (
        $textIn,
        $textOut = @(),
        $textLineBreak = "`n"
    )
    process {
        Write-Debug "String"
        $textOutExtra = @()
        # $textInType = $textIn.GetType()
        # Write-Debug " "
        # Write-Debug "TextIn Name: $($textIn.Name)"
        # Write-Debug "TextIn Type: $($textInType)"
        # Write-Debug "TextIn TypeNameOfValue: $($textIn.TypeNameOfValue)"
        # Write-Debug "TextIn Value: $($textIn.Value)"
        foreach ($textItem in $textIn.PSObject.Properties) {
            # $textItem = $textItem.Key
            # Write-Debug " "
            # Write-Debug "Object Key: $($textItem.Name)"
            # Write-Debug "Object Type: $($textItem.TypeNameOfValue)"
            # Write-Debug "Object Value: $($textItem.Value)"
            if ($textItem.Name -eq "Name" -or $textItem.Name -eq "name") {
                Write-Debug "Name"
                $textOut += "$($textItem.Value)$textLineBreak"
            } elseif ($textItem.Name -eq "Text" -or $textItem.Name -eq "text") {
                Write-Debug "Text"
                $textOut += "$($textItem.Value)$textLineBreak"
            } elseif ($textItem.Name -eq "Description" -or $textItem.Name -eq "description") {
                Write-Debug "Description"
                $textInType = $textItem.Value.GetType().FullName
                if ($textInType -eq "System.String") { 
                    Write-Debug "String"
                    # If it's a string, just use it directly
                    $textOut += "$($textItem.Name): $($textItem.Value)$textLineBreak"
                } else {
                    Write-Debug "Name also"
                    $textOut += "$($textItem.Name): $(ConvertTo-Text $textItem.Value)$textLineBreak"
                }
            } elseif ($textItem.Name -eq "Type" -or $textItem.Name -eq "type") {
                Write-Debug "Type"
                $textOut += ConvertTo-Text $textItem.Value
            } elseif ($textItem.Name -eq "syntaxItem") {
                Write-Debug "syntaxItem"
                $textOut += ConvertTo-Text $textItem.Value
            } elseif ($textItem.Name -eq "returnValue") {
                Write-Debug "returnValue"
                $textOut += ConvertTo-Text $textItem.Value
            } elseif ($textItem.Name -eq "parameter") {
                Write-Debug "parameter"
                $textOut += ConvertTo-Text $textItem.Value
            } elseif ($textItem.Name -eq "textItem") {
                Write-Debug "textItem"
                $textOut += ConvertTo-Text $textItem.Value
            } else {
                Write-Debug "Other"
                $textOutExtra += "$($textItem.Name): $($textItem.Value)$textLineBreak"
            }
        }
        # foreach ($textItem in $textOutExtra) {
        #     Write-Host "Item: $textItem, Type: $($textItem.GetType().Name)"
        # }
        # Write-Host "Contents of textOutExtra:"
        # $textOutExtra | ForEach-Object { Write-Host $_ }        
        # $textOutString = $textOutExtra -join ", "
        $textInType = $textOutExtra.GetType().Name
        [string]$textOutString = ""
        foreach ($textItem in $textOutExtra) {
            $textInType = $textItem.GetType().Name
            if ($textOutString.Length -ge 1) { $textOutString += ", " }
            [string]$textOutString += $textItem.Trim()
        }
        if ($textOutString.Length -ge 1) { $textOut += $textOutString }
        return $textOut
    }
}
function ConvertTo-Text {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $textIn
    )
    Write-Debug "ConvertTo-Text"
    # Initialize description text
    $textOut = @()
    if ($textIn) {
        $textInType = $textIn.GetType().FullName
        $properties = $textIn.PSObject.Properties
        # Output the structure of the detailed description for inspection
        # $textIn | Get-Member
        switch ( $textInType ) {
            "hashtable" {
                Write-Debug "hashtable"
                # Access the description property
                if ($textIn.ContainsKey('Text')) {
                    if ($textIn.text -is [System.Collections.IEnumerable] `
                            -and -not ($textIn.text -is [string])) {
                        # If the description is an array, join it into a single string
                        # $textOut = $textIn.text -join "`n"
                        $textOut += $textIn.text
                    } else {
                        $textOut += $textIn.text
                    }
                }
            }
            "System.Object[]" {
                Write-Debug "Object[]"
                # Create the output string, including all properties and avoiding empty strings
                $formattedProperties = @()
                $textIn | ForEach-Object {
                    # Create a formatted string for each property
                    $tmp = $_.PSObject
                    Write-Debug $tmp
                    # $formattedProperties += $_

                    # Loop through each property in the object
                    $properties = $_.PSObject.Properties
                    if ($properties) {
                        foreach ($property in $properties) {
                            if ($property -eq "parameter") {}
                            if (-not [string]::IsNullOrWhiteSpace($property.Name)) {
                                $formattedProperties += "$($property.Name): $($property.Value)"
                            } elseif (-not [string]::IsNullOrWhiteSpace($property.Value)) {
                                $formattedProperties += "$($property.Value)"
                            } else {
                                $formattedProperties += "$property"
                            }
                        }
                    }

                    # # Create a formatted string for each property
                    # $formattedProperties = $_.GetEnumerator() | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Value) } | 
                    # ForEach-Object { "$($_.Key): $($_.Value)" }

                    # Join the formatted properties with a comma and space
                    # $formattedString = $formattedProperties -join ", "

                    # Return the formatted string
                    # $formattedString
                }
                $textOut += $formattedProperties -join "`n"  # Join with new line for better readability            
            }            
            "System.Management.Automation.PSObject[]" {
                Write-Debug "PSObject[]"
                # If it's an array of PSObjects, join their 'text' properties
                # Create the output string, including all properties and avoiding empty strings
                $textIn | ForEach-Object {
                    ConvertTo-Text $_
                    # Create a formatted string for each property
                    # $formattedProperties = @()
                    # # Loop through each property in the object
                    # foreach ($property in $_.PSObject.Properties) {
                    #     if (-not [string]::IsNullOrWhiteSpace($property.Value)) {
                    #         $formattedProperties += "$($property.Name): $($property.Value)"
                    #     }
                    # }
                    # Join the formatted properties with a comma and space
                }
                # $textOut += $formattedProperties -join "`n"  # Join with new line for better readability            
            }
            "System.Management.Automation.PSObject" {
                Write-Debug "PSObject"
                # Handle the case where $textIn is a single PSObject
                $properties = $textIn.PSObject.Properties
                $formattedProperties = @()
                foreach ($property in $properties) {
                    $formattedProperties += "$($property.Name): $($property.Value)"
                }
                $textOut += $formattedProperties -join "`n"  # Join with new line for better readability            
            }
            "System.Collections.IEnumerable" {
                Write-Debug "IEnumerable"
                # Access the Text property if it exists
                $textOut += ($textIn | ForEach-Object {
                        if ($textIn.PSObject.Properties['Text']) { $textInType.Text } 
                    }) -join "`n"
            }
            "System.Management.Automation.PSCustomObject" {
                Write-Debug "PSCustomObject"
                # Create a formatted string of properties
                $properties = $textIn.PSObject.Properties
                $textOut += ConvertFrom-HashValue -textIn $textIn -textOut $textOut
            }
            "System.String" { 
                Write-Debug "String"
                # If it's a string, just use it directly
                $textOut += $textIn            
            }
            default { 
                Write-Debug "default: $textInType"
                # Unknow object
                $textOut += $textIn
                $Message = "Unknow object $textIn"
                Add-LogText $Message -IsWarning

            }
        }
    } else { 
        $textOut += "No detailed description available."
        Write-Debug $textOut
    }
    $textOutType = $textOut.GetType()
    Write-Debug "Result: $textOut (type: $textOutType)"
    return $textOut
}
function ConvertTo-ObjectArray {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [object[]]$InputObjects
    )
    # asked Jun 26, 2014 at 13:43 nlowe's
    begin {
        $OutputObjects = New-Object System.Collections.ArrayList($null)
    }
    process {
        $OutputObjects.Add($_) | Out-Null
    }
    end {
        Write-Debug "Passing off $($OutputObjects.Count) objects downstream" 
        # return ,$OutputObjects.ToArray()
        @(, $OutputObjects)
    }
}
# escape text
function ConvertTo-EscapedText {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $textIn,
        $logFileNameFull = "",
        [switch]$TrimWhitespace,
        [switch]$SkipEscapes
    )
    process {
        Write-Debug "Escape Text"
        # Initialize description text
        $textOut = $textIn
        if ($textOut) {
            $textInType = $textIn.GetType().FullName
            switch ( $textInType ) {
                # Create the output string, including all properties and avoiding empty strings
                "System.String" { 
                    Write-Debug "String"
                    if ($TrimWhitespace) { $textOut = $textOut.TrimEnd() }
                    if (-not $SkipEscapes) {
                        $textOut = $textOut `
                            -replace '&', '&amp;' `
                            -replace '<', '&lt;' `
                            -replace '>', '&gt;' `
                            -replace '"', '&quot;' `
                            -replace "'", '&apos;'    
                    }
                }
                "System.Object[]" {
                    Write-Debug "Object[]"
                    # Recursive loop
                    foreach ($textRow in $textOut) {
                        <# $textRow is the current item #>
                        [hashtable]$convertParams = @{}
                        $convertParams['SkipEscapes'] = $SkipEscapes
                        $convertParams['TrimWhitespace'] = $TrimWhitespace
                        $textRow = ConvertTo-EscapedText $textRow $logFileNameFull
                    }
                }              
                default { 
                    Write-Debug "Unknow object"
                    $Message = "Error. Cant handle type $textInType for $textIn"
                    $textOut += $Message
                    Add-LogText $Message -IsWarning
                }
            }       
        }
    }
    end {
        return $textOut
    }
}
function ConvertTo-TrimmedText {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $textIn,
        $logFileNameFull = ""
    )
    process {
        Write-Debug "Trim Text"
        return ConvertTo-EscapedText $textIn $logFileNameFull -TrimWhitespace 
    }
}
#endregion
#region Convert Colors
# Define a function to convert ConsoleColor to System.Windows.Media.Color
function Convert-ConsoleToMediaColor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.ConsoleColor]$consoleColor
    )
    switch ($consoleColor) {
        'Black' { return [System.Windows.Media.Color]::FromRgb(0, 0, 0) }
        'DarkBlue' { return [System.Windows.Media.Color]::FromRgb(0, 0, 128) }
        'DarkGreen' { return [System.Windows.Media.Color]::FromRgb(0, 128, 0) }
        'DarkCyan' { return [System.Windows.Media.Color]::FromRgb(0, 128, 128) }
        'DarkRed' { return [System.Windows.Media.Color]::FromRgb(128, 0, 0) }
        'DarkMagenta' { return [System.Windows.Media.Color]::FromRgb(128, 0, 128) }
        'DarkYellow' { return [System.Windows.Media.Color]::FromRgb(128, 128, 0) }
        'Gray' { return [System.Windows.Media.Color]::FromRgb(192, 192, 192) }
        'DarkGray' { return [System.Windows.Media.Color]::FromRgb(128, 128, 128) }
        'Blue' { return [System.Windows.Media.Color]::FromRgb(0, 0, 255) }
        'Green' { return [System.Windows.Media.Color]::FromRgb(0, 255, 0) }
        'Cyan' { return [System.Windows.Media.Color]::FromRgb(0, 255, 255) }
        'Red' { return [System.Windows.Media.Color]::FromRgb(255, 0, 0) }
        'Magenta' { return [System.Windows.Media.Color]::FromRgb(255, 0, 255) }
        'Yellow' { return [System.Windows.Media.Color]::FromRgb(255, 255, 0) }
        'White' { return [System.Windows.Media.Color]::FromRgb(255, 255, 255) }
        default { throw "Unsupported ConsoleColor: $consoleColor" }
    }
}
# Define a function to convert System.Windows.Media.Color to ConsoleColor
function Convert-MediaToConsoleColor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $mediaColor
    )
    $mediaColorType = $mediaColor.GetType().FullName
    if ($mediaColorType -eq "System.ConsoleColor") {
        return [System.ConsoleColor]$mediaColor
    } elseif ($mediaColorType -eq "System.Windows.Media.Color") {
        # Get the RGB values from the MediaColor
        $r = $mediaColor.R
        $g = $mediaColor.G
        $b = $mediaColor.B
        # Determine the ConsoleColor based on the RGB values
        switch ("$r,$g,$b") {
            '0,0,0' { return [System.ConsoleColor]::Black }
            '0,0,128' { return [System.ConsoleColor]::DarkBlue }
            '0,128,0' { return [System.ConsoleColor]::DarkGreen }
            '0,128,128' { return [System.ConsoleColor]::DarkCyan }
            '128,0,0' { return [System.ConsoleColor]::DarkRed }
            '128,0,128' { return [System.ConsoleColor]::DarkMagenta }
            '128,128,0' { return [System.ConsoleColor]::DarkYellow }
            '192,192,192' { return [System.ConsoleColor]::Gray }
            '128,128,128' { return [System.ConsoleColor]::DarkGray }
            '0,0,255' { return [System.ConsoleColor]::Blue }
            '0,255,0' { return [System.ConsoleColor]::Green }
            '0,255,255' { return [System.ConsoleColor]::Cyan }
            '255,0,0' { return [System.ConsoleColor]::Red }
            '255,0,255' { return [System.ConsoleColor]::Magenta }
            '255,255,0' { return [System.ConsoleColor]::Yellow }
            '255,255,255' { return [System.ConsoleColor]::White }
            default { 
                Write-Error -Message "Unsupported MediaColor: $mediaColor" 
                return [System.ConsoleColor]::Red
            }
        }
    } else {
        Write-Error -Message $("Expected [System.Windows.Media.Color] or [System.ConsoleColor]`n" `
                + "Got type: $mediaColorType from: $mediaColor.`n"  `
                + "Attempting to Convert-NameToConsoleColor by value.")
        return Convert-NameToConsoleColor $mediaColor
    }
}
function Convert-NameToConsoleColor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$colorName
    )
    $colorName = $colorName.ToLower()
    switch ($colorName) {
        'black' { return [System.ConsoleColor]::Black }
        'darkblue' { return [System.ConsoleColor]::DarkBlue }
        'darkgreen' { return [System.ConsoleColor]::DarkGreen }
        'darkcyan' { return [System.ConsoleColor]::DarkCyan }
        'darkred' { return [System.ConsoleColor]::DarkRed }
        'darkmagenta' { return [System.ConsoleColor]::DarkMagenta }
        'darkyellow' { return [System.ConsoleColor]::DarkYellow }
        'gray' { return [System.ConsoleColor]::Gray }
        'darkgray' { return [System.ConsoleColor]::DarkGray }
        'blue' { return [System.ConsoleColor]::Blue }
        'green' { return [System.ConsoleColor]::Green }
        'cyan' { return [System.ConsoleColor]::Cyan }
        'red' { return [System.ConsoleColor]::Red }
        'magenta' { return [System.ConsoleColor]::Magenta }
        'yellow' { return [System.ConsoleColor]::Yellow }
        'white' { return [System.ConsoleColor]::White }
        default {
            Write-Error -Message "Unsupported color name: $colorName. Using Red."
            return [System.ConsoleColor]::Red
        }
    }
}
#endregion