# DevOps Resume Platform - Web Application Dockerfile
# Оптимизированный Dockerfile с best practices

# Используем официальный Node.js образ
FROM node:18-alpine

# Метаданные образа
LABEL maintainer="Ромадановский Виталий Денисович <twinleq@bk.ru>"
LABEL description="DevOps Resume Platform Web Application"
LABEL version="1.0.0"

# Установка рабочей директории
WORKDIR /app

# Создание пользователя для безопасности
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Установка системных зависимостей
RUN apk add --no-cache \
    dumb-init \
    && rm -rf /var/cache/apk/*

# Копирование файлов зависимостей
COPY package*.json ./

# Установка зависимостей
RUN npm ci --only=production && \
    npm cache clean --force

# Копирование исходного кода
COPY . .

# Изменение владельца файлов
RUN chown -R nextjs:nodejs /app

# Переключение на непривилегированного пользователя
USER nextjs

# Открытие порта
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Запуск приложения через dumb-init
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]
