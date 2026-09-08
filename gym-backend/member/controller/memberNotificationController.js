const {
    getMemberNotifications,
    getMemberNotificationById,
    markNotificationAsRead
} = require('../model/memberNotificationModel');


// ==========================================
// GET MEMBER NOTIFICATIONS
// ==========================================

const getNotifications = async (req, res) => {
    try {

        // Get logged-in member ID from JWT
        const memberId = req.user.id;

        const notifications = await getMemberNotifications(
            memberId
        );

        res.status(200).json({
            count: notifications.length,
            notifications
        });

    } catch (error) {

        console.error(
            'Get member notifications error:',
            error
        );

        res.status(500).json({
            message: 'Server error'
        });
    }
};


// ==========================================
// MARK NOTIFICATION AS READ
// ==========================================

const markAsRead = async (req, res) => {
    try {

        const memberId = req.user.id;
        const notificationId = req.params.id;

        // First check whether this notification
        // actually belongs to this member
        const notification =
            await getMemberNotificationById(
                notificationId,
                memberId
            );

        if (!notification) {
            return res.status(404).json({
                message: 'Notification not found'
            });
        }

        // Already read
        if (notification.is_read) {
            return res.status(200).json({
                message: 'Notification is already marked as read'
            });
        }

        await markNotificationAsRead(
            notificationId,
            memberId
        );

        res.status(200).json({
            message: 'Notification marked as read'
        });

    } catch (error) {

        console.error(
            'Mark notification as read error:',
            error
        );

        res.status(500).json({
            message: 'Server error'
        });
    }
};


module.exports = {
    getNotifications,
    markAsRead
};