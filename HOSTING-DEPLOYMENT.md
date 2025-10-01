# 🚀 Развертывание на хостинге с Grafana

## 📋 Пошаговая инструкция

### 1. **Подготовка VPS/Хостинга**

#### Требования к серверу:
- **OS**: Ubuntu 22.04 LTS (рекомендуется)
- **CPU**: 2 vCPU
- **RAM**: 4GB
- **Storage**: 40GB SSD
- **Network**: 1TB bandwidth/month

#### Рекомендуемые провайдеры:
- **DigitalOcean** - $24/month (4GB RAM)
- **Linode** - $24/month (4GB RAM)
- **Vultr** - $24/month (4GB RAM)
- **Hetzner** - €20/month (4GB RAM)

### 2. **Подключение к серверу**

```bash
# Подключение по SSH
ssh root@your-server-ip

# Или если используете ключи
ssh -i your-key.pem root@your-server-ip
```

### 3. **Автоматическое развертывание**

```bash
# Скачивание скрипта развертывания
curl -O https://raw.githubusercontent.com/twinleq/devops-resume-platform/main/deploy-hosting.sh

# Права на выполнение
chmod +x deploy-hosting.sh

# Запуск развертывания
sudo ./deploy-hosting.sh
```

### 4. **Ручное развертывание**

Если автоматический скрипт не работает:

```bash
# Обновление системы
apt update && apt upgrade -y

# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Установка Docker Compose
apt install docker-compose-plugin

# Клонирование проекта
git clone https://github.com/twinleq/devops-resume-platform.git
cd devops-resume-platform

# Запуск приложения
docker-compose -f docker-compose.prod.yml up -d --build
```

### 5. **Настройка домена**

#### DNS настройки:
```
A     your-domain.com      → your-server-ip
A     www.your-domain.com  → your-server-ip
CNAME grafana.your-domain.com → your-domain.com
CNAME prometheus.your-domain.com → your-domain.com
```

### 6. **SSL сертификаты (Let's Encrypt)**

```bash
# Установка Certbot
apt install certbot

# Получение сертификатов
certbot certonly --standalone -d your-domain.com -d www.your-domain.com

# Обновление конфигурации Nginx
# Сертификаты будут в /etc/letsencrypt/live/your-domain.com/
```

### 7. **Доступ к сервисам**

После развертывания будут доступны:

#### 🌐 **Основное приложение:**
- **URL**: `http://your-domain.com`
- **HTTPS**: `https://your-domain.com`

#### 📊 **Grafana (Мониторинг):**
- **URL**: `http://your-domain.com:3001`
- **Login**: `admin`
- **Password**: `devops123`

#### 📈 **Prometheus (Метрики):**
- **URL**: `http://your-domain.com:9090`
- **Login**: `admin`
- **Password**: `devops123`

### 8. **Grafana дашборды**

#### Автоматически созданные дашборды:
1. **DevOps Resume Platform Dashboard**
   - Application uptime
   - HTTP request rate
   - Response time
   - Error rate
   - System resources

#### Добавление новых дашбордов:
1. Зайдите в Grafana
2. Создайте новый дашборд
3. Добавьте панели с метриками
4. Экспортируйте как JSON
5. Сохраните в `monitoring/grafana/dashboards/`

### 9. **Мониторинг и алерты**

#### Prometheus алерты настроены для:
- ✅ Application down
- ✅ High error rate (>10%)
- ✅ High response time (>1s)
- ✅ High CPU usage (>80%)
- ✅ High memory usage (>85%)
- ✅ Low disk space (>90%)

#### Настройка уведомлений:
```yaml
# monitoring/alertmanager/alertmanager.yml
route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
- name: 'web.hook'
  slack_configs:
  - api_url: 'YOUR_SLACK_WEBHOOK'
    channel: '#alerts'
```

### 10. **Управление сервисом**

```bash
# Запуск
sudo systemctl start devops-resume

# Остановка
sudo systemctl stop devops-resume

# Перезапуск
sudo systemctl restart devops-resume

# Статус
sudo systemctl status devops-resume

# Логи
docker-compose -f /opt/devops-resume/docker-compose.prod.yml logs -f
```

### 11. **Бэкапы**

#### Автоматические бэкапы:
- **Расписание**: каждый день в 2:00
- **Хранение**: 30 дней
- **Местоположение**: `/opt/backups/devops-resume/`

#### Ручной бэкап:
```bash
/opt/devops-resume/backup.sh
```

### 12. **Обновление приложения**

```bash
cd /opt/devops-resume
git pull origin main
docker-compose -f docker-compose.prod.yml up -d --build
```

### 13. **Безопасность**

#### Настроенные меры:
- ✅ Firewall (UFW) с ограниченными портами
- ✅ SSL/TLS шифрование
- ✅ Basic Auth для мониторинга
- ✅ Security headers
- ✅ Rate limiting
- ✅ Container security

#### Дополнительные рекомендации:
- Регулярно обновляйте систему
- Используйте SSH ключи
- Настройте fail2ban
- Мониторьте логи безопасности

### 14. **Устранение неполадок**

#### Проверка статуса контейнеров:
```bash
docker ps
docker-compose -f docker-compose.prod.yml ps
```

#### Проверка логов:
```bash
# Все сервисы
docker-compose -f docker-compose.prod.yml logs

# Конкретный сервис
docker-compose -f docker-compose.prod.yml logs grafana
```

#### Проверка ресурсов:
```bash
# Использование ресурсов
docker stats

# Место на диске
df -h
```

#### Проверка сети:
```bash
# Порты
netstat -tulpn | grep :80
netstat -tulpn | grep :443
netstat -tulpn | grep :3001
```

### 15. **Стоимость**

#### Ежемесячные расходы:
- **VPS**: $24/month
- **Domain**: $1/month (годовая оплата)
- **SSL**: Free (Let's Encrypt)
- **Мониторинг**: Free (self-hosted)

#### **Общая стоимость: ~$25/month**

### 16. **Полезные команды**

```bash
# Перезапуск только мониторинга
docker-compose -f docker-compose.prod.yml restart prometheus grafana

# Обновление только приложения
docker-compose -f docker-compose.prod.yml up -d --build resume-app

# Просмотр метрик
curl http://localhost:9090/api/v1/query?query=up

# Проверка здоровья
curl http://localhost:80/health
```

## 🎯 **Результат**

После развертывания у вас будет:
- ✅ Полностью работающий сайт-резюме
- ✅ Grafana с дашбордами мониторинга
- ✅ Prometheus с метриками и алертами
- ✅ Автоматические бэкапы
- ✅ SSL сертификаты
- ✅ Firewall и безопасность
- ✅ CI/CD готовность

Ваше DevOps портфолио будет полностью функциональным и готовым для демонстрации работодателям! 🚀
