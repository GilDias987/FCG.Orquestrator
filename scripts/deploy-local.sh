#!/bin/bash

set -e

echo "======================================"
echo "🚀 FCG Kubernetes deploy Local"
echo "======================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
K8S_DIR="$(dirname "$SCRIPT_DIR")/k8s"

# Função para exibir erros
error_exit() {
  echo " Error: $1"
  exit 1
}

# 1. Build das imagens Docker
echo " 1/4: Build das imagens Docker..."
bash "$SCRIPT_DIR/build-images.sh" || error_exit "Failed to build images"
echo ""

# 2. Criar cluster Kind
echo "  2/4: Criando cluster Kind..."
bash "$SCRIPT_DIR/kind-create-cluster.sh" || error_exit "Failed to create cluster"
echo ""

# 3. Carregar imagens no Kind
echo " 3/4: Carregando imagens no cluster Kind..."
bash "$SCRIPT_DIR/push-images.sh" || error_exit "Failed to load images"
echo ""

# 4. Deploy dos recursos Kubernetes
echo "  4/4: Deployando recursos Kubernetes..."
cd "$K8S_DIR"
bash apply-all.sh || error_exit "Failed to deploy resources"
echo ""

# Aguardar os pods ficarem prontos
echo "⏳ Esperando os pods ficarem prontos..."
kubectl wait --for=condition=ready pod -l app=rabbitmq --timeout=120s || echo "⚠️  RabbitMQ pod might take longer"
kubectl wait --for=condition=ready pod -l app=catalog-api --timeout=120s || echo "⚠️  Catalog API pod might take longer"
kubectl wait --for=condition=ready pod -l app=users-api --timeout=120s || echo "⚠️  Users API pod might take longer"
kubectl wait --for=condition=ready pod -l app=payments-api --timeout=120s || echo "⚠️  Payments API pod might take longer"
kubectl wait --for=condition=ready pod -l app=notification-api --timeout=120s || echo "⚠️  Notification API pod might take longer"
echo ""

# Exibir status
echo "======================================"
echo "✅ Deployment Complete!"
echo "======================================"
echo ""
echo "📊 Cluster Status:"
kubectl get pods
echo ""
echo "🌐 Access URLs:"
echo "  - Users API:            http://localhost:30080"
echo "  - Catalog API:         http://localhost:30081"
echo "  - Payments API:     http://localhost:30082"
echo "  - Notification API: http://localhost:30083"
echo "  - RabbitMQ Management: http://localhost:31672 (admin/admin123)"
echo ""
echo "📝 Useful commands:"
echo "  - Check pods:         kubectl get pods"
echo "  - Check services:     kubectl get svc"
echo "  - View logs:          kubectl logs <pod-name>"
echo "  - Delete cluster:     kind delete cluster --name fcg-cluster"
echo ""
