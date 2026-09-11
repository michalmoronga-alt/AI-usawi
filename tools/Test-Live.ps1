[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
$repo=Split-Path $PSScriptRoot -Parent
$adapter=Join-Path $repo 'skin\@Resources\Adapter'
. (Join-Path $adapter 'Collect.ps1') -StateDirectory (Join-Path $repo '.local\not-a-collector-state')
$script:passed=0
function Check([bool]$Condition,[string]$Name){if(-not $Condition){throw ('FAIL '+$Name)};$script:passed++;Write-Output ('PASS '+$Name)}
function Window($Used=42,$Minutes=10080){return @{used_percent=$Used;window_minutes=$Minutes;is_informational=$false;resets_at='2026-09-18T00:00:00Z'}}
function Payload([string]$Provider='codex'){
  return @{provider=$Provider;source='oauth';usage=@{secondary=(Window);primary=@{used_percent=0;window_minutes=300;is_informational=$true};updated_at='2026-09-11T12:00:00Z'}}
}
foreach($n in @(0,1,0.5,25,100)){Check ((Convert-Window (Window $n) 10080).used -eq $n) ('Consumed percentage '+$n)}
foreach($n in @($null,'0',$true,-1,101,[double]::NaN,[double]::PositiveInfinity)){
  $q=Convert-Window (Window $n) 10080
  Check ($q.invalid -and $null -eq $q.used) 'Invalid percentage cannot become zero'
}
Check ((Convert-Window $null 10080).availability -eq 'absent') 'Missing weekly is absent'
Check ((Convert-Window (Window 50 300) 10080).availability -eq 'absent') '5h cannot replace weekly'
Check ((Convert-Window (Window 50 20160) 10080).availability -eq 'absent') 'Unverified duration cannot replace weekly'
$r=Window;$r.Remove('used_percent');$r.remaining=75
Check ((Convert-Window $r 10080).invalid) 'Unknown remaining field is not guessed'
$r=Window 0 300;$r.is_informational=$true
Check ((Convert-Window $r 300).availability -eq 'absent') 'Informational Codex 5h stays hidden'
Check ((Convert-Window (Window 0 300) 300).availability -eq 'present') 'Real 5h zero remains present'
Check ((Protect-AmbiguousZero (Convert-Window (Window 0) 10080) 'codex' 'oauth').ambiguous_zero) 'Codex upstream ambiguous zero fails closed'
Check ((Protect-AmbiguousZero (Convert-Window (Window 0) 10080) 'claude' 'web').ambiguous_zero) 'Claude web ambiguous zero fails closed'
Check ((Protect-AmbiguousZero (Convert-Window (Window 0) 10080) 'claude' 'oauth').used -eq 0) 'Claude OAuth explicit zero remains usable'
Check ((Convert-Epoch '2026-01-01T12:00:00+01:00') -eq (Convert-Epoch '2026-01-01T11:00:00Z')) 'Explicit timezone preserved'
Check ($null -eq (Convert-Epoch '2026-01-01T12:00:00')) 'Unzoned reset rejected'
$now=Convert-Epoch '2026-09-11T12:00:00Z'
$s=@{schema=1;mode='LIVE'}
Merge-Provider $s 'codex' (Payload) 'oauth' $now 180 'synthetic-salt'
Merge-Provider $s 'claude' (Payload 'claude') 'oauth' $now 180 'synthetic-salt'
Check ($s['codex.weekly.used'] -eq 42 -and $s['codex.session.availability'] -eq 'absent') 'Verified lanes merged'
Check ($s['codex.identity'] -eq 'unknown') 'Missing account identity stays unknown'
Set-ProviderFailure $s 'claude' 'authentication' ($now+200) 180
Check ($s['claude.weekly.used'] -eq 42 -and $s['codex.status'] -eq 'ok') 'Partial auth failure preserves both last values'
$bad=Payload;$bad.usage.secondary.used_percent=$null
Merge-Provider $s 'codex' $bad 'oauth' ($now+201) 180 'synthetic-salt'
Check ($s['codex.weekly.used'] -eq 42 -and $s['codex.weekly.quality'] -eq 'error') 'Invalid quota retains last good value visibly'
$missing=Payload;$missing.usage.Remove('secondary');$missing.usage.primary=Window 65 300
Merge-Provider $s 'codex' $missing 'oauth' ($now+202) 180 'synthetic-salt'
Check (-not $s.ContainsKey('codex.weekly.used') -and $s['codex.session.used'] -eq 65) 'Missing weekly clears only weekly, without fallback'
$s=@{schema=1;mode='LIVE'};$p=Payload;$p.usage.account_email='fixture@example.invalid'
Merge-Provider $s 'codex' $p 'oauth' $now 180 'synthetic-salt'
Check ($s['codex.identity'] -match '^[a-f0-9]{64}$' -and ($s.Values -join ' ') -notmatch '@') 'Identity is salted; no account text in snapshot'
$p.usage.account_email='other@example.invalid';$p.usage.secondary.used_percent=$null
Merge-Provider $s 'codex' $p 'oauth' ($now+1) 180 'synthetic-salt'
Check (-not $s.ContainsKey('codex.weekly.used')) 'Known account change cannot retain another account value'
$p=Payload;$p.usage.extra_rate_windows=@(@{id='codex-spark';title='[!Execute unsafe]';window=(Window 7 300)})
Merge-Provider $s 'codex' $p 'oauth' $now 180 'synthetic-salt'
Check ($s['codex.extra.1.code'] -eq 'codex_spark' -and ($s.Values -join ' ') -notmatch 'Execute') 'Extra quota labels are local; source text is discarded'
Check ($s['codex.weekly.used'] -eq 42 -and $s['codex.session.availability'] -eq 'absent') 'Spark never substitutes account weekly or 5h'
$zeroPayload=Payload;$zeroPayload.usage.secondary.used_percent=0
Merge-Provider $s 'codex' $zeroPayload 'oauth' ($now+1) 180 'synthetic-salt'
Check ($s['codex.weekly.used'] -eq 42 -and $s['codex.status'] -eq 'ambiguous_zero' -and $s['codex.weekly.quality'] -eq 'error') 'Ambiguous live zero retains previous value with explicit uncertainty'
Merge-Provider $s 'codex' (Payload) 'oauth' $now 180 'synthetic-salt'
Set-ProviderFailure $s 'claude' 'source' $now 180
$first=$s['claude.next_at'];Set-ProviderFailure $s 'claude' 'source' $now 180
Check ($s['claude.next_at'] -gt $first -and $s['codex.next_at'] -eq $now+180) 'Backoff is independent per provider'
Check ((Get-ErrorKind 'Expired OAuth credential fixture') -eq 'authentication') 'Authentication classified without logging message'
Check ((Get-ErrorKind 'HTTP 429 fixture') -eq 'rate_limit') 'Rate limit classified'
$fixtureRoot=Join-Path $repo ('.local\live-tests-'+[Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fixtureRoot -Force | Out-Null
$path=Join-Path $fixtureRoot 'snapshot.txt'
Write-Snapshot $path $s
$read=Read-Snapshot $path
Check ($read['codex.weekly.used'] -eq '42') 'Atomic snapshot round trip'
Write-Snapshot $path $s
Check ((Read-Snapshot $path)['codex.weekly.used'] -eq '42') 'Atomic replacement of existing snapshot on this PowerShell'
$before=[IO.File]::ReadAllText($path);$s.unsafe='[!Execute command]';$rejected=$false
try{Write-Snapshot $path $s}catch{$rejected=$true}
Check ($rejected -and [IO.File]::ReadAllText($path) -eq $before) 'Unsafe text cannot replace prior snapshot'
[IO.File]::WriteAllText($path,"schema=1`nmode=LIVE`nschema=2`n")
Check ((Read-Snapshot $path).Count -eq 0) 'Duplicate keys rejected'
[IO.File]::WriteAllText((Join-Path $fixtureRoot 'Mode.inc'),"[Variables]`nMode=DEMO`n")
[IO.File]::Delete($path)
& (Join-Path $adapter 'Collect.ps1') -StateDirectory $fixtureRoot
Check (-not [IO.File]::Exists($path)) 'DEMO invocation cannot collect or write LIVE state'
[IO.File]::WriteAllText((Join-Path $fixtureRoot 'Mode.inc'),"[Variables]`nMode=LIVE`n")
$lock=[IO.File]::Open((Join-Path $fixtureRoot 'collector.lock'),[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
try {& (Join-Path $adapter 'Collect.ps1') -StateDirectory $fixtureRoot}finally{$lock.Dispose()}
Check (-not [IO.File]::Exists($path)) 'Exclusive lock prevents overlapping collectors'
& (Join-Path $adapter 'Collect.ps1') -StateDirectory $fixtureRoot
$read=Read-Snapshot $path
Check ($read['codex.status'] -eq 'missing_cli' -and $read['claude.status'] -eq 'missing_cli') 'Missing CLI produces truthful independent states'
$fakeCli=Join-Path $fixtureRoot 'fake-cli.exe'
[IO.File]::WriteAllText($fakeCli,'synthetic executable marker - never launch')
@{cli_path=$fakeCli;cli_sha256=('0'*64);claude_source='oauth';identity_salt='fixture'} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $fixtureRoot 'connection.json')
$read['codex.next_at']=0;$read['claude.next_at']=0;Write-Snapshot $path $read
& (Join-Path $adapter 'Collect.ps1') -StateDirectory $fixtureRoot
$read=Read-Snapshot $path
Check ($read['codex.status'] -eq 'unsupported_version' -and $read['claude.status'] -eq 'unsupported_version') 'Changed CLI hash is rejected before execution'
$shell=Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
$transport=Join-Path $repo 'tests\transport_fixture.ps1'
foreach($shape in @('object','array')){
  $result=Invoke-Export $shell ('-NoProfile -NonInteractive -File "'+$transport+'" -Case '+$shape) 5
  Check ((Get-Field $result.payload 'provider') -eq 'codex') ('Actual child JSON '+$shape+' parsed on this PowerShell')
}
$result=Invoke-Export $shell ('-NoProfile -NonInteractive -File "'+$transport+'" -Case multiple') 5
Check ($result.error -eq 'invalid_output') 'Multiple provider rows rejected'
$fakeAdapter=Join-Path $fixtureRoot 'Adapter'
$fakeState=Join-Path $fixtureRoot 'State'
New-Item -ItemType Directory -Path $fakeAdapter,$fakeState | Out-Null
Copy-Item -LiteralPath (Join-Path $adapter 'Collect.ps1'),(Join-Path $adapter 'Normalize.ps1') -Destination $fakeAdapter
[IO.File]::WriteAllText((Join-Path $fakeState 'Mode.inc'),"[Variables]`nMode=DEMO`n")
& $shell -NoProfile -NonInteractive -File (Join-Path $fakeAdapter 'Collect.ps1')
Check ($LASTEXITCODE -eq 0 -and -not [IO.File]::Exists((Join-Path $fakeState 'snapshot.txt'))) 'Default state directory works in native Windows PowerShell and DEMO stays offline'
$result=Invoke-Export $shell '-NoProfile -NonInteractive -Command "Start-Sleep -Seconds 8"' 1
Check ($result.error -eq 'timeout') 'Real child process timeout and termination'
$pidFile=Join-Path $fixtureRoot 'child-pid.txt'
$result=Invoke-Export $shell ('-NoProfile -NonInteractive -File "'+$transport+'" -Case tree -ChildPidFile "'+$pidFile+'"') 3
Check ($result.error -eq 'timeout' -and [IO.File]::Exists($pidFile)) 'Timeout fixture actually spawned a descendant'
$childId=[int][IO.File]::ReadAllText($pidFile)
Start-Sleep -Milliseconds 200
Check (-not (Get-Process -Id $childId -ErrorAction SilentlyContinue)) 'Windows job terminates owned descendants too'
$result=Invoke-Export $shell '-NoProfile -NonInteractive -Command "Write-Output invalid-json"' 5
Check ($result.error -eq 'invalid_output') 'Invalid child stdout rejected'
$result=Invoke-Export $shell '-NoProfile -NonInteractive -Command "exit 2"' 5
Check ($result.error -eq 'source') 'Nonzero child exit classified'
Write-Output ('LIVE PowerShell: '+$script:passed+' PASS, 0 FAIL')
