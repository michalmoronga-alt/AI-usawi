param([ValidateSet('object','array','multiple','tree')][string]$Case='array',[string]$ChildPidFile)
if($Case -eq 'tree'){
  Start-Sleep -Milliseconds 200
  $child=Start-Process -FilePath (Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe') -ArgumentList '-NoProfile -NonInteractive -Command "Start-Sleep -Seconds 20"' -WindowStyle Hidden -PassThru
  [IO.File]::WriteAllText($ChildPidFile,[string]$child.Id)
  Start-Sleep -Seconds 20
  return
}
$json='{"provider":"codex","source":"oauth","usage":{"secondary":{"used_percent":42,"window_minutes":10080,"is_informational":false}}}'
if($Case -eq 'array'){$json='['+$json+']'}
if($Case -eq 'multiple'){$json='['+$json+','+$json+']'}
[Console]::WriteLine($json)
