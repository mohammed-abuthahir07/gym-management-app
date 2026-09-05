const express = require('express');

const router = express.Router();

const {
    createTrainerAccount
} = require('../controller/adminTrainerController');

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');


// ======================================
// CREATE TRAINER
// ADMIN ONLY
// ======================================

router.post( '/', authMiddleware, roleMiddleware('ADMIN'), createTrainerAccount);

module.exports = router;