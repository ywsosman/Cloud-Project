# Zero-Trust Cloud Lab - Quick Reference Card

Quick commands and information for daily development.

## 🚀 Common Commands

### Docker Compose

```powershell
# Start all services
docker-compose up -d

# Stop all services
docker-compose stop

# Stop and remove
docker-compose down

# View logs (all services)
docker-compose logs -f

# View logs (specific service)
docker-compose logs -f auth-service

# Restart a service
docker-compose restart auth-service

# Rebuild and restart
docker-compose up -d --build auth-service

# Check status
docker-compose ps

# Remove everything (including data)
docker-compose down -v
```

### API Testing (PowerShell)

```powershell
# Health check
Invoke-RestMethod http://localhost:8080/health

# Register user
$body = @{
    username = "testuser"
    email = "test@example.com"
    password = "TestPass123!"
} | ConvertTo-Json

Invoke-RestMethod http://localhost:8080/api/auth/register `
    -Method POST `
    -ContentType "application/json" `
    -Body $body

# Login
$loginBody = @{
    email = "test@example.com"
    password = "TestPass123!"
} | ConvertTo-Json

$response = Invoke-RestMethod http://localhost:8080/api/auth/login `
    -Method POST `
    -ContentType "application/json" `
    -Body $loginBody

$token = $response.accessToken

# Access protected endpoint
$headers = @{Authorization = "Bearer $token"}
Invoke-RestMethod http://localhost:8080/api/auth/me -Headers $headers
```

### Database Access

```powershell
# Connect to PostgreSQL
docker-compose exec postgres psql -U postgres -d zerotrust

# SQL Commands
SELECT * FROM users;
SELECT * FROM sessions;
SELECT * FROM audit_logs ORDER BY timestamp DESC LIMIT 10;
```

### Azure CLI

```powershell
# Login
az login

# Set subscription
az account set --subscription <subscription-id>

# Create resource group
az group create --name zero-trust-lab-rg --location eastus

# List resources
az resource list --resource-group zero-trust-lab-rg

# Create AKS cluster
az aks create `
    --resource-group zero-trust-lab-rg `
    --name zero-trust-aks-cluster `
    --node-count 2 `
    --enable-managed-identity `
    --generate-ssh-keys

# Get AKS credentials
az aks get-credentials `
    --resource-group zero-trust-lab-rg `
    --name zero-trust-aks-cluster
```

### Kubernetes

```powershell
# Create namespace
kubectl apply -f kubernetes/namespace.yaml

# Deploy services
kubectl apply -f kubernetes/

# Check pods
kubectl get pods -n zero-trust

# Check services
kubectl get services -n zero-trust

# View logs
kubectl logs -f <pod-name> -n zero-trust

# Port forward
kubectl port-forward service/api-gateway 8080:80 -n zero-trust

# Delete everything
kubectl delete namespace zero-trust
```

## 📝 API Endpoints

### Base URL
- **Local:** http://localhost:8080
- **Azure:** https://<your-domain>

### Public Endpoints
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/api/auth/register` | Register new user |
| POST | `/api/auth/login` | Login user |
| POST | `/api/auth/refresh` | Refresh token |
| POST | `/api/auth/verify-mfa` | Verify MFA code |

### Protected Endpoints (Requires JWT)
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/auth/me` | Get current user |
| POST | `/api/auth/logout` | Logout |
| POST | `/api/auth/mfa/enable` | Enable MFA |
| GET | `/api/users` | List users (admin) |
| GET | `/api/users/:id` | Get user |
| PUT | `/api/users/:id` | Update user |
| POST | `/api/users/:id/change-password` | Change password |

## 🔒 Environment Variables

### Required
```env
DB_PASSWORD=your-secure-password
JWT_SECRET=your-jwt-secret-min-32-chars
```

### Optional but Recommended
```env
AZURE_SUBSCRIPTION_ID=your-sub-id
AZURE_TENANT_ID=your-tenant-id
ALLOWED_ORIGINS=http://localhost:3000
```

## 🌐 Service URLs

| Service | Local URL | Port |
|---------|-----------|------|
| API Gateway | http://localhost:8080 | 8080 |
| Auth Service | http://localhost:8081 | 8081 |
| PostgreSQL | localhost:5432 | 5432 |
| Redis | localhost:6379 | 6379 |

## 📊 Useful SQL Queries

```sql
-- View all users
SELECT id, username, email, role, created_at FROM users;

-- View recent logins
SELECT u.username, a.action, a.status, a.timestamp 
FROM audit_logs a 
JOIN users u ON a.user_id = u.id 
WHERE a.action = 'login' 
ORDER BY a.timestamp DESC 
LIMIT 10;

-- View failed login attempts
SELECT u.username, COUNT(*) as attempts 
FROM audit_logs a 
JOIN users u ON a.user_id = u.id 
WHERE a.action = 'failed_login' 
GROUP BY u.username 
ORDER BY attempts DESC;

-- View active sessions
SELECT u.username, s.ip_address, s.created_at, s.expires_at 
FROM sessions s 
JOIN users u ON s.user_id = u.id 
WHERE s.expires_at > NOW() AND s.is_revoked = false;

-- Security events summary
SELECT 
    action, 
    status, 
    COUNT(*) as count 
FROM audit_logs 
WHERE timestamp > NOW() - INTERVAL '24 hours' 
GROUP BY action, status 
ORDER BY count DESC;
```

## 🐛 Troubleshooting

### Port Already in Use
```powershell
# Find process using port
netstat -ano | findstr :8080

# Kill process (replace PID)
taskkill /PID <PID> /F
```

### Cannot Connect to Database
```powershell
# Restart PostgreSQL
docker-compose restart postgres

# Check logs
docker-compose logs postgres

# Verify it's running
docker-compose ps
```

### Auth Service Won't Start
```powershell
# Check logs
docker-compose logs auth-service

# Common issues:
# 1. Database not ready → Wait 30 seconds after starting
# 2. Missing .env file → Copy from .env.template
# 3. Invalid JWT_SECRET → Must be at least 32 characters
```

### Kubernetes Pod Errors
```powershell
# Describe pod
kubectl describe pod <pod-name> -n zero-trust

# View logs
kubectl logs <pod-name> -n zero-trust

# Check events
kubectl get events -n zero-trust --sort-by='.lastTimestamp'
```

## 📁 Important Files

| File | Purpose |
|------|---------|
| `START_HERE.md` | Quick start guide |
| `QUICKSTART.md` | Detailed setup |
| `PROJECT_STATUS.md` | Project status |
| `docker-compose.yml` | Local development |
| `.env` | Configuration (create from .env.template) |
| `src/auth-service/src/server.js` | Main application |
| `kubernetes/` | K8s deployment configs |

## 🎯 Development Workflow

1. **Make changes** to code
2. **Rebuild** service:
   ```powershell
   docker-compose up -d --build auth-service
   ```
3. **View logs**:
   ```powershell
   docker-compose logs -f auth-service
   ```
4. **Test** endpoints (see API Testing above)
5. **Commit** changes:
   ```powershell
   git add .
   git commit -m "Description"
   ```

## 📚 Quick Links

- [Project README](README.md)
- [Quick Start](START_HERE.md)
- [Full Guide](QUICKSTART.md)
- [Project Status](PROJECT_STATUS.md)
- [Implementation Summary](IMPLEMENTATION_SUMMARY.md)
- [Zero-Trust Principles](docs/zero-trust-principles.md)

## 🆘 Getting Help

1. **Check logs first**: `docker-compose logs -f`
2. **Review documentation**: See files above
3. **Common issues**: Check QUICKSTART.md troubleshooting section
4. **Still stuck?** Review error messages carefully

## 💾 Data Generation

```powershell
# Generate synthetic data
cd data-collection
python synthetic_data_generator.py

# Collect Azure logs (requires Azure setup)
$env:AZURE_SUBSCRIPTION_ID="your-sub-id"
python azure_log_collector.py
```

## 🔐 Security Checklist

- [ ] Changed DB_PASSWORD from default
- [ ] Changed JWT_SECRET (32+ characters)
- [ ] Reviewed ALLOWED_ORIGINS
- [ ] Using HTTPS in production
- [ ] Secrets in Azure Key Vault (production)
- [ ] Firewall rules configured
- [ ] Monitoring enabled
- [ ] Audit logs reviewed regularly

## 📊 Monitoring

```powershell
# View recent audit logs
docker-compose exec postgres psql -U postgres -d zerotrust -c "SELECT * FROM audit_logs ORDER BY timestamp DESC LIMIT 20;"

# Check service health
Invoke-RestMethod http://localhost:8080/health
Invoke-RestMethod http://localhost:8081/health

# Docker stats
docker stats
```

## 🎓 Next Steps

1. **Complete Week 4**: Azure account setup
2. **Complete Week 5**: Data collection
3. **Complete Week 6**: Architecture review
4. **Complete Week 7**: Cloud deployment
5. **Continue with Week 8+**: Advanced features

---

**💡 Pro Tip:** Bookmark this file for quick reference during development!

