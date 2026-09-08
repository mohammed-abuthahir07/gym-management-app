const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    getAssignedMembers,
    getDietPlans,
    getWorkoutPlans,
    getCheckIns
} = require('../controller/trainerDashboardController');


/*
 * Assigned members count
 */
router.get(
    '/dashboard/assigned-members',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getAssignedMembers
);


/*
 * Diet plans count
 */
router.get(
    '/dashboard/diet-plans',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getDietPlans
);


/*
 * Workout plans count
 */
router.get(
    '/dashboard/workout-plans',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getWorkoutPlans
);


/*
 * Member workout check-ins
 */
router.get(
    '/dashboard/check-ins',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getCheckIns
);


module.exports = router;