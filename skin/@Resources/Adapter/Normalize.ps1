# Internal LIVE snapshot contract v1. External JSON is never rendered or executed.
function Get-Field($Object,[string]$Name) {
  if($null -eq $Object){return $null}
  if($Object -is [Collections.IDictionary]){return $Object[$Name]}
  $property=$Object.PSObject.Properties[$Name]
  if($property){return $property.Value}
  return $null
}
function Test-Number($Value) {
  return ($null -ne $Value -and $Value -isnot [bool] -and $Value -isnot [string] -and
    $Value -is [ValueType] -and [double]::IsNaN([double]$Value) -eq $false -and
    [double]::IsInfinity([double]$Value) -eq $false)
}
function Convert-Epoch($Value) {
  if($Value -is [datetime]) {if($Value.Kind -eq [DateTimeKind]::Unspecified){return $null};return ([DateTimeOffset]$Value).ToUnixTimeSeconds()}
  if($Value -isnot [string] -or $Value -notmatch '^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(?:\.\d+)?(?:Z|[+-]\d\d:\d\d)$'){return $null}
  $parsed=[DateTimeOffset]::MinValue
  if([DateTimeOffset]::TryParse($Value,[Globalization.CultureInfo]::InvariantCulture,[Globalization.DateTimeStyles]::None,[ref]$parsed)){return $parsed.ToUnixTimeSeconds()}
  return $null
}
function Convert-Window($Raw,[int]$Minutes) {
  if($null -eq $Raw){return @{availability='absent'}}
  $info=Get-Field $Raw 'is_informational'
  if($info -eq $true -and $info -is [bool]){return @{availability='absent'}}
  $duration=Get-Field $Raw 'window_minutes'
  if(-not (Test-Number $duration) -or $duration -ne $Minutes){return @{availability='absent'}}
  $used=Get-Field $Raw 'used_percent'
  if($info -isnot [bool] -or -not (Test-Number $used) -or $used -lt 0 -or $used -gt 100){return @{availability='unknown';invalid=$true}}
  return @{availability='present';used=[double]$used;reset_at=(Convert-Epoch (Get-Field $Raw 'resets_at'))}
}
function Protect-AmbiguousZero([hashtable]$Quota,[string]$Provider,[string]$Source) {
  # v0.56.8 Codex JSON and Claude web parse missing upstream utilization as 0.
  # The flattened CLI JSON cannot prove which zero was explicitly measured.
  if($Quota.availability -eq 'present' -and $Quota.used -eq 0 -and ($Provider -eq 'codex' -or $Source -eq 'web')){
    return @{availability='unknown';invalid=$true;ambiguous_zero=$true}
  }
  return $Quota
}
function Read-Snapshot([string]$Path) {
  $state=@{}
  if(-not [IO.File]::Exists($Path)){return $state}
  $raw=[IO.File]::ReadAllText($Path)
  if($raw.Length -gt 32768){return $state}
  foreach($line in $raw -split "`n") {
    if(-not $line.Trim()){continue}
    if($line -notmatch '^([a-z0-9_.]+)=([a-zA-Z0-9_.:-]*)\r?$'){return @{}}
    if($state.ContainsKey($Matches[1])){return @{}}
    $state[$Matches[1]]=$Matches[2].TrimEnd("`r")
  }
  if($state['schema'] -ne '1' -or $state['mode'] -ne 'LIVE'){return @{}}
  return $state
}
function Write-Snapshot([string]$Path,[hashtable]$State) {
  $lines=foreach($key in ($State.Keys | Sort-Object)) {
    $value=[Convert]::ToString($State[$key],[Globalization.CultureInfo]::InvariantCulture)
    if($key -notmatch '^[a-z0-9_.]+$' -or $value -notmatch '^[a-zA-Z0-9_.:-]*$'){throw 'Unsafe internal snapshot value.'}
    $key+'='+$value
  }
  $temporary=$Path+'.'+[Guid]::NewGuid().ToString('N')+'.tmp'
  try {
    [IO.File]::WriteAllText($temporary,($lines -join "`n")+"`n",[Text.UTF8Encoding]::new($false))
    if([IO.File]::Exists($Path)){
      # Windows PowerShell 5.1 binds $null to an empty string here. NullString
      # passes an actual null backup filename to .NET Framework File.Replace.
      for($attempt=0;$attempt -lt 4;$attempt++){
        try{[IO.File]::Replace($temporary,$Path,[System.Management.Automation.Language.NullString]::Value);break}
        catch [IO.IOException]{if($attempt -eq 3){throw};Start-Sleep -Milliseconds 30}
      }
    }else{[IO.File]::Move($temporary,$Path)}
  } finally {if([IO.File]::Exists($temporary)){[IO.File]::Delete($temporary)}}
}
function Get-ErrorKind([string]$Message) {
  if($Message -match '(?i)429|rate.limit|too many requests'){return 'rate_limit'}
  if($Message -match '(?i)auth|credential|401|403|login|expired|revoked|consent|session.?key'){return 'authentication'}
  return 'source'
}
function Set-ProviderFailure([hashtable]$State,[string]$Provider,[string]$Kind,[long]$Now,[int]$Interval) {
  $State[$Provider+'.status']=$Kind
  $State[$Provider+'.attempted_at']=$Now
  $failures=0
  [void][int]::TryParse([string]$State[$Provider+'.failures'],[ref]$failures)
  $failures=[Math]::Min(6,$failures+1)
  $State[$Provider+'.failures']=$failures
  # Backoff is per provider: a failed Claude must not slow healthy Codex.
  $delay=[Math]::Min(3600,$Interval*[Math]::Pow(2,[Math]::Max(0,$failures-1)))
  if($Kind -eq 'rate_limit'){$delay=[Math]::Max(900,$delay)}
  $State[$Provider+'.next_at']=$Now+[long]$delay
}
function Set-Quota([hashtable]$State,[string]$Prefix,[hashtable]$Quota,[long]$Now) {
  if($Quota.invalid){$State[$Prefix+'.quality']='error';return}
  foreach($suffix in @('used','reset_at')){[void]$State.Remove($Prefix+'.'+$suffix)}
  $State[$Prefix+'.availability']=$Quota.availability
  $State[$Prefix+'.quality']='accepted'
  if($Quota.availability -eq 'present') {
    $State[$Prefix+'.used']=$Quota.used
    if($null -ne $Quota.reset_at){$State[$Prefix+'.reset_at']=$Quota.reset_at}
    $State[$Prefix+'.received_at']=$Now
  } else {[void]$State.Remove($Prefix+'.received_at')}
}
function Merge-Provider([hashtable]$State,[string]$Provider,$Payload,[string]$Source,[long]$Now,[int]$Interval,[string]$IdentitySalt) {
  if((Get-Field $Payload 'provider') -ne $Provider){Set-ProviderFailure $State $Provider 'invalid_output' $Now $Interval;return}
  $errorText=Get-Field $Payload 'error'
  if($null -ne $errorText){Set-ProviderFailure $State $Provider (Get-ErrorKind ([string]$errorText)) $Now $Interval;return}
  $usage=Get-Field $Payload 'usage'
  if($null -eq $usage -or (Get-Field $Payload 'source') -ne $Source){Set-ProviderFailure $State $Provider 'invalid_output' $Now $Interval;return}
  $identity='unknown'
  $email=Get-Field $usage 'account_email'
  if($email -is [string] -and $email.Trim()) {
    $hash=[Security.Cryptography.SHA256]::Create()
    try {$identity=[BitConverter]::ToString($hash.ComputeHash([Text.Encoding]::UTF8.GetBytes($IdentitySalt+'|'+$email+'|'+[string](Get-Field $usage 'account_organization')))).Replace('-','').ToLowerInvariant()} finally {$hash.Dispose()}
  }
  # Clear previous values before merging another known account or source.
  if(($State[$Provider+'.identity'] -and $State[$Provider+'.identity'] -ne $identity) -or
     ($State[$Provider+'.source'] -and $State[$Provider+'.source'] -ne $Source)) {
    foreach($key in @($State.Keys)){if($key.StartsWith($Provider+'.')){[void]$State.Remove($key)}}
  }
  $State[$Provider+'.identity']=$identity
  $State[$Provider+'.source']=$Source
  $State[$Provider+'.fetched_at']=$Now
  $State[$Provider+'.attempted_at']=$Now
  $State[$Provider+'.failures']=0
  $State[$Provider+'.next_at']=$Now+$Interval
  $State[$Provider+'.status']='ok'
  [void]$State.Remove($Provider+'.source_at')
  $sourceAt=Convert-Epoch (Get-Field $usage 'updated_at')
  if($null -ne $sourceAt -and $sourceAt -le $Now+60){$State[$Provider+'.source_at']=$sourceAt}
  $weekly=Protect-AmbiguousZero (Convert-Window (Get-Field $usage 'secondary') 10080) $Provider $Source
  $session=Protect-AmbiguousZero (Convert-Window (Get-Field $usage 'primary') 300) $Provider $Source
  Set-Quota $State ($Provider+'.weekly') $weekly $Now
  Set-Quota $State ($Provider+'.session') $session $Now
  if($weekly.invalid -or $session.invalid){Set-ProviderFailure $State $Provider 'invalid_quota' $Now $Interval}
  if($weekly.ambiguous_zero -or $session.ambiguous_zero){$State[$Provider+'.status']='ambiguous_zero'}
  # Only independently identified extra lanes. No averaging or main-ring fallback.
  foreach($key in @($State.Keys)){if($key.StartsWith($Provider+'.extra.')){[void]$State.Remove($key)}}
  $count=0;$omitted=0
  foreach($extra in @(Get-Field $usage 'extra_rate_windows')) {
    if($null -eq $extra){continue}
    $id=Get-Field $extra 'id';$window=Get-Field $extra 'window'
    if((Get-Field $window 'is_informational') -eq $true){continue}
    # Labels are fixed locally. Untrusted provider titles never enter Rainmeter.
    $code=$null;$minutes=0
    if($Provider -eq 'codex' -and $id -eq 'codex-spark'){$code='codex_spark';$minutes=300}
    if($Provider -eq 'claude' -and $id -eq 'claude-weekly-scoped-sonnet'){$code='claude_sonnet';$minutes=10080}
    if($Provider -eq 'claude' -and $id -eq 'claude-weekly-scoped-opus'){$code='claude_opus';$minutes=10080}
    if(-not $code){$omitted++;continue}
    $q=Protect-AmbiguousZero (Convert-Window $window $minutes) $Provider $Source
    if($q.availability -ne 'present' -or $count -ge 3){$omitted++;continue}
    $count++;$prefix=$Provider+'.extra.'+$count
    $State[$prefix+'.code']=$code
    Set-Quota $State $prefix $q $Now
  }
  # Legacy model_specific lacks an unambiguous model identity in this JSON.
  if($null -ne (Get-Field $usage 'model_specific')){$omitted++}
  $State[$Provider+'.extra_count']=$count
  $State[$Provider+'.extra_omitted']=$omitted
}
