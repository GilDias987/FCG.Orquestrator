#!/bin/bash

set -e

CLUSTER_NAME="fcg-cluster"

echo "======================================"
echo "Creating Kind Cluster"
echo "======================================"

# Verifica se o cluster já existe
if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  echo "⚠️  Cluster '${CLUSTER_NAME}' já existe. Deletando..."
  kind delete cluster --name ${CLUSTER_NAME}
fi

echo "Criando novo cluster..."
cat <<EOF | kind create cluster --name ${CLUSTER_NAME} --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 30080
    protocol: TCP
  - containerPort: 30081
    hostPort: 30081
    protocol: TCP
  - containerPort: 30672
    hostPort: 30672
    protocol: TCP
  - containerPort: 31672
    hostPort: 31672
    protocol: TCP
EOF

echo "✅ Cluster '${CLUSTER_NAME}' criado com sucesso!"
echo ""
echo "Endpoints:"
echo "  - Users API: http://localhost:30080"
echo "  - Catalog API: http://localhost:30081"
echo "  - RabbitMQ AMQP: localhost:30672"
echo "  - RabbitMQ Management: http://localhost:31672"
