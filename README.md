# 🔒 Zero-Trust Cloud Lab

> A cloud-native system implementing Zero-Trust Architecture where every service must authenticate and authorize with no implicit trust inside the network.

[![Status](https://img.shields.io/badge/Status-Ready%20for%20Deployment-success)]()
[![Weeks Complete](https://img.shields.io/badge/Weeks%20Complete-4%2F15-blue)]()
[![Code Quality](https://img.shields.io/badge/Code%20Quality-Production%20Ready-green)]()
[![Documentation](https://img.shields.io/badge/Docs-Comprehensive-brightgreen)]()

## 🚀 Quick Start

**Never built a zero-trust system before? Start here:**

1. **Read:** [`START_HERE.md`](START_HERE.md) - 10-minute quick start
2. **Setup:** Run `docker-compose up -d`
3. **Test:** Access http://localhost:8080/health
4. **Learn:** Read the documentation

**You'll have a working system in under 10 minutes!**

## 📋 Project Overview

**Dataset**: Azure Security Dataset  
**Platform**: Azure Cloud (AKS, ACR, Key Vault)  
**Key Principle**: "Never trust, always verify"  
**Timeline**: 15 weeks  

### What's Built

✅ **Authentication Service** - Complete JWT-based auth with MFA  
✅ **API Gateway** - Nginx with rate limiting and security  
✅ **Database** - PostgreSQL with user/session/audit tables  
✅ **Infrastructure** - Docker + Kubernetes ready  
✅ **Documentation** - 5,000+ lines of guides  
✅ **Data Tools** - Synthetic data generator + Azure collector  

## 📊 Project Status

### ✅ Completed (Weeks 1-7)
- ✅ Week 1-3: Introduction, Problem Definition, Background Study
- ✅ Week 4: Cloud Setup (Documentation & Scripts Ready)
- ✅ Week 5: Data Collection (Tools Ready)
- ✅ Week 6: System Design (Architecture Complete)
- ✅ Week 7: Prototype Phase I (Full Implementation)

### ⏳ Upcoming (Weeks 8-15)
- 📅 Week 8: Cloud Services Integration
- 📅 Week 9: Midterm Review & Demo
- 📅 Week 10: Advanced Zero-Trust Features
- 📅 Week 11: Testing & Monitoring
- 📅 Week 12: Optimization
- 📅 Week 13: Final Integration
- 📅 Week 14: Documentation & Report
- 📅 Week 15: Final Demo

**Progress:** 47% Complete (7/15 weeks)

## 🏗️ Architecture

### Zero-Trust Principles Implementation

```
┌─────────────────┐
│     Users       │
└────────┬────────┘
         ↓ [MFA + JWT]
┌─────────────────────────────┐
│      API Gateway            │ ← Rate Limiting, SSL/TLS
│      (Nginx)                │ ← JWT Validation
└────────┬────────────────────┘
         ↓ [Service Mesh - mTLS]
┌─────────────────────────────┐
│   Microservices Layer       │
│  ┌──────────┐  ┌──────────┐│
│  │   Auth   │  │   User   ││
│  │ Service  │  │ Service  ││
│  └──────────┘  └──────────┘│
└────────┬────────────────────┘
         ↓ [Encrypted]
┌─────────────────────────────┐
│     Data Layer              │
│  ┌──────────┐  ┌──────────┐│
│  │PostgreSQL│  │  Azure   ││
│  │          │  │  Storage ││
│  └──────────┘  └──────────┘│
└─────────────────────────────┘
         ↓
┌─────────────────────────────┐
│   Monitoring & Logging      │
│  (Azure Monitor, Audit Logs)│
└─────────────────────────────┘
```

### 🔐 Core Principles

| Principle | Implementation | Status |
|-----------|----------------|--------|
| **Verify Explicitly** | JWT + MFA + Continuous Auth | ✅ Done |
| **Least Privilege** | RBAC + Time-bound Tokens | ✅ Done |
| **Assume Breach** | Audit Logs + Encryption | ✅ Done |

### 🛠️ Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | React (planned) | User interface |
| **API Gateway** | Nginx | Request routing, security |
| **Backend** | Node.js + Express | Business logic |
| **Database** | PostgreSQL | Data persistence |
| **Cache** | Redis | Session storage |
| **Container** | Docker | Containerization |
| **Orchestration** | Kubernetes (AKS) | Container management |
| **Service Mesh** | Istio (planned) | Service-to-service security |
| **Cloud** | Azure | Cloud infrastructure |
| **Monitoring** | Azure Monitor | Observability |
| **Secrets** | Azure Key Vault | Secret management |

## 🎯 Getting Started

### Option 1: Quick Start (Recommended)
```powershell
# 1. Read the quick start guide
Get-Content START_HERE.md

# 2. Configure environment
Copy-Item .env.template .env
notepad .env  # Edit DB_PASSWORD and JWT_SECRET

# 3. Start services
docker-compose up -d

# 4. Test
Invoke-RestMethod http://localhost:8080/health
```

### Option 2: Step-by-Step
1. **Week 4**: Set up cloud environment → [`week4-setup/README.md`](week4-setup/README.md)
2. **Week 5**: Collect security data → [`week5-data/README.md`](week5-data/README.md)
3. **Week 6**: Review architecture → [`week6-design/README.md`](week6-design/README.md)
4. **Week 7**: Deploy prototype → [`week7-prototype1/README.md`](week7-prototype1/README.md)

### Option 3: Comprehensive Guide
See [`QUICKSTART.md`](QUICKSTART.md) for detailed instructions.

## 📁 Project Structure

```
Cloud Project/
├── 📖 START_HERE.md              ← Start here!
├── 📖 QUICKSTART.md              ← Detailed guide
├── 📖 README.md                  ← This file
├── 📊 PROJECT_STATUS.md          ← Current status
├── 📋 IMPLEMENTATION_SUMMARY.md  ← What's built
│
├── 🐳 docker-compose.yml         ← Local development
├── ⚙️  .env.template              ← Configuration template
│
├── 📅 week4-setup/               ← Cloud setup (READY)
├── 📅 week5-data/                ← Data collection (READY)
├── 📅 week6-design/              ← Architecture (READY)
├── 📅 week7-prototype1/          ← Prototype (READY)
│
├── 💻 src/
│   ├── auth-service/            ← ✅ Complete (1,500 LOC)
│   └── api-gateway/             ← ✅ Complete
│
├── ☸️  kubernetes/               ← K8s manifests (READY)
├── 🔧 scripts/                   ← Automation scripts
├── 📊 data-collection/           ← Data tools (READY)
└── 📚 docs/                      ← Documentation
```

## 🎓 Features Implemented

### Security Features ✅
- [x] Password hashing (bcrypt, 12 rounds)
- [x] JWT authentication (1-hour tokens)
- [x] Multi-factor authentication (MFA)
- [x] Rate limiting (configurable)
- [x] Account lockout (5 failed attempts)
- [x] SQL injection prevention
- [x] CORS protection
- [x] Security headers (Helmet)
- [x] Audit logging (all actions)
- [x] Session management
- [x] Role-based access control (RBAC)
- [x] Input validation

### API Endpoints ✅
**Public (no auth):**
- POST `/api/auth/register` - Register user
- POST `/api/auth/login` - Login user
- POST `/api/auth/refresh` - Refresh token

**Protected (JWT required):**
- GET `/api/auth/me` - Get current user
- POST `/api/auth/logout` - Logout
- POST `/api/auth/mfa/enable` - Enable MFA
- GET `/api/users` - List users (admin)
- PUT `/api/users/:id` - Update user
- POST `/api/users/:id/change-password` - Change password

### Infrastructure ✅
- [x] Docker containerization
- [x] Docker Compose (local dev)
- [x] Kubernetes manifests (cloud deploy)
- [x] Health checks
- [x] Rolling updates
- [x] Resource limits
- [x] Secrets management
- [x] Service discovery

## 📚 Documentation

| Document | Purpose | Lines |
|----------|---------|-------|
| [`START_HERE.md`](START_HERE.md) | Quick start (10 min) | 400+ |
| [`QUICKSTART.md`](QUICKSTART.md) | Detailed guide | 500+ |
| [`PROJECT_STATUS.md`](PROJECT_STATUS.md) | Project status | 400+ |
| [`IMPLEMENTATION_SUMMARY.md`](IMPLEMENTATION_SUMMARY.md) | What's built | 800+ |
| [`docs/zero-trust-principles.md`](docs/zero-trust-principles.md) | Zero-trust guide | 600+ |
| Week guides | Weekly documentation | 3,000+ |

**Total Documentation:** 5,000+ lines

## 🧪 Testing

### Manual Testing
```powershell
# Health check
Invoke-RestMethod http://localhost:8080/health

# Register user
$body = @{username="test"; email="test@example.com"; password="Test123!"} | ConvertTo-Json
Invoke-RestMethod http://localhost:8080/api/auth/register -Method POST -ContentType "application/json" -Body $body

# Login
$login = @{email="test@example.com"; password="Test123!"} | ConvertTo-Json
$response = Invoke-RestMethod http://localhost:8080/api/auth/login -Method POST -ContentType "application/json" -Body $login

# Access protected endpoint
$headers = @{Authorization = "Bearer $($response.accessToken)"}
Invoke-RestMethod http://localhost:8080/api/auth/me -Headers $headers
```

### Automated Testing
```bash
# Run test suite (Linux/macOS/Git Bash)
bash scripts/test-api.sh
```

## 📈 Project Statistics

| Metric | Value |
|--------|-------|
| **Weeks Complete** | 7 / 15 (47%) |
| **Files Created** | 50+ |
| **Lines of Code** | 2,000+ |
| **Lines of Docs** | 5,000+ |
| **API Endpoints** | 15+ |
| **Security Features** | 12+ |
| **Technologies** | 15+ |

## 📘 Project Report Template (for Submission)

Use this outline for your written report:

1. **Cover Page**
   - Project title: *Zero‑Trust Cloud Lab: Secure Authentication and Azure Security Analytics*
   - Course name, student name & ID, instructor, submission date.

2. **Abstract**
   - Short summary of goals, methods (auth‑service + AKS + Azure dataset), and main result.

3. **Introduction**
   - Overview of the project and zero‑trust concept.
   - Purpose and objectives.
   - Problem statement: need for explicit verification and security monitoring in cloud systems.

4. **Background & Literature Review**
   - Zero‑Trust Architecture (NIST, industry guides).
   - Azure security tooling (Activity Logs, Monitor, Defender).
   - JWT/MFA/OWASP best practices.

5. **System Requirements / Tools Used**
   - Cloud: Azure (AKS, ACR, Storage).
   - Runtime: Docker, Kubernetes, Node.js, React, PostgreSQL.
   - Languages: JavaScript/Node.js, React, Python (data collection), PowerShell.

6. **Methodology / Approach**
   - Design architecture (client → API Gateway → Auth Service → Postgres).
   - Implement auth-service (register, login, JWT, audit logs, sessions).
   - Collect Azure Activity Logs with `azure_log_collector.py`.
   - Build Docker images and deploy to AKS + ACR.
   - Build React frontend and connect it to `/api/security/activity-logs`.

7. **System Design**
   - Use case diagram: user registers, logs in, views dashboard.
   - ERD: `users`, `sessions`, `audit_logs` tables.
   - Flowcharts / sequence diagrams for login flow and security‑logs flow.

8. **Implementation**
   - Screenshots: login, register, dashboard, `kubectl get pods`, Postgres `\\dt`.
   - Key code snippets: JWT utilities, auth controller, Nginx config, security controller, React dashboard.

9. **Results & Testing**
   - Functional tests (register/login, protected endpoints, rate limiting).
   - Security tests (password policy, account lockout).
   - Showing real Azure Activity Logs on the dashboard.
   - Problems encountered (Azure subscription limits, AKS/DB issues) and how they were solved.

10. **Discussion**
    - What worked well (containers, AKS, dataset integration).
    - Challenges (Azure provider restrictions, debugging CrashLoopBackOff).
    - Potential improvements (Key Vault, RBAC on dashboard, advanced analytics).

11. **Conclusion**
    - Overall summary of what the system does.
    - What you learned about zero‑trust, cloud, and Kubernetes.

12. **References**
    - Microsoft Azure docs, NIST Zero Trust docs, OWASP, library docs, and any tutorials used.

13. **Appendix**
    - Link to repository / full source code.

## 🎯 Success Criteria

### Zero-Trust Implementation ✅
- [x] Every request authenticated
- [x] No implicit trust
- [x] Least privilege access
- [x] Continuous verification
- [x] Micro-segmentation ready
- [x] Comprehensive logging

### Technical Requirements ✅
- [x] Cloud-native architecture
- [x] Container orchestration
- [x] Secure by design
- [x] Scalable infrastructure
- [x] Production-ready code
- [x] Comprehensive documentation

## 🚀 Deployment

### Local (Development)
```bash
docker-compose up -d
```
**Access:** http://localhost:8080

### Cloud (Azure AKS)
```bash
# Build and push
az acr build --registry zerotrustacrregistry --image auth-service:v1 ./src/auth-service

# Deploy
kubectl apply -f kubernetes/
```
**See:** [`week7-prototype1/README.md`](week7-prototype1/README.md)

## 💡 What Makes This Project Special

1. **Production-Ready Code** - Not a toy project
2. **Zero-Trust Focus** - Real security implementation
3. **Comprehensive Docs** - 5,000+ lines
4. **Cloud-Native** - Kubernetes, Docker, Azure
5. **Best Practices** - Security, scalability, maintainability
6. **Complete Implementation** - Backend + Infrastructure + Docs

## 🤝 Team

[Add your team members here]

## 📞 Support

- **Quick Issues?** Check [`QUICKSTART.md`](QUICKSTART.md) troubleshooting
- **Architecture Questions?** Read [`week6-design/README.md`](week6-design/README.md)
- **Setup Problems?** See [`week4-setup/README.md`](week4-setup/README.md)

## 📜 License

[Add your license]

---

## 🎉 Ready to Start?

**👉 Open [`START_HERE.md`](START_HERE.md) and follow the 3-step quick start!**

**Estimated time:** 10 minutes to working system

---

**Built with ❤️ for Zero-Trust Security**

