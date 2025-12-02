# Azure Setup Script for Zero-Trust Cloud Lab
# This script helps you set up Azure for data collection

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Azure Security Dataset Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Azure CLI is installed
Write-Host "Checking Azure CLI..." -ForegroundColor Yellow
if (Get-Command az -ErrorAction SilentlyContinue) {
    $azVersion = az --version | Select-String "azure-cli" | Select-Object -First 1
    Write-Host "[OK] Azure CLI installed: $azVersion" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Azure CLI not found!" -ForegroundColor Red
    Write-Host "Please install from: https://aka.ms/installazurecliwindows" -ForegroundColor Yellow
    Write-Host "Or run: winget install -e --id Microsoft.AzureCLI" -ForegroundColor Yellow
    exit 1
}

# Check if logged in
Write-Host "`nChecking Azure login..." -ForegroundColor Yellow
try {
    $account = az account show 2>$null | ConvertFrom-Json
    if ($account) {
        Write-Host "[OK] Logged in as: $($account.user.name)" -ForegroundColor Green
        Write-Host "    Subscription: $($account.name)" -ForegroundColor Cyan
        Write-Host "    Subscription ID: $($account.id)" -ForegroundColor Cyan
        Write-Host "    Tenant ID: $($account.tenantId)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "[WARNING] Not logged in to Azure" -ForegroundColor Yellow
    Write-Host "Run: az login" -ForegroundColor Yellow
    $login = Read-Host "Do you want to login now? (Y/N)"
    if ($login -eq 'Y' -or $login -eq 'y') {
        az login
    } else {
        Write-Host "Please login first: az login" -ForegroundColor Yellow
        exit 1
    }
}

# Get subscription info
$account = az account show | ConvertFrom-Json
$subscriptionId = $account.id
$tenantId = $account.tenantId
$resourceGroup = "zero-trust-lab-rg"
$location = "eastus"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Creating Azure Resources" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create Resource Group
Write-Host "Creating Resource Group..." -ForegroundColor Yellow
$rgExists = az group exists --name $resourceGroup | ConvertFrom-Json
if (-not $rgExists) {
    az group create --name $resourceGroup --location $location
    Write-Host "[OK] Resource group created" -ForegroundColor Green
} else {
    Write-Host "[OK] Resource group already exists" -ForegroundColor Green
}

# Create Storage Account
Write-Host "`nCreating Storage Account..." -ForegroundColor Yellow
$storageName = "zerotruststorage$(Get-Random -Maximum 9999)"
try {
    az storage account create `
        --name $storageName `
        --resource-group $resourceGroup `
        --location $location `
        --sku Standard_LRS `
        --kind StorageV2 `
        --output none
    
    Write-Host "[OK] Storage account created: $storageName" -ForegroundColor Green
    
    # Create container
    Write-Host "Creating storage container..." -ForegroundColor Yellow
    az storage container create `
        --name security-data `
        --account-name $storageName `
        --auth-mode login `
        --output none
    
    Write-Host "[OK] Container 'security-data' created" -ForegroundColor Green
    
    # Get connection string
    $connectionString = az storage account show-connection-string `
        --name $storageName `
        --resource-group $resourceGroup `
        --query connectionString -o tsv
    
    Write-Host "[OK] Connection string retrieved" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to create storage account: $_" -ForegroundColor Red
}

# Create Log Analytics Workspace
Write-Host "`nCreating Log Analytics Workspace..." -ForegroundColor Yellow
try {
    az monitor log-analytics workspace create `
        --resource-group $resourceGroup `
        --workspace-name "zero-trust-workspace" `
        --location $location `
        --output none
    
    Write-Host "[OK] Log Analytics workspace created" -ForegroundColor Green
} catch {
    Write-Host "[WARNING] Workspace may already exist or failed: $_" -ForegroundColor Yellow
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Setup Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Subscription ID: $subscriptionId" -ForegroundColor White
Write-Host "Tenant ID: $tenantId" -ForegroundColor White
Write-Host "Resource Group: $resourceGroup" -ForegroundColor White
Write-Host "Location: $location" -ForegroundColor White
if ($storageName) {
    Write-Host "Storage Account: $storageName" -ForegroundColor White
    Write-Host "Connection String: $connectionString" -ForegroundColor Cyan
}

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Save these values to data-collection/.env file:" -ForegroundColor White
Write-Host "   AZURE_SUBSCRIPTION_ID=$subscriptionId" -ForegroundColor Cyan
Write-Host "   AZURE_TENANT_ID=$tenantId" -ForegroundColor Cyan
if ($connectionString) {
    Write-Host "   AZURE_STORAGE_CONNECTION_STRING=$connectionString" -ForegroundColor Cyan
}
Write-Host "   UPLOAD_TO_STORAGE=true" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Install Python dependencies:" -ForegroundColor White
Write-Host "   cd data-collection" -ForegroundColor Cyan
Write-Host "   pip install -r requirements.txt" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Run data collection:" -ForegroundColor White
Write-Host "   python azure_log_collector.py" -ForegroundColor Cyan
Write-Host ""

