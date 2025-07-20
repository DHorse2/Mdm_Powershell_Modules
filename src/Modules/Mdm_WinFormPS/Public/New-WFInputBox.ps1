function New-WFInputBox
{
<#
	.SYNOPSIS
		The New-WFInputBox function will prompt the user for input in a window.
	
	.DESCRIPTION
		The New-WFInputBox function will prompt the user for input in a window.
	
	.PARAMETER Message
		Specifies the question you want to ask to the user.
	
	.PARAMETER Title
		Specifies the title of the window.
	
	.PARAMETER DefaultInputText
		Specifies the default answer text.
	
	.EXAMPLE
		PS C:\> New-WFInputBox -Message 'What is your computer name' -Title 'Computer' -DefaultInputText "$env:ComputerName"
	
	.NOTES
		Author: Francois-Xavier Cat
		Twitter:@LazyWinAdm
		www.lazywinadmin.com
		github.com/lazywinadmin
#>
	
	[CmdletBinding(SupportsShouldProcess = $true)]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Message,
		[Alias('WindowsTitle')]
		[string]$title,
		[Alias('DefaultText')]
		[string]$DefaultInputText
	)
	BEGIN
	{
		TRY
		{
			# Load the Assembly
			Add-Type -AssemblyName Microsoft.VisualBasic -ErrorAction 'Stop' -ErrorVariable ErrorBeginAddType
		}
		CATCH
		{
			Write-Warning -Message "New-WFInputBox: Something wrong happened during assembly loading."
			IF ($ErrorBeginAddType) { Write-Warning -Message "[BEGIN] Error while loading assembly Microsoft.VisualBasic" }
			Add-LogText -IsError -ErrorPSItem $_ -Message $Error[0].Exception.Message
		}
	}
	PROCESS
	{
		if ($PSCmdlet.ShouldProcess("InputBox", "Show a new Input box with the following message: $Message"))
		{
			#[Microsoft.VisualBasic.Interaction]::InputBox($Message, $title, $DefaultInputText, $XPosition, $YPosition)
			Write-output $([Microsoft.VisualBasic.Interaction]::InputBox($Message, $title, $DefaultInputText))
		}
	}
} #New-InputBox