const express = require('express');
const router = express.Router();
const { createAdminPlan, getPlans, getPlan} = require('../controller/adminPlanController');

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

// Create Plan
router.post('/',authMiddleware, roleMiddleware('ADMIN'), createAdminPlan);

// Get All Plans
router.get( '/', authMiddleware, roleMiddleware('ADMIN'), getPlans);

// Get Single Plan
router.get('/:id',authMiddleware, roleMiddleware('ADMIN'), getPlan);

module.exports = router;