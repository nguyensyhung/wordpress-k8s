#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Kubernetes Cluster Status          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"

echo -e "${YELLOW} Nodes:${NC}"
kubectl get nodes -o wide

echo -e "\n${YELLOW} System Pods:${NC}"
kubectl get pods -A

echo -e "\n${YELLOW} Services:${NC}"
kubectl get svc -A

echo -e "\n${YELLOW} Storage:${NC}"
kubectl get pv,pvc

echo -e "\n${GREEN} Cluster check completed!${NC}\n"
