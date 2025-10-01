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
    B --> C[Docker Registry]
    B --> D[Infrastructure]
    C --> E[Kubernetes Cluster]
    D --> E
    E --> F[Resume Application]
    E --> G[Prometheus Monitoring]
    E --> H[Grafana Dashboards]
    F --> I[User Access]
    G --> H
```

## 🛠️ Технологический стек

### Frontend
- **HTML5, CSS3, JavaScript** - современный веб-интерфейс
- **Responsive Design** - адаптивный дизайн
- **Progressive Web App** - PWA функциональность

### Backend & Infrastructure
- **Docker** - контейнеризация приложений
- **Kubernetes** - оркестрация контейнеров
- **Nginx** - reverse proxy и статика
- **Terraform** - Infrastructure as Code

### DevOps & Monitoring
- **GitHub Actions** - CI/CD автоматизация
- **Prometheus** - сбор метрик
- **Grafana** - визуализация данных
- **ELK Stack** - централизованное логирование

### Security
- **Network Policies** - сетевая безопасность
- **RBAC** - управление доступом
- **OPA Gatekeeper** - политики безопасности
- **Security Scanning** - сканирование уязвимостей

## 🚀 Возможности

### CI/CD Pipeline
- Автоматическая сборка и тестирование
- Сканирование безопасности
- Развертывание в несколько сред
- Rollback стратегии

### Infrastructure as Code
- Terraform для управления инфраструктурой
- Kubernetes манифесты
- Автоматическое масштабирование
- Управление секретами

### Мониторинг и логирование
- Prometheus для сбора метрик
- Grafana дашборды
- Централизованное логирование
- Алерты и уведомления

### Безопасность
- SSL/TLS шифрование
- Network Policies
- RBAC
- Security scanning

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
- **Grafana**: Production dashboards
- **Prometheus**: Metrics collection

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