const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');

const {
    createProfile,
    getProfile,
    updateProfile
} = require('../controller/memberProfileController');


// =====================================================
// MEMBER PROFILE ROUTES
// =====================================================


// CREATE PROFILE
// POST /api/member/profile

router.post(
    '/profile',
    authMiddleware,
    createProfile
);


// VIEW OWN PROFILE
// GET /api/member/profile

router.get(
    '/profile',
    authMiddleware,
    getProfile
);


// UPDATE OWN PROFILE
// PUT /api/member/profile

router.put(
    '/profile',
    authMiddleware,
    updateProfile
);


module.exports = router;