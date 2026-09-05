const express = require('express');
const router = express.Router();
const { login, getProfile} = require('../controller/trainerAuthController');

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

// Trainer Login
router.post('/login', login);

// Trainer Profile
router.get( '/profile', authMiddleware, roleMiddleware('TRAINER'), getProfile);

module.exports = router;