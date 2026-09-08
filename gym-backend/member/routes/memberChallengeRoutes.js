const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');

const {
    getAllChallenges
} = require('../controller/memberChallengeController');

// =====================================================
// CHALLENGE ROUTES
// =====================================================

// GET ALL ACTIVE CHALLENGES
// GET /api/member/challenges

router.get(
    '/challenges',
    authMiddleware,
    getAllChallenges
);

module.exports = router;
