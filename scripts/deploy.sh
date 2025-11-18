#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   WordPress + MySQL K8s Deployment    ║${NC}"
echo -e "${BLUE}║         Using kubeadm Cluster          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"

# Check if secrets exist
if [ ! -f mysql/mysql-secret.yaml ]; then
    echo -e "${YELLOW}  Secrets not found. Creating secrets first...${NC}\n"
    ./scripts/create-secrets.sh
fi

echo -e "${YELLOW} Deploying WordPress + MySQL to Kubernetes...${NC}\n"

# Deploy MySQL
echo -e "${GREEN} Step 1/5: Deploying MySQL ConfigMap...${NC}"
kubectl apply -f mysql/mysql-configmap.yaml

echo -e "${GREEN} Step 2/5: Deploying MySQL Secret...${NC}"
kubectl apply -f mysql/mysql-secret.yaml

echo -e "${GREEN} Step 3/5: Deploying MySQL Storage (PV & PVC)...${NC}"
kubectl apply -f mysql/mysql-pv.yaml
kubectl apply -f mysql/mysql-pvc.yaml

echo -e "${GREEN} Step 4/5: Deploying MySQL Database...${NC}"
kubectl apply -f mysql/mysql-deployment.yaml
kubectl apply -f mysql/mysql-service.yaml

echo -e "${YELLOW} Waiting for MySQL to be ready (this may take 1-2 minutes)...${NC}"
kubectl wait --for=condition=ready pod -l app=mysql --timeout=300s || {
    echo -e "${RED} MySQL failed to start. Checking logs...${NC}"
    kubectl logs -l app=mysql --tail=50
    exit 1
}

echo -e "${GREEN} MySQL is readyscripts/create-secrets.sh{NC}\n"

# Deploy WordPress
echo -e "${GREEN} Step 5/5: Deploying WordPress Application...${NC}"
kubectl apply -f wordpress/wordpress-pv.yaml
kubectl apply -f wordpress/wordpress-configmap.yaml
kubectl apply -f wordpress/wordpress-pvc.yaml
kubectl apply -f wordpress/wordpress-deployment.yaml
kubectl apply -f wordpress/wordpress-service.yaml

echo -e "${YELLOW} Waiting for WordPress to be ready (this may take 1-2 minutes)...${NC}"
kubectl wait --for=condition=ready pod -l app=wordpress --timeout=300s || {
    echo -e "${RED} WordPress failed to start. Checking logs...${NC}"
    kubectl logs -l app=wordpress --tail=50
    exit 1
}

echo -e "${GREEN} WordPress is readyscripts/create-secrets.sh{NC}\n"

# Get service info
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}          Deployment Summary          ${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}\n"

echo -e "${YELLOW}Pods Status:${NC}"
kubectl get pods

echo -e "\n${YELLOW}Services:${NC}"
kubectl get svc

echo -e "\n${YELLOW}PersistentVolumes:${NC}"
kubectl get pv,pvc

# Get access info
NODEPORT=$(kubectl get svc wordpress-service -o jsonpath='{.spec.ports[0].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

# Try to get public IP
if command -v curl &> /dev/null; then
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "")
fi

echo -e "\n${BLUE}═══════════════════════════════════════${NC}"
echo -e "${GREEN} Access WordPress at:${NC}"
echo -e "${YELLOW}   Internal IP: http://${NODE_IP}:${NODEPORT}${NC}"
if [ ! -z "$PUBLIC_IP" ]; then
    echo -e "${YELLOW}   Public IP:   http://${PUBLIC_IP}:${NODEPORT}${NC}"
    echo -e "\n${RED}  Make sure port ${NODEPORT} is open in your EC2 Security Groupscripts/create-secrets.sh{NC}"
fi
echo -e "${BLUE}═══════════════════════════════════════${NC}\n"

echo -e "${GREEN} Deployment completed successfullyscripts/create-secrets.sh{NC}\n"
