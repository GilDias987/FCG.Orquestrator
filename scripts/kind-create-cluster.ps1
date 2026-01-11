# Verificar Cluster Kubernetes
# PowerShell Script

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Verificando Cluster Kubernetes" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"

try {
    # Verifica se kubectl está configurado
    Write-Host "`nVerificando conexão com cluster..." -ForegroundColor Yellow
    
    $clusterInfo = kubectl cluster-info 2>$null
    
    if ($LASTEXITCODE -ne 0) {
        throw "kubectl não está configurado ou cluster não está disponível"
    }

    Write-Host "Cluster conectado!" -ForegroundColor Green
    Write-Host "`nInformações do cluster:" -ForegroundColor Cyan
    kubectl cluster-info
    
    Write-Host "`nContexto atual:" -ForegroundColor Cyan
    kubectl config current-context
    
    Write-Host "`nNodes disponíveis:" -ForegroundColor Cyan
    kubectl get nodes
    
    Write-Host "`n✅ Cluster Kubernetes está pronto!" -ForegroundColor Green
    Write-Host "`nEndpoints (NodePort):" -ForegroundColor Cyan
    Write-Host "  - Users API:           http://localhost:30080"
    Write-Host "  - Catalog API:         http://localhost:30081"
    Write-Host "  - RabbitMQ AMQP:       localhost:30672"
    Write-Host "  - RabbitMQ Management: http://localhost:31672"
    Write-Host "`nNota: Certifique-se de que o Kubernetes do Docker Desktop está habilitado" -ForegroundColor Gray
}
catch {
    Write-Host "`n❌ Erro: $_" -ForegroundColor Red
    Write-Host "`nDica: Habilite o Kubernetes no Docker Desktop:" -ForegroundColor Yellow
    Write-Host "  Docker Desktop -> Settings -> Kubernetes -> Enable Kubernetes" -ForegroundColor Gray
    exit 1
}
