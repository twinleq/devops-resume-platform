# Docker Containerization

Примеры контейнеризации веб-приложений с Docker и best practices. Включает Dockerfile оптимизацию, multi-stage builds, Docker Compose и безопасность.

## Возможности

- ✅ Оптимизированные Dockerfile с multi-stage builds
- ✅ Docker Compose для разработки и продакшн
- ✅ Nginx reverse proxy конфигурация
- ✅ Безопасность контейнеров
- ✅ Мониторинг и логирование
- ✅ Автоматические обновления
- ✅ CI/CD интеграция

## Технологии

- **Docker** и Docker Compose
- **Nginx** reverse proxy
- **Linux** контейнеры
- **API** разработка
- **Multi-stage builds**
- **Security scanning**

## Структура проекта

```
docker-containerization/
├── web-app/
│   ├── Dockerfile              # Оптимизированный Dockerfile
│   ├── Dockerfile.multi-stage  # Multi-stage build
│   ├── docker-compose.yml      # Development environment
│   ├── docker-compose.prod.yml # Production environment
│   ├── nginx.conf              # Nginx configuration
│   ├── src/                    # Application source code
│   │   ├── app.py             # Python Flask app
│   │   ├── package.json       # Node.js app
│   │   ├── requirements.txt   # Python dependencies
│   │   └── static/            # Static files
│   └── tests/                  # Application tests
├── api-service/
│   ├── Dockerfile              # API service Dockerfile
│   ├── docker-compose.yml      # API service compose
│   ├── src/                    # API source code
│   │   ├── main.py            # FastAPI application
│   │   ├── requirements.txt   # Dependencies
│   │   └── models/            # Data models
│   └── tests/                  # API tests
├── examples/
│   ├── multi-stage-build/      # Multi-stage examples
│   ├── optimization/           # Optimization examples
│   ├── security/              # Security examples
│   └── monitoring/            # Monitoring examples
├── scripts/
│   ├── build.sh               # Build script
│   ├── deploy.sh              # Deployment script
│   ├── security-scan.sh       # Security scanning
│   └── cleanup.sh             # Cleanup script
├── monitoring/
│   ├── prometheus.yml         # Prometheus config
│   ├── grafana/               # Grafana dashboards
│   └── alerts/                # Alert rules
├── security/
│   ├── docker-security.md     # Security best practices
│   ├── scan-results/          # Security scan results
│   └── policies/              # Security policies
└── docs/
    ├── best-practices.md      # Docker best practices
    ├── optimization.md        # Optimization guide
    ├── security.md            # Security guide
    └── troubleshooting.md     # Troubleshooting guide
```

## Быстрый старт

### 1. Клонирование репозитория

```bash
git clone https://github.com/twinleq/docker-containerization.git
cd docker-containerization
```

### 2. Разработка (Development)

```bash
# Запуск веб-приложения для разработки
cd web-app
docker-compose up -d

# Запуск API сервиса
cd ../api-service
docker-compose up -d
```

### 3. Продакшн (Production)

```bash
# Сборка оптимизированных образов
./scripts/build.sh

# Развертывание в продакшн
./scripts/deploy.sh
```

## Примеры Dockerfile

### Базовый Dockerfile (Python Flask)

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Копирование и установка зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копирование приложения
COPY . .

# Создание непривилегированного пользователя
RUN useradd --create-home --shell /bin/bash app
USER app

# Открытие порта
EXPOSE 5000

# Запуск приложения
CMD ["python", "app.py"]
```

### Multi-stage Dockerfile (Node.js)

```dockerfile
# Stage 1: Build
FROM node:18-alpine AS builder

WORKDIR /app

# Копирование package.json и установка зависимостей
COPY package*.json ./
RUN npm ci --only=production

# Копирование исходного кода и сборка
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:18-alpine AS production

WORKDIR /app

# Установка только production зависимостей
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Копирование собранного приложения
COPY --from=builder /app/dist ./dist

# Создание пользователя
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs

# Открытие порта
EXPOSE 3000

# Запуск приложения
CMD ["node", "dist/server.js"]
```

## Docker Compose конфигурации

### Development Environment

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
    depends_on:
      - db
      - redis

  api:
    build: ./api-service
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/app
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=app
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - web
      - api

volumes:
  postgres_data:
  redis_data:
```

### Production Environment

```yaml
version: '3.8'

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.multi-stage
    restart: unless-stopped
    environment:
      - NODE_ENV=production
    depends_on:
      - db
      - redis
    networks:
      - app-network

  api:
    build:
      context: ./api-service
      dockerfile: Dockerfile
    restart: unless-stopped
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/app
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    networks:
      - app-network

  nginx:
    image: nginx:alpine
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.prod.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - web
      - api
    networks:
      - app-network

  db:
    image: postgres:15-alpine
    restart: unless-stopped
    environment:
      - POSTGRES_DB=app
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    volumes:
      - redis_data:/data
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  postgres_data:
  redis_data:
```

## Nginx конфигурация

```nginx
events {
    worker_connections 1024;
}

http {
    upstream web_backend {
        server web:3000;
    }

    upstream api_backend {
        server api:8000;
    }

    server {
        listen 80;
        server_name localhost;

        # Web application
        location / {
            proxy_pass http://web_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # API endpoints
        location /api/ {
            proxy_pass http://api_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Static files
        location /static/ {
            alias /var/www/static/;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
```

## Безопасность контейнеров

### Security Best Practices

1. **Используйте непривилегированных пользователей**
2. **Минимизируйте образы** (alpine, distroless)
3. **Сканируйте на уязвимости**
4. **Используйте multi-stage builds**
5. **Не храните секреты в образах**
6. **Регулярно обновляйте базовые образы**

### Security Scanning

```bash
# Сканирование на уязвимости
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy image your-image:latest

# Анализ зависимостей
docker run --rm -v $(pwd):/app \
    securecodewarrior/docker-security-scan /app
```

## Мониторинг и логирование

### Prometheus метрики

```python
from prometheus_client import Counter, Histogram, start_http_server

REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint'])
REQUEST_LATENCY = Histogram('http_request_duration_seconds', 'HTTP request latency')

@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    request_latency = time.time() - request.start_time
    REQUEST_LATENCY.observe(request_latency)
    REQUEST_COUNT.labels(method=request.method, endpoint=request.endpoint).inc()
    return response
```

### Логирование

```python
import logging
import json

# Настройка структурированного логирования
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

# Структурированные логи
logger.info(json.dumps({
    'event': 'request_completed',
    'method': request.method,
    'endpoint': request.endpoint,
    'status_code': response.status_code,
    'duration': request_latency
}))
```

## CI/CD интеграция

### GitHub Actions

```yaml
name: Docker Build and Deploy

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Docker image
        run: docker build -t your-app:${{ github.sha }} .
      
      - name: Security scan
        run: docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
             aquasec/trivy image your-app:${{ github.sha }}
      
      - name: Push to registry
        run: |
          docker tag your-app:${{ github.sha }} your-registry/your-app:latest
          docker push your-registry/your-app:latest
      
      - name: Deploy to production
        run: |
          docker-compose -f docker-compose.prod.yml up -d
```

## Устранение неполадок

### Частые проблемы

1. **Большой размер образа**
   ```bash
   # Используйте multi-stage builds
   # Очищайте кэш пакетного менеджера
   # Используйте .dockerignore
   ```

2. **Медленная сборка**
   ```bash
   # Используйте Docker layer caching
   # Оптимизируйте порядок команд
   # Используйте BuildKit
   ```

3. **Проблемы с сетью**
   ```bash
   # Проверьте Docker networks
   docker network ls
   docker network inspect bridge
   ```

### Полезные команды

```bash
# Анализ размера образа
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Просмотр слоев
docker history your-image:latest

# Мониторинг контейнеров
docker stats

# Логи контейнеров
docker logs -f container-name

# Вход в контейнер
docker exec -it container-name /bin/bash
```

## Лицензия

MIT License - см. файл [LICENSE](LICENSE)

## Автор

**Ромадановский Виталий Денисович**
- GitHub: [@twinleq](https://github.com/twinleq)
- Email: twinleq@bk.ru
