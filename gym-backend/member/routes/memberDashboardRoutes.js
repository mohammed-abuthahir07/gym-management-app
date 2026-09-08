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
    getTodayWorkoutDashboard
} = require('../controller/memberDashboardController');


/*
 * Check-in days
 */
router.get(
    '/dashboard/checkin-days',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getCheckInDaysDashboard
);

router.get(
    '/dashboard/previous-month-progress',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getPreviousMonthProgressDashboard
);

router.get(
    '/dashboard/today-workout',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getTodayWorkoutDashboard
);

/*
 * Current diet plan
 */
router.get(
    '/dashboard/diet-plan',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getDietPlanDashboard
);


/*
 * Workout plan count
 */
router.get(
    '/dashboard/workout-plans',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getWorkoutPlansDashboard
);


/*
 * Unread notification count
 */
router.get(
    '/dashboard/notifications',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getNotificationDashboard
);


module.exports = router;