const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '../app/src')));

// Database connection
const pool = new Pool({
  user: process.env.DB_USER || 'resume_user',
  host: process.env.DB_HOST || 'postgres',
  database: process.env.DB_NAME || 'resume_db',
  password: process.env.DB_PASSWORD || 'strong_password',
  port: process.env.DB_PORT || 5432,
});

// Server start time for uptime calculation
const serverStartTime = Date.now();

// Initialize database
async function initializeDatabase() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS messages (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) NOT NULL,
        message TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Database initialized successfully');
  } catch (error) {
    console.error('❌ Database initialization failed:', error);
  }
}

// Routes
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    uptime: Math.floor((Date.now() - serverStartTime) / 1000),
    timestamp: new Date().toISOString()
  });
});

app.get('/api/metrics', (req, res) => {
  const uptimeSeconds = Math.floor((Date.now() - serverStartTime) / 1000);
  const uptimeHours = Math.floor(uptimeSeconds / 3600);
  const uptimeMinutes = Math.floor((uptimeSeconds % 3600) / 60);
  
  res.json({
    uptime: `${uptimeHours}h ${uptimeMinutes}m`,
    uptime_seconds: uptimeSeconds,
    response_time: Math.floor(Math.random() * 50) + 10, // Simulated response time
    deployments_today: 1
  });
});

app.post('/api/contact', async (req, res) => {
  try {
    const { name, email, message } = req.body;
    
    // Validation
    if (!name || !email || !message) {
      return res.status(400).json({ 
        success: false, 
        error: 'Все поля обязательны для заполнения' 
      });
    }
    
    // Email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ 
        success: false, 
        error: 'Некорректный email адрес' 
      });
    }
    
    // Save to database
    const result = await pool.query(
      'INSERT INTO messages (name, email, message) VALUES ($1, $2, $3) RETURNING id',
      [name, email, message]
    );
    
    console.log(`📧 New message received from ${name} (${email})`);
    
    res.json({ 
      success: true, 
      message: 'Сообщение успешно отправлено!',
      messageId: result.rows[0].id
    });
    
  } catch (error) {
    console.error('❌ Error saving message:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Ошибка при сохранении сообщения' 
    });
  }
});

app.get('/api/messages', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT name, email, message, created_at FROM messages ORDER BY created_at DESC LIMIT 10'
    );
    res.json({ messages: result.rows });
  } catch (error) {
    console.error('❌ Error fetching messages:', error);
    res.status(500).json({ error: 'Ошибка при получении сообщений' });
  }
});

// Serve static files
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../app/src/index.html'));
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Что-то пошло не так!' });
});

// Start server
app.listen(PORT, async () => {
  console.log(`🚀 Server running on port ${PORT}`);
  await initializeDatabase();
});

module.exports = app;
