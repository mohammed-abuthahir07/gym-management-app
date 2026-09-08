const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    sendToAllMembers,
    sendToAllTrainers,
    sendToMember,
    sendToTrainer,
    getNotifications
} = require('../controller/adminNotificationController');


// Send notification to all members
router.post(
    '/notifications/members',
    authMiddleware,
    roleMiddleware('ADMIN'),
    sendToAllMembers
);


// Send notification to all trainers
router.post(
    '/notifications/trainers',
    authMiddleware,
    roleMiddleware('ADMIN'),
    sendToAllTrainers
);


// Send notification to one member
router.post(
    '/notifications/member/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    sendToMember
);


// Send notification to one trainer
router.post(
    '/notifications/trainer/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    sendToTrainer
);


// Get notification history
router.get(
    '/notifications',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getNotifications
);


module.exports = router;