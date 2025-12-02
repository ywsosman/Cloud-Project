const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/authMiddleware');
const { getActivityLogs } = require('../controllers/securityController');

// Zero‑trust: only authenticated users can see security data
router.get('/activity-logs', authenticate, getActivityLogs);

module.exports = router;


