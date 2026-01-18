# FCG.Orquestrator

Repositório centralizador para orquestração dos microsserviços FCG usando Docker Compose e Kubernetes.

## 📋 Índice

- [Sobre](#sobre)
- [Arquitetura](#arquitetura)
- [Pré-requisitos](#pré-requisitos)
- [Quick Start](#quick-start)
- [Docker Compose](#docker-compose)
- [Kubernetes Local](#kubernetes-local)
- [Scripts Disponíveis](#scripts-disponíveis)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [URLs de Acesso](#urls-de-acesso)

## 🎯 Sobre

Este repositório orquestra os seguintes microsserviços:

- **FCG.Catalog** - API de catálogo de produtos
- **FCG.Users** - API de gerenciamento de usuários
- **FCG.Payments** *(em desenvolvimento)* - API de pagamentos
- **FCG.Notifications** *(em desenvolvimento)* - API de notificações

### Infraestrutura Compartilhada

- **RabbitMQ** - Message broker para comunicação assíncrona
- **SQL Server** - Banco de dados por serviço (pattern de microsserviços)

## 🏗️ Arquitetura

Seguindo as melhores práticas de microsserviços:

- ✅ **Database per Service** - Cada API tem seu próprio banco de dados
- ✅ **Async Communication** - RabbitMQ para mensageria
- ✅ **Container Orchestration** - Kubernetes para produção
- ✅ **Local Development** - Docker Compose para desenvolvimento

## 📦 Pré-requisitos

### Para Docker Compose:
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Docker Compose](https://docs.docker.com/compose/install/) (incluído no Docker Desktop)

### Para Kubernetes Local:
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) com Kubernetes habilitado
  - Settings → Kubernetes → ☑ Enable Kubernetes
- kubectl (incluído no Docker Desktop)

## 🚀 Quick Start

### Opção 1: Docker Compose (Recomendado para desenvolvimento)

```powershell
# Subir todos os serviços
docker-compose up -d

# Ver logs
docker-compose logs -f

# Parar serviços
docker-compose down
```

### Opção 2: Kubernetes Local (Docker Desktop)

```powershell
# 1. Habilite Kubernetes no Docker Desktop:
# Docker Desktop → Settings → Kubernetes → Enable Kubernetes

# 2. Deploy completo (build, verificar cluster, deploy) - UM COMANDO!
.\scripts\deploy-local.ps1
```

## 🐳 Docker Compose

### Subir ambiente completo

```powershell
docker-compose up -d
```

### Serviços incluídos:

| Serviço | Porta | Descrição |
|---------|-------|-----------|
| catalog-api | 8081 | API de Catálogo |
| users-api | 8080 | API de Usuários |
| catalog-sqlserver | 1433 | Banco Catalog |
| users-sqlserver | 1434 | Banco Users |
| rabbitmq | 5672, 15672 | Message Broker |

### Comandos úteis:

```powershell
# Ver status dos containers
docker-compose ps

# Ver logs de um serviço específico
docker-compose logs -f catalog-api

# Rebuild e reiniciar um serviço
docker-compose up -d --build catalog-api

# Parar e remover tudo
docker-compose down -v
```

## ☸️ Kubernetes Local

### Deploy automático (recomendado)

Execute o script principal que faz tudo:

```powershell
.\scripts\deploy-local.ps1
```

Este script irá:
1. ✅ Buildar todas as imagens Docker
2. ✅ Verificar cluster Kubernetes do Docker Desktop
3. ✅ Verificar imagens Docker disponíveis
4. ✅ Aplicar todos os recursos Kubernetes
5. ✅ Aguardar pods ficarem prontos
6. ✅ Exibir status e URLs

### Deploy passo a passo (avançado)

Se preferir executar cada etapa manualmente:

```powershell
# 1. Build das imagens
.\scripts\build-images.ps1

# 2. Verificar cluster Kubernetes
.\scripts\kind-create-cluster.ps1

# 3. Verificar imagens disponíveis
.\scripts\push-images.ps1

# 4. Aplicar recursos Kubernetes
cd k8s
.\apply-all.ps1
# Ou manualmente:
kubectl apply -f namespaces/
kubectl apply -f rabbitmq/
kubectl apply -f users-api/
kubectl apply -f catalog-api/
```

### Comandos Kubernetes úteis:

```powershell
# Ver todos os pods
kubectl get pods

# Ver serviços
kubectl get svc

# Ver logs de um pod
kubectl logs <pod-name>

# Descrever um pod
kubectl describe pod <pod-name>

# Executar comando em um pod
kubectl exec -it <pod-name> -- /bin/bash

# Limpar todos os recursos
kubectl delete all --all

# Utilitário kubectl (ver logs, shell, etc)
.\scripts\kubectl-utils.ps1 status
```

## 📜 Scripts Disponíveis

### PowerShell (Windows)

| Script | Descrição |
|--------|-----------|
| `deploy-local.ps1` | **Deploy completo automático com logs detalhados** |
| `build-images.ps1` | Build de todas as imagens Docker |
| `kind-create-cluster.ps1` | Verifica cluster Kubernetes disponível |
| `push-images.ps1` | Verifica imagens Docker disponíveis |
| `diagnose.ps1` | **Diagnóstico completo do cluster e troubleshooting** |
| `cleanup.ps1` | **Limpa todos os recursos do Kubernetes** |
| `kubectl-utils.ps1` | Utilitários kubectl (logs, shell, status, etc) |

### Bash (Linux/Mac)

| Script | Descrição |
|--------|-----------|
| `deploy-local.sh` | Deploy completo automático |
| `build-images.sh` | Build de todas as imagens Docker |
| `kind-create-cluster.sh` | Verifica cluster Kubernetes disponível |
| `push-images.sh` | Verifica imagens Docker disponíveis |

### 🔍 Novo: Script de Diagnóstico

Execute quando tiver problemas com o deploy:

```powershell
.\scripts\diagnose.ps1
```

Este script fornece:
- ✅ Status detalhado de todos os pods
- ✅ Identificação de pods com problemas
- ✅ Eventos recentes do cluster
- ✅ Logs dos pods com erro
- ✅ Teste de conectividade com as APIs
- ✅ Recomendações de troubleshooting

### 🧹 Novo: Script de Limpeza

Limpe completamente o ambiente:

```powershell
.\scripts\cleanup.ps1
```

Remove todos os recursos do Kubernetes de forma segura.

## 📁 Estrutura do Projeto

```
FCG.Orquestrator/
├── docker-compose.yml              # Compose principal
├── docker-compose.override.yml     # Overrides por ambiente
├── k8s/                            # Recursos Kubernetes
│   ├── namespaces/
│   │   └── fcg-namespace.yaml
│   ├── rabbitmq/
│   │   ├── rabbitmq-configmap.yaml
│   │   ├── rabbitmq-secret.yaml
│   │   ├── rabbitmq-deployment.yaml
│   │   └── rabbitmq-service.yaml
│   ├── catalog-api/
│   │   ├── catalog-configmap.yaml
│   │   ├── catalog-secret.yaml
│   │   ├── catalog-deployment.yaml
│   │   └── catalog-service.yaml
│   ├── users-api/
│   │   ├── users-configmap.yaml
│   │   ├── users-secret.yaml
│   │   ├── users-deployment.yaml
│   │   └── users-service.yaml
│   ├── payments-api/               # Em desenvolvimento
│   └── notifications-api/          # Em desenvolvimento
└── scripts/
    ├── deploy-local.ps1            # PowerShell - Deploy completo
    ├── build-images.ps1            # PowerShell - Build
    ├── kind-create-cluster.ps1     # PowerShell - Verificar cluster
    ├── push-images.ps1             # PowerShell - Verificar imagens
    ├── kubectl-utils.ps1           # PowerShell - Utilitários kubectl
    ├── deploy-local.sh             # Bash - Deploy completo
    ├── build-images.sh             # Bash - Build
    ├── kind-create-cluster.sh      # Bash - Verificar cluster
    └── push-images.sh              # Bash - Verificar imagens
```

## 🌐 URLs de Acesso

### Docker Compose

| Serviço | URL | Credenciais |
|---------|-----|-------------|
| Users API | http://localhost:8080 | - |
| Catalog API | http://localhost:8081 | - |
| RabbitMQ Management | http://localhost:15672 | admin/admin123 |
| SQL Server (Catalog) | localhost:1433 | sa/pass@123 |
| SQL Server (Users) | localhost:1434 | sa/pass@123 |

### Kubernetes (Docker Desktop)

| Serviço | URL | Credenciais |
|---------|-----|-------------|
| Users API | http://localhost:30080 | - |
| Catalog API | http://localhost:30081 | - |
| RabbitMQ AMQP | localhost:30672 | - |
| RabbitMQ Management | http://localhost:31672 | admin/admin123 |

**Nota:** As portas NodePort (300xx) funcionam quando o Kubernetes do Docker Desktop está habilitado.

## 🔧 Configuração

### Variáveis de Ambiente

As variáveis são configuradas nos arquivos:
- **Docker Compose**: `docker-compose.yml` e `docker-compose.override.yml`
- **Kubernetes**: ConfigMaps e Secrets em `k8s/*/`

### Secrets Kubernetes

⚠️ **Importante**: Os secrets estão em plain text (stringData) apenas para desenvolvimento local. Em produção, use:
- Azure Key Vault
- AWS Secrets Manager
- HashiCorp Vault
- Kubernetes External Secrets

## 🐛 Troubleshooting

### Diagnóstico Automático (Recomendado)

Execute o script de diagnóstico completo:

```powershell
.\scripts\diagnose.ps1
```

Este script identifica automaticamente problemas e fornece recomendações.

### Docker Compose

```powershell
# Recrear containers do zero
docker-compose down -v
docker-compose up -d --build

# Ver logs com erro
docker-compose logs --tail=100 catalog-api
```

### Kubernetes

#### Comandos Rápidos de Diagnóstico

```powershell
# Status geral dos pods
kubectl get pods -o wide

# Ver eventos recentes
kubectl get events --sort-by='.lastTimestamp' | Select-Object -Last 20

# Logs de um pod específico
kubectl logs <pod-name>

# Logs do container anterior (útil para crashloop)
kubectl logs <pod-name> --previous

# Detalhes completos de um pod
kubectl describe pod <pod-name>

# Executar diagnóstico completo
.\scripts\diagnose.ps1
```

#### Soluções para Problemas Comuns

**1. Pods em Pending/Waiting:**
```powershell
# Verificar se há recursos suficientes
kubectl describe pod <pod-name>

# Verificar PVCs
kubectl get pvc

# Verificar se imagens foram criadas
docker images | findstr "catalog-api\|users-api"
```

**2. Pods em CrashLoopBackOff:**
```powershell
# Ver logs do crash
kubectl logs <pod-name> --previous

# Verificar configurações
kubectl get configmap <configmap-name> -o yaml
kubectl get secret <secret-name> -o yaml

# Executar diagnóstico
.\scripts\diagnose.ps1
```

**3. Pods em ImagePullBackOff:**
```powershell
# Rebuildar imagens
.\scripts\build-images.ps1

# Verificar imagens disponíveis
docker images

# Verificar imagePullPolicy nos deployments
kubectl get deployment <deployment-name> -o yaml | Select-String "imagePullPolicy"
```

**4. Timeout durante deploy:**
```powershell
# Os init containers aguardam dependências
# Verifique se SQL Server e RabbitMQ estão prontos primeiro
kubectl get pods -l app=catalog-sqlserver
kubectl get pods -l app=users-sqlserver
kubectl get pods -l app=rabbitmq

# Ver logs dos init containers
kubectl logs <pod-name> -c wait-for-sqlserver
kubectl logs <pod-name> -c wait-for-rabbitmq

# Aumentar timeout (já configurado para 3-4 minutos)
# Se ainda assim não funcionar, verificar recursos do sistema
```

**5. Health checks falhando:**
```powershell
# Verificar se endpoint /health existe
kubectl port-forward <pod-name> 8080:8080
# Acessar http://localhost:8080/health no navegador

# Ver logs da aplicação
kubectl logs <pod-name> -f
```

**6. Conectividade entre serviços:**
```powershell
# Testar DNS interno
kubectl run test-pod --image=busybox --rm -it -- nslookup catalog-api

# Testar conectividade
kubectl run test-pod --image=busybox --rm -it -- wget -O- http://catalog-api:8080/health
```

### Limpar e Redeployar

Se nada funcionar, limpe tudo e redeploy:

```powershell
# Limpeza segura com confirmação
.\scripts\cleanup.ps1

# Ou força bruta
kubectl delete all --all --force --grace-period=0
kubectl delete pvc --all

# Aguardar limpeza
Start-Sleep -Seconds 10

# Redeploy completo
.\scripts\deploy-local.ps1
```

### Outros Problemas Comuns

**Porta em uso:**
```powershell
# Windows - Ver processo usando porta
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# Linux/Mac
lsof -i :8080
kill -9 <PID>
```

**Recursos insuficientes:**
```powershell
# Aumentar recursos no Docker Desktop
# Settings → Resources → Aumentar CPU/Memory

# Verificar uso atual
docker stats
```

**Volumes com permissão incorreta:**
```powershell
# Remover volumes e recriar
docker volume ls
docker volume rm <volume-name>
kubectl delete pvc --all
```

## 📚 Recursos Adicionais

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Docker Desktop Kubernetes](https://docs.docker.com/desktop/kubernetes/)
- [RabbitMQ Documentation](https://www.rabbitmq.com/documentation.html)

## 💡 Dicas

**Por que Docker Desktop Kubernetes?**
- ✅ Já vem com Docker Desktop (sem instalação extra)
- ✅ Imagens locais disponíveis automaticamente
- ✅ Mais simples que Kind ou Minikube
- ✅ Ideal para desenvolvimento local
- ✅ 1 click para habilitar

**Quando usar Docker Compose vs Kubernetes?**
- **Docker Compose**: Desenvolvimento rápido, testes locais simples
- **Kubernetes**: Validar YAMLs, testar features K8s, ambiente mais próximo de produção

---

**Desenvolvido pela equipe FCG** 🚀
