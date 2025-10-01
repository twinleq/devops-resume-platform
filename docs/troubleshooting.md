# Руководство по устранению неполадок

## Общие проблемы и решения

### 1. Проблемы с развертыванием

#### Pod не запускается
```bash
# Проверка статуса подов
kubectl get pods -n devops-resume

# Детальная информация о поде
kubectl describe pod <pod-name> -n devops-resume

# Логи пода
kubectl logs <pod-name> -n devops-resume

# Предыдущие логи
kubectl logs <pod-name> -n devops-resume --previous
```

**Возможные причины:**
- Недостаточно ресурсов
- Проблемы с образом
- Ошибки в конфигурации
- Проблемы с секретами

**Решения:**
```bash
# Проверка ресурсов
kubectl top nodes
kubectl top pods -n devops-resume

# Проверка событий
kubectl get events -n devops-resume --sort-by='.lastTimestamp'

# Проверка секретов
kubectl get secrets -n devops-resume
kubectl describe secret <secret-name> -n devops-resume
```

#### ImagePullBackOff
```bash
# Проверка образа
kubectl describe pod <pod-name> -n devops-resume | grep -A 10 "Events:"

# Проверка доступа к ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Проверка существования образа
aws ecr describe-images --repository-name devops-resume-platform --region us-east-1
```

#### CrashLoopBackOff
```bash
# Проверка логов
kubectl logs <pod-name> -n devops-resume

# Проверка конфигурации
kubectl get configmap resume-app-config -n devops-resume -o yaml

# Проверка переменных окружения
kubectl exec -it <pod-name> -n devops-resume -- env
```

### 2. Проблемы с сетью

#### Сервис недоступен
```bash
# Проверка сервисов
kubectl get svc -n devops-resume

# Проверка endpoints
kubectl get endpoints -n devops-resume

# Тест подключения из пода
kubectl exec -it <pod-name> -n devops-resume -- curl http://devops-resume-app-service:80/health
```

#### Ingress не работает
```bash
# Проверка ingress
kubectl get ingress -n devops-resume
kubectl describe ingress devops-resume-app-ingress -n devops-resume

# Проверка ingress controller
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Проверка DNS
nslookup resume.yourdomain.com
dig resume.yourdomain.com
```

#### SSL сертификаты
```bash
# Проверка сертификатов
kubectl get certificates -n devops-resume
kubectl describe certificate resume-app-tls -n devops-resume

# Проверка cert-manager
kubectl get pods -n cert-manager
kubectl logs -n cert-manager deployment/cert-manager

# Проверка ClusterIssuer
kubectl get clusterissuer
kubectl describe clusterissuer letsencrypt-prod
```

### 3. Проблемы с мониторингом

#### Prometheus не собирает метрики
```bash
# Проверка Prometheus
kubectl get pods -n monitoring
kubectl logs -n monitoring deployment/prometheus

# Проверка targets
kubectl port-forward -n monitoring svc/prometheus 9090:9090
curl http://localhost:9090/api/v1/targets

# Проверка ServiceMonitor
kubectl get servicemonitor -n devops-resume
```

#### Grafana не отображает данные
```bash
# Проверка Grafana
kubectl get pods -n monitoring
kubectl logs -n monitoring deployment/grafana

# Проверка datasources
kubectl port-forward -n monitoring svc/grafana 3000:3000
curl http://admin:admin@localhost:3000/api/datasources

# Проверка дашбордов
curl http://admin:admin@localhost:3000/api/dashboards
```

### 4. Проблемы с CI/CD

#### GitHub Actions не запускается
```bash
# Проверка статуса workflow
gh run list --repo yourusername/devops-resume-platform

# Просмотр логов
gh run view <run-id> --repo yourusername/devops-resume-platform

# Проверка секретов
gh secret list --repo yourusername/devops-resume-platform
```

#### Docker build fails
```bash
# Локальная сборка для тестирования
cd app
docker build -t devops-resume-platform:test .

# Проверка Dockerfile
docker run --rm -it devops-resume-platform:test /bin/sh

# Проверка зависимостей
docker run --rm -it devops-resume-platform:test npm list
```

#### Terraform apply fails
```bash
# Проверка состояния
cd terraform
terraform state list
terraform plan

# Проверка логов
terraform apply -auto-approve 2>&1 | tee terraform.log

# Проверка AWS ресурсов
aws eks describe-cluster --name devops-resume-production
aws ecr describe-repositories
```

## Диагностические команды

### 1. Kubernetes диагностика
```bash
# Общий статус кластера
kubectl get nodes
kubectl get pods --all-namespaces
kubectl get svc --all-namespaces
kubectl get ingress --all-namespaces

# Ресурсы
kubectl top nodes
kubectl top pods --all-namespaces
kubectl describe node <node-name>

# События
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
kubectl get events -n devops-resume --field-selector type=Warning
```

### 2. AWS диагностика
```bash
# EKS кластер
aws eks describe-cluster --name devops-resume-production --region us-east-1
aws eks list-nodegroups --cluster-name devops-resume-production --region us-east-1

# Load Balancer
aws elbv2 describe-load-balancers --region us-east-1
aws elbv2 describe-target-groups --region us-east-1

# ECR
aws ecr describe-repositories --region us-east-1
aws ecr list-images --repository-name devops-resume-platform --region us-east-1

# CloudWatch
aws logs describe-log-groups --region us-east-1
aws logs describe-log-streams --log-group-name /aws/eks/devops-resume-production/cluster --region us-east-1
```

### 3. Приложение диагностика
```bash
# Health check
curl -f http://resume.yourdomain.com/health
curl -f http://resume.yourdomain.com/metrics

# Performance test
for i in {1..10}; do
  curl -w "%{time_total}\n" -o /dev/null -s http://resume.yourdomain.com/
done

# Load test
ab -n 1000 -c 10 http://resume.yourdomain.com/
```

## Логи и отладка

### 1. Сбор логов
```bash
# Логи приложения
kubectl logs -n devops-resume deployment/devops-resume-app -f

# Логи ingress
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller -f

# Логи мониторинга
kubectl logs -n monitoring deployment/prometheus -f
kubectl logs -n monitoring deployment/grafana -f

# Системные логи
journalctl -u kubelet -f
journalctl -u docker -f
```

### 2. Отладка сети
```bash
# Проверка DNS
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default.svc.cluster.local

# Проверка подключения
kubectl run -it --rm debug --image=busybox --restart=Never -- wget -qO- http://devops-resume-app-service:80/health

# Проверка портов
kubectl run -it --rm debug --image=busybox --restart=Never -- nc -zv devops-resume-app-service 80
```

### 3. Отладка безопасности
```bash
# Проверка RBAC
kubectl auth can-i get pods --as=system:serviceaccount:devops-resume:resume-app-service-account -n devops-resume

# Проверка Network Policies
kubectl get networkpolicies -n devops-resume
kubectl describe networkpolicy devops-resume-app-network-policy -n devops-resume

# Проверка Security Context
kubectl get pod <pod-name> -n devops-resume -o yaml | grep -A 20 securityContext
```

## Восстановление

### 1. Восстановление из backup
```bash
# Восстановление Terraform state
cd terraform
terraform init -reconfigure
terraform import aws_eks_cluster.main devops-resume-production

# Восстановление Kubernetes ресурсов
kubectl apply -f k8s/

# Восстановление данных
kubectl apply -f backup/restore.yaml
```

### 2. Откат развертывания
```bash
# Откат deployment
kubectl rollout undo deployment/devops-resume-app -n devops-resume

# Проверка истории
kubectl rollout history deployment/devops-resume-app -n devops-resume

# Откат к конкретной ревизии
kubectl rollout undo deployment/devops-resume-app --to-revision=2 -n devops-resume
```

### 3. Восстановление сертификатов
```bash
# Удаление проблемного сертификата
kubectl delete certificate resume-app-tls -n devops-resume

# Принудительное обновление
kubectl annotate ingress devops-resume-app-ingress -n devops-resume cert-manager.io/issue-temporary-certificate=true --overwrite
```

## Профилактика

### 1. Мониторинг здоровья
```bash
# Регулярные проверки
kubectl get pods -n devops-resume
kubectl top nodes
kubectl get events -n devops-resume --sort-by='.lastTimestamp'

# Проверка ресурсов
kubectl describe nodes
kubectl get pv,pvc -n devops-resume
```

### 2. Обновления
```bash
# Обновление кластера
aws eks update-cluster-version --name devops-resume-production --kubernetes-version 1.29

# Обновление node group
aws eks update-nodegroup-version --cluster-name devops-resume-production --nodegroup-name devops-resume-production-node-group
```

### 3. Безопасность
```bash
# Проверка уязвимостей
trivy image your-registry/devops-resume-platform:latest
kubectl get pods -n devops-resume -o jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}' | xargs -I {} trivy image {}

# Обновление зависимостей
npm audit fix
terraform init -upgrade
```

## Полезные ресурсы

### 1. Документация
- [Kubernetes Troubleshooting](https://kubernetes.io/docs/tasks/debug-application-cluster/)
- [AWS EKS Troubleshooting](https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting.html)
- [Prometheus Troubleshooting](https://prometheus.io/docs/guides/troubleshooting/)

### 2. Инструменты
- [kubectl debug](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-running-pod/)
- [k9s](https://k9scli.io/) - TUI для Kubernetes
- [kubectx](https://github.com/ahmetb/kubectx) - Переключение контекстов

### 3. Сообщество
- [Kubernetes Slack](https://kubernetes.slack.com/)
- [AWS EKS Forum](https://forums.aws.amazon.com/forum.jspa?forumID=58)
- [Prometheus Users](https://groups.google.com/forum/#!forum/prometheus-users)

