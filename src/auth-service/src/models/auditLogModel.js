const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const User = require('./userModel');

const AuditLog = sequelize.define('AuditLog', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  userId: {
    type: DataTypes.UUID,
    field: 'user_id',
    references: {
      model: User,
      key: 'id'
    },
    onDelete: 'SET NULL'
  },
  action: {
    type: DataTypes.STRING(50),
    allowNull: false,
    validate: {
      isIn: [[
        'login', 'logout', 'register', 'password_change',
        'mfa_enable', 'mfa_disable', 'token_refresh',
        'account_lock', 'account_unlock', 'permission_change',
        'data_access', 'api_call', 'failed_login',
        'jit_access_request', 'risk_assessment'
      ]]
    }
  },
  resource: {
    type: DataTypes.STRING(100)
  },
  ipAddress: {
    type: DataTypes.STRING(45),
    field: 'ip_address'
  },
  userAgent: {
    type: DataTypes.TEXT,
    field: 'user_agent'
  },
  status: {
    type: DataTypes.ENUM('success', 'failure', 'warning'),
    allowNull: false
  },
  details: {
    type: DataTypes.JSONB,
    defaultValue: {}
  },
  riskScore: {
    type: DataTypes.FLOAT,
    field: 'risk_score',
    validate: {
      min: 0,
      max: 100
    }
  }
}, {
  tableName: 'audit_logs',
  timestamps: true,
  underscored: true,
  createdAt: 'timestamp',
  updatedAt: false,
  indexes: [
    { fields: ['user_id'] },
    { fields: ['timestamp'] },
    { fields: ['action'] },
    { fields: ['status'] }
  ]
});

// Associations
AuditLog.belongsTo(User, { foreignKey: 'userId', as: 'user' });
User.hasMany(AuditLog, { foreignKey: 'userId', as: 'auditLogs' });

// Class methods
AuditLog.logEvent = async function(data) {
  try {
    return await AuditLog.create(data);
  } catch (error) {
    console.error('Failed to create audit log:', error);
    // Don't throw - audit logging shouldn't break the application
  }
};

AuditLog.getSecurityEvents = async function(options = {}) {
  const { userId, startDate, endDate, action, status, limit = 100 } = options;
  
  const where = {};
  
  if (userId) where.userId = userId;
  if (action) where.action = action;
  if (status) where.status = status;
  
  if (startDate || endDate) {
    where.timestamp = {};
    if (startDate) where.timestamp[sequelize.Sequelize.Op.gte] = startDate;
    if (endDate) where.timestamp[sequelize.Sequelize.Op.lte] = endDate;
  }
  
  return await AuditLog.findAll({
    where,
    limit,
    order: [['timestamp', 'DESC']],
    include: [{
      model: User,
      as: 'user',
      attributes: ['id', 'username', 'email']
    }]
  });
};

module.exports = AuditLog;

