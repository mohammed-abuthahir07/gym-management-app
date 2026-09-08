const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');

const {
    getAllExercises
} = require('../controller/memberExerciseController');

// =====================================================
// EXERCISE LIBRARY
// =====================================================

// GET ALL ACTIVE EXERCISES
// GET /api/member/exercises

router.get(
    '/exercises',
    authMiddleware,
    getAllExercises
);

module.exports = router;