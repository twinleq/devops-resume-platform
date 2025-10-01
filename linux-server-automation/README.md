# Linux Server Automation

Автоматизация настройки и управления Linux серверами с помощью bash скриптов и Ansible. Включает мониторинг, бэкапы и безопасность.

## Возможности

- ✅ Автоматическая настройка серверов Ubuntu/CentOS
- ✅ Мониторинг системы и сервисов
- ✅ Автоматические бэкапы данных
- ✅ Управление пользователями и группами
- ✅ Настройка безопасности и firewall
- ✅ Установка и настройка веб-серверов (Apache/Nginx)
- ✅ SSL сертификаты и безопасность

## Технологии

- **Linux** (Ubuntu 22.04, CentOS 8)
- **Bash scripting**
- **Ansible** для автоматизации
- **Prometheus** для мониторинга
- **Grafana** для визуализации
- **UFW/iptables** для firewall
- **Cron** для автоматизации задач

## Структура проекта

```
linux-server-automation/
├── scripts/
│   ├── server-setup.sh          # Основной скрипт настройки
│   ├── monitoring-setup.sh      # Настройка мониторинга
│   ├── backup-script.sh         # Скрипт бэкапов
│   ├── security-hardening.sh    # Настройка безопасности
│   └── user-management.sh       # Управление пользователями
├── ansible/
│   ├── playbooks/
│   │   ├── install-packages.yml
│   │   ├── configure-users.yml
│   │   ├── setup-monitoring.yml
│   │   ├── configure-nginx.yml
│   │   └── security-setup.yml
│   ├── inventory/
│   │   └── hosts.yml
│   └── roles/
│       ├── common/
│       ├── monitoring/
│       ├── security/
│       └── webserver/
├── monitoring/
│   ├── prometheus-config.yml
│   ├── grafana-dashboards/
│   └── alert-rules.yml
├── backup/
│   ├── backup-strategy.md
│   ├── restore-procedures.md
│   └── backup-scripts/
├── security/
│   ├── firewall-rules/
│   ├── ssl-certificates/
│   └── security-policies/
└── docs/
    ├── installation.md
    ├── configuration.md
    └── troubleshooting.md
```

## Быстрый старт

### 1. Клонирование репозитория

```bash
git clone https://github.com/twinleq/linux-server-automation.git
cd linux-server-automation
```

### 2. Настройка сервера

```bash
# Запуск основного скрипта настройки
sudo ./scripts/server-setup.sh

# Настройка мониторинга
sudo ./scripts/monitoring-setup.sh

# Настройка безопасности
sudo ./scripts/security-hardening.sh
```

### 3. Использование Ansible

```bash
# Установка Ansible
pip install ansible

# Запуск playbook
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/install-packages.yml
```

## Основные функции

### Автоматическая настройка сервера

- Обновление системы
- Установка необходимых пакетов
- Настройка временной зоны
- Создание пользователей
- Настройка SSH

### Мониторинг

- Prometheus для сбора метрик
- Grafana для визуализации
- Node Exporter для системных метрик
- Настраиваемые дашборды
- Алерты и уведомления

### Бэкапы

- Автоматические ежедневные бэкапы
- Сжатие и шифрование
- Ротация старых бэкапов
- Восстановление из бэкапа
- Мониторинг бэкапов

### Безопасность

- Настройка UFW firewall
- Отключение ненужных сервисов
- Настройка SSH ключей
- Регулярные обновления безопасности
- Мониторинг безопасности

## Мониторинг

### Доступные метрики

- CPU использование
- Использование памяти
- Дисковое пространство
- Сетевая активность
- Статус сервисов
- Логи системы

### Дашборды Grafana

- System Overview
- Service Status
- Security Monitoring
- Backup Status
- Performance Metrics

## Безопасность

### Настроенные меры безопасности

- Firewall с ограниченными портами
- SSH с ключами вместо паролей
- Регулярные обновления безопасности
- Мониторинг подозрительной активности
- Логирование всех действий

### SSL/TLS сертификаты

- Автоматическое получение Let's Encrypt
- Автоматическое обновление
- Настройка для веб-серверов
- HSTS заголовки

## Устранение неполадок

### Частые проблемы

1. **Проблемы с правами доступа**
   ```bash
   sudo chmod +x scripts/*.sh
   ```

2. **Проблемы с Ansible**
   ```bash
   ansible --version
   pip install --upgrade ansible
   ```

3. **Проблемы с мониторингом**
   ```bash
   systemctl status prometheus
   systemctl status grafana-server
   ```

### Логи

- Системные логи: `/var/log/syslog`
- Логи скриптов: `/var/log/server-automation.log`
- Логи мониторинга: `/var/log/prometheus.log`

## Лицензия

MIT License - см. файл [LICENSE](LICENSE)

## Автор

**Ромадановский Виталий Денисович**
- GitHub: [@twinleq](https://github.com/twinleq)
- Email: twinleq@bk.ru
