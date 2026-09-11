[CmdletBinding()]
param([string]$RainmeterIni,[string]$RainmeterExe,[switch]$Load,
  [ValidateSet('DEMO','LIVE')][string]$Mode='DEMO',
  [string]$CliPath,[string]$VerifiedCliSha256,
  [ValidateSet('oauth','web')][string]$ClaudeSource='oauth')
$ErrorActionPreference='Stop'
$repoRoot=Split-Path $PSScriptRoot -Parent
if(-not $RainmeterIni){$RainmeterIni=Join-Path $env:APPDATA 'Rainmeter\Rainmeter.ini'}
if(-not (Test-Path -LiteralPath $RainmeterIni -PathType Leaf)){throw 'Specify the actual Rainmeter.ini with -RainmeterIni.'}
$skinLine=Select-String -LiteralPath $RainmeterIni -Pattern '^SkinPath=(.+)$' | Select-Object -First 1
if(-not $skinLine){throw 'The selected configuration does not declare SkinPath.'}
$skinRoot=[IO.Path]::GetFullPath($skinLine.Matches[0].Groups[1].Value.Trim())
if(-not (Test-Path -LiteralPath $skinRoot -PathType Container)){throw 'The configured skin directory does not exist.'}
$target=[IO.Path]::GetFullPath((Join-Path $skinRoot 'NOXUN AI Usage DEMO'))
if((Split-Path $target -Parent).TrimEnd('\') -ne $skinRoot.TrimEnd('\')){throw 'Target escaped the skin directory.'}
$source=[IO.Path]::GetFullPath((Join-Path $repoRoot 'skin'))
if($source.StartsWith($skinRoot.TrimEnd('\')+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Source must be outside active Rainmeter skins.'}
$marker=Join-Path $target '.ai-usawi-demo'
$oldManifest=Join-Path $target 'deployment-manifest.json'
$old=$null
if(Test-Path -LiteralPath $target){
  if((Get-Item -LiteralPath $target).Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Deployment target is a link; refusing to follow it.'}
  if(Get-ChildItem -LiteralPath $target -Recurse -Force | Where-Object {$_.Attributes -band [IO.FileAttributes]::ReparsePoint}){throw 'Deployment contains links; inspect it manually.'}
  if(-not (Test-Path -LiteralPath $marker) -or (Get-Content -LiteralPath $marker -Raw).Trim() -ne 'AI-usawi offline DEMO v1'){throw 'Unknown existing target; nothing overwritten.'}
  if(-not (Test-Path -LiteralPath $oldManifest)){throw 'Existing deployment has no manifest; inspect it manually.'}
  $old=Get-Content -LiteralPath $oldManifest -Raw | ConvertFrom-Json
  foreach($entry in $old.files){
    $path=[IO.Path]::GetFullPath((Join-Path $target $entry.path))
    if(-not $path.StartsWith($target+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Invalid manifest path.'}
    if((Test-Path -LiteralPath $path) -and (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $entry.sha256){throw ('Locally modified deployment: '+$entry.path+'. Back it up before replacing.')}
  }
}
if(-not $RainmeterExe){$RainmeterExe=Get-Process -Name Rainmeter -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Path}
if($Load -and (-not $RainmeterExe -or -not (Test-Path -LiteralPath $RainmeterExe))){throw 'Pass the verified Rainmeter executable with -RainmeterExe.'}
$connection=$null
if($Mode -eq 'LIVE'){
  $existingConnection=Join-Path $target '@Resources\State\connection.json'
  if($CliPath){
    if(-not [IO.File]::Exists($CliPath) -or $VerifiedCliSha256 -notmatch '^[a-fA-F0-9]{64}$'){throw 'LIVE requires the verified CLI path and SHA256.'}
    if((Get-FileHash -LiteralPath $CliPath -Algorithm SHA256).Hash -ne $VerifiedCliSha256){throw 'CLI changed since verification.'}
    $connection=@{cli_path=[IO.Path]::GetFullPath($CliPath);cli_sha256=$VerifiedCliSha256;cli_version='0.56.8';claude_source=$ClaudeSource;identity_salt=[Guid]::NewGuid().ToString('N')}
    if(Test-Path -LiteralPath $existingConnection){
      $oldConnection=Get-Content -LiteralPath $existingConnection -Raw | ConvertFrom-Json
      if($oldConnection.identity_salt){$connection.identity_salt=$oldConnection.identity_salt}
    }
  } elseif(-not (Test-Path -LiteralPath $existingConnection)){throw 'No verified LIVE connection configuration.'}
}
$files=@(Get-ChildItem -LiteralPath $source -File -Recurse | Where-Object {$_.FullName -notmatch '[\\/]State[\\/]'})
$entries=@()
foreach($file in $files){
  $relative=$file.FullName.Substring($source.Length+1)
  $bytes=[IO.File]::ReadAllBytes($file.FullName)
  if($relative -eq '@Resources\Runtime.lua'){
    # Rainmeter 4.5 chooses UTF-8 Lua string bindings only for a UTF-16 LE
    # entry script. dofile modules stay UTF-8. Keep reviewable UTF-8 sources.
    $bytes=[Text.Encoding]::Unicode.GetPreamble()+[Text.Encoding]::Unicode.GetBytes([IO.File]::ReadAllText($file.FullName,[Text.Encoding]::UTF8))
  }
  $hasher=[Security.Cryptography.SHA256]::Create()
  try{$hash=[BitConverter]::ToString($hasher.ComputeHash($bytes)).Replace('-','')}finally{$hasher.Dispose()}
  $entries+=@{path=$relative;bytes=$bytes;sha256=$hash}
}
$modeBytes=[Text.Encoding]::UTF8.GetBytes("[Variables]"+[Environment]::NewLine+'Mode='+$Mode+[Environment]::NewLine)
$modeHash=[Security.Cryptography.SHA256]::Create()
try{$modeDigest=[BitConverter]::ToString($modeHash.ComputeHash($modeBytes)).Replace('-','')}finally{$modeHash.Dispose()}
$entries+=@{path='@Resources\State\Mode.inc';bytes=$modeBytes;sha256=$modeDigest}
$testFile=Join-Path $repoRoot 'tests\demo_spec.lua'
$entries+=@{path='@Resources\Tests\demo_spec.lua';bytes=[IO.File]::ReadAllBytes($testFile);sha256=(Get-FileHash -LiteralPath $testFile -Algorithm SHA256).Hash}
$liveTest=Join-Path $repoRoot 'tests\live_spec.lua'
$entries+=@{path='@Resources\Tests\live_spec.lua';bytes=[IO.File]::ReadAllBytes($liveTest);sha256=(Get-FileHash -LiteralPath $liveTest -Algorithm SHA256).Hash}
# Fail before copying if a new file would overwrite untracked local content.
foreach($entry in $entries){
  $destination=Join-Path $target $entry.path
  if((Test-Path -LiteralPath $destination) -and $old -and $entry.path -notin @($old.files.path)){throw ('Untracked local collision: '+$entry.path)}
}
New-Item -ItemType Directory -Path $target -Force | Out-Null
foreach($entry in $entries){
  $destination=Join-Path $target $entry.path
  New-Item -ItemType Directory -Path (Split-Path $destination -Parent) -Force | Out-Null
  [IO.File]::WriteAllBytes($destination,$entry.bytes)
}
New-Item -ItemType Directory -Path (Join-Path $target '@Resources\State') -Force | Out-Null
if($connection){
  $connection | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $target '@Resources\State\connection.json') -Encoding UTF8
}
Set-Content -LiteralPath $marker -Value 'AI-usawi offline DEMO v1' -Encoding UTF8
@{schema=1;mode=$Mode;files=@($entries | ForEach-Object { @{path=$_.path;sha256=$_.sha256} })} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $oldManifest -Encoding UTF8
if($Load){
  & (Join-Path $PSScriptRoot 'Send-DemoCommand.ps1') -Action Activate -RainmeterExe $RainmeterExe
  & (Join-Path $PSScriptRoot 'Send-DemoCommand.ps1') -Action Refresh -RainmeterExe $RainmeterExe
  Write-Output 'If Rainmeter does not know a newly created folder yet, see README. This script never calls Refresh All.'
}
Write-Output ('Deployed isolated '+$Mode+': '+$target)
