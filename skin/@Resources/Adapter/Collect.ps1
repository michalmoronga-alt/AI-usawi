[CmdletBinding()]
param([string]$StateDirectory,
      [ValidateRange(180,3600)][int]$IntervalSeconds=180,
      [ValidateRange(5,35)][int]$TimeoutSeconds=30)
$ErrorActionPreference='Stop'
if(-not $StateDirectory){$StateDirectory=Join-Path (Split-Path $PSScriptRoot -Parent) 'State'}
. (Join-Path $PSScriptRoot 'Normalize.ps1')
$script:ChildJobSource=Join-Path $PSScriptRoot 'ChildJob.cs'
function Invoke-Export([string]$File,[string]$Arguments,[int]$Timeout) {
  $process=New-Object Diagnostics.Process
  $process.StartInfo=New-Object Diagnostics.ProcessStartInfo
  $process.StartInfo.FileName=$File
  $process.StartInfo.Arguments=$Arguments
  $process.StartInfo.UseShellExecute=$false
  $process.StartInfo.CreateNoWindow=$true
  $process.StartInfo.RedirectStandardOutput=$true
  $process.StartInfo.RedirectStandardError=$true
  $job=$null;$started=$false
  try {
    if(-not ('AIUsawi.ChildJob' -as [type])){Add-Type -TypeDefinition ([IO.File]::ReadAllText($script:ChildJobSource))}
    $job=New-Object AIUsawi.ChildJob
    [void]$process.Start()
    $started=$true
    $job.Assign($process.Handle)
    $stdout=$process.StandardOutput.ReadToEndAsync()
    $stderr=$process.StandardError.ReadToEndAsync()
    if(-not $process.WaitForExit($Timeout*1000)){
      $job.Dispose();[void]$process.WaitForExit(2000)
      return @{error='timeout'}
    }
    $job.Dispose()
    if($process.ExitCode -ne 0){return @{error='source'}}
    $raw=$stdout.GetAwaiter().GetResult()
    # Never emit stdout, stderr or exception messages containing provider data.
    if($raw.Length -gt 1048576){return @{error='invalid_output'}}
    try {$parsed=ConvertFrom-Json -InputObject $raw -ErrorAction Stop}catch{return @{error='invalid_output'}}
    if($parsed -is [Array]){
      if($parsed.Count -ne 1){return @{error='invalid_output'}}
      $parsed=$parsed[0]
    }
    if($parsed -isnot [pscustomobject]){return @{error='invalid_output'}}
    return @{payload=$parsed}
  } catch {
    if($started -and -not $process.HasExited){try{$process.Kill()}catch{}}
    return @{error='source'}
  } finally {if($job){$job.Dispose()};$process.Dispose()}
}
if(-not [IO.Directory]::Exists($StateDirectory)){return}
$modeFile=Join-Path $StateDirectory 'Mode.inc'
if(-not [IO.File]::Exists($modeFile) -or [IO.File]::ReadAllText($modeFile) -notmatch '(?m)^Mode=LIVE\r?$'){return}
$lock=$null
try {$lock=[IO.File]::Open((Join-Path $StateDirectory 'collector.lock'),[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)}catch{return}
try {
  $path=Join-Path $StateDirectory 'snapshot.txt'
  $state=Read-Snapshot $path
  $state.schema=1;$state.mode='LIVE';$state.interval=$IntervalSeconds
  $now=[DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
  $config=$null
  try {$config=[IO.File]::ReadAllText((Join-Path $StateDirectory 'connection.json')) | ConvertFrom-Json}catch{}
  $file=Get-Field $config 'cli_path'
  $expected=Get-Field $config 'cli_sha256'
  $source=Get-Field $config 'claude_source'
  $salt=Get-Field $config 'identity_salt'
  $problem=$null
  if(-not $file -or -not [IO.File]::Exists($file)){$problem='missing_cli'}
  elseif($source -notin @('oauth','web') -or -not $expected -or -not $salt){$problem='invalid_config'}
  elseif((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash -ne $expected){$problem='unsupported_version'}
  foreach($provider in @('codex','claude')) {
    $due=0L;[void][long]::TryParse([string]$state[$provider+'.next_at'],[ref]$due)
    if($due -gt $now -and $due -le $now+3600){continue}
    if($problem){Set-ProviderFailure $state $provider $problem $now $IntervalSeconds;continue}
    $selected=if($provider -eq 'codex'){'oauth'}else{$source}
    try{
      $result=Invoke-Export $file ('usage --provider '+$provider+' --format json --source '+$selected+' --web-timeout 30 --no-color') $TimeoutSeconds
      $finished=[DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
      if($result.error){Set-ProviderFailure $state $provider $result.error $finished $IntervalSeconds}
      else {Merge-Provider $state $provider $result.payload $selected $finished $IntervalSeconds $salt}
    }catch{
      $finished=[DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
      Set-ProviderFailure $state $provider 'adapter_error' $finished $IntervalSeconds
    }
    # Each completed provider survives a later timeout or interruption.
    $state.written_at=$finished
    Write-Snapshot $path $state
  }
  $state.written_at=[DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
  Write-Snapshot $path $state
} catch {
  # Fail closed. Last atomic snapshot remains readable; UI ages it locally.
  Write-Output ('AI-usawi collector failed at adapter line '+$_.InvocationInfo.ScriptLineNumber+'; last snapshot retained.')
} finally {if($lock){$lock.Dispose()}}
