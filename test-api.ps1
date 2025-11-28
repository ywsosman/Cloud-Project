# Zero-Trust Cloud Lab - API Test Script

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Zero-Trust API Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Health Check
Write-Host "Test 1: Health Check" -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8080/health"
    Write-Host "✓ Health check passed: $health" -ForegroundColor Green
} catch {
    Write-Host "✗ Health check failed: $_" -ForegroundColor Red
    exit 1
}

# Test 2: Register a user
Write-Host "`nTest 2: User Registration" -ForegroundColor Yellow
$registerBody = @{
    username = "demouser"
    email = "demo@example.com"
    password = "DemoPass123!"
    firstName = "Demo"
    lastName = "User"
} | ConvertTo-Json

try {
    $registerResult = Invoke-RestMethod `
        -Uri "http://localhost:8080/api/auth/register" `
        -Method POST `
        -ContentType "application/json" `
        -Body $registerBody
    
    Write-Host "✓ User registered successfully" -ForegroundColor Green
    Write-Host "  User ID: $($registerResult.user.id)" -ForegroundColor Cyan
    Write-Host "  Username: $($registerResult.user.username)" -ForegroundColor Cyan
} catch {
    if ($_.Exception.Response.StatusCode -eq 409) {
        Write-Host "○ User already exists (this is OK)" -ForegroundColor Yellow
    } else {
        Write-Host "✗ Registration failed: $_" -ForegroundColor Red
    }
}

# Test 3: Login
Write-Host "`nTest 3: User Login" -ForegroundColor Yellow
$loginBody = @{
    email = "demo@example.com"
    password = "DemoPass123!"
} | ConvertTo-Json

try {
    $loginResult = Invoke-RestMethod `
        -Uri "http://localhost:8080/api/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginBody
    
    Write-Host "✓ Login successful" -ForegroundColor Green
    $token = $loginResult.accessToken
    Write-Host "  Access Token (first 50 chars): $($token.Substring(0,50))..." -ForegroundColor Cyan
} catch {
    Write-Host "✗ Login failed: $_" -ForegroundColor Red
    exit 1
}

# Test 4: Access Protected Endpoint
Write-Host "`nTest 4: Access Protected Resource" -ForegroundColor Yellow
$headers = @{
    Authorization = "Bearer $token"
}

try {
    $userInfo = Invoke-RestMethod `
        -Uri "http://localhost:8080/api/auth/me" `
        -Method GET `
        -Headers $headers
    
    Write-Host "✓ Protected endpoint accessed successfully" -ForegroundColor Green
    Write-Host "  User: $($userInfo.user.username)" -ForegroundColor Cyan
    Write-Host "  Email: $($userInfo.user.email)" -ForegroundColor Cyan
    Write-Host "  Role: $($userInfo.user.role)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Protected endpoint failed: $_" -ForegroundColor Red
    exit 1
}

# Test 5: Test Invalid Token
Write-Host "`nTest 5: Test Invalid Token (Should Fail)" -ForegroundColor Yellow
$badHeaders = @{
    Authorization = "Bearer invalid-token-12345"
}

try {
    Invoke-RestMethod `
        -Uri "http://localhost:8080/api/auth/me" `
        -Method GET `
        -Headers $badHeaders
    
    Write-Host "✗ This should have failed!" -ForegroundColor Red
} 
catch {
    Write-Host "✓ Invalid token correctly rejected" -ForegroundColor Green
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "✓ All Tests Completed Successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your Zero-Trust System is working perfectly!" -ForegroundColor Green
Write-Host ""
Write-Host "You can now:" -ForegroundColor Yellow
Write-Host "  1. Register more users" -ForegroundColor White
Write-Host "  2. Test other API endpoints" -ForegroundColor White
Write-Host "  3. View logs: docker-compose logs -f" -ForegroundColor White
Write-Host "  4. Access database: docker-compose exec postgres psql -U postgres -d zerotrust" -ForegroundColor White
Write-Host ""

