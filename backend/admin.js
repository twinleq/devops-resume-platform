const express = require('express');
const { Pool } = require('pg');
const path = require('path');

const app = express();
const port = process.env.ADMIN_PORT || 3002;

// PostgreSQL connection pool
const pool = new Pool({
    user: process.env.PGUSER || 'resume_user',
    host: process.env.PGHOST || 'postgres',
    database: process.env.PGDATABASE || 'resume_db',
    password: process.env.PGPASSWORD || 'strong_password',
    port: process.env.PGPORT || 5432,
});

// Middleware
app.use(express.json());
app.use(express.static('public'));

// Simple admin page
app.get('/', (req, res) => {
    res.send(`
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Админ панель - Сообщения</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #333; border-bottom: 2px solid #007bff; padding-bottom: 10px; }
        .message { background: #f8f9fa; border: 1px solid #dee2e6; border-radius: 5px; padding: 15px; margin: 10px 0; }
        .message-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }
        .message-name { font-weight: bold; color: #007bff; }
        .message-email { color: #6c757d; font-size: 0.9em; }
        .message-date { color: #6c757d; font-size: 0.8em; }
        .message-text { margin-top: 10px; line-height: 1.5; }
        .stats { background: #e3f2fd; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
        .refresh-btn { background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; margin-bottom: 20px; }
        .refresh-btn:hover { background: #0056b3; }
        .no-messages { text-align: center; color: #6c757d; font-style: italic; padding: 40px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📧 Админ панель - Входящие сообщения</h1>
        <button class="refresh-btn" onclick="location.reload()">🔄 Обновить</button>
        <div id="stats" class="stats"></div>
        <div id="messages"></div>
    </div>

    <script>
        async function loadMessages() {
            try {
                const response = await fetch('/api/messages');
                const data = await response.json();
                
                // Обновляем статистику
                document.getElementById('stats').innerHTML = \`
                    <strong>📊 Статистика:</strong> Всего сообщений: \${data.total} | 
                    Последнее сообщение: \${data.latest ? new Date(data.latest.created_at).toLocaleString('ru-RU') : 'Нет сообщений'}
                \`;
                
                // Отображаем сообщения
                const messagesDiv = document.getElementById('messages');
                if (data.messages.length === 0) {
                    messagesDiv.innerHTML = '<div class="no-messages">📭 Сообщений пока нет</div>';
                } else {
                    messagesDiv.innerHTML = data.messages.map(msg => \`
                        <div class="message">
                            <div class="message-header">
                                <div>
                                    <span class="message-name">👤 \${msg.name}</span>
                                    <span class="message-email">(\${msg.email})</span>
                                </div>
                                <div class="message-date">\${new Date(msg.created_at).toLocaleString('ru-RU')}</div>
                            </div>
                            <div class="message-text">\${msg.message.replace(/\\n/g, '<br>')}</div>
                        </div>
                    \`).join('');
                }
            } catch (error) {
                console.error('Ошибка загрузки сообщений:', error);
                document.getElementById('messages').innerHTML = '<div class="no-messages">❌ Ошибка загрузки сообщений</div>';
            }
        }

        // Загружаем сообщения при загрузке страницы
        loadMessages();
        
        // Обновляем каждые 30 секунд
        setInterval(loadMessages, 30000);
    </script>
</body>
</html>
    `);
});

// API endpoint для получения сообщений
app.get('/api/messages', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT id, name, email, message, created_at
            FROM messages 
            ORDER BY created_at DESC 
            LIMIT 50
        `);
        
        const countResult = await pool.query('SELECT COUNT(*) as total FROM messages');
        const latestResult = await pool.query('SELECT created_at FROM messages ORDER BY created_at DESC LIMIT 1');
        
        res.json({
            messages: result.rows,
            total: countResult.rows[0].total,
            latest: latestResult.rows[0] || null
        });
    } catch (err) {
        console.error('Error fetching messages:', err);
        res.status(500).json({ error: 'Failed to fetch messages' });
    }
});

// API endpoint для удаления сообщения
app.delete('/api/messages/:id', async (req, res) => {
    try {
        await pool.query('DELETE FROM messages WHERE id = $1', [req.params.id]);
        res.json({ success: true });
    } catch (err) {
        console.error('Error deleting message:', err);
        res.status(500).json({ error: 'Failed to delete message' });
    }
});

app.listen(port, () => {
    console.log(`Admin panel running on port ${port}`);
});
