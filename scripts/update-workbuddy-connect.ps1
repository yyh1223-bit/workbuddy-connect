# 将 dsh-workbuddy-connect 更新到 0.7.9（按项目 README 的 desktop 文件方式，全自动）
# 请从 DeepSeek Harness 外部运行（双击同目录的 update-workbuddy-connect.cmd 最省事）。
# 本脚本会先完全退出 DeepSeek Harness，安装完成后再自动启动它。
param(
  [string]$Version = '0.7.9',
  [string]$ProfileDir = 'D:\dsh-data\profiles\desktop',
  [switch]$NoRestart
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
$pkgName = 'dsh-workbuddy-connect'
$procName = 'DeepSeek Harness'

# ── 定位桌面 App ────────────────────────────────────────────────
$appRoot = (Get-ChildItem 'D:\' -Directory -Force -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -like '*桌面端*' } | Select-Object -First 1).FullName
if (-not $appRoot) { throw '未找到 DeepSeek Harness 安装目录' }
$appExe = Join-Path $appRoot 'DeepSeek Harness.exe'
Write-Host "App:      $appExe"
Write-Host "Profile:  $ProfileDir"

if (-not (Test-Path $ProfileDir)) { throw "profile 目录不存在: $ProfileDir" }
$pkgFile = Join-Path $ProfileDir 'package.json'
if (-not (Test-Path $pkgFile)) { throw "package.json 不存在: $pkgFile" }

# ── 完全退出 App ───────────────────────────────────────────────
$procs = Get-Process -Name $procName -ErrorAction SilentlyContinue
if ($procs) {
  Write-Host "[1/6] 正在完全退出 $procName ..."
  $procs | ForEach-Object { try { $_.CloseMainWindow() | Out-Null } catch {} }
  Start-Sleep -Seconds 4
  $still = Get-Process -Name $procName -ErrorAction SilentlyContinue
  if ($still) { $still | Stop-Process -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 3 }
  if (Get-Process -Name $procName -ErrorAction SilentlyContinue) {
    throw "$procName 仍在运行。请手动完全退出（含托盘）后重试。"
  }
  Write-Host "      已退出。"
} else {
  Write-Host "[1/6] $procName 未在运行，继续。"
}

# ── 备份 ───────────────────────────────────────────────────────
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
Copy-Item $pkgFile "$pkgFile.bak-$stamp" -Force
$lock = Join-Path $ProfileDir 'pnpm-lock.yaml'
if (Test-Path $lock) { Copy-Item $lock "$lock.bak-$stamp" -Force }
Write-Host "[2/6] 已备份 package.json -> package.json.bak-$stamp"

# ── 写入目标版本（无 BOM，避免 pnpm 解析失败）─────────────────
$json = Get-Content $pkgFile -Raw | ConvertFrom-Json
$current = $json.dependencies.$pkgName
$json.dependencies.$pkgName = $Version
$text = ($json | ConvertTo-Json -Depth 20) + "`n"
[System.IO.File]::WriteAllText($pkgFile, $text, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "[3/6] $pkgName : $current -> $Version"

# ── pnpm 安装 ──────────────────────────────────────────────────
# 不依赖 PATH / APPDATA（从 App 外部启动时环境可能不完整），直接定位 node 与 pnpm 入口
$nodeExe = 'D:\Program Files\nodejs\node.exe'
$pnpmCjs = 'C:\Users\Didi1\AppData\Roaming\npm\node_modules\pnpm\bin\pnpm.cjs'
if (-not (Test-Path $nodeExe) -and $env:ProgramFiles) {
  $alt = Join-Path $env:ProgramFiles 'nodejs\node.exe'
  if (Test-Path $alt) { $nodeExe = $alt }
}
if (-not (Test-Path $pnpmCjs) -and $env:APPDATA) {
  $alt = Join-Path $env:APPDATA 'npm\node_modules\pnpm\bin\pnpm.cjs'
  if (Test-Path $alt) { $pnpmCjs = $alt }
}
Write-Host "[4/6] 执行 pnpm install（可能需要几分钟）..."
Push-Location $ProfileDir
try {
  if ((Test-Path $nodeExe) -and (Test-Path $pnpmCjs)) {
    Write-Host "      使用 $nodeExe $pnpmCjs"
    & $nodeExe $pnpmCjs install
  } else {
    $pnpm = Join-Path $env:APPDATA 'npm\pnpm.cmd'
    if (-not (Test-Path $pnpm)) { $pnpm = 'pnpm' }
    & $pnpm install
  }
  if ($LASTEXITCODE -ne 0) { throw "pnpm install 失败（退出码 $LASTEXITCODE）" }
} finally { Pop-Location }

$installedPkg = Join-Path $ProfileDir "node_modules\$pkgName\package.json"
if (-not (Test-Path $installedPkg)) { throw "安装后未找到 $installedPkg" }
$installed = (Get-Content $installedPkg -Raw | ConvertFrom-Json).version
if ($installed -ne $Version) { throw "版本不匹配：期望 $Version，实际 $installed" }
Write-Host "[5/6] 已安装版本校验通过: $installed"

# ── 重启 App ───────────────────────────────────────────────────
if ($NoRestart) {
  Write-Host "[6/6] 已跳过重启（-NoRestart）"
} else {
  Start-Process $appExe
  Write-Host "[6/6] 已启动 $procName"
}
Write-Host ""
Write-Host "完成。重启后请在模型选择器里确认出现 WorkBuddy / WorkBuddy AI 分组，"
Write-Host "并从中选一个模型做一次简短对话，能正常回复才算接入成功。"
