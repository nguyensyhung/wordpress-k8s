#!/bin/bash

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED}  Cleaning up WordPress + MySQL deployment...${NC}\n"

# Delete WordPress
echo -e "${YELLOW}Deleting WordPress resources...${NC}"
kubectl delete -f wordpress/wordpress-service.yaml --ignore-not-found=true
kubectl delete -f wordpress/wordpress-deployment.yaml --ignore-not-found=true
kubectl delete -f wordpress/wordpress-pvc.yaml --ignore-not-found=true
kubectl delete -f wordpress/wordpress-pv.yaml --ignore-not-found=true
kubectl delete -f wordpress/wordpress-configmap.yaml --ignore-not-found=true

# Delete MySQL
echo -e "${YELLOW}Deleting MySQL resources...${NC}"
kubectl delete -f mysql/mysql-service.yaml --ignore-not-found=true
kubectl delete -f mysql/mysql-deployment.yaml --ignore-not-found=true
kubectl delete -f mysql/mysql-pvc.yaml --ignore-not-found=true
kubectl delete -f mysql/mysql-pv.yaml --ignore-not-found=true
kubectl delete -f mysql/mysql-configmap.yaml --ignore-not-found=true
kubectl delete secret mysql-secret --ignore-not-found=true

# Delete Ingress if exists
if [ -f ingress/wordpress-ingress.yaml ]; then
    kubectl delete -f ingress/wordpress-ingress.yaml --ignore-not-found=true
fi

echo -e "\n${GREEN} Cleanup completed!${NC}"
echo -e "${YELLOW}Note: PersistentVolume data still exists at /mnt/data/${NC}\n"
