const db = require('../../config/db');


// ==========================================
// GET NOTIFICATIONS FOR ONE MEMBER
// ==========================================

const getMemberNotifications = async (memberId) => {
    const [rows] = await db.query(
        `SELECT
            id,
            title,
            message,
            is_read,
            created_at,
            updated_at
         FROM notifications
         WHERE recipient_id = ?
         AND recipient_role = 'MEMBER'
         ORDER BY created_at DESC`,
        [memberId]
    );

    return rows;
};


// ==========================================
// GET ONE NOTIFICATION FOR ONE MEMBER
// ==========================================

const getMemberNotificationById = async (
    notificationId,
    memberId
) => {
    const [rows] = await db.query(
        `SELECT
            id,
            title,
            message,
            is_read,
            created_at,
            updated_at
         FROM notifications
         WHERE id = ?
         AND recipient_id = ?
         AND recipient_role = 'MEMBER'`,
        [
            notificationId,
            memberId
        ]
    );

    return rows[0];
};


// ==========================================
// MARK NOTIFICATION AS READ
// ==========================================

const markNotificationAsRead = async (
    notificationId,
    memberId
) => {
    const [result] = await db.query(
        `UPDATE notifications
         SET is_read = TRUE
         WHERE id = ?
         AND recipient_id = ?
         AND recipient_role = 'MEMBER'`,
        [
            notificationId,
            memberId
        ]
    );

    return result;
};


module.exports = {
    getMemberNotifications,
    getMemberNotificationById,
    markNotificationAsRead
};