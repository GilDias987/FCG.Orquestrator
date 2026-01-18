# Deploy Local Completo
# PowerShell Script

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Kubernetes Deploy Local" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$K8S_DIR = Join-Path (Split-Path -Parent $SCRIPT_DIR) "k8s"

function Show-Error {
    param([string]$Message)
    Write-Host "Erro: $Message" -ForegroundColor Red
    exit 1
}

# Verificar dependencias
Write-Host "Verificando dependencias..." -ForegroundColor Gray
$missingTools = @()

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    $missingTools += "docker"
}
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    $missingTools += "kubectl"
}

if ($missingTools.Count -gt 0) {
    Show-Error "Ferramentas nao encontradas: $($missingTools -join ', '). Instale-as antes de continuar."
}

Write-Host "Todas as dependencias encontradas!`n" -ForegroundColor Green

try {
    # 1. Build das imagens Docker
    Write-Host "1/4: Build das imagens Docker..." -ForegroundColor Yellow
    & "$SCRIPT_DIR\build-images.ps1"
    if ($LASTEXITCODE -ne 0) { Show-Error "Falha ao buildar imagens" }
    Write-Host ""

    # 2. Verificar cluster Kubernetes
    Write-Host "2/4: Verificando cluster Kubernetes..." -ForegroundColor Yellow
    & "$SCRIPT_DIR\kind-create-cluster.ps1"
    if ($LASTEXITCODE -ne 0) { Show-Error "Falha ao verificar cluster" }
    Write-Host ""

    # 3. Verificar imagens Docker
    Write-Host "3/4: Verificando imagens Docker..." -ForegroundColor Yellow
    & "$SCRIPT_DIR\push-images.ps1"
    if ($LASTEXITCODE -ne 0) { Show-Error "Falha ao verificar imagens" }
    Write-Host ""

    # 4. Deploy dos recursos Kubernetes
    Write-Host "4/4: Deployando recursos Kubernetes..." -ForegroundColor Yellow
    Push-Location $K8S_DIR
    & "$K8S_DIR\apply-all.ps1"
    Pop-Location
    Write-Host ""

    # Aguardar pods ficarem prontos
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "Aguardando Pods Inicializarem" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "(SQL Servers podem levar ate 2-3 minutos para inicializar...)" -ForegroundColor Gray
    Write-Host ""
    
    $sqlTimeout = 240
    $appTimeout = 180
    
    function Wait-ForPod {
        param(
            [string]$Label,
            [string]$Name,
            [int]$Timeout
        )
        Write-Host "Aguardando $Name..." -ForegroundColor Yellow -NoNewline
        $result = kubectl wait --for=condition=ready pod -l app=$Label --timeout="${Timeout}s" 2>&1
        if ($LASTEXITCODE -eq 0) { 
            Write-Host " PRONTO" -ForegroundColor Green 
            return $true
        } else {
            Write-Host " TIMEOUT/ERRO" -ForegroundColor Red
            Write-Host "  Status atual:" -ForegroundColor Gray
            kubectl get pods -l app=$Label -o wide | Write-Host
            $podName = kubectl get pods -l app=$Label -o jsonpath='{.items[0].metadata.name}' 2>$null
            if ($podName) {
                Write-Host "  Ultimos eventos:" -ForegroundColor Gray
                kubectl describe pod $podName | Select-String -Pattern "Events:" -Context 0,10 | Write-Host
            }
            return $false
        }
    }
    
    Write-Host "1. SQL Servers" -ForegroundColor Cyan
    $catalogSqlReady = Wait-ForPod "catalog-sqlserver" "Catalog SQL Server" $sqlTimeout
    $usersSqlReady = Wait-ForPod "users-sqlserver" "Users SQL Server" $sqlTimeout
    $paymentsSqlReady = Wait-ForPod "payments-sqlserver" "Payments SQL Server" $sqlTimeout
    Write-Host ""

    Write-Host "2. Message Broker" -ForegroundColor Cyan
    $rabbitReady = Wait-ForPod "rabbitmq" "RabbitMQ" $appTimeout
    Write-Host ""
    
    Write-Host "3. APIs" -ForegroundColor Cyan
    $catalogApiReady = Wait-ForPod "catalog-api" "Catalog API" $appTimeout
    $usersApiReady = Wait-ForPod "users-api" "Users API" $appTimeout
    $paymentsApiReady = Wait-ForPod "payments-api" "Payments API" $appTimeout
    $notificationApiReady = Wait-ForPod "notification-api" "Notification API" $appTimeout
    Write-Host ""
    
    # Resumo
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "Resumo da Inicializacao" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    $allReady = $catalogSqlReady -and $usersSqlReady -and $paymentsSqlReady -and $rabbitReady -and $catalogApiReady -and $usersApiReady -and $paymentsApiReady -and $notificationApiReady
    
    if (-not $allReady) {
        Write-Host "ATENCAO: Alguns pods nao iniciaram completamente!" -ForegroundColor Yellow
        Write-Host "Execute os comandos abaixo para diagnosticar:" -ForegroundColor Yellow
        Write-Host "  kubectl get pods" -ForegroundColor Gray
        Write-Host "  kubectl describe pod <pod-name>" -ForegroundColor Gray
        Write-Host "  kubectl logs <pod-name>" -ForegroundColor Gray
        Write-Host ""
    }

    # Exibir status
    Write-Host "======================================" -ForegroundColor Green
    Write-Host "Deployment Completo!" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Status Detalhado do Cluster:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Pods:" -ForegroundColor Yellow
    kubectl get pods -o wide
    Write-Host ""
    Write-Host "Services:" -ForegroundColor Yellow
    kubectl get svc
    Write-Host ""
    Write-Host "PersistentVolumeClaims:" -ForegroundColor Yellow
    kubectl get pvc
    Write-Host ""
    Write-Host "URLs de Acesso:" -ForegroundColor Cyan
    Write-Host "  - Users API:               http://localhost:30080" -ForegroundColor White
    Write-Host "    Swagger:                 http://localhost:30080/swagger" -ForegroundColor Gray
    Write-Host "  - Catalog API:             http://localhost:30081" -ForegroundColor White
    Write-Host "    Swagger:                 http://localhost:30081/swagger" -ForegroundColor Gray
    Write-Host "  - Payments API:            http://localhost:30082" -ForegroundColor White
    Write-Host "    Swagger:                 http://localhost:30082/swagger" -ForegroundColor Gray
    Write-Host "  - Notification API:        http://localhost:30083" -ForegroundColor White
    Write-Host "    Swagger:                 http://localhost:30083/swagger" -ForegroundColor Gray
    Write-Host "  - RabbitMQ Management:     http://localhost:31672" -ForegroundColor White
    Write-Host "    (Credenciais: admin / admin123)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Comandos Uteis:" -ForegroundColor Cyan
    Write-Host "  Monitoramento:" -ForegroundColor Yellow
    Write-Host "    kubectl get pods                     # Ver status dos pods" -ForegroundColor Gray
    Write-Host "    kubectl get pods -w                  # Watch pods em tempo real" -ForegroundColor Gray
    Write-Host "    kubectl get svc                      # Ver services" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Logs:" -ForegroundColor Yellow
    Write-Host "    kubectl logs <pod-name>              # Ver logs de um pod" -ForegroundColor Gray
    Write-Host "    kubectl logs <pod-name> -f           # Seguir logs em tempo real" -ForegroundColor Gray
    Write-Host "    kubectl logs <pod-name> --previous   # Ver logs do container anterior" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Diagnostico:" -ForegroundColor Yellow
    Write-Host "    kubectl describe pod <pod-name>      # Detalhes e eventos do pod" -ForegroundColor Gray
    Write-Host "    kubectl exec -it <pod-name> -- sh    # Entrar no container" -ForegroundColor Gray
    Write-Host "    kubectl get events --sort-by='.lastTimestamp' # Ver eventos recentes" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Limpeza:" -ForegroundColor Yellow
    Write-Host "    kubectl delete all --all             # Deletar todos os recursos" -ForegroundColor Gray
    Write-Host "    kind delete cluster --name fcg-cluster # Deletar cluster completo" -ForegroundColor Gray
    Write-Host ""
}
catch {
    Show-Error $_.Exception.Message
}