const express = require('express');
const router = express.Router();
const { body, param } = require('express-validator');
const User = require('../models/userModel');
const AuditLog = require('../models/auditLogModel');
const { authenticate, authorize } = require('../middleware/authMiddleware');
const { validate } = require('../middleware/validationMiddleware');
const logger = require('../utils/logger');

/**
 * Get all users (admin only)
 */
router.get('/', authenticate, authorize(['admin']), async (req, res, next) => {
  try {
    const { page = 1, limit = 10, role, isActive } = req.query;
    const offset = (page - 1) * limit;

    const where = {};
    if (role) where.role = role;
    if (isActive !== undefined) where.isActive = isActive === 'true';

    const { count, rows: users } = await User.findAndCountAll({
      where,
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [['created_at', 'DESC']]
    });

    res.json({
      users,
      pagination: {
        total: count,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(count / limit)
      }
    });
  } catch (error) {
    logger.error('Get users error:', error);
    next(error);
  }
});

/**
 * Get user by ID
 */
router.get('/:id', 
  authenticate, 
  param('id').isUUID().withMessage('Invalid user ID'),
  validate,
  async (req, res, next) => {
    try {
      const { id } = req.params;
      const currentUser = req.user;

      // Users can only view their own profile unless they're admin
      if (currentUser.id !== id && currentUser.role !== 'admin') {
        return res.status(403).json({ error: 'Forbidden' });
      }

      const user = await User.findByPk(id);

      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      res.json({ user: user.toJSON() });
    } catch (error) {
      logger.error('Get user error:', error);
      next(error);
    }
  }
);

/**
 * Update user
 */
router.put('/:id',
  authenticate,
  [
    param('id').isUUID().withMessage('Invalid user ID'),
    body('firstName').optional().trim().isLength({ max: 50 }),
    body('lastName').optional().trim().isLength({ max: 50 }),
    body('email').optional().trim().isEmail().normalizeEmail()
  ],
  validate,
  async (req, res, next) => {
    try {
      const { id } = req.params;
      const currentUser = req.user;
      const { firstName, lastName, email } = req.body;

      // Users can only update their own profile unless they're admin
      if (currentUser.id !== id && currentUser.role !== 'admin') {
        return res.status(403).json({ error: 'Forbidden' });
      }

      const user = await User.findByPk(id);

      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      // Check if email is already taken
      if (email && email !== user.email) {
        const existingUser = await User.findOne({ where: { email } });
        if (existingUser) {
          return res.status(409).json({ error: 'Email already in use' });
        }
      }

      // Update user
      if (firstName !== undefined) user.firstName = firstName;
      if (lastName !== undefined) user.lastName = lastName;
      if (email !== undefined) user.email = email;

      await user.save();

      await AuditLog.logEvent({
        userId: currentUser.id,
        action: 'data_access',
        resource: `user:${id}`,
        status: 'success',
        ipAddress: req.ip,
        details: { action: 'update', fields: Object.keys(req.body) }
      });

      res.json({ 
        message: 'User updated successfully',
        user: user.toJSON()
      });
    } catch (error) {
      logger.error('Update user error:', error);
      next(error);
    }
  }
);

/**
 * Change password
 */
router.post('/:id/change-password',
  authenticate,
  [
    param('id').isUUID().withMessage('Invalid user ID'),
    body('currentPassword').notEmpty().withMessage('Current password required'),
    body('newPassword')
      .isLength({ min: 8 })
      .withMessage('Password must be at least 8 characters')
      .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
      .withMessage('Password must contain uppercase, lowercase, number, and special character')
  ],
  validate,
  async (req, res, next) => {
    try {
      const { id } = req.params;
      const currentUser = req.user;
      const { currentPassword, newPassword } = req.body;

      // Users can only change their own password
      if (currentUser.id !== id) {
        return res.status(403).json({ error: 'Forbidden' });
      }

      const user = await User.findByPk(id);

      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      // Verify current password
      const isValid = await user.validatePassword(currentPassword);

      if (!isValid) {
        await AuditLog.logEvent({
          userId: user.id,
          action: 'password_change',
          status: 'failure',
          ipAddress: req.ip,
          details: { reason: 'Invalid current password' }
        });

        return res.status(401).json({ error: 'Invalid current password' });
      }

      // Update password
      user.passwordHash = await User.hashPassword(newPassword);
      await user.save();

      await AuditLog.logEvent({
        userId: user.id,
        action: 'password_change',
        status: 'success',
        ipAddress: req.ip
      });

      logger.info(`Password changed for user: ${user.username}`);

      res.json({ message: 'Password changed successfully' });
    } catch (error) {
      logger.error('Change password error:', error);
      next(error);
    }
  }
);

/**
 * Deactivate user (admin only)
 */
router.post('/:id/deactivate',
  authenticate,
  authorize(['admin']),
  param('id').isUUID().withMessage('Invalid user ID'),
  validate,
  async (req, res, next) => {
    try {
      const { id } = req.params;
      const currentUser = req.user;

      // Can't deactivate yourself
      if (currentUser.id === id) {
        return res.status(400).json({ error: 'Cannot deactivate yourself' });
      }

      const user = await User.findByPk(id);

      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      user.isActive = false;
      await user.save();

      await AuditLog.logEvent({
        userId: currentUser.id,
        action: 'account_lock',
        resource: `user:${id}`,
        status: 'success',
        ipAddress: req.ip
      });

      logger.info(`User deactivated: ${user.username} by ${currentUser.username}`);

      res.json({ message: 'User deactivated successfully' });
    } catch (error) {
      logger.error('Deactivate user error:', error);
      next(error);
    }
  }
);

/**
 * Get user audit logs (admin or own logs)
 */
router.get('/:id/audit-logs',
  authenticate,
  param('id').isUUID().withMessage('Invalid user ID'),
  validate,
  async (req, res, next) => {
    try {
      const { id } = req.params;
      const currentUser = req.user;
      const { limit = 50, action, status } = req.query;

      // Users can only view their own logs unless they're admin
      if (currentUser.id !== id && currentUser.role !== 'admin') {
        return res.status(403).json({ error: 'Forbidden' });
      }

      const logs = await AuditLog.getSecurityEvents({
        userId: id,
        action,
        status,
        limit: parseInt(limit)
      });

      res.json({ logs });
    } catch (error) {
      logger.error('Get audit logs error:', error);
      next(error);
    }
  }
);

module.exports = router;

