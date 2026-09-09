const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    getCurrentMonthCheckinDays,
    getCurrentMonthPaymentStatus,
    getTomorrowWorkout,
    getCurrentMonthCheatMeals,
    getCurrentMonthProgress
} = require('../controller/memberAnalyticsController');

/*
==================================================
MEMBER ANALYTICS
==================================================
*/

// Current month check-in days
router.get(
    '/analytics/current-month-checkin-days',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getCurrentMonthCheckinDays
);

router.get(
    '/analytics/current-month-progress',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getCurrentMonthProgress
);


// Current month payment status
router.get(
    '/analytics/current-month-payment-status',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getCurrentMonthPaymentStatus
);


// Tomorrow workout
router.get(
    '/analytics/tomorrow-workout',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getTomorrowWorkout
);


// Current month cheat meals
router.get(
    '/analytics/current-month-cheat-meals',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getCurrentMonthCheatMeals
);


module.exports = router;