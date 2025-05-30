﻿function Get-WFForm
{
<#
	.SYNOPSIS
		Function to retrieve information about the a Form
	
	.DESCRIPTION
		Function to retrieve information about the a Form
	
	.PARAMETER Form
		Specifies the Form
	
	.PARAMETER Controls
		Specifies that you want to see all the controls in the form
	
	.PARAMETER TabIndex
		Specifies that you want to see the tab index
	
	.PARAMETER Text
		Specifies that you want to see the Title of the form
	
	.NOTES
		Author: Francois-Xavier Cat
		Twitter:@LazyWinAdm
		WWW: 	lazywinadmin.com
		github.com/lazywinadmin
#>
	
	[CmdletBinding()]
	param
	(
		[System.Windows.Forms.Form]$form,
		
		[switch]$Controls,
		
		[switch]$TabIndex,
		
		[Alias('Title')]
		[switch]$Text
	)
	
	BEGIN
	{
		Add-Type -AssemblyName System.Windows.Forms
	}
	PROCESS
	{
		IF ($PSBoundParameters["Controls"])
		{
			$form.Controls
		}
		IF ($PSBoundParameters["TabIndex"])
		{
			$form.TabIndex
		}
		IF ($PSBoundParameters["Text"])
		{
			$form.Text
		}
	} #PROCESS
}