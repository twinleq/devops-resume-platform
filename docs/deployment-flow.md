# Схема развертывания DevOps Resume Platform

## Поток развертывания

```mermaid
flowchart TD
    A[Разработчик] --> B[Git Push]
    B --> C[GitHub Repository]
    C --> D[GitHub Actions Trigger]
    D --> E[Build Stage]
    E --> F[Test Stage]
    F --> G[Security Scan]
    G --> H[Build Docker Image]
    H --> I[Push to Registry]
    I --> J[Deploy to Kubernetes]
    J --> K[Health Check]
    K --> L[Monitoring Setup]
    L --> M[Production Ready]
    
    subgraph "Local Development"
        N[PowerShell Server]
        O[Static Files]
        P[Local Icons]
    end
    
    subgraph "CI/CD Pipeline"
        E
        F
        G
        H
        I
    end
    
    subgraph "Production"
        J
        K
        L
        M
    end
    
    A --> N
    N --> O
    O --> P
```

## Локальное развертывание

```mermaid
graph LR
    A[Проект] --> B[app/src/]
    B --> C[simple-server.ps1]
    C --> D[PowerShell Server]
    D --> E[Port 8086]
    E --> F[Browser]
    
    B --> G[Static Files]
    G --> H[HTML/CSS/JS]
    G --> I[SVG Icons]
    G --> J[Profile Photo]
    
    D --> K[Health Check]
    D --> L[Metrics]
```

## Docker развертывание

```mermaid
graph TB
    A[Docker Compose] --> B[Nginx Container]
    A --> C[App Container]
    A --> D[Monitoring Stack]
    
    B --> E[Reverse Proxy]
    B --> F[Static Files]
    
    C --> G[Application]
    C --> H[Health Endpoints]
    
    D --> I[Prometheus]
    D --> J[Grafana]
    D --> K[Loki]
```

## Kubernetes развертывание

```mermaid
graph TB
    subgraph "Kubernetes Cluster"
        A[Ingress Controller]
        B[Namespace: devops-resume]
        
        subgraph "Application Pods"
            C[Resume App]
            D[Sidecar: Monitoring]
        end
        
        subgraph "Monitoring Stack"
            E[Prometheus]
            F[Grafana]
            G[AlertManager]
        end
        
        subgraph "Storage"
            H[ConfigMap]
            I[Secret]
            J[PersistentVolume]
        end
    end
    
    A --> B
    B --> C
    B --> D
    B --> E
    B --> F
    B --> G
    C --> H
    C --> I
    F --> J
```

## Terraform инфраструктура

```mermaid
graph TB
    A[Terraform State] --> B[AWS Provider]
    B --> C[VPC]
    B --> D[EKS Cluster]
    B --> E[ECR Registry]
    B --> F[Route53]
    B --> G[ACM Certificate]
    
    C --> H[Public Subnets]
    C --> I[Private Subnets]
    
    D --> J[Node Groups]
    D --> K[Add-ons]
    
    E --> L[Docker Images]
    
    F --> M[DNS Records]
    G --> N[SSL/TLS]
```

## Мониторинг и алертинг

```mermaid
graph LR
    A[Application] --> B[Metrics]
    B --> C[Prometheus]
    C --> D[Grafana]
    C --> E[AlertManager]
    
    E --> F[Slack]
    E --> G[Email]
    E --> H[PagerDuty]
    
    D --> I[Dashboards]
    D --> J[Visualization]
    
    subgraph "Metrics Types"
        K[Application Metrics]
        L[Infrastructure Metrics]
        M[Business Metrics]
    end
    
    B --> K
    B --> L
    B --> M
```

## Безопасность

```mermaid
graph TB
    A[Network Policies] --> B[Pod-to-Pod Communication]
    C[RBAC] --> D[Service Accounts]
    C --> E[Roles]
    C --> F[RoleBindings]
    
    G[OPA Gatekeeper] --> H[Admission Controllers]
    H --> I[Policy Validation]
    
    J[Security Scanning] --> K[Container Images]
    J --> L[Code Analysis]
    J --> M[Dependency Check]
    
    N[Secrets Management] --> O[Kubernetes Secrets]
    N --> P[External Vault]
```

## Backup и Disaster Recovery

```mermaid
graph LR
    A[Git Repository] --> B[Code Backup]
    C[Kubernetes State] --> D[etcd Backup]
    E[Application Data] --> F[Persistent Volumes]
    
    G[Backup Strategy] --> H[Daily Backups]
    G --> I[Weekly Full Backup]
    G --> J[Monthly Archive]
    
    K[Disaster Recovery] --> L[Multi-Region]
    K --> M[Cross-Cloud]
    K --> N[RTO: 1 hour]
    K --> O[RPO: 15 minutes]
```
