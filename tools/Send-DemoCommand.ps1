[CmdletBinding()]
param(
  [Parameter(Mandatory)][ValidateSet('Activate','Refresh','Deactivate','Lua','Move')][string]$Action,
  [string]$RainmeterExe,[string]$LuaCommand,[int]$X,[int]$Y
)
$ErrorActionPreference='Stop'
if(-not $RainmeterExe){$RainmeterExe=Get-Process -Name Rainmeter -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Path}
if(-not $RainmeterExe -or -not (Test-Path -LiteralPath $RainmeterExe)){throw 'No verified running Rainmeter executable.'}
$config='"NOXUN AI Usage DEMO"'
switch($Action){
  'Activate' {$arguments='!ActivateConfig '+$config+' "DEMO.ini"'}
  'Refresh' {$arguments='!Refresh '+$config}
  'Deactivate' {$arguments='!DeactivateConfig '+$config}
  'Move' {$arguments='!Move '+$X+' '+$Y+' '+$config}
  'Lua' {
    if($LuaCommand -notmatch "^(?:LoadScenario\('[a-zA-Z0-9]+'\)|Toggle\('(?:codex|claude)'\)|Step\(-?1\)|SetScale\((?:1|1\.0|1\.5)\)|(?:CaptureState|RunTests|Close|TestEvent|Acknowledge|ToggleScale)\(\))$"){throw 'Only explicit DEMO control functions are accepted.'}
    $arguments='!CommandMeasure Runtime "'+$LuaCommand+'" '+$config
  }
}
# This child only forwards a scoped bang. Never terminate the desktop instance.
$child=Start-Process -FilePath $RainmeterExe -ArgumentList $arguments -WindowStyle Hidden -PassThru
if(-not $child.WaitForExit(5000)){
  $child.Kill()
  throw 'Rainmeter did not respond within 5 seconds. Only the forwarding child was stopped.'
}
if($child.ExitCode -ne 0){throw ('Rainmeter command failed: '+$child.ExitCode)}
