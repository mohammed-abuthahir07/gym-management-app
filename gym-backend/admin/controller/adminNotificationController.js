const {
    getAllMembers,
    getAllTrainers,
    getMemberById,
    getTrainerById,
    createNotification,
    createBulkNotifications,
    getAllNotifications
} = require('../model/adminNotificationModel');


// ==========================================
// SEND NOTIFICATION TO ALL MEMBERS
// ==========================================

const sendToAllMembers = async (req, res) => {
    try {

        const { title, message } = req.body;

        if (!title || !message) {
            return res.status(400).json({
                message: 'Title and message are required'
            });
        }

        const members = await getAllMembers();

        if (members.length === 0) {
            return res.status(404).json({
                message: 'No members found'
            });
        }

        const count = await createBulkNotifications(
            members,
            'MEMBER',
            title,
            message
        );

        res.status(201).json({
            message: 'Notification sent to all members',
            recipients: count
        });

    } catch (error) {

        console.error('Send notification to all members error:', error);

        res.status(500).json({
            message: 'Server error'
        });
    }
};


// ==========================================
// SEND NOTIFICATION TO ALL TRAINERS
// ==========================================

const sendToAllTrainers = async (req, res) => {
    try {

        const { title, message } = req.body;

        if (!title || !message) {
            return res.status(400).json({
                message: 'Title and message are required'
            });
        }

        const trainers = await getAllTrainers();

        if (trainers.length === 0) {
            return res.status(404).json({
                message: 'No trainers found'
            });
        }

        const count = await createBulkNotifications(
            trainers,
            'TRAINER',
            title,
            message
        );

        res.status(201).json({
            message: 'Notification sent to all trainers',
            recipients: count
        });

    } catch (error) {

        console.error('Send notification to all trainers error:', error);

        res.status(500).json({
            message: 'Server error'
        });
    }
};


// ==========================================
// SEND NOTIFICATION TO ONE MEMBER
// ==========================================

const sendToMember = async (req, res) => {
    try {

        const memberId = req.params.id;
        const { title, message } = req.body;

        if (!title || !message) {
            return res.status(400).json({
                message: 'Title and message are required'
            });
        }

        const member = await getMemberById(memberId);

        if (!member) {
            return res.status(404).json({
                message: 'Member not found'
            });
        }

        const notificationId = await createNotification(
            member.id,
            'MEMBER',
            title,
            message
        );

        res.status(201).json({
            message: 'Notification sent to member',
            notification_id: notificationId,
            member_id: member.id
        });

    } catch (error) {

        console.error('Send notification to member error:', error);

        res.status(500).json({
            message: 'Server error'
        });
    }
};


// ==========================================
// SEND NOTIFICATION TO ONE TRAINER
// ==========================================

const sendToTrainer = async (req, res) => {
    try {

        const trainerId = req.params.id;
        const { title, message } = req.body;

        if (!title || !message) {
            return res.status(400).json({
                message: 'Title and message are required'
            });
        }

        const trainer = await getTrainerById(trainerId);

        if (!trainer) {
            return res.status(404).json({
                message: 'Trainer not found'
            });
        }

        const notificationId = await createNotification(
            trainer.id,
            'TRAINER',
            title,
            message
        );

        res.status(201).json({
            message: 'Notification sent to trainer',
            notification_id: notificationId,
            trainer_id: trainer.id
        });

    } catch (error) {

        console.error('Send notification to trainer error:', error);

        res.status(500).json({
            message: 'Server error'
        });
    }
};


// ==========================================
// GET NOTIFICATION HISTORY
// ==========================================

const getNotifications = async (req, res) => {
    try {

        const notifications = await getAllNotifications();

        res.status(200).json({
            count: notifications.length,
            notifications
        });

    } catch (error) {

        console.error('Get notifications error:', error);

        res.status(500).json({
            message: 'Server error'
        });
    }
};


module.exports = {
    sendToAllMembers,
    sendToAllTrainers,
    sendToMember,
    sendToTrainer,
    getNotifications
};