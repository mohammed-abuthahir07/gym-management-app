const express = require('express');

const router = express.Router();

const {
    getMemberDashboard,
    getTrainerDashboard,
    getPlanDashboard,
    getPromotionDashboard,
    getChallengeDashboard,

    getRecentPlans,
    getRecentPromotions,
    getRecentChallenges,

    getAdminCurrentMonthRevenue,
    getAdminCurrentYearRevenue,
    getAdminTotalRevenue
} = require('../controller/adminDashboardController');

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');


// ========================================
// DASHBOARD COUNTS
// ========================================

router.get(
    '/member',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getMemberDashboard
);

router.get(
    '/trainer',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getTrainerDashboard
);

router.get(
    '/plan',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getPlanDashboard
);

router.get(
    '/promotion',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getPromotionDashboard
);

router.get(
    '/challenge',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getChallengeDashboard
);


// ========================================
// DASHBOARD REVENUE
// ========================================

router.get(
    '/current-month-revenue',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getAdminCurrentMonthRevenue
);

router.get(
    '/current-year-revenue',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getAdminCurrentYearRevenue
);
router.get(
    '/total-revenue',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getAdminTotalRevenue
);

// ========================================
// RECENT DATA
// ========================================

router.get(
    '/recent/plan',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getRecentPlans
);

router.get(
    '/recent/promotion',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getRecentPromotions
);

router.get(
    '/recent/challenge',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getRecentChallenges
);


module.exports = router;