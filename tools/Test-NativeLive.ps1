[CmdletBinding()]
param([string]$RainmeterIni)
$ErrorActionPreference='Stop'
if(-not $RainmeterIni){$RainmeterIni=Join-Path $env:APPDATA 'Rainmeter\Rainmeter.ini'}
$line=Select-String -LiteralPath $RainmeterIni -Pattern '^SkinPath=(.+)$' | Select-Object -First 1
if(-not $line){throw 'No verified SkinPath.'}
$stateDir=Join-Path $line.Matches[0].Groups[1].Value.Trim() 'NOXUN AI Usage DEMO\@Resources\State'
. (Join-Path (Split-Path $PSScriptRoot -Parent) 'skin\@Resources\Adapter\Normalize.ps1')
$sender=Join-Path $PSScriptRoot 'Send-DemoCommand.ps1'
$script:passed=0
function Check([bool]$Value,[string]$Name){if(-not $Value){throw ('FAIL '+$Name)};$script:passed++;Write-Output ('PASS '+$Name)}
function Inspect {
  & $sender -Action Lua -LuaCommand 'CaptureState()'
  Start-Sleep -Milliseconds 150
  $s=@{};foreach($line in Get-Content -LiteralPath (Join-Path $stateDir 'inspection.txt')){$pair=$line.Split('=',2);if($pair.Count -eq 2){$s[$pair[0]]=$pair[1]}}
  return $s
}
$original=Inspect
if($original.mode -ne 'LIVE'){throw 'Load LIVE before this read-only data test.'}
try {
  & $sender -Action Lua -LuaCommand 'Close()'
  $s=Inspect;$snapshot=Read-Snapshot (Join-Path $stateDir 'snapshot.txt')
  Check ($s['ui.Drag.empty'] -eq 'true') 'LIVE drag area has no helper label'
  foreach($meter in @('ScaleButton','Scenario','Previous','Next','TestEvent','codexSubtitle','claudeSubtitle')){
    Check ($s['ui.'+$meter+'.hidden'] -eq '1') ('LIVE hides helper meter '+$meter)
  }
  Check ($snapshot['codex.status'] -eq 'ok') 'Actual Codex export succeeded'
  Check ($s['codex.weekly.used'] -eq $snapshot['codex.weekly.used']) 'Native weekly equals exported weekly snapshot'
  Check ($s['codex.weekly.reset'] -eq $snapshot['codex.weekly.reset_at']) 'Native reset equals zoned export reset'
  Check ($s['codex.session.availability'] -eq $snapshot['codex.session.availability']) 'Native optional session matches availability'
  Check ($s['codex.weekly.quality'] -eq 'unknown' -or $s['codex.weekly.quality'] -eq 'stale') 'Codex unknown measurement age is disclosed'
  if($snapshot['claude.status'] -eq 'authentication'){
    Check ($s['claude.weekly.used'] -eq 'unknown' -or $s['claude.weekly.quality'] -eq 'error') 'Actual Claude authentication error never fabricates zero'
  }
  $before=$s['codex.weekly.used'];$announcements=$s.announcements
  if($snapshot['claude.status'] -eq 'ok'){
    Check ($s['claude.weekly.used'] -eq $snapshot['claude.weekly.used']) 'Native Claude weekly equals successful export'
    Check ($s['claude.weekly.reset'] -eq $snapshot['claude.weekly.reset_at']) 'Native Claude reset equals successful export'
    Check ($s['claude.session.availability'] -eq $snapshot['claude.session.availability']) 'Native Claude session matches availability'
  }
  & $sender -Action Lua -LuaCommand "LoadScenario('zero')"
  & $sender -Action Lua -LuaCommand 'TestEvent()'
  $s=Inspect
  Check ($s.scenario -eq 'live' -and $s['codex.weekly.used'] -eq $before) 'DEMO scenario commands cannot replace LIVE values'
  Check ($s.announcements -eq $announcements -and $s.event_unread -eq 'false') 'DEMO TEST cannot create a LIVE announcement'
  $hash=(Get-FileHash -LiteralPath (Join-Path $stateDir 'snapshot.txt')).Hash
  foreach($scale in @(1,1.5)){
    & $sender -Action Lua -LuaCommand ('SetScale('+$scale.ToString([Globalization.CultureInfo]::InvariantCulture)+')')
    & $sender -Action Lua -LuaCommand "Toggle('codex')"
    $s=Inspect
    Check ($s.active -eq 'codex' -and [double]$s['window.w'] -eq 376*$scale) ('LIVE detail at scale '+$scale)
    & $sender -Action Lua -LuaCommand "Toggle('claude')"
    $s=Inspect;Check ($s.active -eq 'claude') ('LIVE Claude detail switch at scale '+$scale)
    Check ($s['ui.DetailSubheading.hidden'] -eq '1') ('LIVE detail hides technical mode label at scale '+$scale)
    & $sender -Action Lua -LuaCommand 'Close()'
    $s=Inspect;Check ([double]$s['window.h'] -eq 236*$scale) ('LIVE close shrinks window at scale '+$scale)
  }
  # A scheduled refresh may legitimately occur; this check is meaningful only
  # when the next due time lies outside this short interaction sequence.
  if([long]$snapshot['codex.next_at'] -gt [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()+5 -and
     [long]$snapshot['claude.next_at'] -gt [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()+5){
    Check ((Get-FileHash -LiteralPath (Join-Path $stateDir 'snapshot.txt')).Hash -eq $hash) 'Clicking and drawing do not collect usage'
  }
} finally {
  & $sender -Action Lua -LuaCommand 'Close()'
  & $sender -Action Lua -LuaCommand ('SetScale('+([double]$original.scale).ToString([Globalization.CultureInfo]::InvariantCulture)+')')
  & $sender -Action Move -X ([int]$original['window.x']) -Y ([int]$original['layout.anchor'])
  if($original.active -in @('codex','claude')){& $sender -Action Lua -LuaCommand ("Toggle('"+$original.active+"')")}
}
Write-Output ('LIVE native controls: '+$script:passed+' PASS, 0 FAIL. Physical mouse and provider account confirmation are separate.')
