# Script de Diagnostico do Cluster Kubernetes
# PowerShell Script

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Diagnostico do Cluster Kubernetes" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"

# Verificar se kubectl está disponível
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "Erro: kubectl nao encontrado!" -ForegroundColor Red
    exit 1
}

# 1. Status Geral dos Pods
Write-Host "1. STATUS DOS PODS" -ForegroundColor Yellow
Write-Host "==================" -ForegroundColor Yellow
kubectl get pods -o wide
Write-Host ""

# 2. Pods com problemas
Write-Host "2. PODS COM PROBLEMAS" -ForegroundColor Yellow
Write-Host "=====================" -ForegroundColor Yellow
$problemPods = kubectl get pods --field-selector=status.phase!=Running -o jsonpath='{.items[*].metadata.name}' 2>$null
if ($problemPods) {
    Write-Host "Pods com problemas encontrados:" -ForegroundColor Red
    $problemPods.Split(" ") | ForEach-Object {
        if ($_) {
            Write-Host "  - $_" -ForegroundColor Red
            Write-Host "    Status:" -ForegroundColor Gray
            kubectl get pod $_ -o jsonpath='{.status.phase}' | Write-Host
            Write-Host ""
        }
    }
} else {
    Write-Host "Nenhum pod com problemas encontrado!" -ForegroundColor Green
}
Write-Host ""

# 3. Eventos Recentes
Write-Host "3. EVENTOS RECENTES (ultimos 20)" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow
kubectl get events --sort-by='.lastTimestamp' | Select-Object -Last 20
Write-Host ""

# 4. Status dos Services
Write-Host "4. STATUS DOS SERVICES" -ForegroundColor Yellow
Write-Host "======================" -ForegroundColor Yellow
kubectl get svc
Write-Host ""

# 5. Status dos PVCs
Write-Host "5. STATUS DOS PERSISTENT VOLUME CLAIMS" -ForegroundColor Yellow
Write-Host "=======================================" -ForegroundColor Yellow
kubectl get pvc
Write-Host ""

# 6. Uso de Recursos
Write-Host "6. USO DE RECURSOS" -ForegroundColor Yellow
Write-Host "==================" -ForegroundColor Yellow
Write-Host "Tentando obter metricas dos pods..." -ForegroundColor Gray
kubectl top pods 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Metrics server nao disponivel (normal em ambiente local)" -ForegroundColor Yellow
}
Write-Host ""

# 7. Logs dos Pods com Problemas
Write-Host "7. LOGS DOS PODS COM PROBLEMAS" -ForegroundColor Yellow
Write-Host "===============================" -ForegroundColor Yellow
if ($problemPods) {
    $problemPods.Split(" ") | ForEach-Object {
        if ($_) {
            Write-Host "`nLogs do pod: $_" -ForegroundColor Cyan
            Write-Host "----------------------------------------" -ForegroundColor Gray
            kubectl logs $_ --tail=50 2>&1
            Write-Host ""
        }
    }
} else {
    Write-Host "Nenhum pod com problemas para exibir logs." -ForegroundColor Green
}
Write-Host ""

# 8. Detalhes de Pods Específicos por Label
Write-Host "8. STATUS DETALHADO POR COMPONENTE" -ForegroundColor Yellow
Write-Host "===================================" -ForegroundColor Yellow

$components = @{
    "catalog-sqlserver" = "Catalog SQL Server"
    "users-sqlserver" = "Users SQL Server"
    "payments-sqlserver" = "Payments SQL Server"
    "rabbitmq" = "RabbitMQ"
    "catalog-api" = "Catalog API"
    "users-api" = "Users API"
    "payments-api" = "Payments API"
    "notification-api" = "Notification API"
}

foreach ($label in $components.Keys) {
    $name = $components[$label]
    Write-Host "`n$name ($label):" -ForegroundColor Cyan
    
    $podName = kubectl get pods -l app=$label -o jsonpath='{.items[0].metadata.name}' 2>$null
    if ($podName) {
        $status = kubectl get pod $podName -o jsonpath='{.status.phase}' 2>$null
        $ready = kubectl get pod $podName -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>$null
        $restarts = kubectl get pod $podName -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>$null
        
        Write-Host "  Pod: $podName" -ForegroundColor Gray
        Write-Host "  Status: $status" -ForegroundColor Gray
        Write-Host "  Ready: $ready" -ForegroundColor Gray
        Write-Host "  Restarts: $restarts" -ForegroundColor Gray
        
        if ($status -ne "Running" -or $ready -ne "True") {
            Write-Host "  PROBLEMA DETECTADO!" -ForegroundColor Red
            Write-Host "  Ultimos eventos:" -ForegroundColor Yellow
            kubectl describe pod $podName | Select-String -Pattern "Events:" -Context 0,10
        }
    } else {
        Write-Host "  Pod nao encontrado!" -ForegroundColor Red
    }
}
Write-Host ""

# 9. Teste de Conectividade
Write-Host "9. TESTE DE CONECTIVIDADE" -ForegroundColor Yellow
Write-Host "==========================" -ForegroundColor Yellow
Write-Host "Testando conectividade com os services..." -ForegroundColor Gray
Write-Host ""

$services = @(
    @{Name="Users API"; URL="http://localhost:30080/health"}
    @{Name="Catalog API"; URL="http://localhost:30081/health"}
    @{Name="Payments API"; URL="http://localhost:30082/health"}
    @{Name="Notification API"; URL="http://localhost:30083/health"}
    @{Name="RabbitMQ Management"; URL="http://localhost:31672"}
)

foreach ($service in $services) {
    Write-Host "  Testando $($service.Name)..." -NoNewline
    try {
        $response = Invoke-WebRequest -Uri $service.URL -TimeoutSec 5 -UseBasicParsing 2>$null
        if ($response.StatusCode -eq 200) {
            Write-Host " OK" -ForegroundColor Green
        } else {
            Write-Host " FALHOU (Status: $($response.StatusCode))" -ForegroundColor Red
        }
    }
    catch {
        Write-Host " INACESSIVEL" -ForegroundColor Red
    }
}
Write-Host ""

# 10. Resumo e Recomendações
Write-Host "10. RESUMO E RECOMENDACOES" -ForegroundColor Yellow
Write-Host "===========================" -ForegroundColor Yellow
Write-Host ""

$totalPods = (kubectl get pods -o json | ConvertFrom-Json).items.Count
$runningPods = (kubectl get pods --field-selector=status.phase=Running -o json | ConvertFrom-Json).items.Count
$readyPods = (kubectl get pods -o json | ConvertFrom-Json).items | Where-Object { 
    $_.status.conditions | Where-Object { $_.type -eq "Ready" -and $_.status -eq "True" }
} | Measure-Object | Select-Object -ExpandProperty Count

Write-Host "Total de Pods: $totalPods" -ForegroundColor Cyan
Write-Host "Pods Running: $runningPods" -ForegroundColor Cyan
Write-Host "Pods Ready: $readyPods" -ForegroundColor Cyan
Write-Host ""

if ($readyPods -eq $totalPods) {
    Write-Host "STATUS: Todos os pods estao prontos!" -ForegroundColor Green
} else {
    Write-Host "STATUS: Alguns pods nao estao prontos!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "RECOMENDACOES:" -ForegroundColor Cyan
    Write-Host "  1. Verifique os logs dos pods com problemas acima" -ForegroundColor White
    Write-Host "  2. Execute: kubectl describe pod <pod-name>" -ForegroundColor White
    Write-Host "  3. Verifique se as imagens Docker foram criadas corretamente" -ForegroundColor White
    Write-Host "  4. Verifique se os ConfigMaps e Secrets estao corretos" -ForegroundColor White
    Write-Host "  5. Para reiniciar um pod: kubectl delete pod <pod-name>" -ForegroundColor White
}
Write-Host ""

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Diagnostico Concluido" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
