const express = require('express');

const router = express.Router();

const {
    createTrainerAccount,
    getTrainers,
    getTrainer,
    updateTrainerAccount,
    deleteTrainer
} = require('../controller/adminTrainerController');

const authMiddleware =
    require('../../middleware/authMiddleware');

const roleMiddleware =
    require('../../middleware/roleMiddleware');


// ============================================================
// CREATE
// POST /api/admin/trainers
// ============================================================

router.post(
    '/',
    authMiddleware,
    roleMiddleware('ADMIN'),
    createTrainerAccount
);


// ============================================================
// GET ALL
// GET /api/admin/trainers
// ============================================================

router.get(
    '/',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getTrainers
);


// ============================================================
// GET ONE
// GET /api/admin/trainers/:id
// ============================================================

router.get(
    '/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getTrainer
);


// ============================================================
// UPDATE
// PUT /api/admin/trainers/:id
// ============================================================

router.put(
    '/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    updateTrainerAccount
);


// ============================================================
// DELETE / DEACTIVATE
// DELETE /api/admin/trainers/:id
// ============================================================

router.delete(
    '/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    deleteTrainer
);


module.exports = router;