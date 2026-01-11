# Utilitários Kubectl
# PowerShell Script

param(
    [Parameter(Position=0)]
    [ValidateSet('logs', 'shell', 'restart', 'status', 'events', 'delete-all')]
    [string]$Command = 'status',
    
    [Parameter(Position=1)]
    [string]$PodName
)

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Kubectl Utilities - FCG" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

switch ($Command) {
    'logs' {
        if ([string]::IsNullOrEmpty($PodName)) {
            Write-Host "📋 Pods disponíveis:" -ForegroundColor Yellow
            kubectl get pods
            Write-Host "`nUso: .\kubectl-utils.ps1 logs <pod-name>" -ForegroundColor Gray
        } else {
            Write-Host "📋 Logs do pod: $PodName" -ForegroundColor Yellow
            kubectl logs $PodName -f
        }
    }
    
    'shell' {
        if ([string]::IsNullOrEmpty($PodName)) {
            Write-Host "🐚 Pods disponíveis:" -ForegroundColor Yellow
            kubectl get pods
            Write-Host "`nUso: .\kubectl-utils.ps1 shell <pod-name>" -ForegroundColor Gray
        } else {
            Write-Host "🐚 Abrindo shell no pod: $PodName" -ForegroundColor Yellow
            kubectl exec -it $PodName -- /bin/bash
        }
    }
    
    'restart' {
        if ([string]::IsNullOrEmpty($PodName)) {
            Write-Host "🔄 Deployments disponíveis:" -ForegroundColor Yellow
            kubectl get deployments
            Write-Host "`nUso: .\kubectl-utils.ps1 restart <deployment-name>" -ForegroundColor Gray
        } else {
            Write-Host "🔄 Reiniciando deployment: $PodName" -ForegroundColor Yellow
            kubectl rollout restart deployment $PodName
            kubectl rollout status deployment $PodName
        }
    }
    
    'status' {
        Write-Host "📊 Status do Cluster:" -ForegroundColor Yellow
        Write-Host "`n--- Nodes ---" -ForegroundColor Cyan
        kubectl get nodes
        
        Write-Host "`n--- Pods ---" -ForegroundColor Cyan
        kubectl get pods -o wide
        
        Write-Host "`n--- Services ---" -ForegroundColor Cyan
        kubectl get svc
        
        Write-Host "`n--- Deployments ---" -ForegroundColor Cyan
        kubectl get deployments
        
        Write-Host "`n--- ConfigMaps ---" -ForegroundColor Cyan
        kubectl get configmaps
        
        Write-Host "`n--- Secrets ---" -ForegroundColor Cyan
        kubectl get secrets
    }
    
    'events' {
        Write-Host "📅 Últimos eventos do cluster:" -ForegroundColor Yellow
        kubectl get events --sort-by='.lastTimestamp' | Select-Object -Last 20
    }
    
    'delete-all' {
        Write-Host "⚠️  ATENÇÃO: Isso irá deletar TODOS os recursos!" -ForegroundColor Red
        $confirm = Read-Host "Digite 'sim' para confirmar"
        
        if ($confirm -eq 'sim') {
            Write-Host "`n🗑️  Deletando recursos..." -ForegroundColor Yellow
            kubectl delete all --all
            kubectl delete configmap --all
            kubectl delete secret --all
            Write-Host "✅ Recursos deletados!" -ForegroundColor Green
        } else {
            Write-Host "❌ Operação cancelada" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
