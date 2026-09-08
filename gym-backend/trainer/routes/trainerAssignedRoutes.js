const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    getAssignedMembersController,
    getAssignedMemberProfileController
} = require('../controller/trainerAssignedController');


// ==========================================
// GET ALL MEMBERS ASSIGNED TO TRAINER
// ==========================================

router.get(
    '/assigned-members',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getAssignedMembersController
);


// ==========================================
// GET ONE ASSIGNED MEMBER PROFILE
// ==========================================

router.get(
    '/assigned-members/:id',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getAssignedMemberProfileController
);


module.exports = router;