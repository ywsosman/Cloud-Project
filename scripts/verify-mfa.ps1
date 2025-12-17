# Verify MFA Setup
# Usage: .\scripts\verify-mfa.ps1 -Code "123456"

param(
    [Parameter(Mandatory=$true)]
    [string]$Code,
    [string]$Email = "youssefwaleed2231@gmail.com",
    [string]$Password
)

Write-Host "🔐 Verifying MFA Setup" -ForegroundColor Green
Write-Host "=====================`n" -ForegroundColor Green

# Get public IP
$publicIP = kubectl get service api-gateway -n zero-trust -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>&1

if (-not $publicIP -or $publicIP -match "error") {
    Write-Host "❌ Could not get public IP. Is AKS running?" -ForegroundColor Red
    exit 1
}

# Get password if not provided
if (-not $Password) {
    Write-Host "Enter your password for ${Email}:" -ForegroundColor Yellow
    $securePassword = Read-Host -AsSecureString
    $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    )
}

# Login
Write-Host "Step 1: Logging in..." -ForegroundColor Yellow
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
    Write-Host "✅ Login successful`n" -ForegroundColor Green
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Verify MFA
Write-Host "Step 2: Verifying MFA code..." -ForegroundColor Yellow
$headers = @{
    Authorization = "Bearer $token"
}

$verifyBody = @{
    token = $Code
} | ConvertTo-Json

try {
    $verifyResponse = Invoke-RestMethod -Uri "http://$publicIP/api/auth/mfa/verify" `
        -Method POST `
        -Headers $headers `
        -ContentType "application/json" `
        -Body $verifyBody
    
    Write-Host "✅ MFA verified and enabled successfully!`n" -ForegroundColor Green
    Write-Host "🎉 Your account now has MFA protection!" -ForegroundColor Green
    Write-Host "`nNext time you login, you'll be asked for a 6-digit code from your authenticator app." -ForegroundColor Yellow
    
} catch {
    Write-Host "❌ MFA verification failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Red
    }
    Write-Host "`n💡 Make sure you're using the current 6-digit code from your authenticator app." -ForegroundColor Yellow
    exit 1
}

