# Руководство по мониторингу

## Обзор системы мониторинга

DevOps Resume Platform использует комплексную систему мониторинга для обеспечения высокой доступности и производительности.

## Архитектура мониторинга

```mermaid
graph TB
    subgraph "Application Layer"
        A[Resume App]
        B[Health Endpoints]
        C[Metrics Endpoints]
    end
    
    subgraph "Monitoring Stack"
        D[Prometheus]
        E[Grafana]
        F[AlertManager]
    end
    
    subgraph "Infrastructure Layer"
        G[Node Exporter]
        H[cAdvisor]
        I[Kube-state-metrics]
    end
    
    subgraph "External Services"
        J[CloudWatch]
        K[Slack Notifications]
        L[Email Alerts]
    end
    
    A --> C
    C --> D
    G --> D
    H --> D
    I --> D
    D --> E
    D --> F
    F --> K
    F --> L
    D --> J
```

## Компоненты мониторинга

### 1. Prometheus
- **Назначение**: Сбор и хранение метрик
- **Конфигурация**: `/monitoring/prometheus/prometheus.yml`
- **Доступ**: http://localhost:9090

### 2. Grafana
- **Назначение**: Визуализация метрик
- **Конфигурация**: `/monitoring/grafana/`
- **Доступ**: http://localhost:3000

### 3. AlertManager
- **Назначение**: Управление алертами
- **Конфигурация**: `/monitoring/alertmanager/`
- **Уведомления**: Slack, Email

## Метрики приложения

### 1. HTTP метрики
```prometheus
# Количество HTTP запросов
http_requests_total{method, status, endpoint}

# Время отклика HTTP запросов
http_request_duration_seconds{method, endpoint}

# Активные соединения
http_connections_active

# Размер ответов
http_response_size_bytes
```

### 2. Бизнес метрики
```prometheus
# Время работы приложения
resume_uptime_seconds

# Количество развертываний
resume_deployments_total

# Время отклика
resume_response_time_seconds

# Доступность
resume_availability_ratio
```

### 3. Системные метрики
```prometheus
# Использование CPU
node_cpu_seconds_total{mode}

# Использование памяти
node_memory_MemTotal_bytes
node_memory_MemAvailable_bytes

# Использование диска
node_filesystem_size_bytes
node_filesystem_avail_bytes

# Сетевая активность
node_network_receive_bytes_total
node_network_transmit_bytes_total
```

## Дашборды Grafana

### 1. Application Overview
- **Назначение**: Общий обзор приложения
- **Метрики**:
  - Request rate
  - Response time
  - Error rate
  - Active users

### 2. Infrastructure
- **Назначение**: Мониторинг инфраструктуры
- **Метрики**:
  - CPU usage
  - Memory usage
  - Disk usage
  - Network traffic

### 3. Kubernetes
- **Назначение**: Мониторинг K8s кластера
- **Метрики**:
  - Pod status
  - Node status
  - Resource usage
  - Deployment status

### 4. Security
- **Назначение**: Мониторинг безопасности
- **Метрики**:
  - Failed login attempts
  - Suspicious requests
  - Certificate expiry
  - Security scan results

## Алерты

### 1. Critical Alerts
```yaml
# Высокий уровень ошибок
- alert: HighErrorRate
  expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "High error rate detected"
    description: "Error rate is {{ $value }} errors per second"

# Сервис недоступен
- alert: ServiceDown
  expr: up == 0
  for: 1m
  labels:
    severity: critical
  annotations:
    summary: "Service is down"
    description: "{{ $labels.instance }} is down"
```

### 2. Warning Alerts
```yaml
# Высокое время отклика
- alert: HighResponseTime
  expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High response time"
    description: "95th percentile response time is {{ $value }} seconds"

# Высокое использование CPU
- alert: HighCPUUsage
  expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High CPU usage"
    description: "CPU usage is {{ $value }}%"
```

### 3. Info Alerts
```yaml
# Успешное развертывание
- alert: DeploymentSuccess
  expr: increase(resume_deployments_total[5m]) > 0
  for: 0m
  labels:
    severity: info
  annotations:
    summary: "Deployment successful"
    description: "New deployment detected"
```

## Настройка уведомлений

### 1. Slack уведомления
```yaml
# alertmanager.yml
route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'slack-notifications'

receivers:
- name: 'slack-notifications'
  slack_configs:
  - api_url: 'YOUR_SLACK_WEBHOOK_URL'
    channel: '#alerts'
    title: 'DevOps Resume Platform Alert'
    text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
```

### 2. Email уведомления
```yaml
receivers:
- name: 'email-notifications'
  email_configs:
  - to: 'admin@yourdomain.com'
    from: 'alerts@yourdomain.com'
    smarthost: 'smtp.gmail.com:587'
    auth_username: 'alerts@yourdomain.com'
    auth_password: 'YOUR_EMAIL_PASSWORD'
    subject: 'DevOps Resume Platform Alert'
    body: |
      {{ range .Alerts }}
      Alert: {{ .Annotations.summary }}
      Description: {{ .Annotations.description }}
      {{ end }}
```

## Health Checks

### 1. Application Health
```javascript
// /health endpoint
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00Z",
  "uptime": 99.9,
  "response_time": 50,
  "deployments_today": 0,
  "version": "1.0.0"
}
```

### 2. Infrastructure Health
```bash
# Kubernetes health
kubectl get nodes
kubectl get pods -n devops-resume
kubectl get services -n devops-resume

# AWS health
aws eks describe-cluster --name devops-resume-production
aws elbv2 describe-load-balancers
```

## Логирование

### 1. Структурированные логи
```json
{
  "timestamp": "2024-01-01T00:00:00Z",
  "level": "info",
  "message": "Request processed",
  "method": "GET",
  "path": "/",
  "status": 200,
  "response_time": 50,
  "user_agent": "Mozilla/5.0...",
  "ip": "192.168.1.1"
}
```

### 2. Логирование в Kubernetes
```yaml
# Fluentd configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/*.log
      pos_file /var/log/fluentd-containers.log.pos
      tag kubernetes.*
      format json
    </source>
    
    <match kubernetes.**>
      @type cloudwatch_logs
      log_group_name devops-resume-logs
      log_stream_name ${tag}
      region us-east-1
    </match>
```

## Производительность

### 1. SLA метрики
- **Uptime**: 99.9%
- **Response Time**: < 200ms (95th percentile)
- **Error Rate**: < 0.1%
- **Availability**: 24/7

### 2. Производительность мониторинга
```prometheus
# Core Web Vitals
web_vitals_lcp_seconds
web_vitals_fid_seconds
web_vitals_cls_ratio

# Performance budgets
performance_budget_css_size_bytes
performance_budget_js_size_bytes
performance_budget_image_size_bytes
```

## Troubleshooting

### 1. Проблемы с метриками
```bash
# Проверка Prometheus
kubectl logs -n monitoring deployment/prometheus

# Проверка targets
curl http://localhost:9090/api/v1/targets

# Проверка метрик
curl http://localhost:9090/api/v1/query?query=up
```

### 2. Проблемы с дашбордами
```bash
# Проверка Grafana
kubectl logs -n monitoring deployment/grafana

# Проверка datasources
curl http://admin:admin@localhost:3000/api/datasources
```

### 3. Проблемы с алертами
```bash
# Проверка AlertManager
kubectl logs -n monitoring deployment/alertmanager

# Проверка правил
curl http://localhost:9090/api/v1/rules
```

## Оптимизация

### 1. Retention политики
```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

# Retention для разных типов метрик
rule_files:
  - "retention_rules.yml"
```

### 2. Sampling
```yaml
# Трейсинг с sampling
tracing:
  jaeger:
    samplingType: const
    samplingParam: 0.1  # 10% sampling
```

### 3. Aggregation
```prometheus
# Предварительная агрегация
- record: http_requests:rate5m
  expr: rate(http_requests_total[5m])

- record: http_requests:rate1h
  expr: rate(http_requests_total[1h])
```

## Интеграции

### 1. External monitoring
- **Uptime Robot**: Внешний мониторинг доступности
- **Pingdom**: Мониторинг производительности
- **New Relic**: APM мониторинг

### 2. Incident management
- **PagerDuty**: Управление инцидентами
- **Opsgenie**: Алертинг и эскалация
- **Jira**: Отслеживание проблем

### 3. ChatOps
- **Slack**: Уведомления и команды
- **Microsoft Teams**: Интеграция с Teams
- **Discord**: Сообщество и алерты

