# Carregar Imagens no Cluster Kind
# PowerShell Script

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Carregando Imagens no Cluster" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"
$CLUSTER_NAME = "fcg-cluster"

try {
    # Carrega Catalog API
    Write-Host "`nCarregando catalog-api:latest..." -ForegroundColor Yellow
    kind load docker-image catalog-api:latest --name $CLUSTER_NAME
    
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao carregar catalog-api"
    }

    # Carrega Users API
    Write-Host "Carregando users-api:latest..." -ForegroundColor Yellow
    kind load docker-image users-api:latest --name $CLUSTER_NAME
    
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao carregar users-api"
    }

    # TODO: Uncomment when Payments API is ready
    # Write-Host "Carregando payments-api:latest..." -ForegroundColor Yellow
    # kind load docker-image payments-api:latest --name $CLUSTER_NAME

    # TODO: Uncomment when Notifications API is ready
    # Write-Host "Carregando notifications-api:latest..." -ForegroundColor Yellow
    # kind load docker-image notifications-api:latest --name $CLUSTER_NAME

    Write-Host "`n✅ Todas as imagens foram carregadas no cluster com sucesso!" -ForegroundColor Green
}
catch {
    Write-Host "`n❌ Erro: $_" -ForegroundColor Red
    exit 1
}
