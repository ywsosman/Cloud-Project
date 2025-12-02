# Week 7: Prototype Phase I

## Objectives
- Implement basic authentication system
- Create simple API Gateway
- Deploy basic version on cloud
- Demonstrate zero-trust principle: "Verify Explicitly"
- Expose Azure Security Dataset through a protected API

## Deliverables
- Working authentication service
- API Gateway with JWT validation
- Basic user management
- Initial cloud deployment

## Architecture for Phase I

```
Client → API Gateway → Auth Service → Azure AD/Database
   ↓           ↓             ↓
 HTTPS    JWT Validation  Password Hash
             Rate Limit    MFA (basic)
```

## Implementation Tasks

### 1. Authentication Service

**Technology Stack**:
- Node.js with Express (or Python with FastAPI)
- PostgreSQL (Azure SQL Database)
- JWT for tokens
- bcrypt for password hashing

**Features**:
- User registration
- User login
- Password hashing
- JWT token generation
- Token validation
- Basic MFA (email/SMS)

### 2. API Gateway

**Technology Stack**:
- Nginx or Kong or Azure API Management
- JWT middleware
- Rate limiting

**Features**:
- Request routing
- JWT validation
- Rate limiting (100 req/min per user)
- SSL/TLS termination
- Request logging

### 3. Security Dataset API (Auth Service)

To connect the Week 5 Azure Security Dataset with the running prototype, the `auth-service` now exposes a **read‑only security API**:

- `GET /api/security/activity-logs`
  - **Auth**: JWT required (any authenticated user)
  - **Source**: Reads from `data-collection/azure_activity_logs.json`
  - **Query params**:
    - `limit` (optional, default `50`) – max number of events to return
    - `status` (optional) – filter by status (e.g., `Succeeded`, `Started`)
    - `caller` (optional) – filter by partial match on caller email/UPN
  - **Response**:
    - `count` – number of events returned
    - `totalAvailable` – total events after filters
    - `data` – list of activity log entries (timestamp, level, operation, resource_id, status, caller, category, claims)

This satisfies the “use Azure Security Dataset” part of the prototype and enables a future security dashboard frontend.

## Directory Structure

```
week7-prototype1/
├── auth-service/
│   ├── src/
│   │   ├── controllers/
│   │   │   ├── authController.js
│   │   │   └── userController.js
│   │   ├── middleware/
│   │   │   ├── authMiddleware.js
│   │   │   └── validationMiddleware.js
│   │   ├── models/
│   │   │   └── userModel.js
│   │   ├── routes/
│   │   │   ├── authRoutes.js
│   │   │   └── userRoutes.js
│   │   ├── utils/
│   │   │   ├── jwt.js
│   │   │   └── hash.js
│   │   ├── config/
│   │   │   └── database.js
│   │   └── server.js
│   ├── Dockerfile
│   ├── package.json
│   └── .env.example
├── api-gateway/
│   ├── nginx.conf
│   ├── Dockerfile
│   └── ssl/
├── docker-compose.yml
└── README.md
```

## Implementation Steps

### Step 1: Set Up Database

**Azure SQL Database**:
```bash
# Create Azure SQL Server
az sql server create \
  --name zero-trust-sql-server \
  --resource-group zero-trust-lab-rg \
  --location eastus \
  --admin-user sqladmin \
  --admin-password <YourPassword>

# Create Database
az sql db create \
  --resource-group zero-trust-lab-rg \
  --server zero-trust-sql-server \
  --name zero-trust-db \
  --service-objective S0

# Configure firewall
az sql server firewall-rule create \
  --resource-group zero-trust-lab-rg \
  --server zero-trust-sql-server \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

**Database Schema**:
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    role VARCHAR(20) DEFAULT 'user',
    mfa_enabled BOOLEAN DEFAULT false,
    mfa_secret VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(50) NOT NULL,
    resource VARCHAR(100),
    ip_address VARCHAR(45),
    status VARCHAR(20),
    details JSONB,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_expires_at ON sessions(expires_at);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp);
```

### Step 2: Build Authentication Service

See `auth-service/` directory for full implementation.

**Key Endpoints**:
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login and get JWT
- `POST /api/auth/logout` - Invalidate token
- `POST /api/auth/refresh` - Refresh JWT token
- `POST /api/auth/verify-mfa` - Verify MFA code
- `GET /api/auth/me` - Get current user info

### Step 3: Build API Gateway

See `api-gateway/` directory for configuration.

**Nginx Configuration**:
```nginx
upstream auth_service {
    server auth-service:8081;
}

server {
    listen 80;
    server_name localhost;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=general:10m rate=100r/m;
    limit_req zone=general burst=20 nodelay;

    # Health check
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }

    # Auth endpoints (no JWT required)
    location /api/auth/login {
        proxy_pass http://auth_service;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /api/auth/register {
        proxy_pass http://auth_service;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Protected endpoints (JWT required)
    location /api/ {
        auth_request /auth;
        auth_request_set $auth_status $upstream_status;
        
        proxy_pass http://auth_service;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-User-ID $upstream_http_x_user_id;
    }

    # Internal auth validation
    location = /auth {
        internal;
        proxy_pass http://auth_service/api/auth/validate;
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";
        proxy_set_header X-Original-URI $request_uri;
    }
}
```

### Step 4: Docker Containerization

**auth-service/Dockerfile**:
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 8081

USER node

CMD ["node", "src/server.js"]
```

**docker-compose.yml**:
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: zerotrust
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - zero-trust-net

  auth-service:
    build: ./auth-service
    ports:
      - "8081:8081"
    environment:
      DATABASE_URL: ${DATABASE_URL}
      JWT_SECRET: ${JWT_SECRET}
      JWT_EXPIRY: ${JWT_EXPIRY}
    depends_on:
      - postgres
    networks:
      - zero-trust-net

  api-gateway:
    build: ./api-gateway
    ports:
      - "8080:80"
    depends_on:
      - auth-service
    networks:
      - zero-trust-net

networks:
  zero-trust-net:
    driver: bridge

volumes:
  postgres_data:
```

### Step 5: Deploy to Azure

**Option A: Azure Container Instances (ACI)**
```bash
# Build and push to ACR
az acr build --registry zerotrustacrregistry \
  --image auth-service:v1 ./auth-service

# Deploy to ACI
az container create \
  --resource-group zero-trust-lab-rg \
  --name auth-service \
  --image zerotrustacrregistry.azurecr.io/auth-service:v1 \
  --dns-name-label zero-trust-auth \
  --ports 8081
```

**Option B: Azure Kubernetes Service (AKS)**
```bash
# Create Kubernetes manifests (see kubernetes/ directory)
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/auth-service-deployment.yaml
kubectl apply -f kubernetes/auth-service-service.yaml
kubectl apply -f kubernetes/api-gateway-deployment.yaml
kubectl apply -f kubernetes/api-gateway-service.yaml
```

## Testing

### 1. Unit Tests
```bash
cd auth-service
npm test
```

### 2. Integration Tests
```bash
# Test registration
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"SecurePass123!"}'

# Test login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"SecurePass123!"}'

# Test protected endpoint
curl -X GET http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer <JWT_TOKEN>"
```

### 3. Security Tests
- SQL injection attempts
- XSS attempts
- JWT manipulation
- Brute force protection
- Rate limiting validation

## Security Checklist

- [ ] Passwords hashed with bcrypt (salt rounds >= 12)
- [ ] JWT tokens with expiry (< 1 hour)
- [ ] HTTPS enforced (TLS 1.2+)
- [ ] Input validation on all endpoints
- [ ] SQL parameterized queries (no string concatenation)
- [ ] Rate limiting implemented
- [ ] CORS properly configured
- [ ] Security headers set (HSTS, X-Frame-Options, etc.)
- [ ] Secrets stored in Azure Key Vault
- [ ] Audit logging for all auth events

## Monitoring

### Metrics to Track
- Authentication success/failure rate
- Token generation rate
- API response time
- Error rate
- Active sessions count

### Logging
- All authentication attempts (success/failure)
- Token generation/validation
- API requests with user context
- Security events (suspicious activity)

## Demo Preparation

### What to Demonstrate
1. User registration flow
2. Login with JWT token generation
3. Protected endpoint access
4. Token expiry and refresh
5. Rate limiting in action
6. Audit logs

### Demo Script
```bash
# 1. Register a user
curl -X POST http://<your-endpoint>/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","email":"demo@example.com","password":"DemoPass123!"}'

# 2. Login
TOKEN=$(curl -X POST http://<your-endpoint>/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@example.com","password":"DemoPass123!"}' \
  | jq -r '.token')

# 3. Access protected endpoint
curl -X GET http://<your-endpoint>/api/auth/me \
  -H "Authorization: Bearer $TOKEN"

# 4. Show audit logs
curl -X GET http://<your-endpoint>/api/admin/audit-logs \
  -H "Authorization: Bearer $TOKEN"
```

## Known Issues & Limitations

1. **MFA**: Basic implementation, needs improvement
2. **Session Management**: In-memory, should use Redis
3. **Password Recovery**: Not implemented yet
4. **Account Lockout**: Basic brute-force protection
5. **Device Fingerprinting**: Not implemented

## Next Steps - Week 8

- Integrate Azure Key Vault for secrets
- Add Redis for session management
- Implement service mesh (Istio)
- Add more microservices
- Implement service-to-service authentication
- Add monitoring with Azure Application Insights

## Resources

- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [Azure SQL Database Security](https://docs.microsoft.com/azure/azure-sql/database/security-overview)

