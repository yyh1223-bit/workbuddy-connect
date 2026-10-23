# 无人值守升级：等待片刻 -> 关闭 App -> 调用主脚本安装 -> 失败则回滚 -> 重启 App
# 由 DSH 通过 WMI 以独立进程启动，因此不受 App 退出影响。
param(
  [int]$DelaySeconds = 20,
  [string]$MainScript = 'D:\deepseek ha\update-workbuddy-connect.ps1',
  [string]$ProfileDir = 'D:\dsh-data\profiles\desktop',
  [string]$LogFile = 'D:\deepseek ha\update-workbuddy-connect.log'
)

$ErrorActionPreference = 'Continue'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

Start-Transcript -Path $LogFile -Force | Out-Null

$appRoot = (Get-ChildItem 'D:\' -Directory -Force -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -like '*桌面端*' } | Select-Object -First 1).FullName
$appExe = Join-Path $appRoot 'DeepSeek Harness.exe'

Write-Host "[auto] 将在 $DelaySeconds 秒后关闭 DeepSeek Harness 并开始升级 ..."
Start-Sleep -Seconds $DelaySeconds

$ok = $false
try {
  & $MainScript -ProfileDir $ProfileDir
  $ok = $true
  Write-Host "[auto] 主脚本执行成功。"
} catch {
  Write-Host "[auto] 升级失败：$($_.Exception.Message)"
  Write-Host "[auto] 失败位置：$($_.InvocationInfo.PositionMessage)"
}

if (-not $ok) {
  $bak = Get-ChildItem (Join-Path $ProfileDir 'package.json.bak-*') -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if ($bak) {
    Copy-Item $bak.FullName (Join-Path $ProfileDir 'package.json') -Force
    Write-Host "[auto] 已把 package.json 回滚为 $($bak.Name)"
  }
  Write-Host "[auto] 正在重新启动 DeepSeek Harness（保持原有可用状态）..."
  Start-Process $appExe
} else {
  Write-Host "[auto] 升级完成，App 已由主脚本启动。"
}

Write-Host "[auto] 日志：$LogFile"
Stop-Transcript | Out-Null
