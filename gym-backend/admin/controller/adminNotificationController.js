const {
    getAllMembers,
    getAllTrainers,
    getMemberById,
    getTrainerById,
    createNotification,
    createBulkNotifications,
    getAllNotifications,
    getNotificationById,
    updateNotification,
    deleteNotification
} = require('../model/adminNotificationModel');


// ======================================================
// SEND NOTIFICATION TO ALL MEMBERS
// ======================================================

const sendToAllMembers = async (req, res) => {
    try {

        const { title, message } = req.body;

        if (
            typeof title !== 'string' ||
            typeof message !== 'string' ||
            !title.trim() ||
            !message.trim()
        ) {
            return res.status(400).json({
                success: false,
                message: 'Title and message are required'
            });
        }

        const members = await getAllMembers();

        if (members.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'No members found'
            });
        }

        const count = await createBulkNotifications(
            members,
            'MEMBER',
            title.trim(),
            message.trim()
        );

        return res.status(201).json({
            success: true,
            message: 'Notification sent to all members',
            recipients: count
        });

    } catch (error) {

        console.error(
            'Send notification to all members error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while sending notification'
        });
    }
};


// ======================================================
// SEND NOTIFICATION TO ALL TRAINERS
// ======================================================

const sendToAllTrainers = async (req, res) => {
    try {

        const { title, message } = req.body;

        if (
            typeof title !== 'string' ||
            typeof message !== 'string' ||
            !title.trim() ||
            !message.trim()
        ) {
            return res.status(400).json({
                success: false,
                message: 'Title and message are required'
            });
        }

        const trainers = await getAllTrainers();

        if (trainers.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'No trainers found'
            });
        }

        const count = await createBulkNotifications(
            trainers,
            'TRAINER',
            title.trim(),
            message.trim()
        );

        return res.status(201).json({
            success: true,
            message: 'Notification sent to all trainers',
            recipients: count
        });

    } catch (error) {

        console.error(
            'Send notification to all trainers error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while sending notification'
        });
    }
};


// ======================================================
// SEND NOTIFICATION TO ONE MEMBER
// ======================================================

const sendToMember = async (req, res) => {
    try {

        const memberId = req.params.id;

        const {
            title,
            message
        } = req.body;

        if (
            typeof title !== 'string' ||
            typeof message !== 'string' ||
            !title.trim() ||
            !message.trim()
        ) {
            return res.status(400).json({
                success: false,
                message: 'Title and message are required'
            });
        }

        const member = await getMemberById(
            memberId
        );

        if (!member) {
            return res.status(404).json({
                success: false,
                message: 'Member not found'
            });
        }

        const notificationId =
            await createNotification(
                member.id,
                'MEMBER',
                title.trim(),
                message.trim()
            );

        return res.status(201).json({
            success: true,
            message: 'Notification sent to member',
            notification_id: notificationId,
            member_id: member.id
        });

    } catch (error) {

        console.error(
            'Send notification to member error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while sending notification'
        });
    }
};


// ======================================================
// SEND NOTIFICATION TO ONE TRAINER
// ======================================================

const sendToTrainer = async (req, res) => {
    try {

        const trainerId = req.params.id;

        const {
            title,
            message
        } = req.body;

        if (
            typeof title !== 'string' ||
            typeof message !== 'string' ||
            !title.trim() ||
            !message.trim()
        ) {
            return res.status(400).json({
                success: false,
                message: 'Title and message are required'
            });
        }

        const trainer = await getTrainerById(
            trainerId
        );

        if (!trainer) {
            return res.status(404).json({
                success: false,
                message: 'Trainer not found'
            });
        }

        const notificationId =
            await createNotification(
                trainer.id,
                'TRAINER',
                title.trim(),
                message.trim()
            );

        return res.status(201).json({
            success: true,
            message: 'Notification sent to trainer',
            notification_id: notificationId,
            trainer_id: trainer.id
        });

    } catch (error) {

        console.error(
            'Send notification to trainer error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while sending notification'
        });
    }
};


// ======================================================
// GET ALL NOTIFICATIONS
// ======================================================

const getNotifications = async (req, res) => {
    try {

        const notifications =
            await getAllNotifications();

        return res.status(200).json({
            success: true,
            count: notifications.length,
            notifications
        });

    } catch (error) {

        console.error(
            'Get notifications error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while fetching notifications'
        });
    }
};


// ======================================================
// GET SINGLE NOTIFICATION
// ======================================================

const getNotification = async (req, res) => {
    try {

        const notificationId =
            req.params.id;

        const notification =
            await getNotificationById(
                notificationId
            );

        if (!notification) {
            return res.status(404).json({
                success: false,
                message: 'Notification not found'
            });
        }

        return res.status(200).json({
            success: true,
            message: 'Notification fetched successfully',
            notification
        });

    } catch (error) {

        console.error(
            'Get notification error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while fetching notification'
        });
    }
};


// ======================================================
// UPDATE NOTIFICATION
// ======================================================

const updateAdminNotification = async (req, res) => {
    try {

        const notificationId =
            req.params.id;

        const existingNotification =
            await getNotificationById(
                notificationId
            );

        if (!existingNotification) {
            return res.status(404).json({
                success: false,
                message: 'Notification not found'
            });
        }

        const {
            title,
            message,
            is_read
        } = req.body;


        // --------------------------------------------------
        // Keep old values when fields are omitted
        // --------------------------------------------------

        const updatedTitle =
            title === undefined
                ? existingNotification.title
                : title;

        const updatedMessage =
            message === undefined
                ? existingNotification.message
                : message;

        const updatedIsRead =
            is_read === undefined
                ? Boolean(existingNotification.is_read)
                : is_read;


        // --------------------------------------------------
        // Validate title
        // --------------------------------------------------

        if (
            typeof updatedTitle !== 'string' ||
            !updatedTitle.trim()
        ) {
            return res.status(400).json({
                success: false,
                message: 'Title cannot be empty'
            });
        }


        // --------------------------------------------------
        // Validate message
        // --------------------------------------------------

        if (
            typeof updatedMessage !== 'string' ||
            !updatedMessage.trim()
        ) {
            return res.status(400).json({
                success: false,
                message: 'Message cannot be empty'
            });
        }


        // --------------------------------------------------
        // Validate is_read
        // --------------------------------------------------

        if (
            typeof updatedIsRead !== 'boolean' &&
            updatedIsRead !== 0 &&
            updatedIsRead !== 1
        ) {
            return res.status(400).json({
                success: false,
                message: 'is_read must be true or false'
            });
        }


        const normalizedIsRead =
            Boolean(updatedIsRead);


        // --------------------------------------------------
        // Update
        // --------------------------------------------------

        await updateNotification({
            id: notificationId,
            title: updatedTitle.trim(),
            message: updatedMessage.trim(),
            is_read: normalizedIsRead
        });


        // --------------------------------------------------
        // Fetch updated notification
        // --------------------------------------------------

        const updatedNotification =
            await getNotificationById(
                notificationId
            );

        return res.status(200).json({
            success: true,
            message: 'Notification updated successfully',
            notification: updatedNotification
        });

    } catch (error) {

        console.error(
            'Update notification error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while updating notification'
        });
    }
};


// ======================================================
// DELETE NOTIFICATION PERMANENTLY
// ======================================================

const deleteAdminNotification = async (req, res) => {
    try {

        const notificationId =
            req.params.id;


        // --------------------------------------------------
        // Check notification exists
        // --------------------------------------------------

        const existingNotification =
            await getNotificationById(
                notificationId
            );

        if (!existingNotification) {
            return res.status(404).json({
                success: false,
                message: 'Notification not found'
            });
        }


        // --------------------------------------------------
        // PERMANENT DELETE
        // --------------------------------------------------

        await deleteNotification(
            notificationId
        );


        return res.status(200).json({
            success: true,
            message: 'Notification deleted permanently',
            notification_id: Number(
                notificationId
            )
        });

    } catch (error) {

        console.error(
            'Delete notification error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while deleting notification'
        });
    }
};


// ======================================================
// EXPORT
// ======================================================

module.exports = {
    sendToAllMembers,
    sendToAllTrainers,
    sendToMember,
    sendToTrainer,
    getNotifications,
    getNotification,
    updateAdminNotification,
    deleteAdminNotification
};