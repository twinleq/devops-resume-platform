#!/bin/bash

echo "🔒 Настройка SSL сертификатов для romadanovsky.ru"
echo "=================================================="

# Проверка DNS
echo "📡 Проверка DNS..."
if nslookup romadanovsky.ru > /dev/null 2>&1; then
    echo "✅ DNS разрешается корректно"
else
    echo "❌ DNS не разрешается. Проверьте настройки DNS."
    exit 1
fi

# Установка Certbot
echo "📦 Установка Certbot..."
apt update
apt install -y certbot

# Остановка Nginx для получения сертификата
echo "⏹️ Остановка Nginx..."
docker stop nginx

# Получение SSL сертификата
echo "🔐 Получение SSL сертификата..."
certbot certonly \
    --standalone \
    --non-interactive \
    --agree-tos \
    --email twinleq@bk.ru \
    -d romadanovsky.ru \
    -d www.romadanovsky.ru

# Проверка сертификата
if [ -f "/etc/letsencrypt/live/romadanovsky.ru/fullchain.pem" ]; then
    echo "✅ SSL сертификат получен успешно"
    echo "📁 Сертификат находится в: /etc/letsencrypt/live/romadanovsky.ru/"
else
    echo "❌ Не удалось получить SSL сертификат"
    exit 1
fi

# Настройка автообновления
echo "🔄 Настройка автообновления сертификатов..."
cat > /etc/cron.d/certbot-renew << EOF
0 12 * * * root certbot renew --quiet --post-hook "docker restart nginx"
EOF

# Обновление проекта
echo "📥 Обновление проекта..."
cd /opt/devops-resume
git pull origin main

# Запуск с HTTPS
echo "🚀 Запуск сервисов с HTTPS..."
docker-compose -f docker-compose-full.yml down
docker-compose -f docker-compose-full.yml up -d

# Проверка статуса
echo "📊 Проверка статуса сервисов..."
docker ps

# Проверка HTTPS
echo "🔍 Проверка HTTPS..."
sleep 10
if curl -k https://romadanovsky.ru/health > /dev/null 2>&1; then
    echo "✅ HTTPS работает!"
    echo "🌐 Ваш сайт доступен по адресу: https://romadanovsky.ru"
    echo "📊 Grafana: https://grafana.romadanovsky.ru"
    echo "📈 Prometheus: https://prometheus.romadanovsky.ru"
else
    echo "⚠️ HTTPS пока не работает. Проверьте логи:"
    echo "docker logs nginx"
fi

echo ""
echo "🎉 Настройка SSL завершена!"
echo "📧 Если что-то не работает, проверьте логи:"
echo "   docker logs nginx"
echo "   docker logs backend-api"
