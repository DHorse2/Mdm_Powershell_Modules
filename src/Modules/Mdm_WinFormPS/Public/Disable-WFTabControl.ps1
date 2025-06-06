﻿function Disable-WFTabControl
{
<#
	.SYNOPSIS
		This function will disable a tab control
	
	.DESCRIPTION
		A detailed description of the Disable-WFTabControl function.
	
	.PARAMETER TabControl
		Specifies the TabControl control to disable
	
	.EXAMPLE
		Disable-WFTabControl -TabControl $tabControls
	
	.NOTES
		Francois-Xavier Cat
		@lazywinadm
		www.lazywinadmin.com
		github.com/lazywinadmin
#>
	
	[CmdletBinding(SupportsShouldProcess = $true)]
	param
	(
		[Parameter(Mandatory = $true)]
		[ValidateNotNull()]
		[System.Windows.Forms.TabControl]$tabControls
	)
	
	BEGIN
	{
		Add-Type -AssemblyName System.Windows.Forms
	}
	PROCESS
	{
		IF ($PSCmdlet.ShouldProcess($tabControls, "Disable the TabControl control"))
		{
			$tabControls.Enabled = $false
		}
	}
} #Disable-TabControl