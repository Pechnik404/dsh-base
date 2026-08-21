# dsh-base: базовая установка DeepSeek Harness (Windows)
# Запуск:  .\install.ps1
# или одной командой:
#   powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/Pechnik404/dsh-base/main/install.ps1 | iex"

$ErrorActionPreference = 'Stop'

Write-Host "=== dsh-base: установка DeepSeek Harness ===" -ForegroundColor Cyan

# 1. Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "[1/5] Node.js не найден — ставлю через winget..." -ForegroundColor Yellow
    winget install OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
    # Обновляем PATH в текущей сессии
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
} else {
    Write-Host "[1/5] Node.js: $((node --version))" -ForegroundColor Green
}

# 2. Каталоги DSH
$dshHome = Join-Path $env:USERPROFILE '.dsh'
$profileDir = Join-Path $dshHome 'profiles\web'
$mcpDir = Join-Path $env:USERPROFILE 'Documents\DSH-work\_dsh_mcp'
New-Item -ItemType Directory -Force -Path $profileDir, $mcpDir | Out-Null
Write-Host "[2/5] Профиль DSH: $profileDir" -ForegroundColor Green

# 3. Конфигурация (копируем из репозитория; локальные правки не затираются)
$srcDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Copy-Item (Join-Path $srcDir 'cordis.patch.yml') (Join-Path $profileDir 'cordis.patch.yml') -Force
Write-Host "[3/5] cordis.patch.yml установлен (MCP + vision-модель)" -ForegroundColor Green

# 4. GitHub-лаунчер (безопасный: токен читается из .credentials.yaml)
Copy-Item (Join-Path $srcDir 'github-launcher.js') (Join-Path $mcpDir 'github-launcher.js') -Force
Write-Host "[4/5] github-launcher.js установлен в $mcpDir" -ForegroundColor Green

# 5. Запуск DSH
Write-Host "[5/5] Запускаю: npx @deepseek-ai/dsh web" -ForegroundColor Cyan
Write-Host "После запуска откройте http://127.0.0.1:3080" -ForegroundColor Green
npx @deepseek-ai/dsh web
