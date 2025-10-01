# Simple test for DevOps Resume Platform
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
    Write-Host "✅ Health endpoint: Статус - $($healthData.status)" -ForegroundColor Green
} catch {
    Write-Host "❌ Health endpoint: Ошибка - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎉 Тестирование завершено!" -ForegroundColor Green
Write-Host "🌐 Откройте http://localhost:8081 в браузере для просмотра сайта" -ForegroundColor Cyan
