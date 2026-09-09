const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    getTodayWorkoutAnalytics
} = require('../controller/trainerAnalyticsController');

router.get(
    '/analytics/today-workouts',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getTodayWorkoutAnalytics
);

module.exports = router;