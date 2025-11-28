# Zero-Trust Cloud Lab - Simple Setup Script

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Zero-Trust Cloud Lab - Setup Checker" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if a command exists
function Test-CommandExists {
    param($command)
    try {
        $null = Get-Command $command -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Check Azure CLI
Write-Host "Checking Azure CLI..." -ForegroundColor Yellow
if (Test-CommandExists "az") {
    Write-Host "✓ Azure CLI installed" -ForegroundColor Green
} else {
    Write-Host "✗ Azure CLI not found" -ForegroundColor Red
    Write-Host "  Install from: https://aka.ms/installazurecliwindows" -ForegroundColor Yellow
}

# Check Docker
Write-Host "`nChecking Docker..." -ForegroundColor Yellow
if (Test-CommandExists "docker") {
    Write-Host "✓ Docker installed" -ForegroundColor Green
    
    # Test if Docker is running
    $dockerTest = docker ps 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Docker is running" -ForegroundColor Green
    } else {
        Write-Host "✗ Docker is not running" -ForegroundColor Red
        Write-Host "  Please start Docker Desktop" -ForegroundColor Yellow
    }
} else {
    Write-Host "✗ Docker not found" -ForegroundColor Red
    Write-Host "  Install from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
}

# Check kubectl
Write-Host "`nChecking kubectl..." -ForegroundColor Yellow
if (Test-CommandExists "kubectl") {
    Write-Host "✓ kubectl installed" -ForegroundColor Green
} else {
    Write-Host "✗ kubectl not found" -ForegroundColor Red
    Write-Host "  Install instructions in week4-setup/README.md" -ForegroundColor Yellow
}

# Check Terraform
Write-Host "`nChecking Terraform..." -ForegroundColor Yellow
if (Test-CommandExists "terraform") {
    Write-Host "✓ Terraform installed" -ForegroundColor Green
} else {
    Write-Host "○ Terraform not found (optional)" -ForegroundColor Yellow
}

# Check Node.js
Write-Host "`nChecking Node.js..." -ForegroundColor Yellow
if (Test-CommandExists "node") {
    $nodeVersion = node --version
    Write-Host "✓ Node.js installed: $nodeVersion" -ForegroundColor Green
} else {
    Write-Host "○ Node.js not found (optional for local dev)" -ForegroundColor Yellow
}

# Check Python
Write-Host "`nChecking Python..." -ForegroundColor Yellow
if (Test-CommandExists "python") {
    $pythonVersion = python --version
    Write-Host "✓ Python installed: $pythonVersion" -ForegroundColor Green
} else {
    Write-Host "○ Python not found (needed for data collection)" -ForegroundColor Yellow
}

# Create project directories
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Creating Project Directories..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$directories = @(
    "logs",
    "data",
    "scripts"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "✓ Created: $dir" -ForegroundColor Green
    } else {
        Write-Host "○ Exists: $dir" -ForegroundColor Gray
    }
}

# Check .env file
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Configuration Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if (Test-Path ".env") {
    Write-Host "✓ .env file exists" -ForegroundColor Green
} else {
    Write-Host "○ .env file not found" -ForegroundColor Yellow
    if (Test-Path "env.template") {
        Write-Host "  Run: Copy-Item env.template .env" -ForegroundColor Cyan
    }
}

# Final Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Setup Check Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Install any missing tools listed above" -ForegroundColor White
Write-Host "2. Create .env file: Copy-Item env.template .env" -ForegroundColor White
Write-Host "3. Edit .env and set DB_PASSWORD and JWT_SECRET" -ForegroundColor White
Write-Host "4. Start Docker Desktop if not running" -ForegroundColor White
Write-Host "5. Run: docker-compose up -d" -ForegroundColor White
Write-Host ""
Write-Host "For detailed instructions, see START_HERE.md" -ForegroundColor Gray
Write-Host ""

