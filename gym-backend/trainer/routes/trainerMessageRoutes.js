const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    sendMessage,
    getMessageMembers,
    getConversation,
    markMessageAsRead
} = require('../controller/trainerMessageController');


// Get all members with conversations
router.get(
    '/messages',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getMessageMembers
);


// Get conversation with specific assigned member
router.get(
    '/messages/:memberId',
    authMiddleware,
    roleMiddleware('TRAINER'),
    getConversation
);


// Send message to specific assigned member
router.post(
    '/messages/:memberId',
    authMiddleware,
    roleMiddleware('TRAINER'),
    sendMessage
);


// Mark received message as read
router.put(
    '/messages/:id/read',
    authMiddleware,
    roleMiddleware('TRAINER'),
    markMessageAsRead
);


module.exports = router;