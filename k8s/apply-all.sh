#!/bin/bash

set -e

echo 'Applying namespace'
kubectl apply -f namespaces/

echo 'Applying RabbitMQ'
kubectl apply -f rabbitmq/

echo 'Applying Users API'
kubectl apply -f users-api/

echo 'Applying Catalog API'
kubectl apply -f catalog-api/

echo 'Applying Payments API'
kubectl apply -f payments-api/

echo 'Applying Notifications API'
kubectl apply -f notifications-api/

echo 'All resources applied successfully'
