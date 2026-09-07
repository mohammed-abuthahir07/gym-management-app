const express = require('express');

const router = express.Router();

const {
    createAdminExercise,
    getExercises,
    getExercise,
    updateAdminExercise,
    deleteAdminExercise
} = require('../controller/adminExerciseController');

const authMiddleware =
    require('../../middleware/authMiddleware');

const roleMiddleware =
    require('../../middleware/roleMiddleware');


// ======================================
// CREATE EXERCISE
// ======================================
router.post(
    '/',
    authMiddleware,
    roleMiddleware('ADMIN'),
    createAdminExercise
);


// ======================================
// GET ALL EXERCISES
// ======================================
router.get(
    '/',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getExercises
);


// ======================================
// GET SINGLE EXERCISE
// ======================================
router.get(
    '/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getExercise
);


// ======================================
// UPDATE EXERCISE
// ======================================
router.put(
    '/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    updateAdminExercise
);


// ======================================
// DELETE EXERCISE
// ======================================
router.delete(
    '/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    deleteAdminExercise
);


module.exports = router;