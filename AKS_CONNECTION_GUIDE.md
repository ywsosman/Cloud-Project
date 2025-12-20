# 🔌 AKS Connection Guide

## Quick Connect to AKS

### Step 1: List Your AKS Clusters

First, find your cluster name and resource group:

```powershell
az aks list --query "[].{Name:name, ResourceGroup:resourceGroup, Status:powerState.code}" -o table
```

### Step 2: Connect to AKS

Replace `RESOURCE_GROUP` and `CLUSTER_NAME` with your actual values:

```powershell
# Get AKS credentials (this connects kubectl to your cluster)
az aks get-credentials --resource-group RESOURCE_GROUP --name CLUSTER_NAME --overwrite-existing
```

**Common cluster names:**
- `zero-trust-aks`
- `zero-trust-aks-cluster`

**Common resource groups:**
- `zero-trust-rg`
- `zero-trust-lab-rg`

### Step 3: Verify Connection

```powershell
# Check if you can see pods
kubectl get pods -n zero-trust

# Check services
kubectl get services -n zero-trust

# Check all namespaces
kubectl get namespaces
```

### Step 4: Check Cluster Status

If the cluster is stopped, start it:

```powershell
# Check status
az aks show --resource-group RESOURCE_GROUP --name CLUSTER_NAME --query "powerState.code" -o tsv

# If stopped, start it (takes 5-10 minutes)
az aks start --resource-group RESOURCE_GROUP --name CLUSTER_NAME
```

## Troubleshooting 404 Error

The 404 error on `/api/security/activity-logs` might be because:

1. **Nginx is stripping the `/api/` prefix** - Check the actual nginx config in the pod
2. **Route doesn't exist** - Check if the route is registered in auth-service
3. **Wrong service endpoint** - Check if nginx is pointing to the right service

### Debug Steps:

```powershell
# 1. Check nginx config in the running pod
kubectl exec -n zero-trust deployment/api-gateway -- cat /etc/nginx/nginx.conf

# 2. Check auth-service logs
kubectl logs -n zero-trust deployment/auth-service --tail=50

# 3. Check if the route exists in auth-service
kubectl exec -n zero-trust deployment/auth-service -- curl http://localhost:8081/api/security/activity-logs

# 4. Test from inside the cluster
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- curl http://auth-service.zero-trust.svc.cluster.local:8081/api/security/activity-logs
```

### Check Current Nginx Config

```powershell
# Get the ConfigMap
kubectl get configmap nginx-config -n zero-trust -o yaml

# Or exec into a pod and check
kubectl exec -n zero-trust deployment/api-gateway -- cat /etc/nginx/nginx.conf
```

## Common Commands

```powershell
# View pod logs
kubectl logs -f deployment/api-gateway -n zero-trust
kubectl logs -f deployment/auth-service -n zero-trust

# Restart pods
kubectl rollout restart deployment/api-gateway -n zero-trust
kubectl rollout restart deployment/auth-service -n zero-trust

# Apply updated config
kubectl apply -f kubernetes/api-gateway-deployment.yaml -n zero-trust

# Get public IP
kubectl get service api-gateway -n zero-trust -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```



