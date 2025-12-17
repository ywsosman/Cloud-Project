const AuditLog = require('../models/auditLogModel');
const logger = require('../utils/logger');

/**
 * Calculate risk score for a user action based on multiple factors
 * Returns a score from 0-100 (0 = low risk, 100 = high risk)
 */
const calculateRiskScore = async (user, req, action = 'api_call') => {
  let riskScore = 0;

  try {
    // Factor 1: Failed login attempts (0-25 points)
    if (user.failedLoginAttempts > 0) {
      riskScore += Math.min(25, user.failedLoginAttempts * 5);
    }

    // Factor 2: Account lock status (0-20 points)
    if (user.lockedUntil && user.lockedUntil > new Date()) {
      riskScore += 20;
    }

    // Factor 3: Recent failed logins (0-20 points)
    const recentFailures = await AuditLog.count({
      where: {
        userId: user.id,
        action: 'failed_login',
        status: 'failure',
        timestamp: {
          [require('sequelize').Op.gte]: new Date(Date.now() - 60 * 60 * 1000) // Last hour
        }
      }
    });
    riskScore += Math.min(20, recentFailures * 4);

    // Factor 4: Unusual access pattern (0-15 points)
    const lastLogin = user.lastLogin;
    if (lastLogin) {
      const timeSinceLastLogin = Date.now() - new Date(lastLogin).getTime();
      const hoursSinceLogin = timeSinceLastLogin / (1000 * 60 * 60);
      
      // Suspicious if logging in very quickly after previous login
      if (hoursSinceLogin < 0.1 && action === 'login') {
        riskScore += 15;
      }
    }

    // Factor 5: MFA status (0-10 points)
    if (!user.mfaEnabled && action === 'login') {
      riskScore += 10; // Higher risk without MFA
    }

    // Factor 6: Account age (0-10 points)
    const accountAge = Date.now() - new Date(user.createdAt).getTime();
    const daysSinceCreation = accountAge / (1000 * 60 * 60 * 24);
    if (daysSinceCreation < 1) {
      riskScore += 10; // New accounts are riskier
    }

    // Factor 7: IP address changes (basic check)
    // In production, you'd check against known IPs
    // For now, we'll use a simple heuristic

    // Normalize to 0-100
    riskScore = Math.min(100, Math.max(0, riskScore));

    // Log risk assessment
    await AuditLog.logEvent({
      userId: user.id,
      action: 'risk_assessment',
      status: riskScore > 50 ? 'warning' : 'success',
      ipAddress: req.ip,
      userAgent: req.get('user-agent'),
      riskScore,
      details: {
        action,
        factors: {
          failedAttempts: user.failedLoginAttempts,
          isLocked: !!(user.lockedUntil && user.lockedUntil > new Date()),
          recentFailures,
          mfaEnabled: user.mfaEnabled
        }
      }
    });

    return riskScore;
  } catch (error) {
    logger.error('Risk scoring error:', error);
    // Return moderate risk if calculation fails
    return 50;
  }
};

/**
 * Get risk level category
 */
const getRiskLevel = (score) => {
  if (score >= 75) return 'critical';
  if (score >= 50) return 'high';
  if (score >= 25) return 'medium';
  return 'low';
};

/**
 * Check if action should be blocked based on risk score
 */
const shouldBlockAction = (riskScore, threshold = 75) => {
  return riskScore >= threshold;
};

module.exports = {
  calculateRiskScore,
  getRiskLevel,
  shouldBlockAction
};

