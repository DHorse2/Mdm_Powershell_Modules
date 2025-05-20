function Set-WFForm
{
<#
	.SYNOPSIS
		The Set-WFForm function is used to change the properties of a Form or to intract with it
	
	.DESCRIPTION
		The Set-WFForm function is used to change the properties of a Form or to intract with it
	
	.PARAMETER Form
		Specifies the Form control
	
	.PARAMETER Text
		Specifies the text/Title of the form
	
	.PARAMETER WindowState
		Set the Window State of the form.
	
	.PARAMETER BringToFront
		Bring the form to the front of the screen
	
	.EXAMPLE
		PS C:\> Set-WFForm -Form $form1 -BringToFront
	
	.EXAMPLE
		PS C:\> Set-WFForm -Form $form1 -Text "My GUI"
	
	.EXAMPLE
		PS C:\> Set-WFForm -Form $form1 -WindowState "Minimized"
	
	.NOTES
		Author: Francois-Xavier Cat
		Twitter:@LazyWinAdm
		www.lazywinadmin.com
		github.com/lazywinadmin
#>
	
	[CmdletBinding(SupportsShouldProcess = $true)]
	param
	(
		[System.Windows.Forms.Form]$form,
		
		[Alias('Title')]
		[string]$Text = "Hello World",
		
		[ValidateSet('Maximized', 'Minimized', 'Normal')]
		[string]$WindowState,
		
		[switch]$BringToFront
	)
	
	BEGIN
	{
		Add-Type -AssemblyName System.Windows.Forms
	}
	PROCESS
	{
		IF ($PSBoundParameters["Text"])
		{
			IF ($PSCmdlet.ShouldProcess($form, "Set the Title"))
			{
				$form.Text = $Text
			}
		}
		IF ($PSBoundParameters["WindowState"])
		{
			IF ($PSCmdlet.ShouldProcess($form, "Set Windows State to $WindowState"))
			{
				$form.WindowState = $WindowState
			}
		}
		IF ($PSBoundParameters["BringToFront"])
		{
			IF ($PSCmdlet.ShouldProcess($form, "Bring the Form to the front of the screen"))
			{
				$form.BringToFront()
			}
		}
	} #PROCESS
}