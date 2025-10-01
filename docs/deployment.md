# Руководство по развертыванию

## Предварительные требования

### Локальная разработка
- Docker Desktop
- Docker Compose
- Node.js 18+
- Git

### Облачное развертывание
- AWS Account
- AWS CLI v2
- Terraform 1.6+
- kubectl
- Helm 3.0+

## Быстрый старт

### 1. Клонирование репозитория
```bash
git clone https://github.com/yourusername/devops-resume-platform.git
cd devops-resume-platform
```

### 2. Локальная разработка
```bash
# Запуск с Docker Compose
docker-compose up -d

# Проверка статуса
docker-compose ps

# Просмотр логов
docker-compose logs -f resume-app
```

### 3. Доступ к приложению
- **Приложение**: http://localhost:8080
- **Grafana**: http://localhost:3000 (admin/admin123)
- **Prometheus**: http://localhost:9090
- **Traefik Dashboard**: http://localhost:8081

## Облачное развертывание

### 1. Настройка AWS

#### Создание IAM пользователя
```bash
# Создание пользователя
aws iam create-user --user-name devops-resume-deployer

# Создание политики
cat > devops-resume-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*",
                "eks:*",
                "iam:*",
                "s3:*",
                "route53:*",
                "acm:*",
                "ecr:*",
                "cloudwatch:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF

aws iam create-policy --policy-name DevOpsResumePolicy --policy-document file://devops-resume-policy.json

# Привязка политики
aws iam attach-user-policy --user-name devops-resume-deployer --policy-arn arn:aws:iam::ACCOUNT_ID:policy/DevOpsResumePolicy

# Создание access key
aws iam create-access-key --user-name devops-resume-deployer
```

#### Настройка AWS CLI
```bash
aws configure
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region name: us-east-1
# Default output format: json
```

### 2. Развертывание инфраструктуры

#### Инициализация Terraform
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars

# Редактирование переменных
vim terraform.tfvars
```

#### Развертывание
```bash
# Инициализация
terraform init

# Планирование
terraform plan

# Применение
terraform apply
```

### 3. Настройка Kubernetes

#### Обновление kubeconfig
```bash
aws eks update-kubeconfig --region us-east-1 --name devops-resume-production
```

#### Проверка кластера
```bash
kubectl get nodes
kubectl get namespaces
```

### 4. Развертывание приложения

#### Создание namespace
```bash
kubectl apply -f k8s/namespace.yaml
```

#### Применение манифестов
```bash
kubectl apply -f k8s/
```

#### Проверка развертывания
```bash
kubectl get pods -n devops-resume
kubectl get services -n devops-resume
kubectl get ingress -n devops-resume
```

## CI/CD Pipeline

### 1. Настройка GitHub Secrets

В настройках репозитория добавьте следующие секреты:

```
AWS_ACCESS_KEY_ID: your-access-key
AWS_SECRET_ACCESS_KEY: your-secret-key
DOCKER_USERNAME: your-docker-username
DOCKER_PASSWORD: your-docker-password
SNYK_TOKEN: your-snyk-token
SLACK_WEBHOOK_URL: your-slack-webhook-url
```

### 2. Настройка ECR

```bash
# Создание репозитория (если не создан через Terraform)
aws ecr create-repository --repository-name devops-resume-platform

# Получение login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
```

### 3. Автоматическое развертывание

Pipeline автоматически запускается при:
- Push в main ветку
- Создании Pull Request
- Ручном запуске через GitHub Actions

## Мониторинг

### 1. Prometheus

#### Доступ к Prometheus
```bash
# Port forwarding
kubectl port-forward -n monitoring svc/prometheus 9090:9090

# Открыть в браузере
open http://localhost:9090
```

#### Настройка алертов
```bash
# Применение правил алертов
kubectl apply -f monitoring/prometheus/alert_rules.yml
```

### 2. Grafana

#### Доступ к Grafana
```bash
# Port forwarding
kubectl port-forward -n monitoring svc/grafana 3000:3000

# Открыть в браузере
open http://localhost:3000
# Логин: admin / admin123
```

#### Импорт дашбордов
```bash
# Дашборды автоматически импортируются через provisioning
kubectl apply -f monitoring/grafana/provisioning/
```

## Безопасность

### 1. SSL/TLS сертификаты

#### Настройка cert-manager
```bash
# Установка cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Создание ClusterIssuer
cat > letsencrypt-issuer.yaml << EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

kubectl apply -f letsencrypt-issuer.yaml
```

### 2. Сетевая безопасность

#### Применение Network Policies
```bash
kubectl apply -f k8s/networkpolicy.yaml
```

#### Проверка политик
```bash
kubectl get networkpolicies -n devops-resume
```

## Troubleshooting

### 1. Проблемы с развертыванием

#### Проверка статуса подов
```bash
kubectl describe pod -n devops-resume
kubectl logs -n devops-resume deployment/devops-resume-app
```

#### Проверка событий
```bash
kubectl get events -n devops-resume --sort-by='.lastTimestamp'
```

### 2. Проблемы с сетью

#### Проверка сервисов
```bash
kubectl get svc -n devops-resume
kubectl describe svc -n devops-resume devops-resume-app-service
```

#### Проверка ingress
```bash
kubectl get ingress -n devops-resume
kubectl describe ingress -n devops-resume devops-resume-app-ingress
```

### 3. Проблемы с мониторингом

#### Проверка Prometheus
```bash
kubectl logs -n monitoring deployment/prometheus
```

#### Проверка Grafana
```bash
kubectl logs -n monitoring deployment/grafana
```

## Обновление

### 1. Обновление приложения
```bash
# Обновление образа
kubectl set image deployment/devops-resume-app -n devops-resume resume-app=your-registry/devops-resume-platform:v1.1.0

# Проверка обновления
kubectl rollout status deployment/devops-resume-app -n devops-resume
```

### 2. Обновление инфраструктуры
```bash
cd terraform
terraform plan
terraform apply
```

### 3. Обновление Kubernetes
```bash
# Обновление кластера
aws eks update-cluster-version --region us-east-1 --name devops-resume-production --kubernetes-version 1.29
```

## Удаление

### 1. Удаление приложения
```bash
kubectl delete -f k8s/
```

### 2. Удаление инфраструктуры
```bash
cd terraform
terraform destroy
```

### 3. Очистка ресурсов
```bash
# Удаление ECR репозитория
aws ecr delete-repository --repository-name devops-resume-platform --force

# Удаление S3 bucket
aws s3 rb s3://devops-resume-terraform-state --force
```

## Полезные команды

### Kubernetes
```bash
# Масштабирование
kubectl scale deployment devops-resume-app -n devops-resume --replicas=5

# Перезапуск подов
kubectl rollout restart deployment/devops-resume-app -n devops-resume

# Просмотр ресурсов
kubectl top pods -n devops-resume
kubectl top nodes
```

### AWS
```bash
# Список EKS кластеров
aws eks list-clusters

# Список ECR репозиториев
aws ecr describe-repositories

# Список S3 buckets
aws s3 ls
```

### Docker
```bash
# Сборка образа
docker build -t devops-resume-platform ./app

# Запуск контейнера
docker run -p 8080:8080 devops-resume-platform

# Просмотр логов
docker logs -f container_id
```
