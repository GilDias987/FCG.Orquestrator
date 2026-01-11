#!/bin/bash

set -e

echo "======================================"
echo "Build das Imagens Docker"
echo "======================================"

# Detecta o diretório base automaticamente (pasta repos/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOS_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo "Diretório base: $REPOS_DIR"

# Build Catalog API
echo "Build Catalog API..."
docker build -t catalog-api:latest \
  -f "$REPOS_DIR/FCG.Catalog/FCG.Catalog/FCG.Catalog.WebAPI/Dockerfile" \
  "$REPOS_DIR/FCG.Catalog/FCG.Catalog"

# Build Users API
echo "Build Users API..."
docker build -t users-api:latest \
  -f "$REPOS_DIR/FCG.Users/FCG.Users/FCG.Users.WebAPI/Dockerfile" \
  "$REPOS_DIR/FCG.Users/FCG.Users"

# TODO: Build Payments API when ready
# echo "Building Payments API..."
# docker build -t payments-api:latest \
#   -f "$REPOS_DIR/FCG.Payments/FCG.Payments/FCG.Payments.WebAPI/Dockerfile" \
#   "$REPOS_DIR/FCG.Payments/FCG.Payments"

# TODO: Build Notifications API when ready
# echo "Building Notifications API..."
# docker build -t notifications-api:latest \
#   -f "$REPOS_DIR/FCG.Notifications/FCG.Notifications/FCG.Notifications.WebAPI/Dockerfile" \
#   "$REPOS_DIR/FCG.Notifications/FCG.Notifications"

echo "✅ Todas as imagens foram buildadas com sucesso!"
