# DevOps Resume Platform - Production Dockerfile
FROM nginx:alpine

# Метаданные
LABEL maintainer="Ромадановский Виталий Денисович <twinleq@bk.ru>"
LABEL description="DevOps Resume Platform Production Build"
LABEL version="1.0.0"

# Удаление дефолтной конфигурации nginx
RUN rm /etc/nginx/conf.d/default.conf

# Копирование конфигурации nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Копирование статических файлов
COPY src/ /usr/share/nginx/html/

# Создание пользователя для безопасности
RUN addgroup -g 1001 -S appuser && \
    adduser -S appuser -u 1001

# Изменение владельца файлов
RUN chown -R appuser:appuser /usr/share/nginx/html

# Переключение на непривилегированного пользователя
USER appuser

# Открытие порта
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/health || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]


