# Build das Imagens Docker
# PowerShell Script

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Build das Imagens Docker" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"
$BASE_DIR = "C:\Users\m.oliveira.goncalves\source\repos"

try {
    # Build Catalog API
    Write-Host "`nBuild Catalog API..." -ForegroundColor Yellow
    docker build -t catalog-api:latest `
        -f "$BASE_DIR\FCG.Catalog\FCG.Catalog\FCG.Catalog.WebAPI\Dockerfile" `
        "$BASE_DIR\FCG.Catalog\FCG.Catalog"

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao buildar Catalog API"
    }

    # Build Users API
    Write-Host "`nBuild Users API..." -ForegroundColor Yellow
    docker build -t users-api:latest `
        -f "$BASE_DIR\FCG.Users\FCG.Users\FCG.Users.WebAPI\Dockerfile" `
        "$BASE_DIR\FCG.Users\FCG.Users"

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao buildar Users API"
    }

    # TODO: Build Payments API when ready
    # Write-Host "`nBuild Payments API..." -ForegroundColor Yellow
    # docker build -t payments-api:latest `
    #     -f "$BASE_DIR\FCG.Payments\FCG.Payments\FCG.Payments.WebAPI\Dockerfile" `
    #     "$BASE_DIR\FCG.Payments\FCG.Payments"

    # TODO: Build Notifications API when ready
    # Write-Host "`nBuild Notifications API..." -ForegroundColor Yellow
    # docker build -t notifications-api:latest `
    #     -f "$BASE_DIR\FCG.Notifications\FCG.Notifications\FCG.Notifications.WebAPI\Dockerfile" `
    #     "$BASE_DIR\FCG.Notifications\FCG.Notifications"

    Write-Host "`n✅ Todas as imagens foram buildadas com sucesso!" -ForegroundColor Green
}
catch {
    Write-Host "`n❌ Erro: $_" -ForegroundColor Red
    exit 1
}
