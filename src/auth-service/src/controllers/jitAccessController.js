const User = require('../models/userModel');
const AuditLog = require('../models/auditLogModel');
const { generateAccessToken } = require('../utils/jwt');
const logger = require('../utils/logger');

/**
 * Request Just-In-Time (JIT) elevated access
 * Allows users to request temporary elevated permissions
 */
const requestElevatedAccess = async (req, res, next) => {
  try {
    const user = req.user;
    const { reason, duration = 60 } = req.body; // duration in minutes

    // Validate duration (max 4 hours)
    const maxDuration = 240; // 4 hours
    const requestedDuration = Math.min(parseInt(duration), maxDuration);

    if (!reason || reason.trim().length < 10) {
      return res.status(400).json({
        error: 'Reason required (minimum 10 characters)'
      });
    }

    // Check if user already has elevated access
    if (user.role === 'admin') {
      return res.status(400).json({
        error: 'You already have admin access'
      });
    }

    // Log the request
    await AuditLog.logEvent({
      userId: user.id,
      action: 'jit_access_request',
      status: 'success',
      ipAddress: req.ip,
      userAgent: req.get('user-agent'),
      details: {
        reason,
        requestedDuration,
        currentRole: user.role
      },
      riskScore: calculateRiskScore(user, req)
    });

    // For demo purposes, auto-approve with admin role temporarily
    // In production, this would require admin approval
    const expiresAt = new Date(Date.now() + requestedDuration * 60 * 1000);

    // Generate elevated token (with admin claims)
    const elevatedToken = generateAccessToken({
      ...user.toJSON(),
      role: 'admin',
      elevated: true,
      elevatedUntil: expiresAt.toISOString()
    });

    logger.info(`JIT access granted to ${user.username} for ${requestedDuration} minutes`);

    res.json({
      message: 'Elevated access granted',
      accessToken: elevatedToken,
      expiresAt,
      duration: requestedDuration,
      note: 'This is a demo implementation. Production would require admin approval.'
    });
  } catch (error) {
    logger.error('JIT access request error:', error);
    next(error);
  }
};

/**
 * Calculate risk score based on user behavior and context
 */
const calculateRiskScore = (user, req) => {
  let riskScore = 0;

  // Check failed login attempts
  if (user.failedLoginAttempts > 0) {
    riskScore += user.failedLoginAttempts * 5;
  }

  // Check if account was recently locked
  if (user.lockedUntil && user.lockedUntil > new Date()) {
    riskScore += 20;
  }

  // Check last login time (suspicious if very recent after lockout)
  if (user.lastLogin) {
    const timeSinceLastLogin = Date.now() - new Date(user.lastLogin).getTime();
    const minutesSinceLogin = timeSinceLastLogin / (1000 * 60);
    
    if (minutesSinceLogin < 5 && user.failedLoginAttempts > 0) {
      riskScore += 15;
    }
  }

  // Normalize to 0-100 scale
  return Math.min(100, Math.max(0, riskScore));
};

module.exports = {
  requestElevatedAccess,
  calculateRiskScore
};

