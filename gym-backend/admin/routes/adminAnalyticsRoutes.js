const express = require('express');
const router = express.Router();
const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');
const { memberAnalytics, trainerAnalytics, recentPlans, recentPromotions, recentChallenges} = require('../controller/adminAnalyticsController');


// ==========================================
// MEMBER ANALYTICS
// ==========================================

router.get('/member',authMiddleware,roleMiddleware('ADMIN'),memberAnalytics);

// ==========================================
// TRAINER ANALYTICS
// ==========================================

router.get('/trainer',authMiddleware,roleMiddleware('ADMIN'),trainerAnalytics);

// ==========================================
// MOST RECENT PLANS
// ==========================================

router.get('/plan',authMiddleware,roleMiddleware('ADMIN'),recentPlans);

// ==========================================
// MOST RECENT PROMOTIONS
// ==========================================

router.get('/promotion',authMiddleware,roleMiddleware('ADMIN'),recentPromotions);

// ==========================================
// MOST RECENT CHALLENGES
// ==========================================

router.get('/challenge',authMiddleware,roleMiddleware('ADMIN'),recentChallenges);

module.exports = router;