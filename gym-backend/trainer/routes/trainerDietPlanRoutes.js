const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    assignDietPlan,
    getDietPlans,
    getDietPlan
} = require('../controller/trainerDietPlanController');


router.post(
    '/diet-plans',
    authMiddleware,
    roleMiddleware('TRAINER'),
    assignDietPlan
);


router.get(
    '/diet-plans',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getDietPlans
);


router.get(
    '/diet-plans/:id',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getDietPlan
);


module.exports = router;