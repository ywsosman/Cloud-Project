# Zero-Trust Cloud Lab - Quick Start Guide

This guide will help you get started with the Zero-Trust Cloud Lab project quickly.

## Prerequisites

- Windows 10/11 with PowerShell or Linux/macOS with Bash
- Docker Desktop installed and running
- Azure account (free tier)
- Git
- Node.js 18+ (optional, for local development)

## Quick Setup (5 minutes)

### Step 1: Clone and Navigate

```powershell
cd "D:\youssef\Fullstack Course\Cloud Project"
```

### Step 2: Run Setup Script

**Windows (PowerShell):**
```powershell
.\week4-setup\setup-script.ps1
```

**Linux/macOS:**
```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### Step 3: Configure Environment

1. Copy the environment template:
```powershell
copy .env.template .env
```

2. Edit `.env` file with your settings (minimum required):
```env
DB_PASSWORD=your-secure-password
JWT_SECRET=your-super-secret-jwt-key-min-32-chars
```

### Step 4: Start Services

```bash
docker-compose up -d
```

Wait about 30 seconds for services to initialize.

### Step 5: Verify Setup

```bash
# Check if services are running
docker-compose ps

# Test API Gateway
curl http://localhost:8080/health

# Test Auth Service
curl http://localhost:8081/health
```

## Test the API

### Register a User

```powershell
$body = @{
    username = "admin"
    email = "admin@example.com"
    password = "AdminPass123!"
    firstName = "Admin"
    lastName = "User"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/auth/register" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

Or using curl:
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "email": "admin@example.com",
    "password": "AdminPass123!",
    "firstName": "Admin",
    "lastName": "User"
  }'
```

### Login

```powershell
$loginBody = @{
    email = "admin@example.com"
    password = "AdminPass123!"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body $loginBody

$token = $response.accessToken
Write-Host "Access Token: $token"
```

Or using curl:
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "AdminPass123!"
  }'
```

### Access Protected Endpoint

```powershell
$headers = @{
    Authorization = "Bearer $token"
}

Invoke-RestMethod -Uri "http://localhost:8080/api/auth/me" `
    -Method GET `
    -Headers $headers
```

Or using curl:
```bash
curl -X GET http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Run Automated Tests

**Linux/macOS:**
```bash
chmod +x scripts/test-api.sh
./scripts/test-api.sh
```

**Windows (use Git Bash or WSL):**
```bash
bash scripts/test-api.sh
```

## View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f auth-service

# Last 100 lines
docker-compose logs --tail=100 auth-service
```

## Stop Services

```bash
# Stop but keep data
docker-compose stop

# Stop and remove containers
docker-compose down

# Stop and remove everything including volumes
docker-compose down -v
```

## Project Structure

```
.
├── README.md                  # Project overview
├── QUICKSTART.md             # This file
├── docker-compose.yml        # Local development setup
├── .env.template            # Environment variables template
├── week4-setup/             # Week 4: Cloud setup instructions
├── week5-data/              # Week 5: Data collection
├── week6-design/            # Week 6: System design
├── week7-prototype1/        # Week 7: Basic prototype
├── src/
│   ├── auth-service/        # Authentication microservice
│   └── api-gateway/         # API Gateway (Nginx)
├── kubernetes/              # Kubernetes manifests
├── scripts/                 # Utility scripts
└── docs/                    # Documentation
```

## Available Endpoints

### Public Endpoints (No Authentication)

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/verify-mfa` - Verify MFA code

### Protected Endpoints (Requires JWT)

- `GET /api/auth/me` - Get current user info
- `POST /api/auth/logout` - Logout user
- `POST /api/auth/mfa/enable` - Enable MFA
- `POST /api/auth/mfa/verify` - Verify MFA setup
- `GET /api/users` - List users (admin only)
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user
- `POST /api/users/:id/change-password` - Change password

## Common Issues

### Port Already in Use

If you get "port already in use" error:

```bash
# Find process using port
netstat -ano | findstr :8080
netstat -ano | findstr :8081

# Kill the process (Windows)
taskkill /PID <PID> /F

# Or change ports in docker-compose.yml
```

### Database Connection Error

If auth-service can't connect to database:

```bash
# Check if postgres is running
docker-compose ps

# Restart postgres
docker-compose restart postgres

# Check logs
docker-compose logs postgres
```

### Docker Not Running

```bash
# Start Docker Desktop
# Then verify:
docker ps
```

## Next Steps

1. **Week 4**: Complete cloud environment setup
   - Set up Azure account
   - Create AKS cluster
   - Configure Azure Container Registry

2. **Week 5**: Collect Azure Security Dataset
   - Download security logs
   - Set up data storage
   - Perform initial analysis

3. **Week 6**: Design full system architecture
   - Create architecture diagrams
   - Plan service mesh implementation
   - Design security layers

4. **Week 7+**: Continue with prototype development

## Useful Commands

```bash
# Build specific service
docker-compose build auth-service

# Restart a service
docker-compose restart auth-service

# View service logs
docker-compose logs -f auth-service

# Execute command in container
docker-compose exec auth-service sh

# Access PostgreSQL
docker-compose exec postgres psql -U postgres -d zerotrust

# Clean up everything
docker-compose down -v --remove-orphans
docker system prune -a
```

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Azure Documentation](https://docs.microsoft.com/azure/)
- [Zero-Trust Architecture Guide](docs/zero-trust-principles.md)

## Support

- Check README files in each week's folder
- Review logs: `docker-compose logs`
- Open an issue if you encounter problems

## Security Notes

⚠️ **Important for Production:**

1. Change all default passwords
2. Use Azure Key Vault for secrets
3. Enable HTTPS/TLS
4. Set up proper firewall rules
5. Enable audit logging
6. Regular security updates

---

**Happy Coding!** 🚀

