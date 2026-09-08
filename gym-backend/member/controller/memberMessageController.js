const memberMessageModel = require('../model/memberMessageModel');


// Get assigned trainer
const getAssignedTrainer = async (req, res) => {
    try {
        const memberId = req.user.id;

        const trainer = await memberMessageModel.getAssignedTrainer(memberId);

        if (!trainer) {
            return res.status(404).json({
                success: false,
                message: 'No trainer assigned to this member'
            });
        }

        return res.status(200).json({
            success: true,
            trainer
        });

    } catch (error) {
        console.error('Get assigned trainer error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch assigned trainer'
        });
    }
};


// Send message to assigned trainer
const sendMessage = async (req, res) => {
    try {
        const memberId = req.user.id;
        const { trainerId } = req.params;
        const { message } = req.body;

        if (!message || !message.trim()) {
            return res.status(400).json({
                success: false,
                message: 'Message is required'
            });
        }

        const trainer = await memberMessageModel.getAssignedTrainer(memberId);

        if (!trainer) {
            return res.status(404).json({
                success: false,
                message: 'No trainer assigned to this member'
            });
        }

        // Security check
        if (Number(trainer.id) !== Number(trainerId)) {
            return res.status(403).json({
                success: false,
                message: 'You can only message your assigned trainer'
            });
        }

        const messageId = await memberMessageModel.sendMessage(
            memberId,
            trainerId,
            message.trim()
        );

        return res.status(201).json({
            success: true,
            message: 'Message sent successfully',
            data: {
                id: messageId,
                trainer_id: Number(trainerId),
                message: message.trim()
            }
        });

    } catch (error) {
        console.error('Send member message error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to send message'
        });
    }
};


// Get conversation with assigned trainer
const getConversation = async (req, res) => {
    try {
        const memberId = req.user.id;
        const { trainerId } = req.params;

        const trainer = await memberMessageModel.getAssignedTrainer(memberId);

        if (!trainer) {
            return res.status(404).json({
                success: false,
                message: 'No trainer assigned to this member'
            });
        }

        // Security check
        if (Number(trainer.id) !== Number(trainerId)) {
            return res.status(403).json({
                success: false,
                message: 'You can only access your assigned trainer conversation'
            });
        }

        const messages = await memberMessageModel.getConversation(
            memberId,
            trainerId
        );

        return res.status(200).json({
            success: true,
            trainer_id: Number(trainerId),
            trainer,
            count: messages.length,
            messages
        });

    } catch (error) {
        console.error('Get member conversation error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch conversation'
        });
    }
};


// Mark trainer message as read
const markMessageAsRead = async (req, res) => {
    try {
        const memberId = req.user.id;
        const { id } = req.params;

        const updated = await memberMessageModel.markMessageAsRead(
            memberId,
            id
        );

        if (!updated) {
            return res.status(404).json({
                success: false,
                message: 'Message not found'
            });
        }

        return res.status(200).json({
            success: true,
            message: 'Message marked as read'
        });

    } catch (error) {
        console.error('Mark member message as read error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to mark message as read'
        });
    }
};


module.exports = {
    getAssignedTrainer,
    sendMessage,
    getConversation,
    markMessageAsRead
};