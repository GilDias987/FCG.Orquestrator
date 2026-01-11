# Deploy Local Completo
# PowerShell Script

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "🚀 FCG Kubernetes Deploy Local" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$K8S_DIR = Join-Path (Split-Path -Parent $SCRIPT_DIR) "k8s"

function Show-Error {
    param([string]$Message)
    Write-Host "❌ Erro: $Message" -ForegroundColor Red
    exit 1
}

# Verificar dependências
Write-Host "🔍 Verificando dependências..." -ForegroundColor Gray
$missingTools = @()

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    $missingTools += "docker"
}
if (-not (Get-Command kind -ErrorAction SilentlyContinue)) {
    $missingTools += "kind"
}
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    $missingTools += "kubectl"
}

if ($missingTools.Count -gt 0) {
    Show-Error "Ferramentas não encontradas: $($missingTools -join ', '). Instale-as antes de continuar."
}

Write-Host "✅ Todas as dependências encontradas!`n" -ForegroundColor Green

try {
    # 1. Build das imagens Docker
    Write-Host "📦 1/4: Build das imagens Docker..." -ForegroundColor Yellow
    & "$SCRIPT_DIR\build-images.ps1"
    if ($LASTEXITCODE -ne 0) { Show-Error "Falha ao buildar imagens" }
    Write-Host ""

    # 2. Criar cluster Kind
    Write-Host "🔧 2/4: Criando cluster Kind..." -ForegroundColor Yellow
    & "$SCRIPT_DIR\kind-create-cluster.ps1"
    if ($LASTEXITCODE -ne 0) { Show-Error "Falha ao criar cluster" }
    Write-Host ""

    # 3. Carregar imagens no Kind
    Write-Host "📤 3/4: Carregando imagens no cluster Kind..." -ForegroundColor Yellow
    & "$SCRIPT_DIR\push-images.ps1"
    if ($LASTEXITCODE -ne 0) { Show-Error "Falha ao carregar imagens" }
    Write-Host ""

    # 4. Deploy dos recursos Kubernetes
    Write-Host "☸️  4/4: Deployando recursos Kubernetes..." -ForegroundColor Yellow
    Push-Location $K8S_DIR
    & "$K8S_DIR\apply-all.ps1"
    Pop-Location
    Write-Host ""

    # Aguardar pods ficarem prontos
    Write-Host "⏳ Esperando os pods ficarem prontos..." -ForegroundColor Yellow
    
    $timeout = 120
    Write-Host "Aguardando RabbitMQ..." -ForegroundColor Gray
    kubectl wait --for=condition=ready pod -l app=rabbitmq --timeout="${timeout}s" 2>$null
    if ($LASTEXITCODE -eq 0) { 
        Write-Host "✅ RabbitMQ pronto" -ForegroundColor Green 
    } else {
        Write-Host "⚠️  RabbitMQ pode demorar mais..." -ForegroundColor Yellow 
    }
    
    Write-Host "Aguardando Catalog API..." -ForegroundColor Gray
    kubectl wait --for=condition=ready pod -l app=catalog-api --timeout="${timeout}s" 2>$null
    if ($LASTEXITCODE -eq 0) { 
        Write-Host "✅ Catalog API pronto" -ForegroundColor Green 
    } else {
        Write-Host "⚠️  Catalog API pode demorar mais..." -ForegroundColor Yellow 
    }
    
    Write-Host "Aguardando Users API..." -ForegroundColor Gray
    kubectl wait --for=condition=ready pod -l app=users-api --timeout="${timeout}s" 2>$null
    if ($LASTEXITCODE -eq 0) { 
        Write-Host "✅ Users API pronto" -ForegroundColor Green 
    } else {
        Write-Host "⚠️  Users API pode demorar mais..." -ForegroundColor Yellow 
    }
    Write-Host ""

    # Exibir status
    Write-Host "======================================" -ForegroundColor Green
    Write-Host "✅ Deployment Completo!" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Status do Cluster:" -ForegroundColor Cyan
    Write-Host "Pods:" -ForegroundColor Gray
    kubectl get pods -o wide
    Write-Host "`nServices:" -ForegroundColor Gray
    kubectl get svc
    Write-Host ""
    Write-Host "🌐 URLs de Acesso:" -ForegroundColor Cyan
    Write-Host "  - Users API:           http://localhost:30080"
    Write-Host "  - Catalog API:         http://localhost:30081"
    Write-Host "  - RabbitMQ Management: http://localhost:31672 (admin/admin123)"
    Write-Host ""
    Write-Host "📝 Comandos úteis:" -ForegroundColor Cyan
    Write-Host "  - Ver pods:            kubectl get pods"
    Write-Host "  - Ver services:        kubectl get svc"
    Write-Host "  - Ver logs:            kubectl logs <pod-name>"
    Write-Host "  - Entrar no pod:       kubectl exec -it <pod-name> -- /bin/bash"
    Write-Host "  - Descrever pod:       kubectl describe pod <pod-name>"
    Write-Host "  - Port-forward:        kubectl port-forward svc/<service-name> 8080:80"
    Write-Host "  - Deletar cluster:     kind delete cluster --name fcg-cluster"
    Write-Host "  - Utils kubectl:       .\scripts\kubectl-utils.ps1 [status|logs|shell|restart]"
    Write-Host ""
}
catch {
    Show-Error $_.Exception.Message
}
