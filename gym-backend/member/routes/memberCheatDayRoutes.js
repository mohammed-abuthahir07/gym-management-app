const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    addCheatDay,
    getCheatDays,
    getCheatDay,
    editCheatDay,
    removeCheatDay
} = require('../controller/memberCheatDayController');


// ============================================
// MEMBER CHEAT DAY ROUTES
// ============================================

// Add cheat activity
router.post(
    '/cheat-days',
    authMiddleware,
    roleMiddleware('MEMBER'),
    addCheatDay
);


// Get all own cheat activities
router.get(
    '/cheat-days',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getCheatDays
);


// Get one own cheat activity
router.get(
    '/cheat-days/:id',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getCheatDay
);


// Update own cheat activity
router.put(
    '/cheat-days/:id',
    authMiddleware,
    roleMiddleware('MEMBER'),
    editCheatDay
);


// Delete own cheat activity
router.delete(
    '/cheat-days/:id',
    authMiddleware,
    roleMiddleware('MEMBER'),
    removeCheatDay
);


module.exports = router;