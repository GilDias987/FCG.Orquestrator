# Criar Cluster Kind
# PowerShell Script

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Criando Cluster Kind" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"
$CLUSTER_NAME = "fcg-cluster"

try {
    # Verifica se o cluster já existe
    $existingClusters = kind get clusters 2>$null
    if ($existingClusters -contains $CLUSTER_NAME) {
        Write-Host "`n⚠️  Cluster '$CLUSTER_NAME' já existe. Deletando..." -ForegroundColor Yellow
        kind delete cluster --name $CLUSTER_NAME
    }

    # Cria o cluster com configuração
    Write-Host "`nCriando novo cluster..." -ForegroundColor Yellow
    
    $kindConfig = @"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 30080
    protocol: TCP
  - containerPort: 30081
    hostPort: 30081
    protocol: TCP
  - containerPort: 30672
    hostPort: 30672
    protocol: TCP
  - containerPort: 31672
    hostPort: 31672
    protocol: TCP
"@

    $kindConfig | kind create cluster --name $CLUSTER_NAME --config=-
    
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao criar cluster"
    }

    Write-Host "`n✅ Cluster '$CLUSTER_NAME' criado com sucesso!" -ForegroundColor Green
    Write-Host "`nEndpoints:" -ForegroundColor Cyan
    Write-Host "  - Users API:           http://localhost:30080"
    Write-Host "  - Catalog API:         http://localhost:30081"
    Write-Host "  - RabbitMQ AMQP:       localhost:30672"
    Write-Host "  - RabbitMQ Management: http://localhost:31672"
}
catch {
    Write-Host "`n❌ Erro: $_" -ForegroundColor Red
    exit 1
}
