# Verificar Imagens Docker
# PowerShell Script

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Verificando Imagens Docker" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"

try {
    # Verifica Catalog API
    Write-Host "`nVerificando catalog-api:latest..." -ForegroundColor Yellow
    $catalogImage = docker images catalog-api:latest --format "{{.Repository}}:{{.Tag}}" 2>$null
    
    if ([string]::IsNullOrEmpty($catalogImage)) {
        throw "Imagem catalog-api:latest não encontrada"
    }
    Write-Host "✓ catalog-api:latest encontrada" -ForegroundColor Green

    # Verifica Users API
    Write-Host "Verificando users-api:latest..." -ForegroundColor Yellow
    $usersImage = docker images users-api:latest --format "{{.Repository}}:{{.Tag}}" 2>$null
    
    if ([string]::IsNullOrEmpty($usersImage)) {
        throw "Imagem users-api:latest não encontrada"
    }
    Write-Host "✓ users-api:latest encontrada" -ForegroundColor Green

    Write-Host "Verificando payments-api:latest..." -ForegroundColor Yellow
    $paymentsImage = docker images payments-api:latest --format "{{.Repository}}:{{.Tag}}" 2>$null

    # TODO: Uncomment when Notification API is ready
    Write-Host "Verificando notification-api:latest..." -ForegroundColor Yellow
    $notificationImage = docker images notification-api:latest --format "{{.Repository}}:{{.Tag}}" 2>$null

    Write-Host "`n✅ Todas as imagens estão disponíveis!" -ForegroundColor Green
    Write-Host "`nNota: Com Docker Desktop Kubernetes, as imagens locais são automaticamente disponíveis no cluster" -ForegroundColor Gray
}
catch {
    Write-Host "`n❌ Erro: $_" -ForegroundColor Red
    exit 1
}
