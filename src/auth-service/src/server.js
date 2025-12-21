require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const { sequelize } = require('./config/database');
const logger = require('./utils/logger');
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const securityRoutes = require('./routes/securityRoutes');
const jitAccessRoutes = require('./routes/jitAccessRoutes');
const { errorHandler } = require('./middleware/errorMiddleware');

const app = express();
const PORT = process.env.PORT || 8081;

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});

// Health check endpoints (BEFORE rate limiting!)
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    service: 'auth-service'
  });
});

// Kubernetes health check endpoint
app.get('/healthz', (req, res) => {
  res.status(200).json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    service: 'auth-service',
    uptime: process.uptime()
  });
});

// Apply rate limiting AFTER health checks
app.use('/api/auth/login', rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5, // Stricter limit for login attempts
  message: 'Too many login attempts, please try again later.'
}));

app.use(limiter);

// Body parser
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path}`, {
    ip: req.ip,
    userAgent: req.get('user-agent')
  });
  next();
});

// ML Prediction endpoint for anomaly detection
app.get('/predict', async (req, res) => {
  try {
    // Example: Risk prediction based on authentication patterns
    // In production, this would call an actual ML model
    const { userId, ipAddress, userAgent } = req.query;
    
    // Simulate risk scoring algorithm
    const riskScore = Math.random() * 100;
    const prediction = {
      userId: userId || 'anonymous',
      risk_score: parseFloat(riskScore.toFixed(2)),
      risk_level: riskScore > 70 ? 'high' : riskScore > 40 ? 'medium' : 'low',
      confidence: parseFloat((Math.random() * 0.3 + 0.7).toFixed(2)), // 0.70-1.00
      factors: {
        suspicious_ip: riskScore > 50,
        unusual_time: riskScore > 60,
        new_device: riskScore > 70
      },
      recommendation: riskScore > 70 ? 'require_mfa' : 'allow',
      timestamp: new Date().toISOString(),
      model_version: 'v1.0'
    };
    
    logger.info('Prediction request processed', { 
      userId, 
      riskScore: prediction.risk_score,
      riskLevel: prediction.risk_level 
    });
    
    res.status(200).json(prediction);
  } catch (error) {
    logger.error('Prediction failed:', error);
    res.status(500).json({ 
      error: 'Prediction service unavailable',
      timestamp: new Date().toISOString()
    });
  }
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/security', securityRoutes);
app.use('/api/jit', jitAccessRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Error handler
app.use(errorHandler);

// Database connection and server start
const startServer = async () => {
  try {
    // Test database connection
    await sequelize.authenticate();
    logger.info('Database connection established successfully');

    // Sync database models (for this lab, always ensure tables exist)
    await sequelize.sync({ alter: true });
    logger.info('Database models synchronized');

    // Start server
    app.listen(PORT, () => {
      logger.info(`Auth Service running on port ${PORT}`);
      logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
    });
  } catch (error) {
    logger.error('Unable to start server:', error);
    process.exit(1);
  }
};

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  logger.error('Unhandled Rejection:', err);
  process.exit(1);
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  logger.error('Uncaught Exception:', err);
  process.exit(1);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down gracefully');
  await sequelize.close();
  process.exit(0);
});

startServer();

module.exports = app; // For testing

