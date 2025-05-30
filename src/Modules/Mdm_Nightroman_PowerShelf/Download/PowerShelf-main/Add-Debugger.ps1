<#PSScriptInfo
.VERSION 2.5.0
.AUTHOR Roman Kuzmin
.COPYRIGHT (c) Roman Kuzmin
.TAGS Debug
.GUID e187060e-ad39-425c-a6e3-b1e1e92ab59d
.LICENSEURI http://www.apache.org/licenses/LICENSE-2.0
.PROJECTURI https://github.com/nightroman/PowerShelf
#>

<#
.Synopsis
	Debugger for PowerShell hosts with no own debuggers.

.Description
	The script adds or replaces existing debugger in any runspace. It is
	useful for hosts with no own debuggers, e.g. 'Default Host', 'Package
	Manager Host', 'FarHost'. Or it may replace existing debuggers, e.g.
	in "ConsoleHost".

	The script is called at any moment when debugging is needed. To restore
	the original debuggers, invoke Restore-Debugger defined by Add-Debugger.

	Console like hosts include 'ConsoleHost', 'Visual Studio Code Host',
	'Package Manager Host'. They imply using Read-Host and Write-Host by
	default. Other hosts use GUI input box and output file watching.

.Parameter Path
		Specifies the file used for debugger output. A separate console is
		used for watching its tail. Do not let the file to grow too large.
		Invoke `new` when watching gets slower.

		"$env:TEMP\$Environment.log" is used by default.
		The default file is deleted before debugging.

.Parameter Context
		One or two integers, shown line counts before and after the current.

		@(4, 4) is used by default.

.Parameter Environment
		Specifies the environment name for saving the state. It is also used as
		the input box title and the default output file name.

		The saved state includes context line numbers and input box coordinates.
		Environments are saved as "$HOME\.PowerShelf\Add-Debugger.clixml".

		'Add-Debugger' is used by default.

.Parameter ReadGui
		Tells to use GUI input boxes for input.

.Parameter ReadHost
		Tells to use Read-Host or PSReadLine for input.
		PSReadLine should be imported and configured beforehand.

.Parameter WriteHost
		Tells to use Write-Host and Out-Host for debugger output.

.Example
	>
	# How to debug bare runspaces
	$script = {
		Add-Debugger  # add debugger with default options
		Wait-Debugger # use hardcoded or other breakpoints
	}
	$ps = [PowerShell]::Create().AddScript('& $args[0]').AddArgument($script)
	$null = $ps.BeginInvoke()

.Link
	https://github.com/nightroman/PowerShelf
#>

[CmdletBinding(DefaultParameterSetName='Main')]
param(
	[Parameter(Position=0)]
	[string]$Path
	,
	[ValidateCount(1, 2)]
	[ValidateRange(0, 999)]
	[int[]]$Context = @(4, 4)
	,
	[string]$Environment = 'Add-Debugger'
	,
	[switch]$WriteHost
	,
	[Parameter(ParameterSetName='ReadGui', Mandatory=1)]
	[switch]$ReadGui
	,
	[Parameter(ParameterSetName='ReadHost', Mandatory=1)]
	[switch]$ReadHost
)

# All done?
if (Test-Path Variable:\_Debugger) {
	return
}

# Removes and gets debugger handlers.
function global:Remove-Debugger {
	$debugger = [runspace]::DefaultRunspace.Debugger
	$type = [System.Management.Automation.Debugger]
	$e = $type.GetEvent('DebuggerStop')
	$v = $type.GetField('DebuggerStop', ([System.Reflection.BindingFlags]'NonPublic, Instance')).GetValue($debugger)
	if ($v) {
		$handlers = $v.GetInvocationList()
		foreach($handler in $handlers) {
			$e.RemoveEventHandler($debugger, $handler)
		}
		$handlers
	}
}

# Restores original debugger handlers.
function global:Restore-Debugger {
	if (!(Test-Path Variable:\_Debugger)) {
		return
	}
	$null = Remove-Debugger
	if ($_Debugger.Handlers) {
		foreach($handler in $_Debugger.Handlers) {
			[runspace]::DefaultRunspace.Debugger.add_DebuggerStop($handler)
		}
	}
	Remove-Variable _Debugger -Scope Global -Force
}

function global:Read-DebuggerState {
	param($Environment, $Context)

	if ($Environment -and [System.IO.File]::Exists("$HOME\.PowerShelf\Add-Debugger.clixml")) {
		$config = Import-Clixml -LiteralPath "$HOME\.PowerShelf\Add-Debugger.clixml"
		if ($state = $config[$Environment]) {
			return $state
		}
	}

	$n, $m = $Context
	if ($null -eq $m) {
		$m = $n
	}
	@{
		Data = [pscustomobject]@{n=$n; m=$m; x=-1; y=-1}
		Text = ''
	}
}

function global:Save-DebuggerState {
	if (!$_Debugger.Environment) {
		return
	}

	$state = $_Debugger.State
	if ($state.Text -ceq "$($state.Data)") {
		return
	}

	if ([System.IO.File]::Exists("$HOME\.PowerShelf\Add-Debugger.clixml")) {
		$config = Import-Clixml -LiteralPath "$HOME\.PowerShelf\Add-Debugger.clixml"
	}
	else {
		$null = mkdir "$HOME\.PowerShelf" -Force
		$config = @{}
	}

	$state.Text = "$($state.Data)"
	$config[$_Debugger.Environment] = $state
	$config | Export-Clixml -LiteralPath "$HOME\.PowerShelf\Add-Debugger.clixml"
}

### Init debugger data.

$IsConsoleLikeHost = $Host.Name -in ('ConsoleHost', 'Visual Studio Code Host', 'Package Manager Host')

if (!$ReadHost -and !$ReadGui -and $IsConsoleLikeHost) {
	$ReadHost = $true
}

if (!$WriteHost -and !$Path -and $IsConsoleLikeHost) {
	$WriteHost = $true
}

if (!$WriteHost -and !$Path) {
	$Path = "$env:TEMP\$Environment.log"
	[System.IO.File]::Delete($Path)
}
elseif (!$WriteHost) {
	$Path = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)
}
else {
	$Path = $null
}

$null = New-Variable -Name _Debugger -Scope Global -Description Add-Debugger.ps1 -Option ReadOnly -Value @{
	Path = $Path
	Environment = $Environment
	State = Read-DebuggerState $Environment $Context
	Module = $null
	Args = $null
	Watch = $null
	History = [System.Collections.Generic.List[string]]@()
	Handlers = Remove-Debugger
	Action = '?'
	REIndent1 = [regex]'^(\s*)'
	REIndent2 = [regex]'^(\s+)(.*)'
	REContext = [regex]'^\s*(=)?\s*(\d+)\s*(\d+)?\s*$'
	UseAnsi = $PSVersionTable.PSVersion -ge ([Version]'7.2')
	PSReadLine = if ($ReadHost -and (Get-Module PSReadLine)) {Get-PSReadLineOption}
}

### Define debugger output.
if ($Path) {
	function global:Write-Debugger {
		param(data)
		if ($_Debugger.UseAnsi) {
			$OutputRendering = $PSStyle.OutputRendering
			$PSStyle.OutputRendering = 'ANSI'
		}
		data | Out-File -LiteralPath $_Debugger.Path -Encoding utf8 -ErrorAction 0 -Append
		if ($_Debugger.UseAnsi) {
			$PSStyle.OutputRendering = $OutputRendering
		}
		Watch-Debugger
	}
}
else {
	function global:Write-Debugger {
		param(data)
		data | Out-Host
	}
}

### Define debugger input.
if ($ReadHost -and $_Debugger.PSReadLine) {
	function global:Read-Debugger {
		param($Prompt, $Default)
		$_Debugger.q1 = $_Debugger.PSReadLine.HistorySaveStyle
		$_Debugger.PSReadLine.HistorySaveStyle = 'SaveNothing'
		Write-Host "${Prompt}: " -NoNewline
		try {
			PSConsoleHostReadline
		}
		finally {
			$_Debugger.PSReadLine.HistorySaveStyle = $_Debugger.q1
		}
	}
}
elseif ($ReadHost) {
	function global:Read-Debugger {
		param($Prompt, $Default)
		Read-Host $Prompt
	}
}
else {
	function global:Read-Debugger {
		param($Prompt, $Default)
		$title = if ($_Debugger.Environment) {$_Debugger.Environment} else {'Add-Debugger'}
		Read-InputBox $Prompt $title $Default Step Continue $_Debugger.State.Data
		Save-DebuggerState
	}
}

# Gets an input string from a dialog.
function global:Read-InputBox {
	param($Prompt, $Title, $Default, $Text1, $Text2, $state)

	Add-Type -AssemblyName System.Windows.Forms

	$form = New-Object System.Windows.Forms.Form
	$form.Text = $Title
	$form.TopMost = $true
	$form.Size = New-Object System.Drawing.Size(400, 132)
	$form.FormBorderStyle = 'FixedDialog'
	if ($state -and $state.x -ge 0 -and $state.y -ge 0) {
		$form.StartPosition = 'Manual'
		$form.Location = New-Object System.Drawing.Point($state.x, $state.y)
	}
	else {
		$form.StartPosition = 'CenterScreen'
	}

	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10, 10)
	$label.Size = New-Object System.Drawing.Size(380, 20)
	$label.Text = $Prompt
	$form.Controls.Add($label)

	$text = New-Object System.Windows.Forms.TextBox
	$text.Text = $Default
	$text.Location = New-Object System.Drawing.Point(10, 30)
	$text.Size = New-Object System.Drawing.Size(365, 20)
	$form.Controls.Add($text)

	$ok = New-Object System.Windows.Forms.Button
	$ok.Location = New-Object System.Drawing.Point(225, 60)
	$ok.Size = New-Object System.Drawing.Size(75, 23)
	$ok.Text = $Text1
	$ok.DialogResult = 'OK'
	$form.AcceptButton = $ok
	$form.Controls.Add($ok)

	$cancel = New-Object System.Windows.Forms.Button
	$cancel.Location = New-Object System.Drawing.Point(300, 60)
	$cancel.Size = New-Object System.Drawing.Size(75, 23)
	$cancel.Text = $Text2
	$cancel.DialogResult = 'Continue'
	$form.Controls.Add($cancel)

	$form.add_Load({
		$text.Select()
		$form.Activate()
	})

	$result = $form.ShowDialog()

	if ($state) {
		$state.x = [Math]::Max(0, $form.Location.X)
		$state.y = [Math]::Max(0, $form.Location.Y)
	}

	if ($result -eq 'OK') {
	    return $text.Text
	}

	if ($result -eq 'Continue') {
	    return 'continue'
	}

	'quit'
}

# Starts an external file viewer.
function global:Watch-Debugger {
	param([switch]$New)
	if (($exe = $_Debugger.Watch) -and !$exe.HasExited) {
		if ($New) {
			try { $exe.Kill() } catch {}
		}
		else {
			return
		}
	}
	$path = $_Debugger.Path.Replace("'", "''")
	$app = if ($PSVersionTable.PSEdition -eq 'Core' -and (Get-Command pwsh -ErrorAction 0)) {'pwsh'} else {'powershell'}
	$_Debugger.Watch = Start-Process $app "-NoProfile -Command `$Host.UI.RawUI.WindowTitle = 'Debug output'; Get-Content -LiteralPath '$path' -Encoding UTF8 -Wait" -PassThru
}

# Writes the current invocation info.
function global:Write-DebuggerInfo {
	param($InvocationInfo, $state)

	# write position message
	if ($_ = $InvocationInfo.PositionMessage) {
		Write-Debugger ($_.Trim())
	}

	if (!$state.n -and !$state.m) {
		return
	}

	$file = $InvocationInfo.ScriptName
	if (!$file -or !(Test-Path -LiteralPath $file)) {
		return
	}

	# write file lines
	$markIndex = $InvocationInfo.ScriptLineNumber - 1
	Write-DebuggerFile $file ($markIndex - $state.n) ($state.n + 1 + $state.m) $markIndex
}

# Writes the specified file lines.
function global:Write-DebuggerFile {
	param($Path, $LineIndex, $LineCount, $MarkIndex)

	# amend negative start
	if ($LineIndex -lt 0) {
		$LineCount += $LineIndex
		$LineIndex = 0
	}

	# content lines
	$lines = @(Get-Content -LiteralPath $Path -TotalCount ($LineIndex + $LineCount) -Force -ErrorAction 0)

	# leading spaces
	$re = $_Debugger.REIndent1
	$indent = ($lines[$LineIndex .. -1] | .{process{
		$re.Match($_).Groups[1].Value.Replace("`t", '    ').Length
	}} | Measure-Object -Minimum).Minimum

	if ($ansi = $_Debugger.UseAnsi) {
		$sMark = $PSStyle.Bold+$PSStyle.Background.Yellow
		$sLine = $PSStyle.Bold
		$sReset = $PSStyle.Reset
	}

	# write lines with a mark
	Write-Debugger ''
	$re = $_Debugger.REIndent2
	do {
		$line = $lines[$LineIndex]
		if (($m = $re.Match($line)).Success) {
			$line = $m.Groups[1].Value.Replace("`t", '    ').Substring($indent) + $m.Groups[2].Value
		}
		$isMark = $LineIndex -eq $MarkIndex
		if ($isMark -and $ansi) {
			$line = "$sMark{0,3}:$sReset>> $sLine{1}$sReset" -f ($LineIndex + 1), $line
		}
		else {
			$mark = if ($isMark) {'>>'} else {'  '}
			$line = '{0,3}:{1} {2}' -f ($LineIndex + 1), $mark, $line
		}
		Write-Debugger $line
	}
	while(++$LineIndex -lt $lines.Length)
	Write-Debugger ''
}

Add-Type @'
using System;
using System.Management.Automation;
public class AddDebuggerHelpers
{
	public ScriptBlock DebuggerStopProxy;
	public EventHandler<DebuggerStopEventArgs> DebuggerStopHandler { get { return OnDebuggerStop; } }
	void OnDebuggerStop(object sender, DebuggerStopEventArgs e)
	{
		SessionState state = ((EngineIntrinsics)ScriptBlock.Create("$ExecutionContext").Invoke()[0].BaseObject).SessionState;
		state.InvokeCommand.InvokeScript(false, DebuggerStopProxy, null, state.Module, e);
	}
}
'@

### Add DebuggerStop handler.
$AddDebuggerHelpers = New-Object AddDebuggerHelpers
[runspace]::DefaultRunspace.Debugger.add_DebuggerStop($AddDebuggerHelpers.DebuggerStopHandler)
$AddDebuggerHelpers.DebuggerStopProxy = {
	param($_module, $_args)

	# write breakpoints
	if ($_args.Breakpoints) {&{
		Write-Debugger ''
		foreach($bp in $_args.Breakpoints) {
			if ($bp -is [System.Management.Automation.VariableBreakpoint] -and $bp.Variable -eq 'StackTrace') {
				Write-Debugger 'TERMINATING ERROR BREAKPOINT'
			}
			else {
				Write-Debugger "Hit $bp"
			}
		}
	}}

	# write debug location
	Write-DebuggerInfo $_args.InvocationInfo $_Debugger.State.Data
	Write-Debugger ''

	# hide local variables
	$_Debugger.Module = $_module
	$_Debugger.Args = $_args
	Remove-Variable _module, _args -Scope 0

	# REPL
	for() {
		### prompt
		$_Debugger.LastAction = $_Debugger.Action
		$_Debugger.Action = Read-Debugger 'Step (h or ? for help)' $_Debugger.Action
		if ($_Debugger.Action) {
			$_Debugger.Action = $_Debugger.Action.Trim()
		}
		if (${env:Add-Debugger-Action} -and $_Debugger.Action -in ('s', 'StepInto', 'v', 'StepOver', 'o', 'StepOut', 'c', 'Continue', 'd', 'Detach', 'q', 'Quit')) {
			$_Debugger.Action = ${env:Add-Debugger-Action}
		}
		Write-Debugger "[DBG]: $($_Debugger.Action)"

		### repeat
		if ($_Debugger.Action -eq '' -and $_Debugger.LastAction -in ('s', 'StepInto', 'v', 'StepOver')) {
			$_Debugger.Action = $_Debugger.LastAction
			$_Debugger.Args.ResumeAction = if ($_Debugger.Action -in ('s', 'StepInto')) {'StepInto'} else {'StepOver'}
			return
		}

		### Continue
		if ($_Debugger.Action -in ($null, 'c', 'Continue')) {
			$_Debugger.Args.ResumeAction = 'Continue'
			return
		}

		### StepInto
		if ($_Debugger.Action -in ('s', 'StepInto')) {
			$_Debugger.Args.ResumeAction = 'StepInto'
			return
		}

		### StepOver
		if ($_Debugger.Action -in ('v', 'StepOver')) {
			$_Debugger.Args.ResumeAction = 'StepOver'
			return
		}

		### StepOut
		if ($_Debugger.Action -in ('o', 'StepOut')) {
			$_Debugger.Args.ResumeAction = 'StepOut'
			return
		}

		### Quit
		if ($_Debugger.Action -in ('q', 'Quit')) {
			$_Debugger.Args.ResumeAction = 'Stop'
			if (($exe = $_Debugger.Watch) -and !$exe.HasExited) {
				try { $exe.Kill() } catch {}
			}
			return
		}

		### Detach
		if ($_Debugger.Action -in ('d', 'Detach')) {
			if ($_Debugger.Handlers) {
				Write-Debugger 'd, Detach - not supported in this environment.'
				continue
			}

			$_Debugger.Args.ResumeAction = 'Continue'
			Restore-Debugger
			return
		}

		### history
		if ('r' -eq $_Debugger.Action) {
			Write-Debugger $_Debugger.History
			continue
		}

		### stack
		if ('k' -ceq $_Debugger.Action) {
			Write-Debugger (Get-PSCallStack | Format-Table Command, Location, Arguments -AutoSize)
			continue
		}
		if ('K' -ceq $_Debugger.Action) {
			Write-Debugger (Get-PSCallStack | Format-List)
			continue
		}

		### <number>
		if ($_Debugger.REContext.IsMatch($_Debugger.Action)) {
			&{
				$m = $_Debugger.REContext.Match($_Debugger.Action)
				$n1 = [int]$m.Groups[2].Value
				$n2 = [int]$(if ($m.Groups[3].Success) {$m.Groups[3].Value} else {$n1})
				Write-DebuggerInfo $_Debugger.Args.InvocationInfo @{n=$n1; m=$n2}
				if ($m.Groups[1].Success) {
					$_Debugger.State.Data.n = $n1
					$_Debugger.State.Data.m = $n2
					Save-DebuggerState
				}
			}
			continue
		}

		### new
		if ('new' -eq $_Debugger.Action -and $_Debugger.Path) {
			Remove-Item -LiteralPath $_Debugger.Path
			Write-Debugger (Get-Date)
			Watch-Debugger -New
			continue
		}

		### help
		if ($_Debugger.Action -in ('?', 'h')) {
			Write-Debugger (@(
				''
				'  s, StepInto  Step to the next statement into functions, scripts, etc.'
				'  v, StepOver  Step to the next statement over functions, scripts, etc.'
				'  o, StepOut   Step out of the current function, script, etc.'
				'  c, Continue  Continue operation.'
				if (!$_Debugger.Handlers) {
				'  d, Detach    Continue operation and detach the debugger.'
				}
				'  q, Quit      Stop operation and exit the debugger.'
				'  ?, h         Write this help message.'
				'  k            Write call stack (Get-PSCallStack).'
				'  K            Write detailed call stack using Format-List.'
				''
				'  n1 [n2]      Write debug location in context of n lines.'
				'  = n1 [n2]    Set location context preference to n lines.'
				'  k s n1 [n2]  Write source at stack s in context of n lines.'
				''
				'  r            Write last commands invoked on debugging.'
				if ($_Debugger.Path) {
				'  new          Remove output file and start watching new.'
				}
				'  <empty>      Repeat the last command if it was StepInto, StepOver.'
				'  <command>    Invoke any PowerShell <command> and write its output.'
				''
			) -join [System.Environment]::NewLine)
			continue
		}

		### stack s n1 [n2]
		Set-Alias k debug_stack
		function debug_stack([Parameter()][int]$s, $n1, $n2) {
			$stack = @(Get-PSCallStack)
			if ($s -ge $stack.Count) {
				Write-Debugger 'Out of range of the call stack.'
				return
			}
			$stack = $stack[$s]
			if (!($file = $stack.ScriptName)) {
				Write-Debugger 'The caller has no script file.'
				return
			}
			if ($null -eq $n1) {
				$n1 = 5
				$n2 = 5
			}
			else {
				$n1 = [Math]::Max(0, [int]$n1)
				$n2 = [Math]::Max(0, $(if ($null -eq $n2) {$n1} else {[int]$n2}))
			}
			$markIndex = $stack.ScriptLineNumber - 1
			Write-Debugger $file
			Write-DebuggerFile $file ($markIndex - $n1) ($n1 + 1 + $n2) $markIndex
		}

		### invoke command
		$_Debugger.History.Remove($_Debugger.Action)
		$_Debugger.History.Add($_Debugger.Action)
		try {
			$_Debugger.q1 = [scriptblock]::Create($_Debugger.Action)
			$_Debugger.q2 = $global:Error.Count
			if ($_Debugger.Module) {
				$_Debugger.q1 = $_Debugger.Module.NewBoundScriptBlock($_Debugger.q1)
			}
			Write-Debugger (. $_Debugger.q1)
			if ($_Debugger.q2 -ne $global:Error.Count) {
				$_ = $global:Error[0]
				Write-Debugger $(if ($_.InvocationInfo.ScriptName) {$_} else {"ERROR: $_"})
			}
		}
		catch {
			Write-Debugger $(if ($_.InvocationInfo.ScriptName) {$_} else {"ERROR: $_"})
		}
		Write-Debugger ''
	}
}
