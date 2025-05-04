
function DevEnvGui {
    <#
.SYNOPSIS
    A short one-line action-based description, e.g. 'Tests if a function is valid'
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
.NOTES
    Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>


    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$fileNameFull = "",
        [switch]$ResetSettings
    )
    
    begin {
        $assemblyName = "System.Windows.Forms"
        # $assemblySystemWindowsForms = Get-Assembly -assemblyName $assemblyName
        $null = Get-Assembly -assemblyName $assemblyName
        # Import-Module Mdm_WinFormPS
        if (-not (Get-Module -Name Mdm_WinFormPS)) {
            Import-Module Mdm_WinFormPS
        }
        try {
            $form = New-WFForm
            Get-JsonData -parentObject $form.Data ".\DevEnvGuiConfig.json"
            Get-JsonData -parentObject $form.Data.Components ".\DevEnvComponents.json"
            Show-WFForm $form
        } catch {
            Write-Error "TODO DevEnvGui error. $_"
        }
    }
    process {
        Show-WFForm($form)
    }
    end { }
}

function Get-JsonData {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline)]$inputObjects,
        # Parameter help description
        $parentObject
    )

    begin {
        [Collections.ArrayList]$inputObjects = @()
        # Path to the JSON file
        $jsonFilePath = "path\to\your\file.json"
        $dataOut = @{}

    }
    process {
        [void]$inputObjects.Add($_)
    }
    end {
        $inputObjects | ForEach-Object {
            try {
                $filePath = $_
                # Read the JSON file
                $jsonContent = Get-Content -Path $_ -Raw
                # Convert the JSON string to a PowerShell object
                $data = $jsonContent | ConvertFrom-Json
                # Access the properties of the object
                if ($parentObject) {
                    if ($data.name) {
                        $parentObject[$data.name] = $data
                    } else { $parentObject += $data }
                } else {
                    $dataOut += $data
                }
                Write-Verbose "Data: $data"
            } catch {
                Write-Error "Error processing file $($filePath): $_"
            }
        }
        # Collect results if not using parentObject
        if ($parentObject) {
            Write-Output $parentObject
        } else {
            Write-Output $dataOut
        }
    }
}

function Get-Assembly {
    # Load assemblies such as:
    #   Microsoft.VisualBasic
    #   System.Windows.Forms
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$assemblyName
    )
    begin { }
    process {
        try {
            # Load the Assembly
            $assembly = Add-Type -AssemblyName $assemblyName -ErrorAction 'Stop' -ErrorVariable ErrorBeginAddType
            Write-Verbose "Successfully loaded assembly: $assemblyName"
            return $assembly
        } catch {
            Write-Warning -Message "[BEGIN] Something went wrong while loading assembly $assemblyName."
            if ($ErrorBeginAddType) {
                Write-Warning -Message "[BEGIN] Error details: $($ErrorBeginAddType)"
            }
            Write-Error -Message $_.Exception.Message
        }
    }
    end { }
}