const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    getWorkoutPlans,
    getWorkoutPlan
} = require('../controller/memberWorkoutPlanController');


/**
 * Get all workout plans assigned to logged-in member
 */
router.get(
    '/workout-plans',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getWorkoutPlans
);


/**
 * Get one workout plan assigned to logged-in member
 */
router.get(
    '/workout-plans/:id',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getWorkoutPlan
);


module.exports = router;