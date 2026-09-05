const express = require('express');
const router = express.Router();
const { login, getProfile} = require('../controller/trainerAuthController');

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');


router.post('/login', login);

router.get( '/profile', authMiddleware, roleMiddleware('TRAINER'), getProfile);

module.exports = router;