# Ensure Azure AKS Cluster is Running
# This script checks if the AKS cluster is running and starts it if needed

param(
    [string]$ResourceGroup = "zero-trust-lab-rg",
    [string]$ClusterName = "zero-trust-aks-cluster"
)

Write-Host "🔍 Checking Azure AKS cluster status..." -ForegroundColor Yellow

# Check if Azure CLI is available
try {
    $azVersion = az version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Azure CLI not found"
    }
} catch {
    Write-Host "❌ Azure CLI not found. Please install Azure CLI first." -ForegroundColor Red
    Write-Host "   Download: https://aka.ms/installazurecliwindows" -ForegroundColor Yellow
    exit 1
}

# Check if logged in
$account = az account show 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Not logged in to Azure. Logging in..." -ForegroundColor Yellow
    az login
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to login to Azure." -ForegroundColor Red
        exit 1
    }
}

# Check cluster status
Write-Host "`n📊 Checking cluster status..." -ForegroundColor Cyan
$powerState = az aks show --resource-group $ResourceGroup --name $ClusterName --query "powerState.code" -o tsv 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Cluster '$ClusterName' not found in resource group '$ResourceGroup'." -ForegroundColor Red
    Write-Host "   Please check the cluster name and resource group." -ForegroundColor Yellow
    exit 1
}

if ($powerState -eq "Running") {
    Write-Host "✅ Cluster is already RUNNING!" -ForegroundColor Green
    
    # Get public IP
    Write-Host "`n🌐 Getting public IP..." -ForegroundColor Cyan
    az aks get-credentials --resource-group $ResourceGroup --name $ClusterName --overwrite-existing | Out-Null
    
    $publicIP = kubectl get service api-gateway -n zero-trust -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>&1
    
    if ($publicIP) {
        Write-Host "✅ Public IP: $publicIP" -ForegroundColor Green
        Write-Host "`n📝 Update your frontend .env file:" -ForegroundColor Yellow
        Write-Host "   VITE_API_BASE_URL=http://$publicIP" -ForegroundColor Cyan
    }
    
    # Check pods
    Write-Host "`n🔍 Checking pods status..." -ForegroundColor Cyan
    kubectl get pods -n zero-trust
    
    exit 0
}

if ($powerState -eq "Stopped") {
    Write-Host "⚠️  Cluster is STOPPED. Starting cluster..." -ForegroundColor Yellow
    Write-Host "   This may take 5-10 minutes..." -ForegroundColor Yellow
    
    az aks start --resource-group $ResourceGroup --name $ClusterName
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to start cluster." -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Cluster is starting..." -ForegroundColor Green
    Write-Host "   Waiting for cluster to be ready..." -ForegroundColor Yellow
    
    # Wait for cluster to be ready
    $maxAttempts = 30
    $attempt = 0
    
    while ($attempt -lt $maxAttempts) {
        Start-Sleep -Seconds 10
        $currentState = az aks show --resource-group $ResourceGroup --name $ClusterName --query "powerState.code" -o tsv 2>&1
        
        if ($currentState -eq "Running") {
            Write-Host "✅ Cluster is now RUNNING!" -ForegroundColor Green
            
            # Get credentials
            az aks get-credentials --resource-group $ResourceGroup --name $ClusterName --overwrite-existing | Out-Null
            
            # Get public IP
            Write-Host "`n🌐 Getting public IP..." -ForegroundColor Cyan
            Start-Sleep -Seconds 15  # Wait for services to be ready
            $publicIP = kubectl get service api-gateway -n zero-trust -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>&1
            
            if ($publicIP) {
                Write-Host "✅ Public IP: $publicIP" -ForegroundColor Green
                Write-Host "`n📝 Update your frontend .env file:" -ForegroundColor Yellow
                Write-Host "   VITE_API_BASE_URL=http://$publicIP" -ForegroundColor Cyan
            }
            
            # Check pods
            Write-Host "`n🔍 Checking pods status..." -ForegroundColor Cyan
            kubectl get pods -n zero-trust
            
            exit 0
        }
        
        $attempt++
        Write-Host "   Waiting... ($attempt/$maxAttempts)" -ForegroundColor Gray
    }
    
    Write-Host "⚠️  Cluster is taking longer than expected to start." -ForegroundColor Yellow
    Write-Host "   Check status manually: az aks show --resource-group $ResourceGroup --name $ClusterName" -ForegroundColor Yellow
    exit 0
}

Write-Host "⚠️  Cluster is in state: $powerState" -ForegroundColor Yellow
Write-Host "   This script only handles 'Running' and 'Stopped' states." -ForegroundColor Yellow

