const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    getMyFees,
    getMyFee,
    getMyCurrentMonthFeeStatus,
    getMyPaidFeeHistory
} = require('../controller/memberFeeController');


// All member fees
router.get(
    '/fees',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getMyFees
);

// Current month payment status
router.get(
    '/fees/current-month/paid-status',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getMyCurrentMonthFeeStatus
);

// Paid fee history
router.get(
    '/fees/paid-history',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getMyPaidFeeHistory
);

// Individual fee — KEEP THIS LAST
router.get(
    '/fees/:id',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getMyFee
);

module.exports = router;