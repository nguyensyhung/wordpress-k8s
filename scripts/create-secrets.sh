#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW} Creating Kubernetes Secrets from .env file...${NC}\n"

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${RED} Error: .env file not found!${NC}"
    echo -e "${YELLOW}Please copy .env.example to .env and update with your values${NC}"
    exit 1
fi

# Load environment variables
source .env

# Validate required variables
if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ]; then
    echo -e "${RED} Error: Missing required MySQL environment variables${NC}"
    exit 1
fi

# Create MySQL Secret
kubectl create secret generic mysql-secret \
  --from-literal=root-password="$MYSQL_ROOT_PASSWORD" \
  --from-literal=user="$MYSQL_USER" \
  --from-literal=password="$MYSQL_PASSWORD" \
  --dry-run=client -o yaml > mysql/mysql-secret.yaml

echo -e "${GREEN} Created mysql/mysql-secret.yaml${NC}"

echo -e "\n${GREEN} Secrets created successfully!${NC}"
echo -e "${YELLOW}  Note: *-secret.yaml files are gitignored for security${NC}\n"
