# DevOps Resume Platform

🚀 Полностью автоматизированная платформа для размещения резюме с CI/CD, Infrastructure as Code, мониторингом и GitOps.

## 📋 Описание проекта

Этот проект демонстрирует комплексные DevOps-навыки через создание персонального сайта-резюме, который:
- Автоматически деплоится через CI/CD
- Развертывается через Infrastructure as Code
- Мониторится и логируется
- Масштабируется в Kubernetes
- Обновляется через GitOps

## 🌐 Демо

**Живой сайт:** [https://romadanovsky.ru](https://romadanovsky.ru)

## 🏗️ Архитектура

```mermaid
graph TB
    A[GitHub Repository] --> B[GitHub Actions CI/CD]
    B --> C[Docker Hub Registry]
    B --> D[VPS Server]
    D --> E[Docker Containers]
    E --> F[Nginx Reverse Proxy]
    E --> G[Resume Application]
    E --> H[Prometheus Monitoring]
    E --> I[Grafana Dashboards]
    E --> J[Loki Logging]
    F --> K[SSL/TLS Termination]
    K --> L[User Access]
    H --> I
    J --> I
```

## 🛠️ Технологический стек

### Frontend
- **HTML5, CSS3, JavaScript** - современный веб-интерфейс
- **Responsive Design** - адаптивный дизайн
- **Progressive Web App** - PWA функциональность

### Backend & Infrastructure
- **Docker** - контейнеризация приложений
- **Docker Compose** - оркестрация контейнеров на VPS
- **Nginx** - reverse proxy и SSL termination
- **Terraform** - Infrastructure as Code (опционально)

### DevOps & Monitoring
- **GitHub Actions** - CI/CD автоматизация
- **Prometheus** - сбор метрик
- **Grafana** - визуализация данных
- **Loki** - централизованное логирование
- **Let's Encrypt** - SSL сертификаты

### Security
- **SSL/TLS** - HTTPS шифрование
- **Security Headers** - защита от XSS, CSRF
- **Let's Encrypt** - автоматические SSL сертификаты
- **Firewall** - сетевая безопасность

## 🚀 Возможности

### CI/CD Pipeline
- Автоматическая сборка Docker образов
- Сканирование безопасности контейнеров
- Развертывание на VPS сервер
- Health checks и мониторинг

### Infrastructure as Code
- Docker Compose для оркестрации
- Terraform для управления инфраструктурой (опционально)
- Kubernetes манифесты (для будущего масштабирования)
- Управление секретами через переменные окружения

### Мониторинг и логирование
- Prometheus для сбора метрик приложения
- Grafana дашборды для визуализации
- Loki для централизованного логирования
- Node Exporter для системных метрик

### Безопасность
- SSL/TLS шифрование с Let's Encrypt
- Security headers (HSTS, CSP, X-Frame-Options)
- Firewall настройки
- Docker security best practices

## 📁 Структура проекта

```
devops-resume-platform/
├── app/                    # Веб-приложение
│   ├── src/               # Исходный код
│   ├── Dockerfile         # Docker образ
│   └── nginx.conf         # Nginx конфигурация
├── k8s/                   # Kubernetes манифесты
├── terraform/             # Terraform конфигурации
├── monitoring/            # Мониторинг (Prometheus, Grafana)
├── .github/workflows/     # GitHub Actions
├── docs/                  # Документация
└── security/              # Политики безопасности
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow
1. **Code Push** → Trigger
2. **Build** → Docker image
3. **Test** → Unit/Integration tests
4. **Security Scan** → Vulnerability check
5. **Deploy** → Production server
6. **Health Check** → Verify deployment
7. **Notify** → Success/Failure alerts

## 🔒 Безопасность

### Network Security
- Network Policies
- Pod Security Standards
- RBAC (Role-Based Access Control)

### Application Security
- HTTPS/TLS
- Content Security Policy
- Input Validation
- Secrets Management

## 📊 Мониторинг

### Health Checks
- **Endpoint**: `/health`
- **Response**: `{"status":"UP"}`
- **Frequency**: 30 секунд

### Metrics
- **Endpoint**: `/metrics`
- **Format**: Prometheus format
- **Uptime**: секунды работы

### Dashboards
- **Grafana**: https://grafana.romadanovsky.ru (Production dashboards)
- **Prometheus**: https://prometheus.romadanovsky.ru (Metrics collection)
- **Loki**: Centralized logging system

## 🚀 Быстрый старт

### Production Deployment (VPS)

```bash
# Клонирование репозитория на сервер
git clone https://github.com/twinleq/devops-resume-platform.git
cd devops-resume-platform

# Запуск production stack
docker-compose -f docker-compose.prod.yml up -d

# Проверка статуса
docker-compose -f docker-compose.prod.yml ps

# Проверка логов
docker-compose -f docker-compose.prod.yml logs -f
```

### Локальная разработка

```bash
# Клонирование репозитория
git clone https://github.com/twinleq/devops-resume-platform.git
cd devops-resume-platform

# Запуск локального сервера (PowerShell)
cd app/src
.\simple-server.ps1 -Port 8086
```

### Docker (Development)

```bash
# Запуск с Docker Compose
docker-compose up -d

# Проверка статуса
docker-compose ps
```

### Kubernetes (Optional)

```bash
# Развертывание в Kubernetes
kubectl apply -f k8s/

# Проверка статуса
kubectl get pods -n devops-resume
```

### Infrastructure as Code

```bash
# Инициализация Terraform
terraform init

# Планирование развертывания
terraform plan

# Развертывание инфраструктуры
terraform apply
```

## 📚 Документация

- [Архитектура](docs/architecture.md)
- [Развертывание](docs/deployment.md)
- [Мониторинг](docs/monitoring.md)

## 🎯 Связанные проекты

- [Linux Server Automation](https://github.com/twinleq/linux-server-automation) - Автоматизация Linux серверов
- [Docker Containerization](https://github.com/twinleq/docker-containerization) - Примеры контейнеризации

## 📄 Лицензия

MIT License - см. файл [LICENSE](LICENSE)

## 👨‍💻 Автор

**Ромадановский Виталий Денисович**
- GitHub: [@twinleq](https://github.com/twinleq)
- Email: twinleq@bk.ru
- Сайт: [https://romadanovsky.ru](https://romadanovsky.ru)