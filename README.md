# WordPress + MySQL on Kubernetes (kubeadm)

Production-ready WordPress deployment on Kubernetes cluster created with kubeadm.

## 🏗️ Architecture
```
Kubernetes Cluster (kubeadm)
├── Control Plane
│   ├── kube-apiserver
│   ├── kube-controller-manager
│   ├── kube-scheduler
│   └── etcd
├── Container Runtime: containerd
├── Network Plugin: Flannel/Calico
└── Applications
    ├── MySQL
    │   ├── Deployment (1 replica)
    │   ├── Service (ClusterIP:3306)
    │   ├── PV + PVC (5Gi)
    │   ├── Secret (credentials)
    │   └── ConfigMap
    └── WordPress
        ├── Deployment (2 replicas)
        ├── Service (NodePort:30080)
        ├── PV + PVC (5Gi)
        └── ConfigMap
```

## 📋 Prerequisites

- Ubuntu 22.04 LTS
- 2+ vCPU, 4GB+ RAM
- 20GB+ storage
- Root/sudo access
- Docker installed (for containerd)

## 🚀 Quick Start

### 1. Setup Kubernetes Cluster

Follow the kubeadm installation steps (see Installation Guide below)

### 2. Clone/Create Project
```bash
git clone <your-repo>
cd wordpress-k8s
```

### 3. Configure Environment
```bash
cp .env.example .env
nano .env  # Edit with your passwords
```

### 4. Deploy
```bash
# Create secrets
./scripts/create-secrets.sh

# Deploy application
./scripts/deploy.sh
```

### 5. Access WordPress
```bash
# Get access URL
echo "http://$(curl -s ifconfig.me):30080"
```

## 📁 Project Structure
```
wordpress-k8s/
├── mysql/
│   ├── mysql-configmap.yaml
│   ├── mysql-deployment.yaml
│   ├── mysql-pv.yaml
│   ├── mysql-pvc.yaml
│   ├── mysql-secret.yaml (generated, gitignored)
│   └── mysql-service.yaml
├── wordpress/
│   ├── wordpress-configmap.yaml
│   ├── wordpress-deployment.yaml
│   ├── wordpress-pv.yaml
│   ├── wordpress-pvc.yaml
│   └── wordpress-service.yaml
├── ingress/
│   └── wordpress-ingress.yaml (optional)
├── scripts/
│   ├── create-secrets.sh
│   ├── deploy.sh
│   ├── cleanup.sh
│   └── check-cluster.sh
├── .env (gitignored)
├── .env.example
├── .gitignore
└── README.md
```

## 🔐 Security

- Secrets are NOT committed to Git
- Use strong passwords in `.env`
- All sensitive files in `.gitignore`
- ConfigMap for non-sensitive data only

## 📊 Useful Commands
```bash
# Check cluster status
./scripts/check-cluster.sh

# View all resources
kubectl get all

# Check pods
kubectl get pods -o wide

# View logs
kubectl logs -f deployment/wordpress
kubectl logs -f deployment/mysql

# Describe resources
kubectl describe pod <pod-name>
kubectl describe svc <service-name>

# Access MySQL directly
kubectl exec -it deployment/mysql -- mysql -u root -p

# Port forward for local testing
kubectl port-forward svc/wordpress-service 8080:80
```

## 🐛 Troubleshooting

### Pods in Pending state
```bash
kubectl describe pod <pod-name>
kubectl get pv,pvc
```

### MySQL connection failed
```bash
kubectl logs deployment/mysql
kubectl exec -it deployment/mysql -- mysql -u root -p
```

### Can't access from browser

1. Check Security Group has port 30080 open
2. Verify service: `kubectl get svc wordpress-service`
3. Check pods: `kubectl get pods`

### Node NotReady
```bash
kubectl describe node
kubectl get pods -n kube-system
```

## 🧹 Cleanup
```bash
./scripts/cleanup.sh
```

To completely remove cluster:
```bash
sudo kubeadm reset -f
sudo rm -rf /etc/cni /etc/kubernetes /var/lib/etcd /var/lib/kubelet
sudo rm -rf ~/.kube
```

## 📝 Environment Variables

Required in `.env`:
- `MYSQL_ROOT_PASSWORD`
- `MYSQL_DATABASE`
- `MYSQL_USER`
- `MYSQL_PASSWORD`

## 🎓 Learning Objectives

- ✅ Setup Kubernetes with kubeadm
- ✅ Configure container runtime (containerd)
- ✅ Deploy CNI network plugin
- ✅ Kubernetes Deployments
- ✅ Persistent Volumes & Claims
- ✅ Services (ClusterIP, NodePort)
- ✅ ConfigMaps & Secrets
- ✅ Resource limits & requests
- ✅ Health checks (liveness/readiness probes)
- ✅ Production-ready K8s setup

## 📄 License

MIT License
