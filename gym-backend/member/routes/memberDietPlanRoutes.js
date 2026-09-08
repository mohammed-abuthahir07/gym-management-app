const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    getDietPlans,
    getDietPlan
} = require('../controller/memberDietPlanController');


/**
 * Get all diet plans of logged-in member
 */
router.get(
    '/diet-plans',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getDietPlans
);


/**
 * Get one diet plan of logged-in member
 */
router.get(
    '/diet-plans/:id',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getDietPlan
);


module.exports = router;