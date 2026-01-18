# Script de Limpeza do Deploy Kubernetes
# PowerShell Script

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Limpeza do Deploy Kubernetes" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"

# Verificar se kubectl está disponível
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "Erro: kubectl nao encontrado!" -ForegroundColor Red
    exit 1
}

# Confirmar ação
Write-Host "ATENCAO: Esta acao ira remover todos os recursos do Kubernetes!" -ForegroundColor Yellow
Write-Host "Isso inclui:" -ForegroundColor Yellow
Write-Host "  - Todos os Deployments" -ForegroundColor Gray
Write-Host "  - Todos os Services" -ForegroundColor Gray
Write-Host "  - Todos os ConfigMaps e Secrets" -ForegroundColor Gray
Write-Host "  - Todos os PersistentVolumeClaims (dados serao perdidos!)" -ForegroundColor Gray
Write-Host ""

$confirmation = Read-Host "Deseja continuar? (digite 'SIM' para confirmar)"
if ($confirmation -ne "SIM") {
    Write-Host "Operacao cancelada." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Iniciando limpeza..." -ForegroundColor Yellow
Write-Host ""

try {
    # 1. Deletar Deployments
    Write-Host "1. Removendo Deployments..." -ForegroundColor Yellow
    kubectl delete deployments --all 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   Deployments removidos!" -ForegroundColor Green
    }

    # 2. Deletar Services
    Write-Host "2. Removendo Services..." -ForegroundColor Yellow
    kubectl delete services --all --ignore-not-found=true 2>$null
    # Recriar o service do Kubernetes (default)
    Start-Sleep -Seconds 2

    # 3. Deletar ConfigMaps
    Write-Host "3. Removendo ConfigMaps..." -ForegroundColor Yellow
    kubectl delete configmaps --all 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ConfigMaps removidos!" -ForegroundColor Green
    }

    # 4. Deletar Secrets
    Write-Host "4. Removendo Secrets..." -ForegroundColor Yellow
    kubectl delete secrets --all 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   Secrets removidos!" -ForegroundColor Green
    }

    # 5. Deletar PVCs
    Write-Host "5. Removendo PersistentVolumeClaims..." -ForegroundColor Yellow
    kubectl delete pvc --all 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   PVCs removidos!" -ForegroundColor Green
    }

    # 6. Aguardar finalização
    Write-Host "6. Aguardando finalizacao..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5

    # 7. Verificar limpeza
    Write-Host "7. Verificando limpeza..." -ForegroundColor Yellow
    $remainingPods = kubectl get pods -o json 2>$null | ConvertFrom-Json
    if ($remainingPods.items.Count -eq 0) {
        Write-Host "   Limpeza concluida com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "   Alguns pods ainda estao sendo finalizados..." -ForegroundColor Yellow
        kubectl get pods
    }

    Write-Host ""
    Write-Host "======================================" -ForegroundColor Green
    Write-Host "Limpeza Concluida!" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Voce pode agora:" -ForegroundColor Cyan
    Write-Host "  - Executar um novo deploy: .\deploy-local.ps1" -ForegroundColor White
    Write-Host "  - Deletar o cluster: kind delete cluster --name fcg-cluster" -ForegroundColor White
    Write-Host ""
}
catch {
    Write-Host ""
    Write-Host "Erro durante limpeza: $_" -ForegroundColor Red
    Write-Host "Pode ser necessario executar manualmente:" -ForegroundColor Yellow
    Write-Host "  kubectl delete all --all --force --grace-period=0" -ForegroundColor Gray
    exit 1
}
