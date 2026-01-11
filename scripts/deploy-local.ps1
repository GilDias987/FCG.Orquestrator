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

    # 2. Criar cluster Kind
    Write-Host "2/4: Criando cluster Kind..." -ForegroundColor Yellow
    & "$SCRIPT_DIR\kind-create-cluster.ps1"
    if ($LASTEXITCODE -ne 0) { Show-Error "Falha ao criar cluster" }
    Write-Host ""

    # 3. Carregar imagens no Kind
    Write-Host "3/4: Carregando imagens no cluster Kind..." -ForegroundColor Yellow
    & "$SCRIPT_DIR\push-images.ps1"
    if ($LASTEXITCODE -ne 0) { Show-Error "Falha ao carregar imagens" }
    Write-Host ""

    # 4. Deploy dos recursos Kubernetes
    Write-Host "4/4: Deployando recursos Kubernetes..." -ForegroundColor Yellow
    Push-Location $K8S_DIR
    & "$K8S_DIR\apply-all.ps1"
    Pop-Location
    Write-Host ""

    # Aguardar pods ficarem prontos
    Write-Host "Esperando os pods ficarem prontos..." -ForegroundColor Yellow
    
    $timeout = 120
    Write-Host "Aguardando RabbitMQ..." -ForegroundColor Gray
    kubectl wait --for=condition=ready pod -l app=rabbitmq --timeout="${timeout}s" 2>$null
    if ($LASTEXITCODE -eq 0) { 
        Write-Host "RabbitMQ pronto" -ForegroundColor Green 
    } else {
        Write-Host "RabbitMQ pode demorar mais..." -ForegroundColor Yellow 
    }
    
    Write-Host "Aguardando Catalog API..." -ForegroundColor Gray
    kubectl wait --for=condition=ready pod -l app=catalog-api --timeout="${timeout}s" 2>$null
    if ($LASTEXITCODE -eq 0) { 
        Write-Host "Catalog API pronto" -ForegroundColor Green 
    } else {
        Write-Host "Catalog API pode demorar mais..." -ForegroundColor Yellow 
    }
    
    Write-Host "Aguardando Users API..." -ForegroundColor Gray
    kubectl wait --for=condition=ready pod -l app=users-api --timeout="${timeout}s" 2>$null
    if ($LASTEXITCODE -eq 0) { 
        Write-Host "Users API pronto" -ForegroundColor Green 
    } else {
        Write-Host "Users API pode demorar mais..." -ForegroundColor Yellow 
    }
    Write-Host ""

    # Exibir status
    Write-Host "======================================" -ForegroundColor Green
    Write-Host "Deployment Completo!" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Status do Cluster:" -ForegroundColor Cyan
    kubectl get pods -o wide
    Write-Host ""
    kubectl get svc
    Write-Host ""
    Write-Host "URLs de Acesso:" -ForegroundColor Cyan
    Write-Host "  - Users API:           http://localhost:30080"
    Write-Host "  - Catalog API:         http://localhost:30081"
    Write-Host "  - RabbitMQ Management: http://localhost:31672 (admin/admin123)"
    Write-Host ""
    Write-Host "Comandos uteis:" -ForegroundColor Cyan
    Write-Host "  - Ver pods:        kubectl get pods"
    Write-Host "  - Ver services:    kubectl get svc"
    Write-Host "  - Ver logs:        kubectl logs <pod-name>"
    Write-Host "  - Deletar cluster: kind delete cluster --name fcg-cluster"
    Write-Host ""
}
catch {
    Show-Error $_.Exception.Message
}