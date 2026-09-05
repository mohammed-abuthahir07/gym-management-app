const express = require('express');
const router = express.Router();
const {login, getProfile} = require('../controller/adminAuthController');
const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');



router.post('/login', login);
router.get( '/profile', authMiddleware, roleMiddleware('ADMIN'), getProfile);


module.exports = router;