[CmdletBinding()]
param([string]$NativeReport)
$ErrorActionPreference='Stop'
$repoRoot=Split-Path $PSScriptRoot -Parent
$script:passed=0
function Assert-Demo([bool]$Condition,[string]$Name){if(-not $Condition){throw ('FAIL '+$Name)};$script:passed++;Write-Output ('PASS '+$Name)}
foreach($file in Get-ChildItem -LiteralPath $PSScriptRoot -Filter '*.ps1'){
  $tokens=$null;$errors=$null
  [void][Management.Automation.Language.Parser]::ParseFile($file.FullName,[ref]$tokens,[ref]$errors)
  Assert-Demo ($errors.Count -eq 0) ('PowerShell syntax '+$file.Name)
}
$skin=Join-Path $repoRoot 'skin'
$ini=Get-Content -LiteralPath (Join-Path $skin 'DEMO.ini') -Raw -Encoding UTF8
$sections=@([regex]::Matches($ini,'(?m)^\[([^\]]+)\]') | ForEach-Object {$_.Groups[1].Value})
Assert-Demo (($sections | Select-Object -Unique).Count -eq $sections.Count) 'Unique INI sections'
$runtime=Get-Content -LiteralPath (Join-Path $skin '@Resources\Runtime.lua') -Raw -Encoding UTF8
$allRuntime=($ini+$runtime+(Get-Content -LiteralPath (Join-Path $skin '@Resources\Model.lua') -Raw -Encoding UTF8)+(Get-Content -LiteralPath (Join-Path $skin '@Resources\Fixtures.lua') -Raw -Encoding UTF8))
Assert-Demo ($runtime -notmatch '(?i)https?://|WebParser|os\.execute|io\.popen|socket\.') 'Renderer has no direct network or shell execution'
Assert-Demo ($allRuntime -notmatch '(?i)[A-Z]:\\|Users\\|access_token|refresh_token|sessionKey') 'No private paths or credentials in runtime'
Assert-Demo ($ini -match '(?m)^Text=DEMO$') 'Persistent DEMO label exists even before Lua initialization'
Assert-Demo ($ini -notmatch 'MouseLeaveAction=.*(?:Close\(|Toggle\()') 'Mouse departure cannot close detail'
Assert-Demo ($ini -notmatch '!ZPos\s+[12]|!RefreshApp') 'No forced topmost or global refresh'
Assert-Demo ($ini -match 'RotationAngle=6\.28318530717959' -and $ini -match 'StartAngle=4\.71238898038469') 'Clockwise arcs start at top'
# Exercise actual deployment guards only inside an owned temporary test root.
$caseRoot=Join-Path $repoRoot ('.local\deploy-tests-'+[Guid]::NewGuid().ToString('N'))
$skinRoot=Join-Path $caseRoot 'skins'
New-Item -ItemType Directory -Path $skinRoot -Force | Out-Null
$settings=Join-Path $caseRoot 'Rainmeter.ini'
Set-Content -LiteralPath $settings -Value ("[Rainmeter]`r`nSkinPath="+$skinRoot+'\') -Encoding Unicode
$target=Join-Path $skinRoot 'NOXUN AI Usage DEMO'
New-Item -ItemType Directory -Path $target | Out-Null
Set-Content -LiteralPath (Join-Path $target 'unknown.txt') -Value 'Do not overwrite.'
$rejected=$false
try{& (Join-Path $PSScriptRoot 'Deploy-Demo.ps1') -RainmeterIni $settings | Out-Null}catch{$rejected=$true}
Assert-Demo $rejected 'Unknown existing skin directory is rejected'
Assert-Demo ((Get-Content -LiteralPath (Join-Path $target 'unknown.txt') -Raw).Trim() -eq 'Do not overwrite.') 'Unknown file preserved'
# Verified absolute owned paths; never delete or move across shells.
if(-not ([IO.Path]::GetFullPath($target).StartsWith([IO.Path]::GetFullPath($caseRoot)+'\'))){throw 'Unsafe fixture cleanup path'}
Remove-Item -LiteralPath (Join-Path $target 'unknown.txt')
Remove-Item -LiteralPath $target
& (Join-Path $PSScriptRoot 'Deploy-Demo.ps1') -RainmeterIni $settings | Out-Null
Assert-Demo (Test-Path -LiteralPath (Join-Path $target 'DEMO.ini')) 'Clean isolated deployment succeeds'
$luaEntry=[IO.File]::ReadAllBytes((Join-Path $target '@Resources\Runtime.lua'))
Assert-Demo ($luaEntry[0] -eq 255 -and $luaEntry[1] -eq 254 -and [IO.File]::ReadAllText((Join-Path $target '@Resources\Runtime.lua')) -eq $runtime) 'Rainmeter Unicode entry encoding preserves source text'
$deployed=Join-Path $target '@Resources\Settings.inc'
$saved=[IO.File]::ReadAllBytes($deployed)
Add-Content -LiteralPath $deployed -Value '; local edit'
$rejected=$false
try{& (Join-Path $PSScriptRoot 'Deploy-Demo.ps1') -RainmeterIni $settings | Out-Null}catch{$rejected=$true}
Assert-Demo $rejected 'Locally modified deployment is not overwritten'
$rejected=$false
try{& (Join-Path $PSScriptRoot 'Remove-Demo.ps1') -RainmeterIni $settings -FilesOnly | Out-Null}catch{$rejected=$true}
Assert-Demo $rejected 'Locally modified deployment is not deleted'
[IO.File]::WriteAllBytes($deployed,$saved)
& (Join-Path $PSScriptRoot 'Remove-Demo.ps1') -RainmeterIni $settings -FilesOnly | Out-Null
Assert-Demo (-not (Test-Path -LiteralPath $target)) 'Rollback removes only owned DEMO directory'
Assert-Demo (Test-Path -LiteralPath $settings) 'Rollback preserves parent configuration'
if($NativeReport){
  $native=Get-Content -LiteralPath $NativeReport -Raw
  Assert-Demo ($native -match '^DEMO Lua Lua 5\.1: \d+ PASS, 0 FAIL' -and $native -notmatch '(?m)^FAIL ') 'Native Lua suite'
  Write-Output $native
}
Write-Output ('DEMO PowerShell: '+$script:passed+' PASS, 0 FAIL')
