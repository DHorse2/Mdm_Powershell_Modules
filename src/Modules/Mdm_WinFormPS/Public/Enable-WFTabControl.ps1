function Enable-WFTabControl
{
<#
	.SYNOPSIS
		This function will enable a TabControl control
	
	.DESCRIPTION
		This function will enable a TabControl control
	
	.PARAMETER TabControl
		Specifies the TabControl Control to enable.
	
	.EXAMPLE
		Enable-WFTabControl -TabControl $tabControls
	
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
		IF ($PSCmdlet.ShouldProcess($tabControls, "Enable the TabControl control"))
		{
			$tabControls.Enabled = $true
		}
	}
}