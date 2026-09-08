const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    getDietPlans,
    getDietPlan,
    getTodayDiet
} = require('../controller/memberDietPlanController');


// Get complete weekly diet
router.get(
    '/diet-plans',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getDietPlans
);


// Get one diet entry
router.get(
    '/diet-plans/:id',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getDietPlan
);


// Get today's diet
router.get(
    '/diet-plans/today',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getTodayDiet
);


module.exports = router;