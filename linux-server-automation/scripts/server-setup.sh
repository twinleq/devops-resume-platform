#!/bin/bash

# DevOps Resume Platform - Linux Server Setup Script
# Автоматическая настройка Linux сервера для DevOps задач

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Функции для вывода
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
    apt update
    apt upgrade -y
    apt autoremove -y
    success "Система обновлена"
}

# Установка основных пакетов
install_essential_packages() {
    log "Установка основных пакетов..."
    
    packages=(
        "curl"
        "wget"
        "git"
        "vim"
        "htop"
        "tree"
        "unzip"
        "zip"
        "tar"
        "gzip"
        "rsync"
        "ssh"
        "openssh-server"
        "ufw"
        "fail2ban"
        "cron"
        "logrotate"
        "ntp"
        "htop"
        "iotop"
        "nethogs"
        "tcpdump"
        "netstat-nat"
        "lsof"
        "strace"
        "tcpdump"
        "wireshark-common"
    )
    
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            log "Установка $package..."
            apt install -y "$package"
        else
            log "$package уже установлен"
        fi
    done
    
    success "Основные пакеты установлены"
}

# Настройка временной зоны
setup_timezone() {
    log "Настройка временной зоны..."
    timedatectl set-timezone Europe/Moscow
    systemctl enable systemd-timesyncd
    systemctl start systemd-timesyncd
    success "Временная зона настроена на Europe/Moscow"
}

# Создание пользователя devops
create_devops_user() {
    log "Создание пользователя devops..."
    
    if ! id "devops" &>/dev/null; then
        useradd -m -s /bin/bash devops
        usermod -aG sudo devops
        mkdir -p /home/devops/.ssh
        chmod 700 /home/devops/.ssh
        chown devops:devops /home/devops/.ssh
        success "Пользователь devops создан"
    else
        warning "Пользователь devops уже существует"
    fi
}

# Настройка SSH
configure_ssh() {
    log "Настройка SSH..."
    
    # Резервная копия конфигурации
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    
    # Настройка SSH
    cat > /etc/ssh/sshd_config << 'EOF'
# Основные настройки SSH
Port 22
Protocol 2
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PermitEmptyPasswords no
MaxAuthTries 3
MaxSessions 10
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 60
Banner /etc/ssh/banner

# Логирование
SyslogFacility AUTH
LogLevel INFO

# Безопасность
X11Forwarding no
AllowTcpForwarding yes
GatewayPorts no
PermitTunnel no
ChrootDirectory none
EOF

    # Создание баннера
    cat > /etc/ssh/banner << 'EOF'
***************************************************************************
                    ДОБРО ПОЖАЛОВАТЬ НА СЕРВЕР DEVOPS
***************************************************************************
Этот сервер находится под мониторингом.
Все действия логируются.
Несанкционированный доступ запрещен.
***************************************************************************
EOF

    systemctl restart ssh
    success "SSH настроен"
}

# Настройка firewall
setup_firewall() {
    log "Настройка firewall..."
    
    # Сброс правил
    ufw --force reset
    
    # Политики по умолчанию
    ufw default deny incoming
    ufw default allow outgoing
    
    # Разрешение SSH
    ufw allow ssh
    
    # Разрешение HTTP и HTTPS
    ufw allow 80/tcp
    ufw allow 443/tcp
    
    # Разрешение мониторинга (локальная сеть)
    ufw allow from 10.0.0.0/8 to any port 9090
    ufw allow from 172.16.0.0/12 to any port 9090
    ufw allow from 192.168.0.0/16 to any port 9090
    
    ufw allow from 10.0.0.0/8 to any port 3000
    ufw allow from 172.16.0.0/12 to any port 3000
    ufw allow from 192.168.0.0/16 to any port 3000
    
    # Включение firewall
    ufw --force enable
    
    success "Firewall настроен"
}

# Настройка fail2ban
setup_fail2ban() {
    log "Настройка fail2ban..."
    
    cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
backend = systemd

[sshd]
enabled = true
port = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
maxretry = 3
bantime = 3600
findtime = 600

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
logpath = /var/log/nginx/error.log
maxretry = 3
bantime = 3600
findtime = 600

[nginx-noscript]
enabled = true
filter = nginx-noscript
logpath = /var/log/nginx/access.log
maxretry = 3
bantime = 3600
findtime = 600
EOF

    systemctl enable fail2ban
    systemctl start fail2ban
    
    success "Fail2ban настроен"
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
    
    # Добавление пользователя devops в группу docker
    usermod -aG docker devops
    
    success "Docker установлен"
}

# Установка мониторинга
install_monitoring() {
    log "Установка Prometheus и Grafana..."
    
    # Создание пользователя для мониторинга
    useradd --no-create-home --shell /bin/false prometheus
    useradd --no-create-home --shell /bin/false node_exporter
    
    # Создание директорий
    mkdir -p /etc/prometheus
    mkdir -p /var/lib/prometheus
    chown prometheus:prometheus /etc/prometheus
    chown prometheus:prometheus /var/lib/prometheus
    
    # Скачивание и установка Prometheus
    cd /tmp
    wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
    tar xzf prometheus-2.45.0.linux-amd64.tar.gz
    cp prometheus-2.45.0.linux-amd64/prometheus /usr/local/bin/
    cp prometheus-2.45.0.linux-amd64/promtool /usr/local/bin/
    cp -r prometheus-2.45.0.linux-amd64/consoles /etc/prometheus
    cp -r prometheus-2.45.0.linux-amd64/console_libraries /etc/prometheus
    chown prometheus:prometheus /usr/local/bin/prometheus
    chown prometheus:prometheus /usr/local/bin/promtool
    chown -R prometheus:prometheus /etc/prometheus/consoles
    chown -R prometheus:prometheus /etc/prometheus/console_libraries
    
    # Скачивание и установка Node Exporter
    wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
    tar xzf node_exporter-1.6.1.linux-amd64.tar.gz
    cp node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
    chown node_exporter:node_exporter /usr/local/bin/node_exporter
    
    success "Prometheus и Node Exporter установлены"
}

# Создание systemd сервисов
create_systemd_services() {
    log "Создание systemd сервисов..."
    
    # Prometheus service
    cat > /etc/systemd/system/prometheus.service << 'EOF'
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.listen-address=0.0.0.0:9090 \
    --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
EOF

    # Node Exporter service
    cat > /etc/systemd/system/node_exporter.service << 'EOF'
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable prometheus
    systemctl enable node_exporter
    systemctl start prometheus
    systemctl start node_exporter
    
    success "Systemd сервисы созданы и запущены"
}

# Настройка cron задач
setup_cron_jobs() {
    log "Настройка cron задач..."
    
    # Создание cron задач для root
    cat > /etc/cron.d/server-automation << 'EOF'
# Обновление системы (еженедельно)
0 2 * * 0 root apt update && apt upgrade -y && apt autoremove -y

# Очистка логов (ежедневно)
0 1 * * * root find /var/log -name "*.log" -mtime +30 -delete

# Ротация логов (ежедневно)
0 0 * * * root /usr/sbin/logrotate /etc/logrotate.conf

# Проверка дискового пространства (ежедневно)
0 6 * * * root df -h | awk '$5 > 80 {print $0}' | mail -s "Disk Usage Alert" root
EOF

    success "Cron задачи настроены"
}

# Настройка логирования
setup_logging() {
    log "Настройка логирования..."
    
    # Создание директории для логов
    mkdir -p /var/log/server-automation
    
    # Настройка logrotate
    cat > /etc/logrotate.d/server-automation << 'EOF'
/var/log/server-automation/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 root root
}
EOF

    success "Логирование настроено"
}

# Создание скрипта мониторинга
create_monitoring_script() {
    log "Создание скрипта мониторинга..."
    
    cat > /usr/local/bin/server-monitor.sh << 'EOF'
#!/bin/bash

# Скрипт мониторинга состояния сервера

LOG_FILE="/var/log/server-automation/server-monitor.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Функция логирования
log_message() {
    echo "[$DATE] $1" >> $LOG_FILE
}

# Проверка использования диска
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    log_message "WARNING: Disk usage is ${DISK_USAGE}%"
fi

# Проверка использования памяти
MEMORY_USAGE=$(free | awk 'NR==2{printf "%.2f", $3*100/$2 }')
if (( $(echo "$MEMORY_USAGE > 80" | bc -l) )); then
    log_message "WARNING: Memory usage is ${MEMORY_USAGE}%"
fi

# Проверка загрузки CPU
CPU_LOAD=$(uptime | awk '{print $10}' | sed 's/,//')
if (( $(echo "$CPU_LOAD > 2" | bc -l) )); then
    log_message "WARNING: CPU load is $CPU_LOAD"
fi

# Проверка статуса сервисов
services=("docker" "prometheus" "node_exporter" "ssh" "ufw")
for service in "${services[@]}"; do
    if ! systemctl is-active --quiet $service; then
        log_message "ERROR: Service $service is not running"
    fi
done

log_message "Server monitoring check completed"
EOF

    chmod +x /usr/local/bin/server-monitor.sh
    
    # Добавление в cron (каждые 5 минут)
    echo "*/5 * * * * root /usr/local/bin/server-monitor.sh" >> /etc/cron.d/server-automation
    
    success "Скрипт мониторинга создан"
}

# Основная функция
main() {
    log "Начинаем автоматическую настройку Linux сервера..."
    
    check_root
    update_system
    install_essential_packages
    setup_timezone
    create_devops_user
    configure_ssh
    setup_firewall
    setup_fail2ban
    install_docker
    install_monitoring
    create_systemd_services
    setup_cron_jobs
    setup_logging
    create_monitoring_script
    
    success "Настройка сервера завершена!"
    
    echo ""
    echo "=========================================="
    echo "🚀 Linux Server готов к работе!"
    echo "=========================================="
    echo ""
    echo "📊 Мониторинг:"
    echo "   Prometheus: http://$(hostname -I | awk '{print $1}'):9090"
    echo "   Node Exporter: http://$(hostname -I | awk '{print $1}'):9100"
    echo ""
    echo "👤 Пользователь:"
    echo "   Username: devops"
    echo "   Groups: sudo, docker"
    echo ""
    echo "🔒 Безопасность:"
    echo "   SSH: настроен (только ключи)"
    echo "   Firewall: UFW активен"
    echo "   Fail2ban: активен"
    echo ""
    echo "📋 Полезные команды:"
    echo "   systemctl status prometheus"
    echo "   systemctl status node_exporter"
    echo "   ufw status"
    echo "   fail2ban-client status"
    echo ""
}

# Запуск
main "$@"
