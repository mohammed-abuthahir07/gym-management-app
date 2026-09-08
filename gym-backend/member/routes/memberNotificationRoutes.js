const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');

const {
    getNotifications,
    markAsRead
} = require('../controller/memberNotificationController');


// Get logged-in member notifications
router.get(
    '/notifications',
    authMiddleware,
    getNotifications
);


// Mark member notification as read
router.put(
    '/notifications/:id/read',
    authMiddleware,
    markAsRead
);


module.exports = router;