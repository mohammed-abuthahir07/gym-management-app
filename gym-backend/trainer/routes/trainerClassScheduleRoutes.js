const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    createClassScheduleController,
    getTrainerClassSchedulesController,
    getTrainerClassScheduleByIdController,
    updateClassScheduleController,
    deleteClassScheduleController
} = require('../controller/trainerClassScheduleController');


// ==========================================
// CREATE CLASS
// ==========================================
router.post(
    '/class-schedules',
    authMiddleware,
    roleMiddleware('TRAINER'),
    createClassScheduleController
);


// ==========================================
// GET ALL TRAINER CLASSES
// ==========================================
router.get(
    '/class-schedules',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getTrainerClassSchedulesController
);


// ==========================================
// GET ONE CLASS
// ==========================================
router.get(
    '/class-schedules/:id',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getTrainerClassScheduleByIdController
);


// ==========================================
// UPDATE CLASS
// ==========================================
router.put(
    '/class-schedules/:id',
    authMiddleware,
    roleMiddleware('TRAINER'),
    updateClassScheduleController
);


// ==========================================
// DELETE CLASS
// ==========================================
router.delete(
    '/class-schedules/:id',
    authMiddleware,
    roleMiddleware('TRAINER'),
    deleteClassScheduleController
);


module.exports = router;