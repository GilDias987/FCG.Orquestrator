# Build das Imagens Docker
# PowerShell Script

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Build das Imagens Docker" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"

# Detecta o diretório base automaticamente (pasta repos/)
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$REPOS_DIR = Split-Path -Parent (Split-Path -Parent $SCRIPT_DIR)

Write-Host "Diretório base: $REPOS_DIR" -ForegroundColor Gray

try {
    # Build Catalog API
    Write-Host "`nBuild Catalog API..." -ForegroundColor Yellow
    docker build -t catalog-api:latest `
        -f "$REPOS_DIR\FCG.Catalog\FCG.Catalog\FCG.Catalog.WebAPI\Dockerfile" `
        "$REPOS_DIR\FCG.Catalog\FCG.Catalog"

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao buildar Catalog API"
    }

    # Build Users API
    Write-Host "`nBuild Users API..." -ForegroundColor Yellow
    docker build -t users-api:latest `
        -f "$REPOS_DIR\FCG.Users\FCG.Users\FCG.Users.WebAPI\Dockerfile" `
        "$REPOS_DIR\FCG.Users\FCG.Users"

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao buildar Users API"
    }

    # Build Payments API when ready
    Write-Host "`nBuild Payments API..." -ForegroundColor Yellow
    docker build -t payments-api:latest `
        -f "$REPOS_DIR\FCG.Payments\FCG.Payments\FCG.Payments.WebAPI\Dockerfile" `
        "$REPOS_DIR\FCG.Payments\FCG.Payments"

    # Build Notification API when ready
    Write-Host "`nBuild Notification API..." -ForegroundColor Yellow
    docker build -t notification-api:latest `
        -f "$REPOS_DIR\FCG.Notification\FCG.Notification\FCG.Notification.WebAPI\Dockerfile" `
        "$REPOS_DIR\FCG.Notification\FCG.Notification"

    Write-Host "`n✅ Todas as imagens foram buildadas com sucesso!" -ForegroundColor Green
}
catch {
    Write-Host "`n❌ Erro: $_" -ForegroundColor Red
    exit 1
}
