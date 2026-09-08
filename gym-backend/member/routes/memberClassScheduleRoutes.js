const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    getMemberClassSchedulesController,
    getMemberClassScheduleByIdController
} = require('../controller/memberClassScheduleController');


// ==========================================
// GET ALL CLASS SCHEDULES
// ==========================================
router.get(
    '/class-schedules',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getMemberClassSchedulesController
);


// ==========================================
// GET ONE CLASS SCHEDULE
// ==========================================
router.get(
    '/class-schedules/:id',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getMemberClassScheduleByIdController
);


module.exports = router;