# Week 4: Cloud Setup

## Objectives
- Set up cloud environment (Azure free tier)
- Install Docker & Kubernetes
- Configure basic development environment

## Tasks Checklist

### 1. Azure Account Setup
- [ ] Create Azure free tier account
- [ ] Set up billing alerts (to avoid unexpected charges)
- [ ] Create resource group: `zero-trust-lab-rg`
- [ ] Set up Azure CLI locally

### 2. Docker Installation
- [ ] Install Docker Desktop
- [ ] Verify installation: `docker --version`
- [ ] Test with hello-world: `docker run hello-world`
- [ ] Create Docker Hub account (optional)

### 3. Kubernetes Setup
- [ ] Enable Kubernetes in Docker Desktop OR
- [ ] Set up Azure Kubernetes Service (AKS) cluster
- [ ] Install kubectl: `kubectl version --client`
- [ ] Configure kubectl to connect to cluster

### 4. Development Tools
- [ ] Install Azure CLI
- [ ] Install Terraform (for IaC)
- [ ] Install Helm (K8s package manager)
- [ ] Set up Git repository

### 5. Basic Security Setup
- [ ] Create Azure Key Vault
- [ ] Set up service principal for automation
- [ ] Configure RBAC roles

## Installation Guide

### Azure CLI Installation

**Windows (PowerShell):**
```powershell
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
```

**Verify:**
```bash
az --version
az login
```

### Docker Installation

1. Download Docker Desktop from https://www.docker.com/products/docker-desktop
2. Install and restart computer
3. Verify:
```bash
docker --version
docker run hello-world
```

### Kubernetes (kubectl) Installation

**Windows (PowerShell):**
```powershell
curl.exe -LO "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"
# Add to PATH
```

**Verify:**
```bash
kubectl version --client
```

### Terraform Installation

**Windows (PowerShell):**
```powershell
# Using Chocolatey
choco install terraform

# Or download from https://www.terraform.io/downloads
```

## Azure Resources to Create

### Resource Group
```bash
az group create --name zero-trust-lab-rg --location eastus
```

### Azure Container Registry (ACR)
```bash
az acr create --resource-group zero-trust-lab-rg \
  --name zerotrustacrregistry --sku Basic
```

### Azure Kubernetes Service (AKS)
```bash
az aks create \
  --resource-group zero-trust-lab-rg \
  --name zero-trust-aks-cluster \
  --node-count 2 \
  --enable-managed-identity \
  --generate-ssh-keys \
  --attach-acr zerotrustacrregistry
```

### Azure Key Vault
```bash
az keyvault create \
  --name zero-trust-keyvault \
  --resource-group zero-trust-lab-rg \
  --location eastus
```

## Project Initialization

Create basic project files:

```bash
# Initialize Git repository
git init

# Create directory structure
mkdir -p src/{api-gateway,auth-service,services,frontend}
mkdir -p infrastructure/terraform
mkdir -p kubernetes/manifests
mkdir -p tests
mkdir -p docs

# Create .gitignore
cat > .gitignore << EOF
# Environment variables
.env
*.env

# Cloud credentials
.azure/
.aws/
.gcp/

# Terraform
**/.terraform/
*.tfstate
*.tfstate.backup

# Docker
**/.dockerignore

# Node modules
**/node_modules/

# Python
**/__pycache__/
*.pyc
**/venv/

# IDE
.vscode/
.idea/
*.swp
EOF
```

## Environment Variables Template

Create `.env.template`:
```bash
# Azure Configuration
AZURE_SUBSCRIPTION_ID=your-subscription-id
AZURE_TENANT_ID=your-tenant-id
AZURE_CLIENT_ID=your-client-id
AZURE_CLIENT_SECRET=your-client-secret

# Resource Configuration
RESOURCE_GROUP=zero-trust-lab-rg
LOCATION=eastus
ACR_NAME=zerotrustacrregistry
AKS_CLUSTER_NAME=zero-trust-aks-cluster
KEY_VAULT_NAME=zero-trust-keyvault

# Application Configuration
JWT_SECRET=your-jwt-secret
DATABASE_URL=your-database-url
```

## Verification Steps

After setup, verify everything works:

```bash
# Azure CLI
az account show

# Docker
docker ps

# Kubernetes
kubectl cluster-info
kubectl get nodes

# Terraform
terraform version
```

## Next Steps

- Week 5: Collect Azure Security Dataset and set up data storage
- Begin designing zero-trust architecture

## Resources

- [Azure Free Account](https://azure.microsoft.com/free/)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Azure Zero Trust Implementation](https://docs.microsoft.com/en-us/security/zero-trust/)

