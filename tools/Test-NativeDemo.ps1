[CmdletBinding()]
param([string]$RainmeterIni,[string]$RainmeterExe)
$ErrorActionPreference='Stop'
if(-not $RainmeterIni){$RainmeterIni=Join-Path $env:APPDATA 'Rainmeter\Rainmeter.ini'}
$skinLine=Select-String -LiteralPath $RainmeterIni -Pattern '^SkinPath=(.+)$' | Select-Object -First 1
if(-not $skinLine){throw 'No verified SkinPath.'}
$stateFile=Join-Path $skinLine.Matches[0].Groups[1].Value.Trim() 'NOXUN AI Usage DEMO\@Resources\State\inspection.txt'
if(-not (Test-Path -LiteralPath $stateFile)){throw 'Load the isolated DEMO first.'}
$sender=Join-Path $PSScriptRoot 'Send-DemoCommand.ps1'
$script:passed=0
function Get-DemoState {
  & $sender -Action Lua -LuaCommand 'CaptureState()' -RainmeterExe $RainmeterExe
  Start-Sleep -Milliseconds 150
  $state=@{}
  foreach($line in Get-Content -LiteralPath $stateFile){$pair=$line.Split('=',2);if($pair.Length -eq 2){$state[$pair[0]]=$pair[1]}}
  return $state
}
function Invoke-Demo([string]$Command){
  & $sender -Action Lua -LuaCommand $Command -RainmeterExe $RainmeterExe
  Start-Sleep -Milliseconds 150
  return Get-DemoState
}
function Assert-Native([bool]$Condition,[string]$Name){
  if(-not $Condition){Write-Output ($s | ConvertTo-Json -Compress);throw ('FAIL '+$Name)}
  $script:passed++;Write-Output ('PASS '+$Name)
}
$original=Get-DemoState
try{
  $s=Invoke-Demo 'Acknowledge()'
  $s=Invoke-Demo 'Close()'
  $s=Invoke-Demo 'SetScale(1)'
  $cases=@(
    @{id='normal';weekly='65';session='unknown';available='absent'},
    @{id='codex5h';weekly='65';session='35';available='present'},
    @{id='codex5hzero';weekly='65';session='0';available='present'},
    @{id='zero';weekly='0';session='0';available='present'},
    @{id='quarter';weekly='25';session='25';available='present'},
    @{id='half';weekly='50';session='50';available='present'},
    @{id='full';weekly='100';session='100';available='present'},
    @{id='weeklyMissing';weekly='unknown';session='65';available='present'},
    @{id='stale';weekly='65';session='35';available='present'},
    @{id='unknown5h';weekly='65';session='unknown';available='unknown'},
    @{id='resetUnknown';weekly='65';session='unknown';available='absent'},
    @{id='resetDue';weekly='65';session='unknown';available='absent'},
    @{id='event';weekly='65';session='unknown';available='absent'},
    @{id='invalid';weekly='unknown';session='unknown';available='unknown'}
  )
  foreach($case in $cases){
    $s=Invoke-Demo ("LoadScenario('"+$case.id+"')")
    Assert-Native ($s.scenario -eq $case.id -and $s['codex.weekly.used'] -eq $case.weekly -and $s['codex.session.used'] -eq $case.session -and $s['codex.session.availability'] -eq $case.available) ('Native fixture '+$case.id)
  }
  $s=Invoke-Demo 'Acknowledge()'
  $s=Invoke-Demo "LoadScenario('normal')"
  foreach($factor in @(1,1.5)){
    $s=Invoke-Demo ('SetScale('+$factor.ToString([Globalization.CultureInfo]::InvariantCulture)+')')
    Assert-Native ([double]$s['window.w'] -eq 376*$factor -and [double]$s['window.h'] -eq 236*$factor) ('Closed native window size at scale '+$factor)
    $s=Invoke-Demo "Toggle('codex')"
    Assert-Native ($s.active -eq 'codex' -and [double]$s['window.h'] -gt 236*$factor) ('Native Codex detail at scale '+$factor)
    $s=Invoke-Demo "Toggle('claude')"
    Assert-Native ($s.active -eq 'claude') ('Native detail switches to Claude at scale '+$factor)
    $s=Invoke-Demo "Toggle('claude')"
    Assert-Native ($s.active -eq 'none' -and [double]$s['window.h'] -eq 236*$factor) ('Native second toggle closes and shrinks at scale '+$factor)
  }
  $s=Invoke-Demo 'SetScale(1)'
  $edge=[int]$s['layout.work_top']+[int]$s['layout.work_height']-236
  & $sender -Action Move -X ([int]$s['window.x']) -Y $edge -RainmeterExe $RainmeterExe
  Start-Sleep -Milliseconds 200
  $s=Invoke-Demo "Toggle('claude')"
  Assert-Native ($s['layout.above'] -eq 'true' -and [double]$s['layout.anchor'] -eq $edge -and [double]$s['window.y'] -ge [double]$s['layout.work_top']) 'Bottom-edge detail opens above with stable ring anchor'
  $s=Invoke-Demo 'SetScale(1.5)'
  Assert-Native ([double]$s['window.y']+[double]$s['window.h'] -le [double]$s['layout.work_top']+[double]$s['layout.work_height']) 'Scaling at bottom edge keeps the whole widget inside work area'
  $s=Invoke-Demo 'Close()'
  $s=Invoke-Demo 'TestEvent()';$announced=$s.announcements
  Assert-Native ($s.event_unread -eq 'true') 'Native TEST event appears'
  $s=Invoke-Demo 'Acknowledge()'
  Start-Sleep -Milliseconds 1200
  $s=Get-DemoState
  Assert-Native ($s.event_unread -eq 'false' -and $s.announcements -eq $announced) 'Acknowledged event does not return on redraw'
  $s=Invoke-Demo "LoadScenario('resetDue')";$reset=$s['codex.weekly.reset']
  Start-Sleep -Milliseconds 5500
  $s=Get-DemoState
  Assert-Native ($s['codex.weekly.used'] -eq '65' -and $s['codex.weekly.reset'] -eq $reset -and [DateTimeOffset]::UtcNow.ToUnixTimeSeconds() -gt [long]$reset) 'Elapsed native countdown preserves anchored reset and percentage'
  Write-Output ('DEMO native controls: '+$script:passed+' PASS, 0 FAIL. Physical mouse and visual QA are separate.')
}finally{
  $s=Invoke-Demo 'Acknowledge()';$s=Invoke-Demo 'Close()'
  $s=Invoke-Demo 'SetScale(1)';$s=Invoke-Demo "LoadScenario('normal')"
  & $sender -Action Move -X ([int]$original['window.x']) -Y ([int]$original['layout.anchor']) -RainmeterExe $RainmeterExe
}
