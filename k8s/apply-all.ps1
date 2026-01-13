# Apply all Kubernetes resources
# PowerShell Script

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Aplicando recursos Kubernetes" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"

try {
    Write-Host "`nAplicando namespace..." -ForegroundColor Yellow
    kubectl apply -f namespaces/

    Write-Host "`nAplicando SQL Servers..." -ForegroundColor Yellow
    kubectl apply -f catalog-sqlserver/
    kubectl apply -f users-sqlserver/
    kubectl apply -f payments-sqlserver/
    # kubectl apply -f notifications-sqlserver/

    Write-Host "`nAplicando RabbitMQ..." -ForegroundColor Yellow
    kubectl apply -f rabbitmq/

    Write-Host "`nAplicando Users API..." -ForegroundColor Yellow
    kubectl apply -f users-api/

    Write-Host "`nAplicando Catalog API..." -ForegroundColor Yellow
    kubectl apply -f catalog-api/

    Descomentar quando estiverem prontos
    Write-Host "`nAplicando Payments API..." -ForegroundColor Yellow
    kubectl apply -f payments-api/

    # Write-Host "`nAplicando Notifications API..." -ForegroundColor Yellow
    # kubectl apply -f notifications-api/

    Write-Host "`n✅ Todos os recursos foram aplicados com sucesso!" -ForegroundColor Green
}
catch {
    Write-Host "`n❌ Erro ao aplicar recursos: $_" -ForegroundColor Red
    exit 1
}
