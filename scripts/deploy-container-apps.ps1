Param(
    [string]$ResourceGroup = "zero-trust-lab-rg",
    [string]$Location = "eastus",
    [string]$AcrName = "zerotrustacrregistry",
    [string]$ContainerEnvName = "zero-trust-ca-env",
    [string]$AuthAppName = "auth-service-app",
    [string]$GatewayAppName = "api-gateway-app"
)

<#
.SYNOPSIS
Deploys auth-service and api-gateway to Azure Container Apps.

.DESCRIPTION
- Builds Docker images from the local repo
- Pushes them to Azure Container Registry (ACR)
- Creates a Container Apps environment
- Deploys:
    - auth-service (Node.js API)
    - api-gateway (Nginx reverse proxy)

REQUIREMENTS:
- az CLI installed
- Azure Container Apps extension:
    az extension add --name containerapp
- Logged in:
    az login

ENVIRONMENT VARIABLES USED (set before running):
- $env:DATABASE_URL   → Postgres connection string (Azure DB recommended)
- $env:JWT_SECRET     → Secret for JWT signing
- $env:JWT_EXPIRY     → e.g. "1h"

USAGE:
    cd "D:\youssef\Fullstack Course\Cloud Project"
    .\scripts\deploy-container-apps.ps1
#>

Write-Host "`n=== Zero-Trust Lab: Deploy to Azure Container Apps ===`n" -ForegroundColor Cyan

# 1. Resource group
Write-Host "Checking resource group '$ResourceGroup'..." -ForegroundColor Yellow
$rgExists = az group exists --name $ResourceGroup | ConvertFrom-Json
if (-not $rgExists) {
    Write-Host "Creating resource group..." -ForegroundColor Yellow
    az group create --name $ResourceGroup --location $Location | Out-Null
} else {
    Write-Host "Resource group already exists." -ForegroundColor Green
}

# 2. ACR
Write-Host "`nChecking ACR '$AcrName'..." -ForegroundColor Yellow
$acr = az acr show --name $AcrName --resource-group $ResourceGroup --only-show-errors 2>$null
if (-not $acr) {
    Write-Host "Creating ACR..." -ForegroundColor Yellow
    az acr create `
        --resource-group $ResourceGroup `
        --name $AcrName `
        --sku Basic `
        --location $Location | Out-Null
} else {
    Write-Host "ACR already exists." -ForegroundColor Green
}

$AcrLoginServer = (az acr show --name $AcrName --query loginServer -o tsv)

# 3. Build & push images using ACR build (no local Docker daemon required in Azure)
Write-Host "`nBuilding and pushing images to ACR..." -ForegroundColor Yellow

Write-Host "Building auth-service image..." -ForegroundColor Yellow
az acr build `
    --registry $AcrName `
    --image auth-service:v1 `
    ./src/auth-service | Out-Null

Write-Host "Building api-gateway image..." -ForegroundColor Yellow
az acr build `
    --registry $AcrName `
    --image api-gateway:v1 `
    ./src/api-gateway | Out-Null

Write-Host "Images pushed to $AcrLoginServer" -ForegroundColor Green

# 4. Log Analytics workspace (required for Container Apps env)
Write-Host "`nSetting up Log Analytics workspace..." -ForegroundColor Yellow
$lawName = "$ResourceGroup-law"
$law = az monitor log-analytics workspace show `
    --resource-group $ResourceGroup `
    --workspace-name $lawName 2>$null
if (-not $law) {
    az monitor log-analytics workspace create `
        --resource-group $ResourceGroup `
        --workspace-name $lawName `
        --location $Location | Out-Null
}
$lawId = az monitor log-analytics workspace show `
    --resource-group $ResourceGroup `
    --workspace-name $lawName `
    --query id -o tsv

# 5. Container Apps environment
Write-Host "`nChecking Container Apps environment '$ContainerEnvName'..." -ForegroundColor Yellow
$envExists = az containerapp env show `
    --name $ContainerEnvName `
    --resource-group $ResourceGroup 2>$null
if (-not $envExists) {
    az containerapp env create `
        --name $ContainerEnvName `
        --resource-group $ResourceGroup `
        --location $Location `
        --logs-workspace-id $lawId `
        --logs-workspace-key (az monitor log-analytics workspace get-shared-keys `
            --resource-group $ResourceGroup `
            --workspace-name $lawName `
            --query primarySharedKey -o tsv) | Out-Null
    Write-Host "Container Apps environment created." -ForegroundColor Green
} else {
    Write-Host "Container Apps environment already exists." -ForegroundColor Green
}

# 6. Environment variables
if (-not $env:DATABASE_URL) {
    Write-Host "`n[WARNING] DATABASE_URL environment variable is not set." -ForegroundColor Yellow
    Write-Host "         Container apps will start, but auth-service may not connect to a database." -ForegroundColor Yellow
}
if (-not $env:JWT_SECRET) {
    Write-Host "`n[WARNING] JWT_SECRET environment variable is not set. Using a weak default (dev only!)." -ForegroundColor Yellow
    $env:JWT_SECRET = "dev-secret-change-this"
}
if (-not $env:JWT_EXPIRY) {
    $env:JWT_EXPIRY = "1h"
}

$authEnvVars = @(
    "NODE_ENV=production",
    "PORT=8081",
    "DATABASE_URL=$($env:DATABASE_URL)",
    "JWT_SECRET=$($env:JWT_SECRET)",
    "JWT_EXPIRY=$($env:JWT_EXPIRY)"
)

$gatewayEnvVars = @(
    "NODE_ENV=production",
    "AUTH_SERVICE_URL=http://auth-service-app"
)

# 7. Deploy auth-service Container App
Write-Host "`nDeploying auth-service to Azure Container Apps..." -ForegroundColor Yellow
az containerapp create `
    --name $AuthAppName `
    --resource-group $ResourceGroup `
    --environment $ContainerEnvName `
    --image "$AcrLoginServer/auth-service:v1" `
    --target-port 8081 `
    --ingress internal `
    --registry-server $AcrLoginServer `
    --min-replicas 1 `
    --max-replicas 3 `
    --env-vars $authEnvVars `
    --query properties.configuration.ingress.fqdn -o tsv

# 8. Deploy api-gateway Container App (public)
Write-Host "`nDeploying api-gateway to Azure Container Apps..." -ForegroundColor Yellow
$gatewayUrl = az containerapp create `
    --name $GatewayAppName `
    --resource-group $ResourceGroup `
    --environment $ContainerEnvName `
    --image "$AcrLoginServer/api-gateway:v1" `
    --target-port 80 `
    --ingress external `
    --registry-server $AcrLoginServer `
    --min-replicas 1 `
    --max-replicas 3 `
    --env-vars $gatewayEnvVars `
    --query properties.configuration.ingress.fqdn -o tsv

Write-Host "`n=== Deployment Complete ===" -ForegroundColor Green
Write-Host "API Gateway URL: http://$gatewayUrl" -ForegroundColor Cyan
Write-Host "Use this URL as VITE_API_BASE_URL in your frontend .env file." -ForegroundColor Cyan


