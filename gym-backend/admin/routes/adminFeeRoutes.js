const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    createAdminFee,
    getAdminFees,
    getAdminMemberFeeHistory,
    getAdminFee,
    updateAdminFee,
    deleteAdminFee,
    getAdminCurrentMonthFeeStatus
} = require('../controller/adminFeeController');


// Create Fee
router.post(
    '/fees',
    authMiddleware,
    roleMiddleware('ADMIN'),
    createAdminFee
);


// Get all fees
router.get(
    '/fees',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getAdminFees
);

router.get(
    '/fees/current-month',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getAdminCurrentMonthFeeStatus
);


// Get one member's complete fee history
router.get(
    '/fees/member/:memberId',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getAdminMemberFeeHistory
);


// Get one fee
router.get(
    '/fees/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getAdminFee
);


// Update fee
router.put(
    '/fees/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    updateAdminFee
);


// Delete fee
router.delete(
    '/fees/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    deleteAdminFee
);




module.exports = router;