[CmdletBinding()]
param([string]$RainmeterIni,[string]$RainmeterExe,[switch]$FilesOnly)
$ErrorActionPreference='Stop'
if(-not $RainmeterIni){$RainmeterIni=Join-Path $env:APPDATA 'Rainmeter\Rainmeter.ini'}
$line=Select-String -LiteralPath $RainmeterIni -Pattern '^SkinPath=(.+)$' | Select-Object -First 1
if(-not $line){throw 'No verified SkinPath.'}
$root=[IO.Path]::GetFullPath($line.Matches[0].Groups[1].Value.Trim()).TrimEnd('\')
$target=[IO.Path]::GetFullPath((Join-Path $root 'NOXUN AI Usage DEMO'))
if((Split-Path $target -Parent).TrimEnd('\') -ne $root){throw 'Unsafe removal target.'}
if(-not (Test-Path -LiteralPath $target)){Write-Output 'DEMO is already absent.';return}
if((Get-Item -LiteralPath $target).Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Removal target is a link; refusing to follow it.'}
if(Get-ChildItem -LiteralPath $target -Recurse -Force | Where-Object {$_.Attributes -band [IO.FileAttributes]::ReparsePoint}){throw 'Deployment contains links; refusing recursive removal.'}
$marker=Join-Path $target '.ai-usawi-demo'
if(-not (Test-Path -LiteralPath $marker) -or (Get-Content -LiteralPath $marker -Raw).Trim() -ne 'AI-usawi offline DEMO v1'){throw 'Unknown directory; refusing removal.'}
$manifest=Get-Content -LiteralPath (Join-Path $target 'deployment-manifest.json') -Raw | ConvertFrom-Json
foreach($entry in $manifest.files){
  $path=[IO.Path]::GetFullPath((Join-Path $target $entry.path))
  if(-not $path.StartsWith($target+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Invalid manifest path.'}
  if((Test-Path -LiteralPath $path) -and (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $entry.sha256){throw ('Modified file; back it up before removal: '+$entry.path)}
}
$known=@($manifest.files.path)+@('.ai-usawi-demo','deployment-manifest.json','@Resources\State\inspection.txt','@Resources\State\test-results.txt','@Resources\State\connection.json','@Resources\State\snapshot.txt','@Resources\State\collector.lock')
foreach($file in Get-ChildItem -LiteralPath $target -File -Recurse){
  $relative=$file.FullName.Substring($target.Length+1)
  if($relative -notin $known){throw ('Unexpected file; inspect/back up before removal: '+$relative)}
}
if(-not $FilesOnly){
  if(-not $RainmeterExe){$RainmeterExe=Get-Process -Name Rainmeter -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Path}
  if($RainmeterExe){& (Join-Path $PSScriptRoot 'Send-DemoCommand.ps1') -Action Deactivate -RainmeterExe $RainmeterExe;Start-Sleep -Milliseconds 300}
}
$lockPath=Join-Path $target '@Resources\State\collector.lock'
$deadline=[DateTime]::UtcNow.AddSeconds(75)
$handle=$null
while([IO.File]::Exists($lockPath) -and -not $handle){
  try{$handle=[IO.File]::Open($lockPath,[IO.FileMode]::Open,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)}catch{
    if([DateTime]::UtcNow -gt $deadline){throw 'Collector is still active; retry removal after it finishes.'}
    Start-Sleep -Milliseconds 250
  }
}
if($handle){$handle.Dispose()}
Remove-Item -LiteralPath $target -Recurse
Write-Output 'Only NOXUN AI Usage DEMO was removed. Source repository was retained.'
