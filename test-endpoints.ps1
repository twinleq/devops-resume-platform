# Test script for DevOps Resume Platform endpoints
Write-Host "🧪 Тестирование DevOps Resume Platform" -ForegroundColor Green
Write-Host ""

# Test main page
Write-Host "1. Тестирование главной страницы..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081" -UseBasicParsing -TimeoutSec 5
    Write-Host "✅ Главная страница: HTTP $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Главная страница: Ошибка - $($_.Exception.Message)" -ForegroundColor Red
}

# Test health endpoint
Write-Host "2. Тестирование health endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/health" -UseBasicParsing -TimeoutSec 5
    $healthData = $response.Content | ConvertFrom-Json
    Write-Host "✅ Health endpoint: Статус - $($healthData.status), Uptime - $($healthData.uptime)%" -ForegroundColor Green
} catch {
    Write-Host "❌ Health endpoint: Ошибка - $($_.Exception.Message)" -ForegroundColor Red
}

# Test metrics endpoint
Write-Host "3. Тестирование metrics endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/metrics" -UseBasicParsing -TimeoutSec 5
    Write-Host "✅ Metrics endpoint: Получено $($response.Content.Length) байт данных" -ForegroundColor Green
} catch {
    Write-Host "❌ Metrics endpoint: Ошибка - $($_.Exception.Message)" -ForegroundColor Red
}

# Test CSS
Write-Host "4. Тестирование CSS файла..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/styles.css" -UseBasicParsing -TimeoutSec 5
    Write-Host "✅ CSS файл: HTTP $($response.StatusCode), Content-Type - $($response.Headers.'Content-Type')" -ForegroundColor Green
} catch {
    Write-Host "❌ CSS файл: Ошибка - $($_.Exception.Message)" -ForegroundColor Red
}

# Test JavaScript
Write-Host "5. Тестирование JavaScript файла..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/script.js" -UseBasicParsing -TimeoutSec 5
    Write-Host "✅ JavaScript файл: HTTP $($response.StatusCode), Content-Type - $($response.Headers.'Content-Type')" -ForegroundColor Green
} catch {
    Write-Host "❌ JavaScript файл: Ошибка - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎉 Тестирование завершено!" -ForegroundColor Green
Write-Host "🌐 Откройте http://localhost:8081 в браузере для просмотра сайта" -ForegroundColor Cyan
