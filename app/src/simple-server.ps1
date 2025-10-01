# Simple PowerShell HTTP Server for DevOps Resume Platform
param(
    [int]$Port = 8080
)

# Create HTTP listener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()

Write-Host "🚀 DevOps Resume Platform запущен!" -ForegroundColor Green
Write-Host "📍 URL: http://localhost:$Port" -ForegroundColor Cyan
Write-Host "⏹️  Для остановки нажмите Ctrl+C" -ForegroundColor Yellow
Write-Host ""

# MIME types
$mimeTypes = @{
    '.html' = 'text/html; charset=utf-8'
    '.css'  = 'text/css'
    '.js'   = 'application/javascript'
    '.json' = 'application/json'
    '.ico'  = 'image/x-icon'
    '.png'  = 'image/png'
    '.jpg'  = 'image/jpeg'
    '.svg'  = 'image/svg+xml'
}

# API endpoints
$apiEndpoints = @{
    '/health' = @{
        status = 'healthy'
        timestamp = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ')
        uptime = 99.9
        response_time = 50
        deployments_today = 0
        version = '1.0.0'
    }
    '/metrics' = @'
# HELP resume_uptime_seconds Total uptime in seconds
# TYPE resume_uptime_seconds counter
resume_uptime_seconds 86400
# HELP resume_response_time_seconds Response time in seconds
# TYPE resume_response_time_seconds histogram
resume_response_time_seconds_bucket{le="0.1"} 100
resume_response_time_seconds_bucket{le="0.5"} 95
resume_response_time_seconds_bucket{le="1.0"} 90
resume_response_time_seconds_bucket{le="+Inf"} 85
resume_response_time_seconds_count 100
resume_response_time_seconds_sum 25.5
'@
}

function Get-FileContent {
    param([string]$FilePath)
    
    try {
        $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
        return $content
    }
    catch {
        return $null
    }
}

function Get-MimeType {
    param([string]$Extension)
    
    if ($mimeTypes.ContainsKey($Extension)) {
        return $mimeTypes[$Extension]
    }
    return 'text/plain'
}

function Send-Response {
    param(
        [System.Net.HttpListenerContext]$Context,
        [string]$Content,
        [string]$ContentType = 'text/html; charset=utf-8',
        [int]$StatusCode = 200
    )
    
    $response = $Context.Response
    $response.StatusCode = $StatusCode
    $response.ContentType = $ContentType
    $response.Headers.Add('Access-Control-Allow-Origin', '*')
    $response.Headers.Add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
    $response.Headers.Add('Access-Control-Allow-Headers', 'Content-Type')
    
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($Content)
    $response.ContentLength64 = $buffer.Length
    $response.OutputStream.Write($buffer, 0, $buffer.Length)
    $response.Close()
}

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $url = $request.Url.LocalPath
        
        Write-Host "$(Get-Date -Format 'HH:mm:ss') - $($request.HttpMethod) $url" -ForegroundColor Gray
        
        # Handle CORS preflight
        if ($request.HttpMethod -eq 'OPTIONS') {
            Send-Response -Context $context -Content '' -ContentType 'text/plain'
            continue
        }
        
        # API endpoints
        if ($apiEndpoints.ContainsKey($url)) {
            $endpoint = $apiEndpoints[$url]
            if ($url -eq '/health') {
                $json = $endpoint | ConvertTo-Json -Depth 3
                Send-Response -Context $context -Content $json -ContentType 'application/json'
            } elseif ($url -eq '/metrics') {
                Send-Response -Context $context -Content $endpoint -ContentType 'text/plain'
            }
            continue
        }
        
        # Default to index.html
        if ($url -eq '/' -or $url -eq '') {
            $url = '/index.html'
        }
        
        # Remove leading slash for file path
        $filePath = Join-Path $PSScriptRoot $url.TrimStart('/')
        
        # Check if file exists
        if (Test-Path $filePath -PathType Leaf) {
            $extension = [System.IO.Path]::GetExtension($filePath)
            $contentType = Get-MimeType -Extension $extension
            $content = Get-FileContent -FilePath $filePath
            
            if ($content -ne $null) {
                Send-Response -Context $context -Content $content -ContentType $contentType
            } else {
                Send-Response -Context $context -Content 'File read error' -ContentType 'text/plain' -StatusCode 500
            }
        } else {
            # 404 Not Found
            $notFoundContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>404 - Not Found</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        h1 { color: #e74c3c; }
    </style>
</head>
<body>
    <h1>404 - Страница не найдена</h1>
    <p>Запрашиваемый ресурс не найден.</p>
    <a href="/">← Вернуться на главную</a>
</body>
</html>
"@
            Send-Response -Context $context -Content $notFoundContent -ContentType 'text/html; charset=utf-8' -StatusCode 404
        }
    }
}
catch {
    Write-Host "Ошибка сервера: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    if ($listener.IsListening) {
        $listener.Stop()
    }
    Write-Host "`n🛑 Сервер остановлен" -ForegroundColor Yellow
}

