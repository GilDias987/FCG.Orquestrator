#!/bin/bash

set -e

CLUSTER_NAME="fcg-cluster"

echo "======================================"
echo "Carregando Imagens no Cluster"
echo "======================================"

echo "Carregando catalog-api:latest..."
kind load docker-image catalog-api:latest --name ${CLUSTER_NAME}

echo "Carregando users-api:latest..."
kind load docker-image users-api:latest --name ${CLUSTER_NAME}

# TODO: Uncomment when Payments API is ready
# echo "Loading payments-api:latest..."
# kind load docker-image payments-api:latest --name ${CLUSTER_NAME}

# TODO: Uncomment when Notifications API is ready
# echo "Loading notifications-api:latest..."
# kind load docker-image notifications-api:latest --name ${CLUSTER_NAME}

echo "✅ Todas as imagens foram carregadas no cluster com sucesso!"
