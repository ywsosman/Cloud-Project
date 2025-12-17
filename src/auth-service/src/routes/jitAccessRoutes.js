const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const { authenticate } = require('../middleware/authMiddleware');
const { validate } = require('../middleware/validationMiddleware');
const jitAccessController = require('../controllers/jitAccessController');

const jitRequestValidation = [
  body('reason')
    .trim()
    .isLength({ min: 10, max: 500 })
    .withMessage('Reason must be between 10 and 500 characters'),
  body('duration')
    .optional()
    .isInt({ min: 15, max: 240 })
    .withMessage('Duration must be between 15 and 240 minutes')
];

/**
 * Request Just-In-Time elevated access
 * POST /api/jit/request
 */
router.post(
  '/request',
  authenticate,
  jitRequestValidation,
  validate,
  jitAccessController.requestElevatedAccess
);

module.exports = router;

