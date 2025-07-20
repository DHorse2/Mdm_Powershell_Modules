
# Set-WFTabPage
function Set-WFTabPage {
    param (
        [System.Windows.Forms.TabControl]$tabControl,
        [string]$tabPageText
    )
    # Find the TabPage by text and switch to it
    $tabPage = $tabControl.TabPages | Where-Object { $_.Text -eq $tabPageText }
    if ($tabPage) {
        $tabControl.SelectedTab = $tabPage
    } else {
        Write-Verbose "TabPage '$tabPageText' not found."
    }
}