# Zero-Trust Cloud Lab - Week 4 Setup Script
# Run this script in PowerShell as Administrator

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Zero-Trust Cloud Lab - Setup Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if a command exists
function Test-CommandExists {
    param($command)
    $null = Get-Command $command -ErrorAction SilentlyContinue
    return $?
}

# Check Azure CLI
Write-Host "Checking Azure CLI..." -ForegroundColor Yellow
if (Test-CommandExists az) {
    $azVersion = az --version | Select-String "azure-cli" | Select-Object -First 1
    Write-Host "✓ Azure CLI installed: $azVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Azure CLI not found. Installing..." -ForegroundColor Red
    Write-Host "Please download and install from: https://aka.ms/installazurecliwindows" -ForegroundColor Yellow
    Start-Process "https://aka.ms/installazurecliwindows"
}

# Check Docker
Write-Host "`nChecking Docker..." -ForegroundColor Yellow
if (Test-CommandExists docker) {
    $dockerVersion = docker --version
    Write-Host "✓ Docker installed: $dockerVersion" -ForegroundColor Green
    
    # Test Docker
    Write-Host "Testing Docker..." -ForegroundColor Yellow
    docker ps > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Docker is running" -ForegroundColor Green
    } else {
        Write-Host "✗ Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    }
} else {
    Write-Host "✗ Docker not found." -ForegroundColor Red
    Write-Host "Please download and install Docker Desktop from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    Start-Process "https://www.docker.com/products/docker-desktop"
}

# Check kubectl
Write-Host "`nChecking kubectl..." -ForegroundColor Yellow
if (Test-CommandExists kubectl) {
    $kubectlVersion = kubectl version --client --short 2>$null
    Write-Host "✓ kubectl installed: $kubectlVersion" -ForegroundColor Green
} else {
    Write-Host "✗ kubectl not found. Installing..." -ForegroundColor Red
    Write-Host "Installing kubectl via curl..." -ForegroundColor Yellow
    
    $kubectlPath = "$env:USERPROFILE\kubectl.exe"
    curl.exe -LO "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"
    Move-Item kubectl.exe $kubectlPath -Force
    
    Write-Host "Adding kubectl to PATH..." -ForegroundColor Yellow
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($userPath -notlike "*$env:USERPROFILE*") {
        [Environment]::SetEnvironmentVariable("PATH", "$userPath;$env:USERPROFILE", "User")
        Write-Host "✓ kubectl added to PATH. Please restart PowerShell." -ForegroundColor Green
    }
}

# Check Terraform
Write-Host "`nChecking Terraform..." -ForegroundColor Yellow
if (Test-CommandExists terraform) {
    $terraformVersion = terraform --version | Select-Object -First 1
    Write-Host "✓ Terraform installed: $terraformVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Terraform not found." -ForegroundColor Red
    Write-Host "Please install via Chocolatey: choco install terraform" -ForegroundColor Yellow
    Write-Host "Or download from: https://www.terraform.io/downloads" -ForegroundColor Yellow
}

# Check Helm
Write-Host "`nChecking Helm..." -ForegroundColor Yellow
if (Test-CommandExists helm) {
    $helmVersion = helm version --short
    Write-Host "✓ Helm installed: $helmVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Helm not found." -ForegroundColor Red
    Write-Host "Please install via Chocolatey: choco install kubernetes-helm" -ForegroundColor Yellow
}

# Create project directory structure
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Creating Project Structure..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$directories = @(
    "src/api-gateway",
    "src/auth-service",
    "src/user-service",
    "src/security-service",
    "src/data-service",
    "src/frontend",
    "infrastructure/terraform",
    "infrastructure/arm-templates",
    "kubernetes/manifests",
    "kubernetes/helm-charts",
    "data-collection",
    "tests/unit",
    "tests/integration",
    "tests/security",
    "docs",
    "scripts",
    "monitoring"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "✓ Created: $dir" -ForegroundColor Green
    } else {
        Write-Host "○ Exists: $dir" -ForegroundColor Gray
    }
}

# Create .env.template
Write-Host "`nCreating .env.template..." -ForegroundColor Yellow
$envTemplate = @"
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
STORAGE_ACCOUNT_NAME=zerotruststorage

# Application Configuration
JWT_SECRET=your-jwt-secret-here-change-this
JWT_EXPIRY=3600
DATABASE_URL=your-database-url

# API Configuration
API_GATEWAY_PORT=8080
AUTH_SERVICE_PORT=8081
USER_SERVICE_PORT=8082
SECURITY_SERVICE_PORT=8083
DATA_SERVICE_PORT=8084

# Monitoring
ENABLE_MONITORING=true
LOG_LEVEL=info
"@

Set-Content -Path ".env.template" -Value $envTemplate
Write-Host "✓ Created .env.template" -ForegroundColor Green

# Azure Login and Setup
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Azure Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if (Test-CommandExists az) {
    Write-Host "Do you want to login to Azure now? (Y/N): " -ForegroundColor Yellow -NoNewline
    $response = Read-Host
    
    if ($response -eq 'Y' -or $response -eq 'y') {
        Write-Host "Logging into Azure..." -ForegroundColor Yellow
        az login
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n✓ Successfully logged into Azure" -ForegroundColor Green
            
            Write-Host "`nDo you want to create Azure resources now? (Y/N): " -ForegroundColor Yellow -NoNewline
            $createResources = Read-Host
            
            if ($createResources -eq 'Y' -or $createResources -eq 'y') {
                Write-Host "`nCreating Resource Group..." -ForegroundColor Yellow
                az group create --name zero-trust-lab-rg --location eastus
                
                Write-Host "`nResource Group created. Other resources can be created using:" -ForegroundColor Yellow
                Write-Host "  - Azure Portal" -ForegroundColor Cyan
                Write-Host "  - Azure CLI commands in week4-setup/README.md" -ForegroundColor Cyan
                Write-Host "  - Terraform (coming in infrastructure/terraform)" -ForegroundColor Cyan
            }
        }
    }
}

# Final Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Review week4-setup/README.md for detailed setup instructions" -ForegroundColor White
Write-Host "2. Copy .env.template to .env and fill in your Azure credentials" -ForegroundColor White
Write-Host "3. Create Azure resources (Resource Group, AKS, ACR, Key Vault)" -ForegroundColor White
Write-Host "4. Configure kubectl to connect to your AKS cluster" -ForegroundColor White
Write-Host "5. Proceed to Week 5 for data collection" -ForegroundColor White
Write-Host ""
Write-Host "For questions or issues, refer to the documentation in /docs" -ForegroundColor Gray
Write-Host ""
