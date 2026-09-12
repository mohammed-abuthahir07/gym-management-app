const express = require('express');

const router = express.Router();

const {
    createAdminPlan,
    getPlans,
    getPlan,
    updateAdminPlan,
    deleteAdminPlan
} = require('../controller/adminPlanController');

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');


// ======================================================
// CREATE PLAN
// ======================================================

router.post(
    '/',
    authMiddleware,
    roleMiddleware('ADMIN'),
    createAdminPlan
);


// ======================================================
// GET ALL PLANS
// ======================================================

router.get(
    '/',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getPlans
);


// ======================================================
// GET SINGLE PLAN
// ======================================================

router.get(
    '/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getPlan
);


// ======================================================
// UPDATE PLAN
// ======================================================

router.put(
    '/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    updateAdminPlan
);


// ======================================================
// DELETE PLAN - PERMANENT
// ======================================================

router.delete(
    '/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    deleteAdminPlan
);


module.exports = router;