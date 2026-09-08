const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    getAssignedTrainer,
    sendMessage,
    getConversation,
    markMessageAsRead
} = require('../controller/memberMessageController');


// Get assigned trainer
router.get(
    '/messages/trainer',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getAssignedTrainer
);


// Get conversation with assigned trainer
router.get(
    '/messages/:trainerId',
    authMiddleware,
    roleMiddleware('MEMBER'),
    getConversation
);


// Send message to assigned trainer
router.post(
    '/messages/:trainerId',
    authMiddleware,
    roleMiddleware('MEMBER'),
    sendMessage
);


// Mark trainer message as read
router.put(
    '/messages/:id/read',
    authMiddleware,
    roleMiddleware('MEMBER'),
    markMessageAsRead
);


module.exports = router;