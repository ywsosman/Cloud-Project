# Enable MFA for Your Account
# Usage: .\scripts\enable-mfa.ps1

param(
    [string]$Email = "youssefwaleed2231@gmail.com",
    [string]$Password
)

Write-Host "🔐 Enabling MFA for Your Account" -ForegroundColor Green
Write-Host "===============================`n" -ForegroundColor Green

# Get public IP
Write-Host "Step 1: Getting Azure AKS public IP..." -ForegroundColor Yellow
$publicIP = kubectl get service api-gateway -n zero-trust -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>&1

if (-not $publicIP -or $publicIP -match "error") {
    Write-Host "❌ Could not get public IP. Is AKS running?" -ForegroundColor Red
    Write-Host "   Run: .\scripts\ensure-azure-running.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Public IP: $publicIP`n" -ForegroundColor Green

# Get password if not provided
if (-not $Password) {
    Write-Host "Enter your password for ${Email}:" -ForegroundColor Yellow
    $securePassword = Read-Host -AsSecureString
    $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    )
}

# Step 1: Login
Write-Host "Step 2: Logging in..." -ForegroundColor Yellow
$loginBody = @{
    email = $Email
    password = $Password
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://$publicIP/api/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginBody
    
    $token = $loginResponse.accessToken
    Write-Host "✅ Login successful!`n" -ForegroundColor Green
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Red
    }
    exit 1
}

# Step 2: Enable MFA
Write-Host "Step 3: Enabling MFA..." -ForegroundColor Yellow
$headers = @{
    Authorization = "Bearer $token"
}

try {
    $mfaResponse = Invoke-RestMethod -Uri "http://$publicIP/api/auth/mfa/enable" `
        -Method POST `
        -Headers $headers
    
    Write-Host "✅ MFA setup initiated!`n" -ForegroundColor Green
    
    # Display QR code info
    Write-Host "📱 MFA Setup Instructions:" -ForegroundColor Cyan
    Write-Host "========================`n" -ForegroundColor Cyan
    
    Write-Host "1. Open your authenticator app (Google Authenticator, Microsoft Authenticator, etc.)" -ForegroundColor White
    Write-Host "2. Scan this QR code or enter the secret manually:`n" -ForegroundColor White
    
    # Save QR code to file
    $qrCodeBase64 = $mfaResponse.qrCode
    $qrCodeBytes = [Convert]::FromBase64String($qrCodeBase64 -replace '^data:image/png;base64,', '')
    $qrCodePath = Join-Path $PSScriptRoot ".." "mfa-qrcode.png"
    [System.IO.File]::WriteAllBytes($qrCodePath, $qrCodeBytes)
    
    Write-Host "✅ QR Code saved to: $qrCodePath" -ForegroundColor Green
    Write-Host "   Open this file to scan with your authenticator app`n" -ForegroundColor Yellow
    
    Write-Host "Secret Key (if manual entry needed):" -ForegroundColor Cyan
    Write-Host $mfaResponse.secret -ForegroundColor White
    Write-Host ""
    
    Write-Host "3. After scanning, you need to verify the setup with a code from your app" -ForegroundColor White
    Write-Host "4. Run: .\scripts\verify-mfa.ps1 -Secret '$($mfaResponse.secret)'`n" -ForegroundColor Yellow
    
    # Save secret for verification
    $secretPath = Join-Path $PSScriptRoot ".." "mfa-secret.txt"
    $mfaResponse.secret | Out-File -FilePath $secretPath -Encoding utf8
    Write-Host "💾 Secret saved to: $secretPath (for verification step)`n" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Failed to enable MFA: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Red
        
        if ($responseBody -match "already enabled") {
            Write-Host "`nℹ️  MFA is already enabled for this account." -ForegroundColor Yellow
            Write-Host "   To reset MFA, contact an administrator or disable it first." -ForegroundColor Yellow
        }
    }
    exit 1
}

Write-Host "`n🎉 MFA Setup Complete!" -ForegroundColor Green
Write-Host "Next: Verify MFA with a code from your authenticator app" -ForegroundColor Yellow

