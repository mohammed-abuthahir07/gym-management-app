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
    getRecentChallenges
} = require('../controller/adminDashboardController');

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');


// ========================================
// DASHBOARD COUNTS
// ========================================

router.get('/member',authMiddleware,roleMiddleware('ADMIN'),getMemberDashboard);
router.get('/trainer', authMiddleware,roleMiddleware('ADMIN'),getTrainerDashboard);
router.get('/plan',authMiddleware,roleMiddleware('ADMIN'),getPlanDashboard);
router.get('/promotion',authMiddleware,roleMiddleware('ADMIN'),getPromotionDashboard);
router.get('/challenge',authMiddleware,roleMiddleware('ADMIN'),getChallengeDashboard);

// ========================================
// RECENT DATA
// ========================================

router.get('/recent/plan',authMiddleware,roleMiddleware('ADMIN'),getRecentPlans);
router.get('/recent/promotion',authMiddleware,roleMiddleware('ADMIN'),getRecentPromotions);
router.get('/recent/challenge',authMiddleware,roleMiddleware('ADMIN'),getRecentChallenges);


module.exports = router;