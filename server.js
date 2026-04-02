const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors({
    origin: '*',
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Import routes
const authRoutes = require('./src/routes/auth');
const unitsRoutes = require('./src/routes/units');

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/units', unitsRoutes);

// Health check
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        environment: 'development'
    });
});

// Test endpoint
app.get('/api/test', (req, res) => {
    res.json({ message: 'API is working!', timestamp: new Date().toISOString() });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        success: false,
        error: 'Not Found',
        path: req.path
    });
});

// Start server
app.listen(PORT, () => {
    console.log(`
╔═══════════════════════════════════════════════════════════╗
║     FUEL TRACKER SYSTEM - BACKEND API (JSON Database)     ║
╠═══════════════════════════════════════════════════════════╣
║  Server running on: http://localhost:${PORT}                  ║
║  Health check: http://localhost:${PORT}/health                ║
║  Test API:     http://localhost:${PORT}/api/test              ║
╠═══════════════════════════════════════════════════════════╣
║  Login credentials:                                         ║
║    Admin:      admin / admin123                             ║
║    Operator:   opr001 / password123                         ║
║    Fuelman:    fml001 / password123                         ║
║    Supervisor: spv001 / password123                         ║
╚═══════════════════════════════════════════════════════════╝
    `);
});