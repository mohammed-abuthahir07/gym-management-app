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
 * Get total workout check-in days
 *
 * GET /api/member/dashboard/checkin-days
 */
router.get(
    '/dashboard/checkin-days',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getCheckInDaysDashboard
);


/*
 * Get today's diet
 *
 * GET /api/member/dashboard/diet-plan
 *
 * Automatically returns:
 * Monday    -> Monday diet
 * Tuesday   -> Tuesday diet
 * etc.
 */
router.get(
    '/dashboard/diet-plan',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getDietPlanDashboard
);


/*
 * Get total workout plans
 *
 * GET /api/member/dashboard/workout-plans
 */
router.get(
    '/dashboard/workout-plans',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getWorkoutPlansDashboard
);


/*
 * Get unread notification count
 *
 * GET /api/member/dashboard/notifications
 */
router.get(
    '/dashboard/notifications',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getNotificationDashboard
);


/*
 * Get previous month's latest progress
 *
 * GET /api/member/dashboard/previous-month-progress
 */
router.get(
    '/dashboard/previous-month-progress',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getPreviousMonthProgressDashboard
);


/*
 * Get today's workout
 *
 * GET /api/member/dashboard/today-workout
 *
 * Automatically returns:
 * Monday    -> Monday workout
 * Tuesday   -> Tuesday workout
 * etc.
 */
router.get(
    '/dashboard/today-workout',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getTodayWorkoutDashboard
);


module.exports = router;