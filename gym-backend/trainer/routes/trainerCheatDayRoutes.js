const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    getTrainerAssignedMembers,
    getAssignedMemberCheatDays,
    getAssignedMemberCheatDay,
    getCurrentMonthCheatDetails,
    getPreviousMonthCheatDetails
} = require('../controller/trainerCheatDayController');


// =====================================================
// ASSIGNED MEMBERS
// =====================================================

router.get(
    '/cheat-days/members',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getTrainerAssignedMembers
);


// =====================================================
// CURRENT MONTH CHEAT DETAILS
// ALL ASSIGNED MEMBERS
// =====================================================

router.get(
    '/cheat-days/current-month',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getCurrentMonthCheatDetails
);


// =====================================================
// PREVIOUS MONTH CHEAT DETAILS
// ALL ASSIGNED MEMBERS
// =====================================================

router.get(
    '/cheat-days/previous-month',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getPreviousMonthCheatDetails
);


// =====================================================
// ONE ASSIGNED MEMBER - ALL CHEAT ACTIVITIES
// =====================================================

router.get(
    '/cheat-days/members/:memberId',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getAssignedMemberCheatDays
);


// =====================================================
// ONE CHEAT ACTIVITY
// =====================================================

router.get(
    '/cheat-days/members/:memberId/:id',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getAssignedMemberCheatDay
);


module.exports = router;