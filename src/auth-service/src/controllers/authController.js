const User = require('../models/userModel');
const Session = require('../models/sessionModel');
const AuditLog = require('../models/auditLogModel');
const { generateAccessToken, generateRefreshToken, verifyToken } = require('../utils/jwt');
const logger = require('../utils/logger');
const speakeasy = require('speakeasy');
const QRCode = require('qrcode');

/**
 * Register a new user
 */
const register = async (req, res, next) => {
  try {
    const { username, email, password, firstName, lastName } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({
      where: { 
        [User.sequelize.Sequelize.Op.or]: [{ email }, { username }]
      }
    });

    if (existingUser) {
      await AuditLog.logEvent({
        action: 'register',
        status: 'failure',
        ipAddress: req.ip,
        userAgent: req.get('user-agent'),
        details: { reason: 'User already exists', email, username }
      });

      return res.status(409).json({ error: 'User already exists' });
    }

    // Create new user
    const user = await User.create({
      username,
      email,
      passwordHash: password, // Will be hashed by the model hook
      firstName,
      lastName
    });

    // Log successful registration
    await AuditLog.logEvent({
      userId: user.id,
      action: 'register',
      status: 'success',
      ipAddress: req.ip,
      userAgent: req.get('user-agent')
    });

    logger.info(`New user registered: ${username}`);

    res.status(201).json({
      message: 'User registered successfully',
      user: {
        id: user.id,
        username: user.username,
        email: user.email
      }
    });
  } catch (error) {
    logger.error('Registration error:', error);
    next(error);
  }
};

/**
 * Login user
 */
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // Find user
    const user = await User.findOne({ where: { email } });

    if (!user) {
      await AuditLog.logEvent({
        action: 'failed_login',
        status: 'failure',
        ipAddress: req.ip,
        userAgent: req.get('user-agent'),
        details: { reason: 'User not found', email }
      });

      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Check if account is locked
    if (user.isLocked()) {
      await AuditLog.logEvent({
        userId: user.id,
        action: 'failed_login',
        status: 'failure',
        ipAddress: req.ip,
        userAgent: req.get('user-agent'),
        details: { reason: 'Account locked' }
      });

      return res.status(423).json({ 
        error: 'Account locked', 
        lockedUntil: user.lockedUntil 
      });
    }

    // Validate password
    const isValidPassword = await user.validatePassword(password);

    if (!isValidPassword) {
      // Increment failed login attempts
      user.failedLoginAttempts += 1;

      // Lock account after 5 failed attempts
      if (user.failedLoginAttempts >= 5) {
        user.lockedUntil = new Date(Date.now() + 30 * 60 * 1000); // 30 minutes
      }

      await user.save();

      await AuditLog.logEvent({
        userId: user.id,
        action: 'failed_login',
        status: 'failure',
        ipAddress: req.ip,
        userAgent: req.get('user-agent'),
        details: { 
          reason: 'Invalid password',
          attempts: user.failedLoginAttempts 
        }
      });

      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Check if MFA is enabled
    if (user.mfaEnabled) {
      // Generate temporary token for MFA verification
      const mfaToken = generateAccessToken({ ...user.toJSON(), mfaVerified: false });
      
      return res.json({
        requiresMfa: true,
        mfaToken
      });
    }

    // Reset failed login attempts
    user.failedLoginAttempts = 0;
    user.lockedUntil = null;
    user.lastLogin = new Date();
    await user.save();

    // Generate tokens
    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);

    // Create session
    await Session.create({
      userId: user.id,
      tokenHash: Session.hashToken(refreshToken),
      ipAddress: req.ip,
      userAgent: req.get('user-agent'),
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 days
    });

    // Calculate risk score
    const { calculateRiskScore } = require('../utils/riskScoring');
    const riskScore = await calculateRiskScore(user, req, 'login');

    // Log successful login with risk score
    await AuditLog.logEvent({
      userId: user.id,
      action: 'login',
      status: 'success',
      ipAddress: req.ip,
      userAgent: req.get('user-agent'),
      riskScore
    });

    logger.info(`User logged in: ${user.username}`);

    res.json({
      message: 'Login successful',
      accessToken,
      refreshToken,
      user: user.toJSON()
    });
  } catch (error) {
    logger.error('Login error:', error);
    next(error);
  }
};

/**
 * Logout user
 */
const logout = async (req, res, next) => {
  try {
    const user = req.user;
    const refreshToken = req.body.refreshToken;

    if (refreshToken) {
      // Revoke session
      const tokenHash = Session.hashToken(refreshToken);
      await Session.update(
        { isRevoked: true },
        { where: { tokenHash, userId: user.id } }
      );
    }

    // Log logout
    await AuditLog.logEvent({
      userId: user.id,
      action: 'logout',
      status: 'success',
      ipAddress: req.ip,
      userAgent: req.get('user-agent')
    });

    logger.info(`User logged out: ${user.username}`);

    res.json({ message: 'Logout successful' });
  } catch (error) {
    logger.error('Logout error:', error);
    next(error);
  }
};

/**
 * Refresh access token
 */
const refreshToken = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({ error: 'Refresh token required' });
    }

    // Verify refresh token
    let payload;
    try {
      payload = verifyToken(refreshToken);
    } catch (error) {
      return res.status(401).json({ error: 'Invalid refresh token' });
    }

    // Check if token type is refresh
    if (payload.type !== 'refresh') {
      return res.status(401).json({ error: 'Invalid token type' });
    }

    // Check if session exists and is valid
    const tokenHash = Session.hashToken(refreshToken);
    const session = await Session.findOne({
      where: { tokenHash, userId: payload.sub }
    });

    if (!session || !session.isValid()) {
      return res.status(401).json({ error: 'Invalid or expired session' });
    }

    // Get user
    const user = await User.findByPk(payload.sub);

    if (!user || !user.isActive) {
      return res.status(401).json({ error: 'User not found or inactive' });
    }

    // Generate new access token
    const accessToken = generateAccessToken(user);

    // Log token refresh
    await AuditLog.logEvent({
      userId: user.id,
      action: 'token_refresh',
      status: 'success',
      ipAddress: req.ip,
      userAgent: req.get('user-agent')
    });

    res.json({ accessToken });
  } catch (error) {
    logger.error('Token refresh error:', error);
    next(error);
  }
};

/**
 * Get current user info
 */
const me = async (req, res, next) => {
  try {
    const user = req.user;
    res.json({ user: user.toJSON() });
  } catch (error) {
    logger.error('Get user info error:', error);
    next(error);
  }
};

/**
 * Enable MFA
 */
const enableMFA = async (req, res, next) => {
  try {
    const user = req.user;

    if (user.mfaEnabled) {
      return res.status(400).json({ error: 'MFA already enabled' });
    }

    // Generate MFA secret
    const secret = speakeasy.generateSecret({
      name: `ZeroTrust (${user.email})`,
      issuer: 'Zero-Trust Cloud Lab'
    });

    // Generate QR code
    const qrCodeUrl = await QRCode.toDataURL(secret.otpauth_url);

    // Save secret (temporarily)
    user.mfaSecret = secret.base32;
    await user.save();

    res.json({
      secret: secret.base32,
      qrCode: qrCodeUrl,
      message: 'Scan QR code with authenticator app and verify'
    });
  } catch (error) {
    logger.error('Enable MFA error:', error);
    next(error);
  }
};

/**
 * Verify MFA
 */
const verifyMFA = async (req, res, next) => {
  try {
    const { token, mfaToken } = req.body;

    // If called during login
    if (mfaToken) {
      const payload = verifyToken(mfaToken);
      const user = await User.findByPk(payload.sub);

      const verified = speakeasy.totp.verify({
        secret: user.mfaSecret,
        encoding: 'base32',
        token
      });

      if (!verified) {
        await AuditLog.logEvent({
          userId: user.id,
          action: 'failed_login',
          status: 'failure',
          ipAddress: req.ip,
          details: { reason: 'Invalid MFA token' }
        });

        return res.status(401).json({ error: 'Invalid MFA token' });
      }

      // Generate full tokens
      const accessToken = generateAccessToken(user);
      const refreshToken = generateRefreshToken(user);

      await Session.create({
        userId: user.id,
        tokenHash: Session.hashToken(refreshToken),
        ipAddress: req.ip,
        userAgent: req.get('user-agent'),
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
      });

      user.lastLogin = new Date();
      await user.save();

      await AuditLog.logEvent({
        userId: user.id,
        action: 'login',
        status: 'success',
        ipAddress: req.ip,
        details: { mfaVerified: true }
      });

      return res.json({
        message: 'MFA verification successful',
        accessToken,
        refreshToken,
        user: user.toJSON()
      });
    }

    // If called during MFA setup
    const user = req.user;

    const verified = speakeasy.totp.verify({
      secret: user.mfaSecret,
      encoding: 'base32',
      token
    });

    if (!verified) {
      return res.status(401).json({ error: 'Invalid MFA token' });
    }

    user.mfaEnabled = true;
    await user.save();

    await AuditLog.logEvent({
      userId: user.id,
      action: 'mfa_enable',
      status: 'success',
      ipAddress: req.ip
    });

    res.json({ message: 'MFA enabled successfully' });
  } catch (error) {
    logger.error('Verify MFA error:', error);
    next(error);
  }
};

/**
 * Validate token (internal endpoint for API gateway)
 */
const validateToken = async (req, res) => {
  try {
    const authHeader = req.get('Authorization');
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const token = authHeader.substring(7);
    const payload = verifyToken(token);

    // Get user to verify they still exist and are active
    const user = await User.findByPk(payload.sub);

    if (!user || !user.isActive) {
      return res.status(401).json({ error: 'Invalid user' });
    }

    // Set user ID in response header for API gateway
    res.set('X-User-ID', user.id);
    res.set('X-User-Role', user.role);

    res.status(200).json({ valid: true, userId: user.id });
  } catch (error) {
    logger.warn('Token validation failed:', error.message);
    res.status(401).json({ error: 'Invalid token' });
  }
};

module.exports = {
  register,
  login,
  logout,
  refreshToken,
  me,
  enableMFA,
  verifyMFA,
  validateToken
};

