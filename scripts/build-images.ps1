# Build das Imagens Docker
# PowerShell Script

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Build das Imagens Docker" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"

# Detecta o diretório base automaticamente (pasta repos/)
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$REPOS_DIR = Split-Path -Parent (Split-Path -Parent $SCRIPT_DIR)

# Gera tag com timestamp para forçar atualização dos pods
$IMAGE_TAG = (Get-Date -Format "yyyyMMdd-HHmmss")
$TAG_FILE = Join-Path $SCRIPT_DIR ".image-tag"

Write-Host "Diretório base: $REPOS_DIR" -ForegroundColor Gray
Write-Host "Tag da imagem: $IMAGE_TAG" -ForegroundColor Gray

# Salva a tag para uso posterior
Set-Content -Path $TAG_FILE -Value $IMAGE_TAG

try {
    # Build Catalog API
    Write-Host "`nBuild Catalog API..." -ForegroundColor Yellow
    docker build -t catalog-api:$IMAGE_TAG -t catalog-api:latest `
        -f "$REPOS_DIR\FCG.Catalog\FCG.Catalog\FCG.Catalog.WebAPI\Dockerfile" `
        "$REPOS_DIR\FCG.Catalog\FCG.Catalog"

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao buildar Catalog API"
    }

    # Build Users API
    Write-Host "`nBuild Users API..." -ForegroundColor Yellow
    docker build -t users-api:$IMAGE_TAG -t users-api:latest `
        -f "$REPOS_DIR\FCG.Users\FCG.Users\FCG.Users.WebAPI\Dockerfile" `
        "$REPOS_DIR\FCG.Users\FCG.Users"

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao buildar Users API"
    }

    # Build Payments API when ready
    Write-Host "`nBuild Payments API..." -ForegroundColor Yellow
    docker build -t payments-api:$IMAGE_TAG -t payments-api:latest `
        -f "$REPOS_DIR\FCG.Payments\FCG.Payments\FCG.Payments.WebAPI\Dockerfile" `
        "$REPOS_DIR\FCG.Payments\FCG.Payments"

    # Build Notification API when ready
    Write-Host "`nBuild Notification API..." -ForegroundColor Yellow
    docker build -t notification-api:$IMAGE_TAG -t notification-api:latest `
        -f "$REPOS_DIR\FCG.Notification\FCG.Notification\FCG.Notification.WebAPI\Dockerfile" `
        "$REPOS_DIR\FCG.Notification\FCG.Notification"

    Write-Host "`n✅ Todas as imagens foram buildadas com sucesso!" -ForegroundColor Green
    Write-Host "   Tag: $IMAGE_TAG" -ForegroundColor Gray
}
catch {
    Write-Host "`n❌ Erro: $_" -ForegroundColor Red
    exit 1
}
