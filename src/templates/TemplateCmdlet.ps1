# Heading
#Requires -Version 7.3
<#
.SYNOPSIS
    A script that performs some task.

.DESCRIPTION
    A detailed description of what the script does.

.PARAMETER InputFile
    The path to the input file.

.PARAMETER OutputFile
    The path to the output file.

.EXAMPLE
    .\\MyScript.ps1 -InputFile C:\\input.txt -OutputFile C:\\output.txt

    Runs the script with the specified input and output files.
#>
param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_})]
    [string]$InputFile,

    [Parameter(Mandatory=$true)]
    [ValidateScript({-not (Test-Path $_)})]
    [string]$OutputFile
)

#region Variables

$ErrorActionPreference = 'Stop'

#endregion

#region Functions
Function Test-ScriptCmdlet
{
[CmdletBinding()]
    param ($Parameter1)
    begin{}
    process{
        # SupportsShouldProcess=$true
    }
    end{}
    clean{}
}

# [CmdletBinding(ConfirmImpact=<String>,
# DefaultParameterSetName=<String>,
# HelpURI=<URI>,
# SupportsPaging=<Boolean>,
# SupportsShouldProcess=<Boolean>,
# PositionalBinding=<Boolean>)]

<#
 .Synopsis
  Displays a visual representation of a calendar.

 .Description
  Displays a visual representation of a calendar. This function supports multiple months
  and lets you highlight specific date ranges or days.

 .Parameter Start
  The first month to display.

 .Parameter End
  The last month to display.

 .Parameter FirstDayOfWeek
  The day of the month on which the week begins.

 .Parameter HighlightDay
  Specific days (numbered) to highlight. Used for date ranges like (25..31).
  Date ranges are specified by the Windows PowerShell range syntax. These dates are
  enclosed in square brackets.

 .Parameter HighlightDate
  Specific days (named) to highlight. These dates are surrounded by asterisks.

 .Example
   # Show a default display of this month.
   Show-Calendar

 .Example
   # Display a date range.
   Show-Calendar -Start "March, 2010" -End "May, 2010"

 .Example
   # Highlight a range of days.
   Show-Calendar -HighlightDay (1..10 + 22) -HighlightDate "2008-12-25"
#>