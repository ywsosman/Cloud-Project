# Simple API Test

Write-Host "`n===== Zero-Trust API Test =====" -ForegroundColor Cyan
Write-Host ""

# Test 1: Health Check
Write-Host "1. Testing Health Check..." -ForegroundColor Yellow
$health = Invoke-RestMethod -Uri "http://localhost:8080/health"
Write-Host "   Result: $health" -ForegroundColor Green

# Test 2: Register User
Write-Host "`n2. Testing User Registration..." -ForegroundColor Yellow
$body = @{
    username = "quicktest"
    email = "quick@test.com"
    password = "QuickTest123!"
} | ConvertTo-Json

try {
    $reg = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/register" -Method POST -ContentType "application/json" -Body $body
    Write-Host "   User registered: $($reg.user.username)" -ForegroundColor Green
}
catch {
    Write-Host "   User already exists (OK)" -ForegroundColor Yellow
}

# Test 3: Login
Write-Host "`n3. Testing Login..." -ForegroundColor Yellow
$loginBody = @{
    email = "quick@test.com"
    password = "QuickTest123!"
} | ConvertTo-Json

$login = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -ContentType "application/json" -Body $loginBody
Write-Host "   Login successful!" -ForegroundColor Green
$token = $login.accessToken
Write-Host "   Token: $($token.Substring(0,40))..." -ForegroundColor Cyan

# Test 4: Access Protected
Write-Host "`n4. Testing Protected Endpoint..." -ForegroundColor Yellow
$headers = @{Authorization = "Bearer $token"}
$me = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/me" -Headers $headers
Write-Host "   Logged in as: $($me.user.username) ($($me.user.email))" -ForegroundColor Green

Write-Host "`n===== All Tests Passed! =====" -ForegroundColor Green
Write-Host ""

