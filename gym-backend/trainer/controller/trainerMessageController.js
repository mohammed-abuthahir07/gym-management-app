const trainerMessageModel = require('../model/trainerMessageModel');

// Send message to assigned member
const sendMessage = async (req, res) => {
    try {
        const trainerId = req.user.id;
        const { memberId } = req.params;
        const { message } = req.body;

        if (!message || !message.trim()) {
            return res.status(400).json({
                success: false,
                message: 'Message is required'
            });
        }

        const isAssigned = await trainerMessageModel.checkMemberAssigned(
            trainerId,
            memberId
        );

        if (!isAssigned) {
            return res.status(403).json({
                success: false,
                message: 'This member is not assigned to you'
            });
        }

        const messageId = await trainerMessageModel.sendMessage(
            trainerId,
            memberId,
            message.trim()
        );

        return res.status(201).json({
            success: true,
            message: 'Message sent successfully',
            data: {
                id: messageId,
                member_id: Number(memberId),
                message: message.trim()
            }
        });

    } catch (error) {
        console.error('Send trainer message error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to send message'
        });
    }
};


// Get members who have conversations with trainer
const getMessageMembers = async (req, res) => {
    try {
        const trainerId = req.user.id;

        const members = await trainerMessageModel.getMessageMembers(trainerId);

        return res.status(200).json({
            success: true,
            count: members.length,
            members
        });

    } catch (error) {
        console.error('Get message members error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch message members'
        });
    }
};


// Get conversation with a specific assigned member
const getConversation = async (req, res) => {
    try {
        const trainerId = req.user.id;
        const { memberId } = req.params;

        const isAssigned = await trainerMessageModel.checkMemberAssigned(
            trainerId,
            memberId
        );

        if (!isAssigned) {
            return res.status(403).json({
                success: false,
                message: 'This member is not assigned to you'
            });
        }

        const messages = await trainerMessageModel.getConversation(
            trainerId,
            memberId
        );

        return res.status(200).json({
            success: true,
            member_id: Number(memberId),
            count: messages.length,
            messages
        });

    } catch (error) {
        console.error('Get conversation error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch conversation'
        });
    }
};


// Mark received message as read
const markMessageAsRead = async (req, res) => {
    try {
        const trainerId = req.user.id;
        const { id } = req.params;

        const updated = await trainerMessageModel.markMessageAsRead(
            trainerId,
            id
        );

        if (!updated) {
            return res.status(404).json({
                success: false,
                message: 'Message not found or already unavailable'
            });
        }

        return res.status(200).json({
            success: true,
            message: 'Message marked as read'
        });

    } catch (error) {
        console.error('Mark message as read error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to mark message as read'
        });
    }
};


module.exports = {
    sendMessage,
    getMessageMembers,
    getConversation,
    markMessageAsRead
};