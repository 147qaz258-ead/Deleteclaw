# OpenClaw 一键卸载脚本 (Windows PowerShell)
# WARNING: 此脚本将删除所有 OpenClaw 数据和配置。

$ErrorActionPreference = "SilentlyContinue"

Write-Host "🦞 OpenClaw 一键卸载工具" -ForegroundColor Yellow
Write-Host "此脚本将卸载 OpenClaw 服务并删除所有本地数据 ($HOME\.openclaw)。"
Write-Host "警告：操作不可逆！" -ForegroundColor Red

# 确认操作
$confirm = Read-Host "您确定要继续吗？(y/N)"
if ($confirm -notmatch "^[Yy]$") {
    Write-Host "卸载取消。"
    exit
}

# 1. 停止并停止计划任务
Write-Host "`n==> 停止并移除计划任务..." -ForegroundColor Green
$tasks = @("OpenClaw Gateway", "OpenClaw Node")

foreach ($task in $tasks) {
    Write-Host "检查任务: $task"
    $taskExists = schtasks /Query /TN $task 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "正在删除任务: $task"
        schtasks /Delete /TN $task /F | Out-Null
    }
}

# 2. 清理 Docker 资源 (如果安装了 Docker Desktop)
Write-Host "`n==> 清理 Docker 资源..." -ForegroundColor Green
if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Host "移除 OpenClaw 相关容器和卷..."
    docker rm -f openclaw-gateway openclaw-cli 2>$null
    docker volume rm openclaw_home openclaw_config openclaw_workspace 2>$null
    Write-Host "提示: 如果需要删除 Docker 镜像，请手动执行 'docker rmi openclaw:local'。" -ForegroundColor Yellow
}

# 3. 删除本地数据目录
Write-Host "`n==> 删除本地数据 ($HOME\.openclaw)..." -ForegroundColor Green
$openclawDir = Join-Path $HOME ".openclaw"
if (Test-Path $openclawDir) {
    Write-Host "正在删除 $openclawDir"
    Remove-Item -Recurse -Force $openclawDir
} else {
    Write-Host "未找到 $openclawDir 目录。"
}

# 4. 提示卸载全局 NPM 包
Write-Host "`n==> 完成!" -ForegroundColor Green
Write-Host "大部分组件已清理完毕。" -ForegroundColor Yellow
Write-Host "最后一步，请执行以下命令手动卸载全局命令：" -ForegroundColor Yellow
Write-Host "  npm uninstall -g openclaw"

Write-Host "`nOpenClaw 已成功从您的系统中移除。" -ForegroundColor Green
