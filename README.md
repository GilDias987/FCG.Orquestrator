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
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

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

### Opção 2: Kubernetes Local com Kind

```powershell
# Deploy completo (build, cluster, deploy) - UM ÚNICO COMANDO!
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
2. ✅ Criar cluster Kind local
3. ✅ Carregar imagens no cluster (sem registry externo)
4. ✅ Aplicar todos os recursos Kubernetes
5. ✅ Aguardar pods ficarem prontos
6. ✅ Exibir status e URLs

### Deploy passo a passo (avançado)

Se preferir executar cada etapa manualmente:

```powershell
# 1. Build das imagens
.\scripts\build-images.ps1

# 2. Criar cluster Kind
.\scripts\kind-create-cluster.ps1

# 3. Carregar imagens no Kind
.\scripts\push-images.ps1

# 4. Aplicar recursos Kubernetes
cd k8s
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

# Deletar cluster
kind delete cluster --name fcg-cluster
```

## 📜 Scripts Disponíveis

### PowerShell (Windows)

| Script | Descrição |
|--------|-----------|
| `deploy-local.ps1` | **Deploy completo automático** |
| `build-images.ps1` | Build de todas as imagens Docker |
| `kind-create-cluster.ps1` | Cria cluster Kind com portas mapeadas |
| `push-images.ps1` | Carrega imagens no Kind (sem registry) |

### Bash (Linux/Mac)

| Script | Descrição |
|--------|-----------|
| `deploy-local.sh` | Deploy completo automático |
| `build-images.sh` | Build de todas as imagens Docker |
| `kind-create-cluster.sh` | Cria cluster Kind com portas mapeadas |
| `push-images.sh` | Carrega imagens no Kind (sem registry) |

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
    ├── kind-create-cluster.ps1     # PowerShell - Cluster
    ├── push-images.ps1             # PowerShell - Load images
    ├── deploy-local.sh             # Bash - Deploy completo
    ├── build-images.sh             # Bash - Build
    ├── kind-create-cluster.sh      # Bash - Cluster
    └── push-images.sh              # Bash - Load images
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

### Kubernetes (Kind)

| Serviço | URL | Credenciais |
|---------|-----|-------------|
| Users API | http://localhost:30080 | - |
| Catalog API | http://localhost:30081 | - |
| RabbitMQ AMQP | localhost:30672 | - |
| RabbitMQ Management | http://localhost:31672 | admin/admin123 |

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

### Docker Compose

```powershell
# Recrear containers do zero
docker-compose down -v
docker-compose up -d --build

# Ver logs com erro
docker-compose logs --tail=100 catalog-api
```

### Kubernetes

```powershell
# Ver eventos do cluster
kubectl get events --sort-by='.lastTimestamp'

# Ver logs de um pod com erro
kubectl logs <pod-name> --previous

# Reiniciar deployment
kubectl rollout restart deployment catalog-api-deployment

# Deletar e recriar cluster
kind delete cluster --name fcg-cluster
.\scripts\deploy-local.ps1
```

### Problemas comuns

**Porta em uso:**
```powershell
# Windows - Ver processo usando porta
netstat -ano | findstr :8080
taskkill /PID <PID> /F
```

**Imagem não encontrada no Kind:**
```powershell
# Recarregar imagens
.\scripts\push-images.ps1
```

**Pods em CrashLoopBackOff:**
```powershell
# Ver logs do pod
kubectl logs <pod-name>
kubectl describe pod <pod-name>
```

## 📚 Recursos Adicionais

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Kind Documentation](https://kind.sigs.k8s.io/)
- [RabbitMQ Documentation](https://www.rabbitmq.com/documentation.html)

---

**Desenvolvido pela equipe FCG** 🚀
