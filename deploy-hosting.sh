#!/bin/bash

# DevOps Resume Platform - Deployment Script for Hosting
# Этот скрипт развертывает проект на VPS/хостинге с полным мониторингом

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для вывода сообщений
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка прав root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "Этот скрипт должен запускаться с правами root"
        exit 1
    fi
}

# Обновление системы
update_system() {
    log "Обновление системы..."
    apt update && apt upgrade -y
    success "Система обновлена"
}

# Установка Docker
install_docker() {
    log "Установка Docker..."
    
    # Удаление старых версий
    apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # Установка зависимостей
    apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
    
    # Добавление GPG ключа Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Добавление репозитория Docker
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Установка Docker
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Запуск и включение Docker
    systemctl start docker
    systemctl enable docker
    
    success "Docker установлен"
}

# Установка Docker Compose
install_docker_compose() {
    log "Установка Docker Compose..."
    
    # Скачивание последней версии
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    
    # Права на выполнение
    chmod +x /usr/local/bin/docker-compose
    
    # Создание символической ссылки
    ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    success "Docker Compose установлен"
}

# Настройка firewall
setup_firewall() {
    log "Настройка firewall..."
    
    # Установка UFW если не установлен
    apt install -y ufw
    
    # Сброс правил
    ufw --force reset
    
    # Настройка политик по умолчанию
    ufw default deny incoming
    ufw default allow outgoing
    
    # Разрешение SSH
    ufw allow ssh
    
    # Разрешение HTTP и HTTPS
    ufw allow 80/tcp
    ufw allow 443/tcp
    
    # Разрешение мониторинга (только для локальной сети)
    ufw allow from 10.0.0.0/8 to any port 3001
    ufw allow from 172.16.0.0/12 to any port 3001
    ufw allow from 192.168.0.0/16 to any port 3001
    
    # Включение firewall
    ufw --force enable
    
    success "Firewall настроен"
}

# Создание пользователя для приложения
create_app_user() {
    log "Создание пользователя для приложения..."
    
    if ! id "devops" &>/dev/null; then
        useradd -r -s /bin/bash -m -d /opt/devops-resume devops
        usermod -aG docker devops
        success "Пользователь devops создан"
    else
        warning "Пользователь devops уже существует"
    fi
}

# Создание директорий
create_directories() {
    log "Создание директорий..."
    
    APP_DIR="/opt/devops-resume"
    mkdir -p $APP_DIR/{nginx/ssl,logs,monitoring/{prometheus,grafana/{dashboards,provisioning/{datasources,dashboards}},loki,promtail,alertmanager}}
    
    # Права доступа
    chown -R devops:devops $APP_DIR
    chmod -R 755 $APP_DIR
    
    success "Директории созданы"
}

# Настройка SSL сертификатов
setup_ssl() {
    log "Настройка SSL сертификатов..."
    
    SSL_DIR="/opt/devops-resume/nginx/ssl"
    
    # Создание самоподписанного сертификата для тестирования
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout $SSL_DIR/key.pem \
        -out $SSL_DIR/cert.pem \
        -subj "/C=RU/ST=Moscow/L=Moscow/O=DevOps/CN=your-domain.com"
    
    chmod 600 $SSL_DIR/key.pem
    chmod 644 $SSL_DIR/cert.pem
    chown -R devops:devops $SSL_DIR
    
    success "SSL сертификаты созданы"
    warning "Для продакшн используйте Let's Encrypt сертификаты"
}

# Настройка мониторинга
setup_monitoring() {
    log "Настройка конфигураций мониторинга..."
    
    MONITORING_DIR="/opt/devops-resume/monitoring"
    
    # Prometheus конфигурация
    cat > $MONITORING_DIR/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'resume-app'
    static_configs:
      - targets: ['resume-app:80']
    metrics_path: '/metrics'
    scrape_interval: 30s
  
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
EOF

    # Alert rules
    cat > $MONITORING_DIR/prometheus/alert_rules.yml << 'EOF'
groups:
  - name: resume-platform
    rules:
      - alert: ResumeAppDown
        expr: up{job="resume-app"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Resume application is down"
          description: "Resume application has been down for more than 1 minute."
      
      - alert: HighErrorRate
        expr: rate(http_requests_total{job="resume-app",status=~"5.."}[5m]) > 0.1
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} errors per second."
      
      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket{job="resume-app"}[5m])) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time"
          description: "95th percentile response time is {{ $value }} seconds."
      
      - alert: HighCPUUsage
        expr: 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage"
          description: "CPU usage is {{ $value }}%."
      
      - alert: HighMemoryUsage
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Memory usage is {{ $value }}%."
      
      - alert: DiskSpaceLow
        expr: 100 - ((node_filesystem_avail_bytes * 100) / node_filesystem_size_bytes) > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Disk space is low"
          description: "Disk usage is {{ $value }}%."
EOF

    success "Конфигурации мониторинга настроены"
}

# Клонирование проекта
clone_project() {
    log "Клонирование проекта..."
    
    PROJECT_DIR="/opt/devops-resume"
    cd $PROJECT_DIR
    
    # Если проект уже существует, обновляем его
    if [ -d ".git" ]; then
        git pull origin main
        success "Проект обновлен"
    else
        git clone https://github.com/twinleq/devops-resume-platform.git .
        success "Проект клонирован"
    fi
    
    # Права доступа
    chown -R devops:devops $PROJECT_DIR
}

# Запуск приложения
start_application() {
    log "Запуск приложения..."
    
    PROJECT_DIR="/opt/devops-resume"
    cd $PROJECT_DIR
    
    # Остановка существующих контейнеров
    docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
    
    # Сборка и запуск
    docker-compose -f docker-compose.prod.yml up -d --build
    
    # Ожидание запуска
    sleep 30
    
    # Проверка статуса
    if docker-compose -f docker-compose.prod.yml ps | grep -q "Up"; then
        success "Приложение запущено"
    else
        error "Ошибка при запуске приложения"
        docker-compose -f docker-compose.prod.yml logs
        exit 1
    fi
}

# Настройка systemd сервиса
setup_systemd_service() {
    log "Настройка systemd сервиса..."
    
    cat > /etc/systemd/system/devops-resume.service << 'EOF'
[Unit]
Description=DevOps Resume Platform
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/devops-resume
ExecStart=/usr/bin/docker-compose -f docker-compose.prod.yml up -d
ExecStop=/usr/bin/docker-compose -f docker-compose.prod.yml down
TimeoutStartSec=0
User=devops
Group=devops

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable devops-resume.service
    
    success "Systemd сервис настроен"
}

# Настройка автоматических бэкапов
setup_backups() {
    log "Настройка автоматических бэкапов..."
    
    cat > /opt/devops-resume/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/opt/backups/devops-resume"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Бэкап конфигураций
tar -czf $BACKUP_DIR/config_$DATE.tar.gz -C /opt/devops-resume monitoring nginx docker-compose.prod.yml

# Бэкап данных Grafana
docker exec devops-resume-grafana tar -czf /tmp/grafana_backup.tar.gz -C /var/lib/grafana .
docker cp devops-resume-grafana:/tmp/grafana_backup.tar.gz $BACKUP_DIR/grafana_$DATE.tar.gz

# Бэкап данных Prometheus
docker exec devops-resume-prometheus tar -czf /tmp/prometheus_backup.tar.gz -C /prometheus .
docker cp devops-resume-prometheus:/tmp/prometheus_backup.tar.gz $BACKUP_DIR/prometheus_$DATE.tar.gz

# Удаление старых бэкапов (старше 30 дней)
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete
EOF

    chmod +x /opt/devops-resume/backup.sh
    chown devops:devops /opt/devops-resume/backup.sh
    
    # Настройка cron задачи
    echo "0 2 * * * /opt/devops-resume/backup.sh" | crontab -u devops -
    
    success "Автоматические бэкапы настроены"
}

# Основная функция
main() {
    log "Начинаем развертывание DevOps Resume Platform..."
    
    check_root
    update_system
    install_docker
    install_docker_compose
    setup_firewall
    create_app_user
    create_directories
    setup_ssl
    setup_monitoring
    clone_project
    start_application
    setup_systemd_service
    setup_backups
    
    success "Развертывание завершено!"
    
    echo ""
    echo "=========================================="
    echo "🚀 DevOps Resume Platform развернута!"
    echo "=========================================="
    echo ""
    echo "📱 Основное приложение:"
    echo "   http://your-domain.com"
    echo ""
    echo "📊 Мониторинг:"
    echo "   Grafana: http://your-domain.com:3001"
    echo "   Prometheus: http://your-domain.com:9090"
    echo ""
    echo "🔧 Управление:"
    echo "   sudo systemctl start devops-resume"
    echo "   sudo systemctl stop devops-resume"
    echo "   sudo systemctl restart devops-resume"
    echo "   sudo systemctl status devops-resume"
    echo ""
    echo "📋 Логи:"
    echo "   docker-compose -f /opt/devops-resume/docker-compose.prod.yml logs -f"
    echo ""
    echo "⚠️  Не забудьте:"
    echo "   1. Настроить домен в DNS"
    echo "   2. Установить Let's Encrypt сертификаты"
    echo "   3. Настроить мониторинг алертов"
    echo ""
}

# Запуск
main "$@"
