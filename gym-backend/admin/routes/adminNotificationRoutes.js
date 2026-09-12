const express = require('express');

const router = express.Router();

const authMiddleware =
    require('../../middleware/authMiddleware');

const roleMiddleware =
    require('../../middleware/roleMiddleware');

const {
    sendToAllMembers,
    sendToAllTrainers,
    sendToMember,
    sendToTrainer,
    getNotifications,
    getNotification,
    updateAdminNotification,
    deleteAdminNotification
} = require('../controller/adminNotificationController');


// ======================================================
// SEND NOTIFICATION TO ALL MEMBERS
// ======================================================

router.post(
    '/notifications/members',
    authMiddleware,
    roleMiddleware('ADMIN'),
    sendToAllMembers
);


// ======================================================
// SEND NOTIFICATION TO ALL TRAINERS
// ======================================================

router.post(
    '/notifications/trainers',
    authMiddleware,
    roleMiddleware('ADMIN'),
    sendToAllTrainers
);


// ======================================================
// SEND NOTIFICATION TO ONE MEMBER
// ======================================================

router.post(
    '/notifications/member/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    sendToMember
);


// ======================================================
// SEND NOTIFICATION TO ONE TRAINER
// ======================================================

router.post(
    '/notifications/trainer/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    sendToTrainer
);


// ======================================================
// GET ALL NOTIFICATIONS
// ======================================================

router.get(
    '/notifications',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getNotifications
);


// ======================================================
// GET SINGLE NOTIFICATION
// ======================================================

router.get(
    '/notifications/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getNotification
);


// ======================================================
// UPDATE NOTIFICATION
// ======================================================

router.put(
    '/notifications/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    updateAdminNotification
);


// ======================================================
// DELETE NOTIFICATION - PERMANENT
// ======================================================

router.delete(
    '/notifications/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    deleteAdminNotification
);


module.exports = router;