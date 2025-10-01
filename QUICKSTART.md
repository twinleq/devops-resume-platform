# 🚀 Быстрый запуск DevOps Resume Platform

## Локальный запуск (Windows)

### Способ 1: Автоматический запуск
1. Запустите файл `start-local.bat` (двойной клик)
2. Сайт автоматически откроется в браузере по адресу http://localhost:8080

### Способ 2: Ручной запуск
1. Откройте PowerShell в папке `app/src`
2. Выполните команду:
   ```powershell
   powershell -ExecutionPolicy Bypass -File simple-server.ps1
   ```
3. Откройте браузер и перейдите на http://localhost:8080

### Способ 3: Прямое открытие HTML
1. Перейдите в папку `app/src`
2. Откройте файл `index.html` в браузере
3. ⚠️ Некоторые функции (API endpoints) могут не работать

## Что вы увидите

- ✅ **Современное резюме** с responsive дизайном
- ✅ **Интерактивные элементы** и анимации
- ✅ **Health check** статус в реальном времени
- ✅ **Метрики производительности**
- ✅ **Технологический стек** с иконками

## API Endpoints

- `GET /health` - Статус приложения
- `GET /metrics` - Метрики в формате Prometheus
- `GET /` - Главная страница

## Структура проекта

```
devops-resume-platform/
├── app/src/              # Веб-приложение
│   ├── index.html       # Главная страница
│   ├── styles.css       # Стили
│   ├── script.js        # JavaScript
│   └── simple-server.ps1 # Локальный сервер
├── k8s/                 # Kubernetes манифесты
├── terraform/           # Infrastructure as Code
├── .github/workflows/   # CI/CD pipelines
├── monitoring/          # Мониторинг
└── docs/               # Документация
```

## Следующие шаги

1. **Изучите код** в папке `app/src/`
2. **Прочитайте документацию** в папке `docs/`
3. **Настройте CI/CD** в `.github/workflows/`
4. **Разверните в облаке** используя `terraform/`

## Проблемы?

- Убедитесь, что порт 8080 свободен
- Проверьте, что PowerShell может выполнять скрипты
- Попробуйте другой порт: `simple-server.ps1 -Port 8081`

## 🎯 Цель проекта

Этот проект демонстрирует:
- ✅ Современные веб-технологии
- ✅ DevOps практики и автоматизацию
- ✅ Infrastructure as Code
- ✅ CI/CD pipelines
- ✅ Мониторинг и логирование
- ✅ Безопасность и масштабируемость

**Идеальный проект для резюме DevOps Engineer!** 🚀
