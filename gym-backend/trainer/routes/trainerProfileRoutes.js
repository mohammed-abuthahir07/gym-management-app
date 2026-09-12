const express = require('express');

const router = express.Router();

const {
    updateTrainerProfileController
} = require('../controller/trainerProfileController');

const authMiddleware =
    require('../../middleware/authMiddleware');

const roleMiddleware =
    require('../../middleware/roleMiddleware');


// ============================================================
// UPDATE TRAINER PROFILE
// ============================================================

router.put(
    '/',
    authMiddleware,
    roleMiddleware('TRAINER'),
    updateTrainerProfileController
);


module.exports = router;