const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    getCheckInDaysDashboard,
    getDietPlanDashboard,
    getWorkoutPlansDashboard,
    getNotificationDashboard,
    getPreviousMonthProgressDashboard,
    getTodayWorkoutDashboard,
    getCurrentMonthCheatCountDashboard
} = require('../controller/memberDashboardController');


// ============================================================
// GET TOTAL WORKOUT CHECK-IN DAYS
// ============================================================

router.get(
    '/dashboard/checkin-days',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getCheckInDaysDashboard
);


// ============================================================
// GET CURRENT MONTH CHEAT COUNT
// ============================================================

router.get(
    '/dashboard/cheat-count',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getCurrentMonthCheatCountDashboard
);


// ============================================================
// GET TODAY'S DIET
// ============================================================

router.get(
    '/dashboard/diet-plan',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getDietPlanDashboard
);


// ============================================================
// GET TOTAL WORKOUT PLANS
// ============================================================

router.get(
    '/dashboard/workout-plans',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getWorkoutPlansDashboard
);


// ============================================================
// GET UNREAD NOTIFICATION COUNT
// ============================================================

router.get(
    '/dashboard/notifications',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getNotificationDashboard
);


// ============================================================
// GET PREVIOUS MONTH'S LATEST PROGRESS
// ============================================================

router.get(
    '/dashboard/previous-month-progress',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getPreviousMonthProgressDashboard
);


// ============================================================
// GET TODAY'S WORKOUT
// ============================================================

router.get(
    '/dashboard/today-workout',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getTodayWorkoutDashboard
);


module.exports = router;