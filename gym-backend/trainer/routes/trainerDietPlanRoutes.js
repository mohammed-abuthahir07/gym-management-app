const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    assignDietPlan,
    getDietPlans,
    getDietPlan,
    editDietPlan,
    removeDietPlan
} = require('../controller/trainerDietPlanController');


// Assign diet
router.post(
    '/diet-plans',
    authMiddleware,
    roleMiddleware('TRAINER'),
    assignDietPlan
);


// Get all trainer diet plans
router.get(
    '/diet-plans',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getDietPlans
);


// Get one diet plan
router.get(
    '/diet-plans/:id',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getDietPlan
);


// Update diet plan
router.put(
    '/diet-plans/:id',
    authMiddleware,
    roleMiddleware('TRAINER'),
    editDietPlan
);


// Delete diet plan
router.delete(
    '/diet-plans/:id',
    authMiddleware,
    roleMiddleware('TRAINER'),
    removeDietPlan
);


module.exports = router;