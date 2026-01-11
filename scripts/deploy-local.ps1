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
    Write-Host "Esperando os pods ficarem prontos..." -ForegroundColor Yellow
    
    $timeout = 120
    
    Write-Host "`nAguardando SQL Servers..." -ForegroundColor Yellow
    Write-Host "(SQL Servers podem levar ate 2 minutos para inicializar...)" -ForegroundColor Gray
    
    kubectl wait --for=condition=ready pod -l app=catalog-sqlserver --timeout="${sqlTimeout}s" 2>$null
    if ($LASTEXITCODE -eq 0) { 
        Write-Host "  Catalog SQL Server pronto" -ForegroundColor Green 
    } else {
        Write-Host "  Catalog SQL Server ainda inicializando (verifique: kubectl get pods)" -ForegroundColor Yellow 
    }
    
    kubectl wait --for=condition=ready pod -l app=users-sqlserver --timeout="${sqlTimeout}s" 2>$null
    if ($LASTEXITCODE -eq 0) { 
        Write-Host "  Users SQL Server pronto" -ForegroundColor Green 
    } else {
        Write-Host "  Users SQL Server ainda inicializando (verifique: kubectl get pods)" -ForegroundColor Yellow 
    }

    # kubectl wait --for=condition=ready pod -l app=payments-sqlserver --timeout="${sqlTimeout}s" 2>$null
    # if ($LASTEXITCODE -eq 0) { 
    #     Write-Host "  Payments SQL Server pronto" -ForegroundColor Green
    # } else {
    #     Write-Host "  Payments SQL Server ainda inicializando" -ForegroundColor Yellow
    # }
    
    # kubectl wait --for=condition=ready pod -l app=notifications-sqlserver --timeout="${sqlTimeout}s" 2>$null
    # if ($LASTEXITCODE -eq 0) {
    #     Write-Host "  Notifications SQL Server pronto" -ForegroundColor Green
    # } else {
    #     Write-Host "  Notifications SQL Server ainda inicializando" -ForegroundColor Yellow
    # }

    Write-Host "`nAguardando RabbitMQ..." -ForegroundColor Yellow
    kubectl wait --for=condition=ready pod -l app=rabbitmq --timeout="${appTimeout}s" 2>$null
    if ($LASTEXITCODE -eq 0) { 
        Write-Host "  RabbitMQ pronto" -ForegroundColor Green 
    } else {
        Write-Host "  RabbitMQ ainda inicializando" -ForegroundColor Yellow 
    }
    
    Write-Host "`nAguardando APIs..." -ForegroundColor Yellow
    kubectl wait --for=condition=ready pod -l app=catalog-api --timeout="${appTimeout}s" 2>$null
    if ($LASTEXITCODE -eq 0) { 
        Write-Host "  Catalog API pronto" -ForegroundColor Green 
    } else {
        Write-Host "  Catalog API ainda inicializando" -ForegroundColor Yellow 
    }
    
    kubectl wait --for=condition=ready pod -l app=users-api --timeout="${appTimeout}s" 2>$null
    if ($LASTEXITCODE -eq 0) { 
        Write-Host "  Users API pronto" -ForegroundColor Green 
    } else {
        Write-Host "  Users API ainda inicializando" -ForegroundColor Yellow 
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
    Write-Host "  - Limpar deploy:   kubectl delete all --all"
    Write-Host ""
}
catch {
    Show-Error $_.Exception.Message
}