# ☁️ Cloud Deployment Guide - Zero-Trust Lab

## 🎯 Goal
Deploy your local Docker services to Azure Cloud.

## 📊 Current vs Cloud Architecture

### Current (Local Docker)
```
Your Computer
├── Docker Compose
│   ├── auth-service (container)
│   ├── api-gateway (container)
│   ├── postgres (container)
│   └── redis (container)
```

### Cloud (Azure)
```
Azure Cloud
├── Azure Kubernetes Service (AKS)
│   ├── auth-service (pod)
│   └── api-gateway (pod)
├── Azure Database for PostgreSQL (managed)
└── Azure Cache for Redis (managed)
```

## 🚀 Deployment Steps

### Phase 1: Prepare Azure Resources

#### 1.1 Create Azure Container Registry (ACR)
```powershell
# Create ACR
az acr create `
    --resource-group zero-trust-lab-rg `
    --name zerotrustacrregistry `
    --sku Basic `
    --location eastus

# Login to ACR
az acr login --name zerotrustacrregistry
```

#### 1.2 Create Azure Kubernetes Service (AKS)
```powershell
# Create AKS cluster
az aks create `
    --resource-group zero-trust-lab-rg `
    --name zero-trust-aks-cluster `
    --node-count 2 `
    --enable-managed-identity `
    --generate-ssh-keys `
    --attach-acr zerotrustacrregistry `
    --location eastus

# Get credentials
az aks get-credentials `
    --resource-group zero-trust-lab-rg `
    --name zero-trust-aks-cluster
```

#### 1.3 Create Azure Database for PostgreSQL
```powershell
# Create PostgreSQL server
az postgres flexible-server create `
    --resource-group zero-trust-lab-rg `
    --name zero-trust-postgres `
    --location eastus `
    --admin-user postgresadmin `
    --admin-password <your-secure-password> `
    --sku-name Standard_B1ms `
    --tier Burstable `
    --version 15 `
    --storage-size 32

# Create database
az postgres flexible-server db create `
    --resource-group zero-trust-lab-rg `
    --server-name zero-trust-postgres `
    --database-name zerotrust
```

#### 1.4 Create Azure Cache for Redis
```powershell
# Create Redis cache
az redis create `
    --resource-group zero-trust-lab-rg `
    --name zero-trust-redis `
    --location eastus `
    --sku Basic `
    --vm-size c0
```

### Phase 2: Build and Push Docker Images

#### 2.1 Build Images
```powershell
# Build auth-service
cd src/auth-service
docker build -t auth-service:latest .

# Build api-gateway
cd ../api-gateway
docker build -t api-gateway:latest .
```

#### 2.2 Tag for ACR
```powershell
# Tag images
docker tag auth-service:latest zerotrustacrregistry.azurecr.io/auth-service:v1
docker tag api-gateway:latest zerotrustacrregistry.azurecr.io/api-gateway:v1
```

#### 2.3 Push to ACR
```powershell
# Push images
docker push zerotrustacrregistry.azurecr.io/auth-service:v1
docker push zerotrustacrregistry.azurecr.io/api-gateway:v1
```

### Phase 3: Update Kubernetes Manifests

#### 3.1 Update Image References
Edit `kubernetes/auth-service-deployment.yaml`:
```yaml
image: zerotrustacrregistry.azurecr.io/auth-service:v1
```

Edit `kubernetes/api-gateway-deployment.yaml`:
```yaml
image: zerotrustacrregistry.azurecr.io/api-gateway:v1
```

#### 3.2 Update Database Connection
Edit `kubernetes/secrets-template.yaml`:
```yaml
# Use Azure Database connection string
host: zero-trust-postgres.postgres.database.azure.com
username: postgresadmin
password: <your-password>
```

#### 3.3 Update Redis Connection
Add to environment variables:
```yaml
REDIS_HOST: zero-trust-redis.redis.cache.windows.net
REDIS_PORT: 6380
REDIS_SSL: true
REDIS_PASSWORD: <redis-key>
```

### Phase 4: Deploy to AKS

#### 4.1 Create Namespace
```powershell
kubectl apply -f kubernetes/namespace.yaml
```

#### 4.2 Create Secrets
```powershell
# Create database secret
kubectl create secret generic database-secret `
    --from-literal=host=zero-trust-postgres.postgres.database.azure.com `
    --from-literal=port=5432 `
    --from-literal=database=zerotrust `
    --from-literal=username=postgresadmin `
    --from-literal=password=<your-password> `
    -n zero-trust

# Create Redis secret
kubectl create secret generic redis-secret `
    --from-literal=host=zero-trust-redis.redis.cache.windows.net `
    --from-literal=port=6380 `
    --from-literal=password=<redis-key> `
    -n zero-trust

# Create JWT secret
kubectl create secret generic jwt-secret `
    --from-literal=secret=<your-jwt-secret> `
    -n zero-trust
```

#### 4.3 Deploy Services
```powershell
# Deploy all services
kubectl apply -f kubernetes/auth-service-deployment.yaml
kubectl apply -f kubernetes/api-gateway-deployment.yaml

# Check status
kubectl get pods -n zero-trust
kubectl get services -n zero-trust
```

#### 4.4 Get Public IP
```powershell
# Get LoadBalancer IP
kubectl get service api-gateway -n zero-trust

# Your API will be available at:
# http://<EXTERNAL-IP>
```

## 🔄 Migration Strategy

### Option 1: Gradual Migration (Recommended)
1. **Week 1**: Deploy to cloud, keep local running
2. **Week 2**: Test cloud deployment
3. **Week 3**: Switch traffic to cloud
4. **Week 4**: Shut down local (optional)

### Option 2: Big Bang Migration
1. Deploy everything to cloud
2. Test thoroughly
3. Switch DNS/traffic
4. Shut down local

## 📋 Pre-Deployment Checklist

- [ ] Azure account created
- [ ] Resource group created
- [ ] ACR created and logged in
- [ ] AKS cluster created
- [ ] Azure Database for PostgreSQL created
- [ ] Azure Cache for Redis created
- [ ] Docker images built and pushed
- [ ] Kubernetes manifests updated
- [ ] Secrets created in Kubernetes
- [ ] Database schema migrated
- [ ] Environment variables configured
- [ ] Health checks passing
- [ ] Load balancer IP obtained

## 🔐 Security Considerations

### 1. Use Azure Key Vault
```powershell
# Create Key Vault
az keyvault create `
    --name zero-trust-keyvault `
    --resource-group zero-trust-lab-rg `
    --location eastus

# Store secrets
az keyvault secret set `
    --vault-name zero-trust-keyvault `
    --name database-password `
    --value <your-password>
```

### 2. Use Managed Identity
- AKS uses managed identity
- No need to store credentials
- Automatic rotation

### 3. Network Security
- Use Azure Network Security Groups
- Enable private endpoints
- Restrict public access

## 💰 Cost Estimation

### Free Tier (First Month)
- ACR: Free (Basic tier)
- AKS: Free (but nodes cost ~$70/month)
- PostgreSQL: Free tier available
- Redis: Free tier (C0) available

### After Free Tier
- AKS (2 nodes): ~$70/month
- PostgreSQL (Basic): ~$5/month
- Redis (Basic): ~$15/month
- Storage: ~$2/month
- **Total: ~$92/month**

## 🧪 Testing Cloud Deployment

### 1. Health Check
```powershell
# Get service IP
$ip = kubectl get service api-gateway -n zero-trust -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Test
Invoke-RestMethod "http://$ip/health"
```

### 2. Test Registration
```powershell
$body = @{
    username = "clouduser"
    email = "cloud@test.com"
    password = "CloudPass123!"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://$ip/api/auth/register" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

### 3. Check Logs
```powershell
# View pod logs
kubectl logs -f deployment/auth-service -n zero-trust
```

## 🔄 Rollback Plan

If something goes wrong:
```powershell
# Rollback to previous version
kubectl rollout undo deployment/auth-service -n zero-trust

# Or delete everything
kubectl delete namespace zero-trust
```

## 📊 Monitoring

### Azure Monitor
- View logs: Azure Portal → AKS → Insights
- Set up alerts
- Monitor performance

### Application Insights
- Add to your code
- Track requests
- Monitor errors

## 🎯 Next Steps After Deployment

1. **Set up CI/CD** - Automate deployments
2. **Configure monitoring** - Set up alerts
3. **Enable auto-scaling** - Handle traffic spikes
4. **Set up backups** - Database backups
5. **Configure SSL/TLS** - HTTPS certificates
6. **Set up custom domain** - Your own domain name

## 🟦 Alternative: Azure Container Apps (Simpler than AKS)

If you prefer **Azure Container Apps** instead of AKS (no cluster management), use the helper script:

```powershell
cd "D:\youssef\Fullstack Course\Cloud Project"

# (Optional but recommended) Set env vars for database and JWT
$env:DATABASE_URL = "<your-azure-postgres-connection-string>"
$env:JWT_SECRET = "<your-jwt-secret>"
$env:JWT_EXPIRY = "1h"

.\scripts\deploy-container-apps.ps1
```

The script will:
- Ensure the resource group and ACR exist
- Build and push `auth-service` and `api-gateway` images to ACR
- Create a Container Apps environment
- Deploy:
  - `auth-service-app` (internal)
  - `api-gateway-app` (public HTTP endpoint)

At the end it prints a URL like:

- `http://<gateway-fqdn>` → use this as `VITE_API_BASE_URL` in the frontend:

```bash
# frontend/.env
VITE_API_BASE_URL=http://<gateway-fqdn>
```

## 📚 Resources

- [AKS Documentation](https://docs.microsoft.com/azure/aks/)
- [Azure Container Apps](https://learn.microsoft.com/azure/container-apps/)
- [ACR Documentation](https://docs.microsoft.com/azure/container-registry/)
- [Azure Database for PostgreSQL](https://docs.microsoft.com/azure/postgresql/)
- [Azure Cache for Redis](https://docs.microsoft.com/azure/azure-cache-for-redis/)

---

## ✅ Summary

**Yes, you need to deploy your Docker services to Azure cloud!**

**Option A – AKS (cluster-based):**
1. Build Docker images
2. Push to Azure Container Registry
3. Deploy to Azure Kubernetes Service
4. Use Azure managed services (Database, Redis)

**Option B – Azure Container Apps (no cluster management):**
1. Run `scripts/deploy-container-apps.ps1`
2. Get the public URL for `api-gateway-app`
3. Point your frontend and tests to that URL

**You can keep local for development and deploy to cloud for production!** 🚀

---

## ⚠️ Cloud Deployment Limitations on Current Subscription

During implementation we hit several **subscription-level restrictions** in Azure that prevent a fully running cloud environment (particularly the database layer). These are important to document for your report:

### 1. Container Registry Tasks & Container Apps
- **ACR Tasks** (used by `az acr build`) are **not permitted**:
  - Error:  
    `ACR Tasks requests for the registry zerotrustacrregistry and 40374cd5-6fe6-4d50-8207-12af93346498 are not permitted.`
- **Azure Container Apps** environment creation failed due to Log Analytics / environment issues under this subscription.
- Mitigation: We switched to **local Docker builds + push to ACR** and then used **AKS** instead of Container Apps.

### 2. Azure Database for PostgreSQL (DB provider blocked)
- Attempting to create an Azure Database for PostgreSQL flexible server returned:
  - Error:  
    `The subscription is not registered to use namespace 'Microsoft.DBforPostgreSQL'.`
- This means the subscription cannot provision Postgres servers, so `auth-service` in AKS has no reachable cloud database and fails with:
  - `SequelizeHostNotFoundError: getaddrinfo ENOTFOUND <postgres-host>`

### 3. Resulting State in AKS
- **Working:**
  - ACR registry: `zerotrustacrregistry.azurecr.io`
  - Images pushed: `auth-service:v1`, `api-gateway:v1`
  - AKS cluster: `zero-trust-aks-cluster` (Free tier, `Standard_DC2s_v3`)
  - Kubernetes namespace, services, and LoadBalancer:
    - `api-gateway` service type `LoadBalancer` with external IP.
- **Limited:**
  - `auth-service` pods on AKS crash because they cannot resolve/connect to a real Postgres host.
  - Therefore, the public health endpoint on AKS does not respond even though the LoadBalancer IP exists.

### 4. How This Is Addressed in the Project
- The **full zero-trust stack (auth-service, API gateway, dataset API, frontend dashboards)** is implemented and tested:
  - Locally via Docker + local Postgres.
  - Using **real Azure Security logs** collected into `data-collection/azure_activity_logs.*`.
- The **cloud migration path is fully documented**:
  - Building and pushing images to ACR.
  - Creating AKS cluster and deploying manifests.
  - Expected configuration for Azure PostgreSQL and Redis.
- The only missing piece in Azure is the **managed Postgres instance**, which is blocked by subscription policy. Once `Microsoft.DBforPostgreSQL` is enabled (or another database option is allowed), the existing manifests and secrets can be updated to point to the new connection string and the AKS deployment will become fully functional.


