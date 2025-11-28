# Week 6: System Design

## Objectives
- Draft comprehensive architecture diagram
- Define data flow and service interactions
- Design security layers
- Present to TA/instructor for feedback

## Zero-Trust Architecture Design

### Core Principles Implementation

1. **Verify Explicitly**
   - Every request requires authentication
   - Continuous validation of user identity
   - Context-aware access decisions

2. **Least Privilege Access**
   - Just-In-Time (JIT) access provisioning
   - Just-Enough-Access (JEA) policies
   - Time-bound permissions

3. **Assume Breach**
   - Micro-segmentation of network
   - End-to-end encryption
   - Comprehensive logging and monitoring

## System Architecture

### High-Level Components

```
┌─────────────────────────────────────────────────────────────────┐
│                          Users/Clients                           │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API Gateway                                 │
│              (Authentication & Authorization)                    │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Service Mesh (Istio)                          │
│              (mTLS, Traffic Management, Policies)                │
└──────────────────────┬──────────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┬──────────────┐
        ▼              ▼              ▼              ▼
    ┌────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
    │  Auth  │   │  User    │   │ Security │   │  Data    │
    │Service │   │ Service  │   │ Service  │   │ Service  │
    └────────┘   └──────────┘   └──────────┘   └──────────┘
        │              │              │              │
        └──────────────┴──────────────┴──────────────┘
                       │
                       ▼
            ┌─────────────────────┐
            │   Azure Services    │
            │  - Key Vault        │
            │  - SQL Database     │
            │  - Blob Storage     │
            │  - Monitor          │
            └─────────────────────┘
```

### Detailed Component Design

#### 1. API Gateway
- **Technology**: Azure API Management / Kong / Nginx
- **Responsibilities**:
  - Request routing
  - Rate limiting
  - Initial authentication
  - SSL/TLS termination
  - Request/response logging

#### 2. Identity and Access Management
- **Technology**: Azure AD / Auth0 / Keycloak
- **Features**:
  - OAuth 2.0 / OpenID Connect
  - Multi-Factor Authentication (MFA)
  - JWT token generation and validation
  - Session management
  - User directory integration

#### 3. Service Mesh
- **Technology**: Istio / Linkerd
- **Capabilities**:
  - Mutual TLS (mTLS) between services
  - Service-to-service authentication
  - Traffic encryption
  - Circuit breaking
  - Observability

#### 4. Microservices

**Auth Service**
- User authentication
- Token generation/validation
- MFA verification
- Session management

**User Service**
- User profile management
- Role and permission management
- User activity logging

**Security Service**
- Threat detection
- Anomaly detection using Azure Security Dataset
- Risk scoring
- Security event processing

**Data Service**
- Secure data access
- Data encryption/decryption
- Access audit logging

#### 5. Data Layer
- **Azure SQL Database**: User data, permissions
- **Azure Cosmos DB**: Session data, activity logs
- **Azure Blob Storage**: Security datasets, logs
- **Azure Key Vault**: Secrets, keys, certificates

#### 6. Monitoring & Logging
- **Azure Monitor**: Infrastructure monitoring
- **Application Insights**: Application performance
- **Azure Log Analytics**: Centralized logging
- **Azure Sentinel**: SIEM capabilities

## Data Flow Diagrams

### Authentication Flow

```
1. User → API Gateway: Login request (username/password)
2. API Gateway → Auth Service: Validate credentials
3. Auth Service → Azure AD: Verify identity
4. Azure AD → Auth Service: Identity confirmed
5. Auth Service → MFA Service: Send MFA challenge
6. MFA Service → User: MFA code (SMS/Email/App)
7. User → API Gateway: MFA code
8. API Gateway → Auth Service: Verify MFA
9. Auth Service → User: JWT token (short-lived)
10. Auth Service → Logging: Log authentication event
```

### Service-to-Service Communication Flow

```
1. Service A → Service Mesh: Request to Service B
2. Service Mesh: Validate Service A's certificate (mTLS)
3. Service Mesh → Policy Engine: Check authorization
4. Policy Engine: Evaluate least-privilege rules
5. Policy Engine → Service Mesh: Allow/Deny decision
6. Service Mesh → Service B: Forward request (if allowed)
7. Service B: Process request
8. Service B → Service Mesh: Response
9. Service Mesh → Service A: Encrypted response
10. Service Mesh → Monitoring: Log transaction
```

### Data Access Flow

```
1. User → API Gateway: Request data (with JWT)
2. API Gateway: Validate JWT
3. API Gateway → Authorization Service: Check permissions
4. Authorization Service → Azure AD: Verify user claims
5. Authorization Service: Evaluate data access policy
6. Authorization Service → Data Service: Access granted
7. Data Service → Azure Key Vault: Get encryption key
8. Data Service → Azure SQL/Storage: Retrieve data
9. Data Service: Decrypt data
10. Data Service → User: Return data
11. Data Service → Audit Log: Record access event
```

## Security Layers

### Layer 1: Network Security
- Virtual Network (VNet) segmentation
- Network Security Groups (NSGs)
- Azure Firewall
- DDoS protection
- Private endpoints

### Layer 2: Identity Security
- Multi-Factor Authentication (MFA)
- Conditional Access policies
- Privileged Identity Management (PIM)
- Identity Protection

### Layer 3: Application Security
- Input validation
- Output encoding
- OWASP Top 10 protection
- API security (rate limiting, throttling)
- SQL injection prevention

### Layer 4: Data Security
- Encryption at rest (AES-256)
- Encryption in transit (TLS 1.3)
- Azure Key Vault for key management
- Data classification and labeling
- Data loss prevention (DLP)

### Layer 5: Infrastructure Security
- Container security scanning
- Kubernetes security policies
- Pod security policies
- RBAC in Kubernetes
- Secrets management

### Layer 6: Monitoring & Response
- Real-time threat detection
- Security Information and Event Management (SIEM)
- Automated incident response
- Continuous compliance monitoring

## Technology Stack

### Frontend
- React/Vue.js with TypeScript
- Authentication libraries (MSAL.js for Azure AD)
- Secure session management

### Backend Services
- **Language**: Node.js/Python/Go
- **Framework**: Express/FastAPI/Gin
- **Authentication**: JWT, OAuth 2.0
- **Authorization**: RBAC/ABAC

### Infrastructure
- **Container**: Docker
- **Orchestration**: Kubernetes (AKS)
- **Service Mesh**: Istio
- **IaC**: Terraform/Bicep
- **CI/CD**: Azure DevOps/GitHub Actions

### Security Tools
- Azure Security Center
- Azure Sentinel
- Azure Key Vault
- Azure AD
- OWASP ZAP (security testing)

## Architecture Diagrams to Create

1. **High-Level Architecture Diagram**
2. **Authentication Flow Diagram**
3. **Service Communication Diagram**
4. **Data Flow Diagram**
5. **Security Layers Diagram**
6. **Deployment Architecture**
7. **Network Topology**

## Presentation Preparation

### For TA/Instructor Feedback

**Slide 1: Project Overview**
- Zero-Trust Cloud Lab objectives
- Key principles

**Slide 2: Architecture Overview**
- High-level component diagram
- Technology choices

**Slide 3: Authentication & Authorization**
- How zero-trust is enforced
- Identity management approach

**Slide 4: Service Communication**
- Micro-segmentation strategy
- mTLS implementation

**Slide 5: Data Security**
- Encryption strategy
- Key management

**Slide 6: Monitoring & Logging**
- Observability approach
- Incident response

**Slide 7: Implementation Plan**
- Weeks 7-15 roadmap
- Milestones

**Slide 8: Challenges & Questions**
- Technical challenges anticipated
- Questions for feedback

## Key Design Decisions to Document

1. **Why Istio over Linkerd?** (or vice versa)
2. **Database choice for different data types**
3. **JWT vs session-based authentication**
4. **Single-cloud vs multi-cloud approach**
5. **Synchronous vs asynchronous communication**
6. **Monorepo vs multi-repo**

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Azure credit limits | High | Monitor usage, optimize resources |
| Complex service mesh setup | Medium | Use managed Istio, extensive testing |
| Performance overhead of encryption | Medium | Use hardware acceleration, caching |
| Token management complexity | Medium | Use established libraries, short TTLs |

## Next Steps

- Week 7: Begin implementing authentication service
- Set up basic API gateway
- Create proof-of-concept for service-to-service auth

## Resources

- [Azure Zero Trust Architecture](https://docs.microsoft.com/security/zero-trust/)
- [Istio Documentation](https://istio.io/docs/)
- [NIST Zero Trust Architecture](https://www.nist.gov/publications/zero-trust-architecture)

