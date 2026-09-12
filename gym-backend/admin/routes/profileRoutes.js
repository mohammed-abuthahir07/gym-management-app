const express = require('express');

const router = express.Router();

const {
    updateAdminProfileController
} = require('../controller/profileController');

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');


// ============================================================
// UPDATE ADMIN PROFILE
// ============================================================

router.put(
    '/',
    authMiddleware,
    roleMiddleware('ADMIN'),
    updateAdminProfileController
);


module.exports = router;