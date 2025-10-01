@echo off
echo 🚀 Запуск DevOps Resume Platform локально...
echo.

cd /d "%~dp0app\src"

echo 📁 Переход в директорию: %CD%
echo 🌐 Запуск веб-сервера на порту 8080...
echo.

start powershell -ExecutionPolicy Bypass -Command "& {Write-Host '🚀 DevOps Resume Platform запущен!' -ForegroundColor Green; Write-Host '📍 URL: http://localhost:8080' -ForegroundColor Cyan; Write-Host '⏹️  Для остановки закройте это окно' -ForegroundColor Yellow; Write-Host '🧪 Тест иконок: http://localhost:8080/test-icons.html' -ForegroundColor Magenta; Write-Host ''; .\simple-server.ps1 -Port 8080}"

timeout /t 3 /nobreak > nul

echo 🌐 Открытие сайта в браузере...
start http://localhost:8080

echo.
echo ✅ Готово! Сайт должен открыться в браузере.
echo 💡 Если сайт не открылся, перейдите по адресу: http://localhost:8080
echo 🧪 Тест иконок: http://localhost:8080/test-icons.html
echo.
pause
