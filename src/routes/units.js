const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');
const jwt = require('jsonwebtoken');

const dbPath = path.join(__dirname, '../../db.json');
const JWT_SECRET = 'fuel-tracker-secret-key-2026';

const readDB = () => {
    try {
        const data = fs.readFileSync(dbPath, 'utf8');
        return JSON.parse(data);
    } catch (error) {
        return { users: [], units: [], fuelEntries: [] };
    }
};

// Middleware untuk verifikasi token
const verifyToken = (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ success: false, message: 'No token provided' });
    }
    
    const token = authHeader.substring(7);
    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded;
        next();
    } catch (error) {
        return res.status(401).json({ success: false, message: 'Invalid token' });
    }
};

// GET /api/units
router.get('/', verifyToken, (req, res) => {
    const db = readDB();
    res.json({
        success: true,
        data: db.units
    });
});

// GET /api/units/:code
router.get('/:code', verifyToken, (req, res) => {
    const db = readDB();
    const unit = db.units.find(u => u.unit_code === req.params.code);
    
    if (!unit) {
        return res.status(404).json({
            success: false,
            message: 'Unit not found'
        });
    }
    
    res.json({
        success: true,
        data: unit
    });
});

module.exports = router;