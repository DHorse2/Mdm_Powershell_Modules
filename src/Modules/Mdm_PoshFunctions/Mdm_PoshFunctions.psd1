@{

    # Script module or binary module file associated with this manifest.
    RootModule        = 'Mdm_PoshFunctions.psm1'

    # Version number of this module.
    ModuleVersion     = '2.2.12'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID              = '188504d6-d6ed-4ee3-92c4-7b426ed3d611'

    # Author of this module
    Author            = 'Bill Riedy'

    # Company or vendor of this module
    CompanyName       = ''

    # Copyright statement for this module
    Copyright         = '(c) 2024 Bill Riedy. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'A curated collection of over 250 PowerShell functions. Many functions written by me. Others are attributed wherever possible.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # Recreate by running from PS prompts in PoshFunctions folder
    #

    <# To recreate Markdown help

    remove-item .\Docs\Markdown\*
    new-markdownhelp -Module PoshFunctions -OutputFolder .\Docs\Markdown -Encoding ([System.Text.Encoding]::Ascii)

    To recreate HTML from Markdown

    remove-item .\Docs\HTML\* -recurse -force
    Convert-MarkdownToHTML -Path .\Docs\Markdown\* -SiteDirectory .\Docs\Html

    #>
    <#
    dir .\Formats\*.ps1xml |
    Get-RelativePath -RelativeTo $pwd |
    Write-StringArray -VariableName FormatsToProcess -ExcludeDollarSign |
    Format-WrapText -Width 100 |
    Set-Clipboard
#>

    FormatsToProcess  = @( '.\Formats\Get-DriveStatBytes.Format.ps1xml',
        '.\Formats\Get-DriveStatGB.Format.ps1xml', '.\Formats\Get-DriveStatKB.Format.ps1xml',
        '.\Formats\Get-DriveStatMB.Format.ps1xml', '.\Formats\Get-NamedColorBrief.Format.ps1xml',
        '.\Formats\Get-NamedColorFull.Format.ps1xml', '.\Formats\Get-PrintableAscii.Format.ps1xml',
        '.\Formats\Get-RebootHistory.Format.ps1xml', '.\Formats\Get-VssAdminListWriters.Format.ps1xml',
        '.\Formats\New-PFDateFormat.Format.ps1xml', '.\Formats\Test-Port.Format.ps1xml' )

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    # Recreated by running the following from PS prompt in PoshFunctions folder

    <#
    dir .\Functions\*.ps1 |
    select -expand basename |
    Write-StringArray -VariableName FunctionsToExport -ExcludeDollarSign |
    Format-WrapText -Width 80 |
    set-clipboard
#>

    FunctionsToExport = @( 'Add-FileAttribute', 'Compare-ObjectProperty',
        'Compare-ObjectSetComplement', 'Compare-ObjectSetDifference',
        'Compare-ObjectSetIntersection', 'Compare-ObjectSetUnion',
        'Compare-PSGalleryObject', 'Convert-HexToRGB', 'Convert-Int32ToUint32',
        'Convert-Int64ToText', 'Convert-Int64ToUint64', 'Convert-ObjectToHashtable',
        'Convert-RGBToHex', 'Convert-SecureStringToString', 'Convert-UserFlag',
        'ConvertFrom-Base64', 'ConvertFrom-Binary', 'ConvertFrom-DateTime',
        'ConvertFrom-FsRight', 'ConvertFrom-Hex', 'ConvertFrom-HexString',
        'ConvertFrom-HtmlEncode', 'ConvertFrom-RomanNumeral', 'ConvertFrom-UrlEncode',
        'ConvertFrom-UTC', 'ConvertFrom-Xml', 'ConvertTo-Base64', 'ConvertTo-Binary',
        'ConvertTo-BinaryIPv4', 'ConvertTo-Bool', 'ConvertTo-DateTime',
        'ConvertTo-DecimalIPv4', 'ConvertTo-DottedDecimalIPv4', 'ConvertTo-Hex',
        'ConvertTo-HexString', 'ConvertTo-HtmlEncode', 'ConvertTo-OrderedDictionary',
        'ConvertTo-PFEscape', 'ConvertTo-RomanNumeral', 'ConvertTo-UncPath',
        'ConvertTo-UrlEncode', 'ConvertTo-UTC', 'Copy-Object', 'Expand-IPv6',
        'Expand-String', 'Expand-Tab', 'Export-CSVSortedColumn', 'Export-FontSample',
        'FileSizeAbove', 'FileSizeBelow', 'Format-MacAddress', 'Format-RandomCase',
        'Format-ReverseString', 'Format-ReverseToken', 'Format-SortedList',
        'Format-TitleCase', 'Format-WrapText', 'Get-AppEventSound', 'Get-ArpTable',
        'Get-Assoc', 'Get-AutoRun.inf', 'Get-BashPath', 'Get-BinaryType',
        'Get-CeasarCipher', 'Get-ComputerSite', 'Get-ComputerUptime',
        'Get-ConsoleColor', 'Get-ConsoleWindowSize', 'Get-DaysOfWeek',
        'Get-Desktop.ini', 'Get-DiceRoll', 'Get-DiskType', 'Get-DisplayBrightness',
        'Get-DNSHostEntryAsync', 'Get-DriveStat', 'Get-DuplicateFileName', 'Get-Enum',
        'Get-ErrorInfo', 'Get-ExecutableForFile', 'Get-Factorial', 'Get-FileEncoding',
        'Get-FileName', 'Get-FileSizeOnDisk', 'Get-FileWithLeadingSpace',
        'Get-FolderName', 'Get-Font', 'Get-Fortune', 'Get-FsRight', 'Get-Ftype',
        'Get-InvalidFileCharacter', 'Get-IpRange', 'Get-IpV4Network',
        'Get-LastDayInMonth', 'Get-List', 'Get-LongName', 'Get-MachineType',
        'Get-MacVendor', 'Get-Magic8Ball', 'Get-Months', 'Get-MyLocalLogonTime',
        'Get-NamedColor', 'Get-NetworkCredential', 'Get-NTFSPermission', 'Get-NtpDate',
        'Get-Power', 'Get-PrintableAscii', 'Get-PrivateProfileComment',
        'Get-PrivateProfileSection', 'Get-PrivateProfileSectionNames',
        'Get-PrivateProfileString', 'Get-ProcessUser', 'Get-PSWho', 'Get-RandomDate',
        'Get-RandomHexDigit', 'Get-RandomMacAddress', 'Get-RebootHistory',
        'Get-RegExpandString', 'Get-RegistryValue', 'Get-RelativePath', 'Get-Round',
        'Get-SaveFileName', 'Get-ScheduledTaskUser', 'Get-ServiceUser', 'Get-Shortcut',
        'Get-ShortName', 'Get-SID', 'Get-SpeakerVolume', 'Get-SpecialFolder',
        'Get-SqlDatabase', 'Get-SqlIndexFragmentation', 'Get-SqlStoredProcedure',
        'Get-StaticProperty', 'Get-String', 'Get-StringHash', 'Get-SubnetMaskIPv4',
        'Get-TruncatedDate', 'Get-Type', 'Get-TypeAccelerator', 'Get-UrlContent',
        'Get-VssVolume', 'Get-VssWriter', 'Get-VssWriterToService', 'Get-WordCount',
        'Get-WordList', 'grep', 'Invoke-Beep', 'Invoke-CountdownTimer',
        'Invoke-SoundPlayer', 'Invoke-Speak', 'Join-Object', 'Lock-Workstation',
        'Measure-Char', 'Merge-Object', 'mklink', 'Move-ToRecycleBin',
        'New-ColorPicker', 'New-Credential', 'New-DatePicker', 'New-FontPicker',
        'New-InputBox', 'New-InputBoxSecureString', 'New-MailToURI', 'New-MessageBox',
        'New-PFDateFormat', 'New-QR', 'New-QRCode', 'New-RandomPassword',
        'New-Screenshot', 'New-Shortcut', 'New-SmsUri', 'New-TelephoneUri',
        'New-TemporaryFileWithExtension', 'New-VirtualHardDisk', 'New-WifiUri',
        'Optimize-SqlIndexFragmentation', 'Optimize-SqlStoredProcedure',
        'Out-PDFToPrinter', 'Read-HostPause', 'Read-HostWithDefault',
        'Remove-BlankOrComment', 'Remove-EmptyProperty', 'Remove-FileAttribute',
        'Remove-QuotesFromCsv', 'Remove-TeamsCache', 'Remove-Trailing',
        'Reset-Desktop', 'Resolve-FQDN', 'Resolve-HostName', 'Resolve-PathForce',
        'sed', 'Set-AutoRun.inf', 'Set-Capslock', 'Set-Desktop.ini', 'Set-Display',
        'Set-EOLTerminator', 'Set-FileEncoding', 'Set-Numlock',
        'Set-PrivateProfileComment', 'Set-PrivateProfileString', 'Set-Scrolllock',
        'Set-SpeakerMute', 'Set-SpeakerVolume', 'Set-Type', 'Set-WindowState',
        'Set-WindowStyle', 'Show-Calendar', 'Show-FileAttribute', 'Show-Object',
        'Show-Progress', 'Show-SubnetMaskIPv4', 'Show-Timezone', 'Split-CanonicalName',
        'Split-DistinguishedName', 'Split-Line', 'Start-ADReplication',
        'Start-RecordSession', 'Stop-RecordSession', 'Switch-Mute',
        'Test-ConnectionAsync', 'Test-CSVFormat', 'Test-IsAdmin', 'Test-IsCapsLock',
        'Test-IsDate', 'Test-IsFileLocked', 'Test-IsHexString', 'Test-IsLocalIPv4',
        'Test-IsNull', 'Test-IsNumeric', 'Test-IsNumLock', 'Test-IsScrollLock',
        'Test-IsSpeakerMute', 'Test-IsValidEmailAddress', 'Test-IsValidIPv4',
        'Test-IsValidIPv6', 'Test-MultipleBool', 'Test-Network', 'Test-NtpDateVsNow',
        'Test-Password', 'Test-PasswordComplexity', 'Test-Port', 'Test-Set',
        'Update-ExplorerIcon', 'Use-Stopwatch', 'Write-SelectStatement',
        'Write-StringArray', 'Write-StringHash', 'Write-TextMenu' )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    #CmdletsToExport = '*'

    # Variables to export from this module
    #VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    # AliasesToExport   = '*'

    <#
    To recreate:

    $regex = "\[alias\('(.+)'\)]"
    sls -pattern FunctionAlias .\Functions\*.ps1 | foreach-object {
        if ($_ -match $regex) {
            $matches[1]
        }
    } | sort-object |
    Write-StringArray -VariableName AliasesToExport -ExcludeDollarSign |
    Format-WrapText -width 80 | set-clipboard
#>

    AliasesToExport   = @( 'Base64Decode', 'Base64Encode', 'Beep',
        'Convert-IntToText', 'Convert-ROT13', 'ConvertTo-BinaryIP',
        'ConvertTo-DecimalIP', 'ConvertTo-DottedDecimalIP', 'CountdownTimer',
        'Fortune', 'Get-DupeFileName', 'Get-Folder', 'Get-LastReboot', 'Get-SaveFile',
        'Get-SubnetMaskIP', 'Get-VssadminListVolumes', 'Get-VssadminListWriters',
        'Parse-Bool', 'Recycle', 'ReverseString', 'Set-Speaker', 'Show-Color',
        'Show-DaysOfWeek', 'Show-InvalidFileCharacter', 'ShowMonth', 'Show-NamedColor',
        'Show-SpecialFolder', 'Show-SubnetMaskIP', 'Show-TypeAccelerator', 'Speak',
        'Test-IsLocalIP', 'Test-IsValidIP', 'Test-MultiBool', 'Union-Object',
        'UrlDecode', 'UrlEncode', 'WrapText' )

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @( 'base64', 'beep', 'binaryip', 'calendar', 'capslock', 'color-hex',
                'color-rgb', 'color-show', 'computersite', 'computer-site', 'credential',
                'date-random', 'datetime', 'date-truncate', 'days-week', 'decimalip',
                'display', 'dns-async', 'dotteddecimalip', 'email-address', 'expand-string',
                'expand-tab', 'exponentiation', 'file', 'file-encoding', 'file-invalidchar',
                'folder', 'format', 'functions', 'gui', 'ini', 'inputbox', 'ip', 'iprange',
                'isadmin', 'isdate', 'ishexstring', 'isnumeric', 'isvalidemail', 'isvalidip',
                'library', 'macaddress', 'magic8ball', 'markdown', 'msgbox',
                'numlock', 'ping-async', 'popup', 'progress', 'random-date', 'registry',
                'reverse-string', 'rot13', 'round', 'savefile', 'scrolllock', 'set-type',
                'share-permission', 'share-stat', 'shortcut', 'sid', 'speak', 'subnetmask',
                'system', 'timezone', 'urlencode', 'utc', 'wrap-text', 'xml' )


            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/riedyw/PoshFunctions/blob/master/Resources/License.txt'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/riedyw/PoshFunctions'

            # A URL to an icon representing this module.
            IconUri      = 'https://github.com/riedyw/PoshFunctions/blob/master/Resources/PoshFunctions.png'

            # ReleaseNotes of this module
            ReleaseNotes = @'
For full release notes see .\Resources\ReleaseNotes.txt
### 2.2.12
* added about_PoshFunctions for an overview of the module
* updated PoshFunctions.psm1 - added $Script:IconFile variable
* updated Wisdom.txt - minor grammatical mistakes
* added ConvertTo-PFEscape - some of the New-*Uri functions needed to be able to escape strings in a special way
* added Get-SpeakerVolume - wanted to be able to determine what the current volume of the speakers are
* added Get-VssWriterToService - VSS writers are managed by a particular service and this corresponds the two
* added New-MailToURI - used to create properly formatted string to generate a QR code to begin composing an email
* added New-SmsUri - used to create properly formatted string to generate a QR code to compose a text message
* added New-TelephoneUri - used to create properly formatted string to generate a QR code to begin calling a number
* added New-TemporaryFileWithExtension - extend functionality of New-TemporaryFile so that a custom extension can be used
* added New-WifiUri - used to create properly formatted string to generate a QR code to join a particular SSID
* added Remove-OldFiles - given a path, a filespec, and a count it will search that path for the filespec and keep the latest count of files that match
* added Set-SpeakerMute - using API based function
* added Test-IsSpeakerMute - using API based function
* deleted Show-ConsoleColor - incorporated into Get-ConsoleColor
* deleted Show-ConsoleColorWithBackground - incorporated into Get-ConsoleColor
* deleted Show-ShortDaysOfWeek - incorporated into Get-DaysOfWeek with -Short parameter
* deleted Show-ShortMonth - incorporated into Get-Months with -Short parameter
* deleted Show-SubnetMaskIPv4 - incorporated into Get-SubnetMaskIPv4 with -All parameter
* deleted Show-Timezone - no longer needed with Get-TimeZone from Microsoft.PowerShell.Management
* renamed Get-DaysOfWeek - from Show-DaysOfWeek, also incorporated -Short parameter so that this incorporates both functions
* renamed Get-Months - from Show-Month, also incorporated -Short parameter so that this incorporates both functions
* renamed Get-VssVolume - Original name 'Get-VssadminListVolumes', aliased to 'Get-VssadminListVolumes'
* renamed Get-VssWriter - Original name 'Get-VssadminListWriters', aliased to 'Get-VssadminListWriters'
* renamed Show-ColorWithBackground - from original name Show-ColorsWithBackground, aliased to Show-ColorsWithBackground. Be more Powershell-y
* renamed Show-ConsoleColor - from original name Show-AllColor, aliased to Show-AllColor
* rewrote New-QRCode - previous version relied on Google service no longer available, using a new service now, parameters changed
* rewrote Set-SpeakerVolume - to use API based function and not SendKeys
* updated Get-ComputerUptime - added credential to New-CimSession
* updated Get-ConsoleColor - incorporated -Show and -ShowWithBackground parameters
* updated Get-DisplayBrightness - using more standard -IncludeInput parameter
* updated Get-Enum - changed logic from adding to array with += to using [System.Collections.ArrayList] and .Add method
* updated Get-Font - updated comment help to indicate that it captures the state of fonts when the Powershell session initiated
* updated Get-Fortune - updated comment help and clarified a few things
* updated Get-IpRange - changed logic from adding to array with += to using [System.Collections.ArrayList] and .Add method
* updated Get-SubnetMaskIPv4 - added -All parameter, used parameter set names, defined default parameter set name, made subnet mask first property in output
* updated Get-Type - changed logic from adding to array with += to using [System.Collections.ArrayList] and .Add method
* updated Get-TypeAccelerator - changed logic from adding to array with += to using [System.Collections.ArrayList] and .Add method
* updated New-ColorPicker - changed how the icon is set
* updated New-DatePicker - changed how the icon is set
* updated New-FontPicker - changed how the icon is set
* updated New-InputBoxSecureString - added switch parameter to allow for string output as opposed to secure string output, changed how icon set
* updated New-MessageBox - corrected validation set for -Defaultbutton parameter
* updated New-ScreenShot - added note in comment help that it may trigger anti-malware software
* updated New-VirtualHardDisk - updated comment help, removed unused variables
* updated Set-SpeakerVolume - use defined class to directly set the volume
* updated Start-ADReplication - made $Name optional and defaults to $env:COMPUTERNAME
* updated Test-IsScrollLock - updated comment help
* updated Test-Network - altered logic so that it returns an array even if returning 0 or 1 item

### 2.2.11
* added format files for result sets containing more than 4 columns
* added Pester test file templates for functions. Only a handful have been populated with real tests. This will be coming in future release
* updated .\Resources\WordList.txt and removed over 200 offensive words
* added Add-FileAttribute - to manipulate 'ReadOnly', 'Hidden', 'System', 'Archive' file attributes
* added Convert-Int64ToUint64 - to properly return Reg_QWord values from the registry
* added Get-AutoRun.inf - to get the values from the hidden/system file found at the root of a drive letter: icon and label
* added Get-Desktop.ini - to get the values from the hidden/system file found in a folder: folder type, infotip (hover info), icon
* added Get-RebootHistory - to return a history of reboots, includes custom type for formatting
* added New-VirtualHardDisk - to create local .vhd, need to run at elevated prompt
* added Read-HostPause - to mimic the PAUSE command in cmd.exe where you only need to press a key to continue, not just the Enter key
* added Remove-FileAttribute - to manipulate 'ReadOnly', 'Hidden', 'System', 'Archive' file attributes
* added Resolve-PathForce - returns explicit path to single file/folder even if it doesn't exist
* added Set-AutoRun.inf - to set the values from the hidden/system file found at the root of a drive letter: icon and label
* added Set-Desktop.ini - to set the values from the hidden/system file found in a folder: folder type, infotip (hover info), icon
* added Set-FileAttribute - to manipulate 'ReadOnly', 'Hidden', 'System', 'Archive' file attributes
* removed Eexit - really belongs in the $profile of my computer and not here
* renamed Get-FsRight - from original Show-FsRight, provided alias as Show-FsRight, changed += to ArrayList, left justify name
* renamed Get-NamedColor - from original name Show-NamedColor to be more in line with PowerShell standards, added -Full parameter and formatting
* updated Convert-HexToRGB - changed delimiter from ',' to ', ' so exports to CSV are read properly by Excel
* updated ConvertFrom-FsRight - changed reference from Show-FsRight to Get-FsRight
* updated ConvertTo-Hex - changed hex value to be upper case to conform more with standard representation
* updated Expand-IPv6 - added 'ERROR: ' to beginning of throw statement
* updated Expand-Tab - changed $InputString to position 0, also value from pipeline by name
* updated Export-FontSample - changed to use System.Collections.Arraylist, default $Path to (Join-Path -Path $env:TEMP -ChildPath 'FontSample.htm'), no longer HTML tokenizing -Text
* updated Get-Assoc - added /d argument to cmd.exe to bypass any AutoRun setting in registry
* updated Get-ConsoleColor - alignment was right justified, fixed by converting color enum ToString()
* updated Get-DriveState - to use custom types for formatting
* updated Get-ExecutableForFile - to resolve path names to explicit path if passed a relative one
* updated Get-FType - added /d argument to cmd.exe to bypass any AutoRun setting in registry
* updated Get-IPv4Network - corrected comment help, set default for subnet mask
* updated Get-LongName - added 'ERROR: ' to beginning of throw statement
* updated Get-NamedColor - addressed issue with named colors not appearing
* updated Get-PrintableAscii - to use custom type for formatting
* updated Get-RegExpandString - added 'ERROR: ' to beginning of throw statement
* updated Get-RegistryValue - changed when retrieving DWord value performs Convert-Int32ToUint32 on the returned value, calling subfunctions with -Verbose:$false, minor typos
* updated Get-ShortName - added 'ERROR: ' to beginning of throw statement
* updated Get-VssAdminListWriters - to use custom type for formatting
* updated Get-WordCount - changed property names, sorted by frequency descending, then word ascending
* updated New-MessageBox - fixed issue with -AsString and a timeout not reporting correctly
* updated New-RandomPassword - added NumeralCount and SymbolCount parameters to increase complexity
* updated New-Screenshot - added 'ERROR: ' to beginning of throw statement
* updated New-Shortcut - resolved path to .lnk as it must be explicit path, used resolve-pathforce to resolve non-existent file
* updated Set-PrivateProfileComment - change += to System.Collections.Arraylist, changed positional parameters
* updated Split-CanonicalName - added alias of CN to CanonicalName
* updated Split-DistinguishedName - added alias of DN to DistinguishedName
* updated Write-StringHash - change += to System.Collections.Arraylist for $ReturnVal
* updated Write-TextMnu - changed temporary file handling, fixed options passed from pipeline problem, using Set-Clipboard vs clip.exe, padded menu selection option to 2 characters

### 2.2.10
* added Get-AppEventsSound - determines sounds configured for Windows events
* added Get-ConsoleWindowSize - returns both the window size and buffer size of current console window
* added Get-DiskType - returns the type of disk and type of bus for a given computer(s) local disk(s)
* added Get-FileSizeOnDisk - returns actual disk usage when NTFS compression is enabled for file(s)
* added Get-IpV4Network - to determine network given IP address and subnet mask
* added Get-StringHash - to send a string, or array of strings through a hashing function
* added Set-EOLTerminator - to convert a text file to either Unix, Mac, or Windows EOL characters
* added Set-FileEncoding - to set the file encoding on a text file
* added Set-WindowState - to minimize/maximize a window
* added Test-CSVFormat - determine if number of fields match header row
* removed Get-MD5Sum - functionality already present in Get-FileHash available in Microsoft.PowerShell.Utility module
* updated ConvertFrom-Base64 - added $EncodingType to provide support for Ascii, UTF32, etc. encoding
* updated ConvertTo-Base64 - added $EncodingType to provide support for Ascii, UTF32, etc. encoding
* updated Get-CaesarCipher - to allow negative rotation
* updated Get-FileEncoding - allow processing of multiple files, output now shows both encoding and fullname of file
* updated Get-PrivateProfileSection - fixed error when ini value contains a backslash '\'
* updated Get-SqlIndexFragmentation - removed indentation on SQL here string
* updated Invoke-Beep - added Start-Sleep in -StarWars section
* updated Invoke-SoundPlayer - performed a .Dispose() as part of cleanup
* updated New-InputBoxSecureString - correct equality test to be case sensitive
'@

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = False

            # External dependent modules of this module
            # ExternalModuleDependencies = ''

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}
