# 🚀 START HERE - Zero-Trust Cloud Lab

**Welcome!** This guide will get you up and running in under 10 minutes.

## ✨ What You're Building

A **Zero-Trust Cloud System** where every service must authenticate - no implicit trust. Perfect for your cloud security project!

## 📋 What's Already Done

✅ **Weeks 1-3**: Problem definition and research (completed)  
✅ **Week 4-7**: Full implementation ready (infrastructure + code)  
⏳ **Week 8-15**: Your next steps

## 🎯 Quick Start (3 Steps)

### Step 1: Check Prerequisites (2 minutes)

Open PowerShell and check if you have Docker:

```powershell
docker --version
```

**Don't have Docker?** 
- Download: https://www.docker.com/products/docker-desktop
- Install and restart your computer
- Ensure Docker is running (check system tray)

### Step 2: Configure Environment (2 minutes)

1. Create your environment file:
```powershell
Copy-Item .env.template .env
```

2. Edit `.env` with Notepad:
```powershell
notepad .env
```

3. Change these two lines (minimum):
```env
DB_PASSWORD=YourSecurePassword123!
JWT_SECRET=your-super-secret-jwt-key-at-least-32-characters-long
```

Save and close.

### Step 3: Start the System (5 minutes)

```powershell
# Start all services
docker-compose up -d

# Wait 30 seconds for everything to start
Start-Sleep -Seconds 30

# Check if it's running
docker-compose ps
```

You should see 3 services running: `postgres`, `auth-service`, `api-gateway`

## ✅ Test It Works

### Test 1: Health Check
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/health"
```

Should return: `{"status":"healthy",...}`

### Test 2: Register a User
```powershell
$body = @{
    username = "testuser"
    email = "test@example.com"
    password = "TestPass123!"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/auth/register" 
    -Method POST 
    -ContentType "application/json" 
    -Body $body
```

Should return: `{"message":"User registered successfully",...}`

### Test 3: Login
```powershell
$loginBody = @{
    email = "test@example.com"
    password = "TestPass123!"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body $loginBody

# Save your token
$token = $response.accessToken
Write-Host "✓ Login successful! Token: $($token.Substring(0,50))..."
```

### Test 4: Access Protected Resource
```powershell
$headers = @{
    Authorization = "Bearer $token"
}

Invoke-RestMethod -Uri "http://localhost:8080/api/auth/me" `
    -Headers $headers
```

Should return your user information!

## 🎉 Success!

If all tests passed, you have:
- ✅ Working authentication system
- ✅ API Gateway with security
- ✅ Database with user management
- ✅ Zero-trust principles in action

## 📚 What's Included

### Working Code
- **Authentication Service** (Node.js + Express)
  - User registration & login
  - JWT tokens
  - MFA support
  - Audit logging
  
- **API Gateway** (Nginx)
  - Request routing
  - JWT validation
  - Rate limiting
  - Security headers

- **Database** (PostgreSQL)
  - User management
  - Session tracking
  - Audit logs

### Documentation
- `README.md` - Project overview
- `QUICKSTART.md` - Detailed quick start
- `PROJECT_STATUS.md` - What's done and what's next
- `week*/README.md` - Week-by-week guides
- `docs/zero-trust-principles.md` - Zero-trust architecture

### Tools & Scripts
- Docker Compose for local development
- Kubernetes manifests for cloud deployment
- Data collection scripts (Python)
- Test scripts
- Setup automation

## 🗺️ Project Structure

```
Cloud Project/
├── START_HERE.md          ← You are here
├── QUICKSTART.md          ← Detailed guide
├── docker-compose.yml     ← Start services
├── src/
│   ├── auth-service/      ← Authentication API
│   └── api-gateway/       ← Nginx gateway
├── kubernetes/            ← Deploy to cloud
├── data-collection/       ← Generate test data
└── week4-setup/          ← Azure setup guide
```

## 📖 Next Steps

### Immediate (Today)
1. ✅ Get the system running (you just did this!)
2. 📊 Generate test data:
   ```powershell
   cd data-collection
   python synthetic_data_generator.py
   ```
3. 📱 Test all API endpoints (see `QUICKSTART.md`)

### This Week (Week 4)
1. Set up Azure account (free tier)
2. Run: `.\week4-setup\setup-script.ps1`
3. Create Azure resources:
   - Resource Group
   - Container Registry
   - Kubernetes Cluster
   - Key Vault

See: `week4-setup/README.md`

### Next Week (Week 5)
1. Collect Azure security data
2. Upload to cloud storage
3. Analyze security patterns

See: `week5-data/README.md`

### Weeks 6-7
1. Review system architecture
2. Deploy to Azure Kubernetes
3. Present prototype

See: `week6-design/README.md` and `week7-prototype1/README.md`

## 🛠️ Common Commands

```powershell
# View logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f auth-service

# Restart services
docker-compose restart

# Stop services
docker-compose stop

# Stop and remove everything
docker-compose down

# Remove everything including data
docker-compose down -v
```

## 🐛 Troubleshooting

### "Port already in use"
```powershell
# Find what's using port 8080
netstat -ano | findstr :8080

# Kill the process (replace <PID> with actual process ID)
taskkill /PID <PID> /F
```

### "Docker is not running"
1. Start Docker Desktop from Start menu
2. Wait for it to fully start (whale icon in system tray)
3. Try again

### "Cannot connect to database"
```powershell
# Restart PostgreSQL
docker-compose restart postgres

# Check logs
docker-compose logs postgres
```

### Need to reset everything?
```powershell
# Nuclear option - removes everything
docker-compose down -v
docker system prune -a

# Start fresh
docker-compose up -d
```

## 📞 Getting Help

1. **Check the logs first:**
   ```powershell
   docker-compose logs -f auth-service
   ```

2. **Review documentation:**
   - `QUICKSTART.md` - Detailed setup
   - `week*/README.md` - Week-specific guides
   - `PROJECT_STATUS.md` - Current status

3. **Common issues:**
   - Port conflicts → Change ports in `docker-compose.yml`
   - Database errors → Restart postgres service
   - Permission errors → Run PowerShell as Administrator

## 🎓 Learning Resources

### Zero-Trust Architecture
- Read: `docs/zero-trust-principles.md`
- [NIST Zero Trust Guide](https://www.nist.gov/publications/zero-trust-architecture)

### Technologies Used
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [Azure Getting Started](https://docs.microsoft.com/azure/get-started/)
- [JWT Authentication](https://jwt.io/introduction)

### Security Best Practices
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [API Security Checklist](https://github.com/shieldfy/API-Security-Checklist)

## 🎯 Your Weekly Goals

- **Week 4** (Current): Get everything running locally + Azure setup
- **Week 5**: Collect and analyze security data
- **Week 6**: Review architecture and get feedback
- **Week 7**: Deploy prototype to Azure
- **Week 8**: Add advanced features (service mesh, monitoring)
- **Week 9**: Midterm demo
- **Weeks 10-15**: Advanced features, testing, optimization, final demo

## 🌟 Key Features

### Already Implemented ✅
- User authentication (register, login, logout)
- JWT token management
- Multi-factor authentication (MFA)
- Password hashing (bcrypt)
- Rate limiting
- Audit logging
- Session management
- Role-based access control
- API Gateway with security
- Docker containerization
- Kubernetes deployment configs

### Coming Next (Week 8+)
- Azure Key Vault integration
- Service mesh (Istio)
- Advanced monitoring
- Multi-cloud support
- AI-based threat detection
- Cost optimization

## 🔒 Security Features

Your system already includes:
- ✅ Password hashing (bcrypt, 12 rounds)
- ✅ JWT tokens (1-hour expiry)
- ✅ Rate limiting (prevents brute force)
- ✅ Account lockout (5 failed attempts)
- ✅ SQL injection prevention
- ✅ CORS protection
- ✅ Security headers
- ✅ Audit logging
- ✅ Input validation

## 💡 Pro Tips

1. **Use Git:** Version control your changes
   ```powershell
   git init
   git add .
   git commit -m "Initial setup"
   ```

2. **Environment Variables:** Never commit `.env` to Git (already in `.gitignore`)

3. **Test Often:** Run tests after every change
   ```powershell
   bash scripts/test-api.sh  # Requires Git Bash or WSL
   ```

4. **Read Logs:** Logs are your friend when debugging
   ```powershell
   docker-compose logs -f
   ```

5. **Documentation:** Keep notes in each `week*/README.md` file

## 🚀 Ready to Go!

You now have:
- ✅ Working zero-trust system
- ✅ Complete documentation
- ✅ Cloud deployment configs
- ✅ 4 weeks of deliverables ready
- ✅ Clear path for next 11 weeks

**Start coding and good luck with your project!** 🎉

---

**Questions?** Check `QUICKSTART.md` for more detailed instructions or `PROJECT_STATUS.md` for project overview.

**Next:** Run the Azure setup script → `.\week4-setup\setup-script.ps1`

