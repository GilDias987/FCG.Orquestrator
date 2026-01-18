# Update Deployment Rápido
# PowerShell Script para atualizar um deployment específico sem rebuild completo

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("catalog", "users", "payments", "notification", "all")]
    [string]$Service = "all"
)

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Update Deployment Kubernetes" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

function Update-Deployment {
    param(
        [string]$DeploymentName,
        [string]$ImageName
    )
    
    Write-Host "Atualizando $DeploymentName..." -ForegroundColor Yellow
    
    # Força restart do deployment alterando annotation
    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    kubectl patch deployment $DeploymentName -p "{`"spec`":{`"template`":{`"metadata`":{`"annotations`":{`"kubectl.kubernetes.io/restartedAt`":`"$timestamp`"}}}}}"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ $DeploymentName reiniciado" -ForegroundColor Green
        kubectl rollout status deployment/$DeploymentName --timeout=60s
    } else {
        Write-Host "  ✗ Falha ao atualizar $DeploymentName" -ForegroundColor Red
    }
    Write-Host ""
}

try {
    $deployments = @{
        "catalog" = @{deployment="catalog-api-deployment"; image="catalog-api"}
        "users" = @{deployment="users-api-deployment"; image="users-api"}
        "payments" = @{deployment="payments-api-deployment"; image="payments-api"}
        "notification" = @{deployment="notification-api-deployment"; image="notification-api"}
    }

    if ($Service -eq "all") {
        foreach ($key in $deployments.Keys) {
            Update-Deployment $deployments[$key].deployment $deployments[$key].image
        }
    } else {
        $deploy = $deployments[$Service]
        Update-Deployment $deploy.deployment $deploy.image
    }

    Write-Host "======================================" -ForegroundColor Green
    Write-Host "Update Completo!" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Status dos Pods:" -ForegroundColor Cyan
    kubectl get pods
}
catch {
    Write-Host "`n❌ Erro: $_" -ForegroundColor Red
    exit 1
}
