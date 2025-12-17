# 🔐 How to Enable MFA for Your Account

This guide shows you how to enable Multi-Factor Authentication (MFA) for your account.

---

## 🚀 Quick Method: Use the Script

### Step 1: Run the Enable MFA Script

```powershell
# Navigate to project root
cd "D:\youssef\Fullstack Course\Cloud Project"

# Run the script
.\scripts\enable-mfa.ps1
```

The script will:
1. ✅ Get the Azure public IP
2. ✅ Ask for your password
3. ✅ Login to get a token
4. ✅ Enable MFA and generate QR code
5. ✅ Save QR code to `mfa-qrcode.png`

### Step 2: Scan QR Code

1. Open your authenticator app:
   - **Google Authenticator** (iOS/Android)
   - **Microsoft Authenticator** (iOS/Android)
   - **Authy** (iOS/Android/Desktop)
   - Any TOTP-compatible app

2. Scan the QR code from `mfa-qrcode.png`

3. You'll see a 6-digit code in your app

### Step 3: Verify MFA Setup

```powershell
# Verify with a code from your authenticator app
.\scripts\verify-mfa.ps1 -Code "123456"
```

Replace `123456` with the current 6-digit code from your authenticator app.

---

## 🎨 Alternative: Use the Frontend

### Step 1: Login to Frontend

1. Open http://localhost:5173
2. Login with your credentials

### Step 2: Enable MFA (when UI is ready)

Once the MFA settings page is added to the frontend, you can enable MFA through the UI.

**Note**: Currently, use the script method above.

---

## 📱 Manual Method: Using API Directly

### Step 1: Login and Get Token

```powershell
$publicIP = kubectl get service api-gateway -n zero-trust -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

$loginBody = @{
    email = "youssefwaleed2231@gmail.com"
    password = "YourPassword123!"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://$publicIP/api/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body $loginBody

$token = $response.accessToken
```

### Step 2: Enable MFA

```powershell
$headers = @{
    Authorization = "Bearer $token"
}

$mfaResponse = Invoke-RestMethod -Uri "http://$publicIP/api/auth/mfa/enable" `
    -Method POST `
    -Headers $headers

# Display QR code info
$mfaResponse | ConvertTo-Json
```

### Step 3: Save QR Code

```powershell
# Save QR code to file
$qrCodeBase64 = $mfaResponse.qrCode
$qrCodeBytes = [Convert]::FromBase64String($qrCodeBase64 -replace '^data:image/png;base64,', '')
[System.IO.File]::WriteAllBytes("mfa-qrcode.png", $qrCodeBytes)

# Open the QR code
Start-Process "mfa-qrcode.png"
```

### Step 4: Verify MFA

```powershell
# Get a code from your authenticator app (e.g., "123456")
$verifyBody = @{
    token = "123456"  # Replace with code from your app
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://$publicIP/api/auth/mfa/verify" `
    -Method POST `
    -Headers $headers `
    -ContentType "application/json" `
    -Body $verifyBody
```

---

## ✅ After MFA is Enabled

### What Changes:

1. **Login Flow**:
   - Enter email and password
   - **NEW**: You'll see an MFA challenge screen
   - Enter 6-digit code from authenticator app
   - Access granted

2. **Security**:
   - Your account is now protected with 2FA
   - Even if password is compromised, attackers need your phone
   - Higher security score in risk assessment

### Testing MFA Login:

1. Logout (or use incognito mode)
2. Go to login page
3. Enter credentials
4. **You should see the MFA challenge screen** (NEW!)
5. Enter code from authenticator app
6. Should redirect to dashboard

---

## 🔧 Troubleshooting

### Issue: "MFA already enabled"

**Solution**: MFA is already set up. You can:
- Use MFA login flow (enter code when logging in)
- Or disable and re-enable if needed

### Issue: QR Code doesn't scan

**Solution**: 
1. Check the QR code image is clear
2. Try manual entry with the secret key
3. Make sure your authenticator app supports TOTP

### Issue: "Invalid MFA token" when verifying

**Solution**:
- Make sure you're using the **current** 6-digit code
- TOTP codes change every 30 seconds
- Wait for a new code and try again

### Issue: Can't login after enabling MFA

**Solution**:
- Make sure you're entering the code from your authenticator app
- Codes are time-sensitive (30 seconds)
- If you lost access, you may need to disable MFA (contact admin)

---

## 📝 Files Created

After running the script, you'll have:
- `mfa-qrcode.png` - QR code to scan
- `mfa-secret.txt` - Secret key (for manual entry)

**Keep these files secure!** They contain sensitive information.

---

## 🎓 For Your Demo

**What to Show**:
1. Enable MFA using the script
2. Show QR code being scanned
3. Demonstrate MFA login flow:
   - Login → MFA challenge → Dashboard
4. Explain the security benefits

---

## 🚀 Quick Commands

```powershell
# Enable MFA
.\scripts\enable-mfa.ps1

# Verify MFA (replace 123456 with code from app)
.\scripts\verify-mfa.ps1 -Code "123456"

# Test MFA login (use frontend)
# Go to http://localhost:5173/login
```

---

**Ready to enable MFA? Run `.\scripts\enable-mfa.ps1`!** 🔐

