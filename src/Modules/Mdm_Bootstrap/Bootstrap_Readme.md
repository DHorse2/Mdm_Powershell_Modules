# Language Modes

There is an environment variable "__PSLockDownPolicy" that may need to be set to "8". Mine was set at "4" on a Win 10 Home system.

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment]

__PSLockDownPolicy
FullLanguage = 8 & ConstrainedLanguage = 4.

Remove-Item Env:__PSLockDownPolicy
Set-ExecutionPolicy Unrestricted -Scope CurrentUser
$ExecutionContext.SessionState.LanguageMode = “FullLanguage”

