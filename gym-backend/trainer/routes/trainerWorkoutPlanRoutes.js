const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    assignWorkoutPlan,
    getPlans,
    getPlan,
    addExercise,
    updatePlan,
    updateExercise,
    removePlan,
    removeExercise
} = require('../controller/trainerWorkoutPlanController');


// =====================================================
// ASSIGN WORKOUT PLAN
// =====================================================

router.post(
    '/workout-plans',
    authMiddleware,
    roleMiddleware('TRAINER'),
    assignWorkoutPlan
);


// =====================================================
// GET ALL TRAINER WORKOUT PLANS
// =====================================================

router.get(
    '/workout-plans',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getPlans
);


// =====================================================
// GET ONE PLAN + EXERCISES
// =====================================================

router.get(
    '/workout-plans/:id',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getPlan
);


// =====================================================
// UPDATE PLAN NAME
// =====================================================

router.put(
    '/workout-plans/:id',
    authMiddleware,
    roleMiddleware('TRAINER'),
    updatePlan
);


// =====================================================
// DELETE PLAN
// =====================================================

router.delete(
    '/workout-plans/:id',
    authMiddleware,
    roleMiddleware('TRAINER'),
    removePlan
);


// =====================================================
// ADD MORE EXERCISE
// =====================================================

router.post(
    '/workout-plans/:id/exercises',
    authMiddleware,
    roleMiddleware('TRAINER'),
    addExercise
);


// =====================================================
// UPDATE EXERCISE
// =====================================================

router.put(
    '/workout-plans/:planId/exercises/:workoutExerciseId',
    authMiddleware,
    roleMiddleware('TRAINER'),
    updateExercise
);


// =====================================================
// DELETE EXERCISE
// =====================================================

router.delete(
    '/workout-plans/:planId/exercises/:workoutExerciseId',
    authMiddleware,
    roleMiddleware('TRAINER'),
    removeExercise
);


module.exports = router;