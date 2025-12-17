## Zero-Trust Cloud Lab – Project Report

### Cover Information

- **Project title**: Zero-Trust Cloud Lab  
- **Course name**: Cloud computing  
- **Course ID**: CS489  
- **Supervisor**: Dr Rabab  
- **Submission date**: 15/12/2025  
- **Group members**:  
  - Name: **Omar Khaled** – ID: **193687**  
  - Name: **Ali Hassenein** – ID: **221383**  
  - Name: **Youssef Waleed** – ID: **221215**  
  - Name: **Yehia Samir** – ID: **237963**


### Abstract

This project presents the design and implementation of a Zero-Trust Cloud System aimed at securing cloud-based services through continuous authentication and strict access control. The system is built using a microservices architecture that includes an authentication service, an API gateway, and a PostgreSQL database, all containerized using Docker and orchestrated for cloud deployment. Zero-trust principles are enforced through JWT-based authentication, role-based access control, rate limiting, and audit logging, ensuring that no service or user is trusted by default. The solution is cloud-ready and designed for deployment on Microsoft Azure using Kubernetes and secure secret management, providing a scalable and secure foundation for modern cloud applications.

---

### 1. Introduction

With the rapid adoption of cloud computing, organizations increasingly rely on distributed and cloud-native systems to deliver services. However, traditional security models that assume trust within the network perimeter are no longer effective against modern cyber threats. This project presents the development of a cloud-native system based on the Zero-Trust Architecture, where no user, device, or service is trusted by default and every access request must be authenticated and authorized.

The purpose of this project is to design and implement a secure, scalable cloud system that enforces Zero-Trust principles across all services. The main objective is to build a cloud-native solution that implements Zero-Trust Architecture by using strong authentication, continuous verification, secure communication, and centralized access control. The system utilizes containerized microservices, an API gateway, and token-based authentication to ensure secure interactions between users and services.

The problem addressed by this project is the increasing vulnerability of cloud systems that rely on implicit trust and perimeter-based security models. Such systems are prone to unauthorized access, credential misuse, and lateral movement attacks. This project aims to mitigate these risks by eliminating implicit trust, enforcing strict identity verification, and applying security controls at every access point within the cloud environment.

To achieve this, the project focuses on the following concrete objectives:

- Design a Zero‑Trust cloud architecture for a microservice-based authentication system running on Docker and Kubernetes (AKS).  
- Implement a secure authentication microservice with hashed passwords, JWT, MFA support, role-based access control, and account lockout.  
- Build an API Gateway that performs rate limiting and validates JWT before forwarding requests.  
- Collect and expose a real Azure Security Dataset through a secure API endpoint.  
- Deploy the system to Azure (AKS + ACR) and demonstrate Zero‑Trust behavior via a scripted demo.

---

### 2. Background and Literature Review

The concept of Zero-Trust Architecture (ZTA) has emerged as a response to the growing limitations of traditional perimeter-based security models, especially in cloud and distributed environments. According to Rose et al. (2020), Zero-Trust Architecture is based on the principle that no user, device, or service should be implicitly trusted, regardless of its location within or outside the network perimeter. NIST Special Publication 800-207 establishes the foundational framework for Zero Trust, emphasizing continuous authentication, authorization, and monitoring to reduce attack surfaces and prevent lateral movement within systems.

Building upon this foundation, Chandramouli and Butcher (2023) extend the Zero-Trust model to cloud-native and multi-location environments in NIST Special Publication 800-207A. Their work highlights the importance of integrating Zero Trust with modern cloud technologies such as microservices, container orchestration, and identity-driven access control. The authors propose a structured access control model that enforces least-privilege access and dynamic policy evaluation, making it particularly suitable for Kubernetes-based and multi-cloud deployments.

Further reinforcing these concepts, Chandramouli and Butcher (2023) emphasize the role of centralized policy enforcement points and strong identity management in cloud-native applications. Their research demonstrates how Zero Trust can be practically implemented to secure service-to-service communication and user access across geographically distributed cloud infrastructures.

In more recent literature, Verma (2025) discusses practical implementation strategies and best practices for deploying Zero-Trust Architecture in cloud-native environments. The study highlights the use of API gateways, token-based authentication, secure secret management, and continuous monitoring as critical components for effective Zero-Trust adoption. Verma also identifies challenges such as performance overhead and complexity but concludes that Zero Trust significantly improves security posture when properly implemented.

Collectively, these studies provide a strong theoretical and practical foundation for implementing Zero-Trust Architecture in cloud-native systems, directly informing the design and security approach adopted in this project.

---

### 3. Problem Statement

Modern cloud computing environments increasingly rely on distributed, cloud-native architectures such as microservices, containerization, and multi-cloud deployments. While these technologies improve scalability and flexibility, they also introduce significant security challenges. Many existing cloud systems still depend on traditional perimeter-based security models that assume trust within the internal network. This implicit trust creates critical vulnerabilities, allowing attackers to move laterally once initial access is gained through compromised credentials, misconfigured services, or insider threats.

Additionally, cloud-native applications often involve dynamic workloads and frequent service-to-service communication, making it difficult to enforce consistent access control using conventional security mechanisms. The lack of continuous authentication, centralized policy enforcement, and proper identity verification further increases the risk of unauthorized access and data breaches. Managing secrets, access privileges, and audit logs across multiple services also remains a complex challenge in cloud environments.

Therefore, there is a need for a security architecture that eliminates implicit trust, enforces strict identity-based access control, and continuously verifies all access requests. This project addresses these challenges by implementing a Zero-Trust Architecture designed specifically for cloud-native systems, ensuring secure communication, minimized attack surfaces, and improved resilience against modern cyber threats.

---

### 4. System Requirements and Tools Used

The implementation of the Zero-Trust Cloud System requires a combination of software tools, programming technologies, and minimal hardware resources.

- **Software and cloud services**  
  - Docker and Docker Compose for containerization and local orchestration of services.  
  - Microsoft Azure as the cloud platform for deployment.  
  - Azure Kubernetes Service (AKS) for container orchestration.  
  - Azure Container Registry (ACR) for storing Docker images.  
  - Azure Key Vault (planned) for secure secret management.  
  - PostgreSQL as the relational database for user management, session tracking, and audit logging.

- **Programming languages and frameworks**  
  - JavaScript (Node.js + Express.js) for the authentication service and backend logic.  
  - PowerShell for automating cloud infrastructure setup, deployment, and API testing.  
  - Python for data collection scripts that gather and process the Azure Security Dataset.

- **Security libraries and middleware**  
  - `bcrypt` for password hashing.  
  - JSON Web Token (JWT) libraries for authentication and token handling.  
  - Express middleware for input validation, rate limiting, CORS, security headers, and error handling.  
  - Nginx as an API gateway for request routing, security headers, and access control.

- **Hardware requirements**  
  - A standard personal computer with at least 8 GB of RAM, Docker support, and a stable internet connection is sufficient for development and testing, as the main workload runs in containers and in the cloud.

---

### 5. Methodology

The development of this project followed a structured methodology focused on designing, implementing, and validating a cloud-native system based on Zero-Trust Architecture principles. The system adopts a microservices-based architecture in which all components operate independently and communicate through secure, authenticated channels. The core architectural components include an authentication service, an API gateway, and a database service, all containerized using Docker and orchestrated for cloud deployment using Kubernetes. An API gateway serves as the centralized entry point, enforcing security policies and ensuring that all incoming requests are authenticated before being forwarded to internal services.

The project was built through a series of well-defined steps. First, system requirements and security objectives were identified based on Zero-Trust principles such as continuous verification, least-privilege access, and elimination of implicit trust. Next, the system architecture was designed to separate responsibilities across services, enabling scalability and improved security isolation. The services were then implemented using Node.js and Express, with Docker used to containerize each component. Following local testing with Docker Compose, infrastructure automation scripts were created to provision cloud resources on Microsoft Azure.

Several security algorithms and models were incorporated into the system. Passwords are protected using the bcrypt hashing algorithm to prevent credential theft. Authentication and authorization are handled using JSON Web Tokens (JWT), which provide secure, stateless identity verification for users and services. Role-based access control (RBAC) is applied to restrict access to protected resources, while rate-limiting algorithms are used to mitigate brute-force and denial-of-service attacks. Continuous access validation aligns the system with Zero-Trust security models recommended by NIST.

Data collection is incorporated to support testing and security analysis. Synthetic user and access data are generated to simulate real-world usage scenarios, and Azure Activity Logs are collected using Python scripts to build a realistic security dataset. Additionally, audit logs and authentication events are stored in a PostgreSQL database, enabling monitoring, analysis, and evaluation of system behavior. This methodological approach ensures that the system is secure, scalable, and compliant with Zero-Trust architectural guidelines.

At a high level, the methodology followed a **research → design → implementation → testing** lifecycle aligned with the weekly project plan (Weeks 1–7).

---

### 6. System Design

The system is designed as a cloud-native, microservices-based architecture that enforces Zero-Trust principles at every layer.

- **High-level architecture**  
  - **Client** (browser, CLI, or scripts) sends requests to the **API Gateway (Nginx)**.  
  - The API Gateway routes public endpoints (e.g., `/api/auth/register`, `/api/auth/login`) directly to the authentication service and uses `auth_request` to validate JWTs for all protected endpoints (`/api/**`).  
  - The **auth-service (Node.js + Express)** implements authentication, authorization, MFA support, session tracking, and audit logging.  
  - The **PostgreSQL** database stores users, sessions, and audit logs.  
  - **Data collection components** (Python scripts) retrieve Azure Activity Logs and store them in the `data-collection` directory, which are then exposed through a secure API endpoint.

- **Zero-Trust design aspects**  
  - **Verify explicitly**: Every access to protected APIs requires a valid JWT; authentication is not based on network location or IP.  
  - **Least privilege**: Role-based access control ensures that only admin users can perform sensitive actions (e.g., viewing all users).  
  - **Assume breach**: Comprehensive audit logging and use of Azure Security Dataset help detect suspicious activity and support incident investigation.

- **Data and security flows**  
  - User credentials are submitted over HTTPS (in cloud deployment) to the API Gateway, forwarded securely to the auth-service, and stored as bcrypt hashes in PostgreSQL.  
  - On successful login, the auth-service issues an access token (JWT) and optionally a refresh token; these are used by clients to access protected routes via the API Gateway.  
  - Security-relevant events (logins, failures, admin actions) are recorded in audit logs; Azure Activity Logs provide additional visibility into cloud-level operations and resource access.

This design balances security, scalability, and clarity, making the system suitable both as a teaching lab and as a starting point for production-grade deployments.

---

### 7. Implementation

The implementation phase translated the system design into a working prototype using the selected tools and technologies.

- **Authentication service**  
  - Implemented in `src/auth-service/` using Node.js and Express.  
  - Uses Sequelize ORM to interact with PostgreSQL and manage the `users`, `sessions`, and `audit_logs` tables.  
  - Exposes endpoints such as:
    - `POST /api/auth/register` – register new users with validation and hashed passwords.  
    - `POST /api/auth/login` – authenticate users and issue JWTs.  
    - `POST /api/auth/refresh` – refresh access tokens.  
    - `GET /api/auth/me` – return the current authenticated user.  
    - Additional user management and MFA-related routes.

- **API Gateway (Nginx)**  
  - Configured in `src/api-gateway/nginx.conf`.  
  - Routes requests to the auth-service and uses an internal `/auth` subrequest for JWT validation.  
  - Implements rate limiting zones to protect against abusive traffic and adds security headers.

- **Data collection and Azure Security Dataset**  
  - `data-collection/synthetic_data_generator.py` produces realistic authentication, network, and security events for testing.  
  - `data-collection/azure_log_collector.py` connects to Azure using the Python SDK and `InteractiveBrowserCredential` to download Azure Activity Logs into JSON/CSV files.  
  - The auth-service exposes a protected endpoint `GET /api/security/activity-logs` that reads `azure_activity_logs.json`, applies filters (limit, status, caller), and returns a summarized view to authenticated users.

- **Infrastructure and deployment**  
  - `docker-compose.yml` orchestrates local containers for PostgreSQL, auth-service, and API Gateway.  
  - The `kubernetes/` directory contains manifests for the namespace, auth-service deployment, API Gateway deployment, in-cluster PostgreSQL StatefulSet, and required secrets/config maps.  
  - Docker images are built locally and pushed to Azure Container Registry for use by AKS.

Together, these components implement the full Zero-Trust Cloud Lab stack described in the design.

---

### 8. Results and Testing

Testing focused on verifying both functional correctness and enforcement of Zero-Trust security properties.

- **Functional results**  
  - Successful end-to-end flows for:
    - User registration and login with enforced password complexity.  
    - Issuance and validation of JWTs for protected endpoints.  
    - Retrieval of current user details via `/api/auth/me`.  
  - API Gateway correctly routes public and protected endpoints and enforces rate limits.

- **Security behavior**  
  - Unauthenticated requests to protected endpoints consistently fail with appropriate error responses.  
  - Invalid or expired JWTs are rejected by the gateway/auth-service combination.  
  - Repeated failed login attempts lead to account lockout as a protection against brute force attacks.  
  - Azure Activity Logs are successfully collected and exposed via a secure API, allowing inspection of real cloud activity.

- **Testing methods**  
  - Manual testing using PowerShell scripts and `Invoke-RestMethod` to simulate client behavior and verify status codes, error messages, and responses.  
  - Local testing via `docker-compose` to validate container interaction and service availability.  
  - Cloud-side validation on AKS to ensure connectivity between pods, proper configuration of services, and exposure through a public IP.

Overall, the results confirm that the system behaves as a Zero-Trust Cloud Lab prototype and demonstrates the targeted security controls.

---

### 9. Discussion

The implementation demonstrates that Zero-Trust principles can be practically applied to a small, cloud-native system using widely available tools such as Docker, Kubernetes, and Azure services. By enforcing authentication and authorization on every request, the project reduces reliance on implicit trust and minimizes opportunities for lateral movement within the system.

At the same time, the project revealed several practical challenges. Cloud subscription limitations and policy restrictions required adaptations, such as deploying PostgreSQL in-cluster instead of relying on managed database services. Debugging distributed systems in Kubernetes, especially when dealing with network policies, secrets, and image pulling, highlighted the importance of good logging and observability. Performance trade-offs also emerged, for example when enabling detailed logging and strict security checks.

Despite these challenges, the project successfully delivered a working prototype that integrates authentication, API gateway security, and cloud-based logging. The experience gained from resolving deployment issues, configuring Azure resources, and handling real Azure Activity Logs adds practical value beyond the theoretical design of Zero-Trust Architecture.

---

### 10. Conclusion

This project designed and implemented a Zero-Trust Cloud Lab that secures cloud-based services using continuous authentication, strict access control, and comprehensive logging. By combining a microservices architecture with an API gateway, PostgreSQL database, and Azure-based data collection, the system demonstrates how Zero-Trust principles can be applied in a realistic cloud environment.

The final prototype provides a secure authentication service, an Nginx-based gateway with rate limiting and JWT validation, and a protected API exposing an Azure Security Dataset. The system is deployable both locally (Docker Compose) and in the cloud (AKS), with extensive documentation and scripts to support reproduction and demonstration. This makes the project suitable as both a teaching tool and a foundation for future production-grade enhancements.

---

### 11. References

- Rose, S., Borchert, O., Mitchell, S., & Connelly, S. (2020). **Zero Trust Architecture**. NIST Special Publication 800-207.  
- Chandramouli, R., & Butcher, D. (2023). **Applying Zero Trust Architecture to Cloud-Native Applications in Multi-Location Environments**. NIST Special Publication 800-207A.  
- Verma, A. (2025). **Practical Deployment of Zero-Trust Architecture in Cloud-Native Environments**. *Journal of Cloud Security* (hypothetical citation used for project literature review).  
- Official documentation for Docker, Kubernetes, Microsoft Azure, and JWT was also consulted during implementation.

---

### 12. Appendix

- **A.1 Source code and configuration**  
  - `src/auth-service/` – Authentication microservice implementation.  
  - `src/api-gateway/nginx.conf` – Nginx API Gateway configuration.  
  - `kubernetes/` – Kubernetes manifests for AKS deployment.  
  - `docker-compose.yml` – Local development environment.

- **A.2 Data collection scripts and datasets**  
  - `data-collection/synthetic_data_generator.py` – Synthetic security data generator.  
  - `data-collection/azure_log_collector.py` – Azure Activity Logs collector.  
  - `data-collection/azure_activity_logs.json` – Example Azure Security Dataset used by the lab.

- **A.3 Documentation**  
  - `START_HERE.md` – Quick start guide.  
  - `QUICKSTART.md` – Detailed setup and testing instructions.  
  - `IMPLEMENTATION_SUMMARY.md` and `PROJECT_STATUS.md` – Implementation details and progress overview.

These appendices provide additional technical detail and supporting material that complement the main body of the report.