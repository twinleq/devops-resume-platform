# DevOps Resume Platform - Backend API
FROM node:18-alpine

# Метаданные
LABEL maintainer="Ромадановский Виталий Денисович <twinleq@bk.ru>"
LABEL description="DevOps Resume Platform Backend API"

# Создание директории приложения
WORKDIR /app

# Копирование package.json и package-lock.json
COPY package*.json ./

# Установка зависимостей
RUN npm ci --only=production

# Копирование исходного кода
COPY . .

# Создание непривилегированного пользователя
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Изменение владельца файлов
RUN chown -R nodejs:nodejs /app
USER nodejs

# Открытие порта
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3001/api/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Запуск приложения
CMD ["npm", "start"]
