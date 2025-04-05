# Setup
# Allow Scripts unsigned-local signed-internet
set-executionpolicy remotesigned

# Commands
$PSVersionTable.PSVersion
Get-Command -CommandTyper Cmdlet > G:\PowershellCommands.txt

# Types
# (Object) Boolean, Int, Float, String
# $Bob = returned Object
$Bob = "Robert"
$Bob
$Bob.GetType()
# System.Array
$Dave = @("Zero","One", "Two", "Three")
$Dave
$Dave.GetType() # Object[] BaseType = System.Array
$Dave[1] = "Twos"
$Dave[5] = "Allowed"
$Dave.Length()
$Dave[5]
# Key Value pairs
$Charlie = @{key0 = "Zero"; key1 = "One"; key2 = "Two"; key3 = "Three"}
$Charlie.Add("key4", "Four")
$Charlie.Set_Item("key4", "Foures")

# Collect all Cmdlets to a text file
Get-Command -CommandTyper Cmdlet > G:\PowershellCommands.txt

# View unique properties
$Bob | Select-Object

# View all properties
Get-Member -InputObject $Bob

Write-Host '.\PS Quick Reference XXXXX.ps1'
$Frank = Read-Host '.\Dev Env NN Setup Win.ps1'
$Frank

# More commands
switch ($Bob) {
    "Ian" { Write-Host "Ian is here"}
    "Bob" { Write-Host "Bob is your uncle."}
    condition {  }
    Default {}
}

for ($i = 0; $i -lt $array.Count; $i++) {
    F
}
for( $counter =0; $counter -le 5; $counter++) {
    # stmt
}

foreach ($item in $Charlie) {
    # stmt
}

while ($counter -ne 0)  {

}

do {
    # stmt
} while (
     # condition
     $true
)

# function Verb-ThisObject {
#     # [CmdletBinding]
#     # # Parameter help description
#     # # ? [Parameter(AttributeValues)]
#     # [Parameter(Mandatory)]
#     # [ParameterType] #int32
#     # $ParameterName #verbCount

#     # Write-Error -Message "Error occured" -ErrorAction Ignore
# }

# Exceptions
Throw "text"
Write-Error -Message "Error occured" -ErrorAction Ignore
try { Verb-Object -ErrorAction Stop } catch {
    Write-Output "Oops" Write-Output $_
}

# File System
New-Item -Path C:\Test -Name "PowerShellTest" -ItemType Directory
New-Item -Path C:\Test\PowerShellTest -Name "PowerShellTest Text.txt" -ItemType File
Copy-Item -Path "C:\Test\PowerShellTest\PowerShellTest Text.txt" -Destination "C:\Test\PowerShellTest\PowerShellTest Text COPY.txt"
Move-Item -Path "x" -Destination "y"
Rename-Item -Path "C:\Test\PowerShellTest\PowerShellTest Text COPY.txt" -NewName "Old Test Text"
Remove-Item -Path "x" -Filter "y"
Test-Path "C:\Test\PowerShellTest\PowerShellTest Text COPY.txt"
# cat ls

# Modules
Import-Module Microsoft.PowerShell.LocalAccounts

# ActiveDirectory
Import-Module ActiveDirectory
New-AdUser "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
Set-AdUser ""
Get-AdUser ""
Add-AdGroupMember -Identity "Group" -Members "Member"
Remove-AdGroupMember -Identity "Group" -Members "Member"
