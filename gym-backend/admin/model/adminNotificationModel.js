const db = require('../../config/db');


// Get all members
const getAllMembers = async () => {
    const [rows] = await db.query(
        `SELECT id
         FROM users
         WHERE role = 'MEMBER'`
    );

    return rows;
};


// Get all trainers
const getAllTrainers = async () => {
    const [rows] = await db.query(
        `SELECT id
         FROM users
         WHERE role = 'TRAINER'`
    );

    return rows;
};


// Check member
const getMemberById = async (id) => {
    const [rows] = await db.query(
        `SELECT id, name, email
         FROM users
         WHERE id = ? AND role = 'MEMBER'`,
        [id]
    );

    return rows[0];
};


// Check trainer
const getTrainerById = async (id) => {
    const [rows] = await db.query(
        `SELECT id, name, email
         FROM users
         WHERE id = ? AND role = 'TRAINER'`,
        [id]
    );

    return rows[0];
};


// Create notification for one user
const createNotification = async (
    recipientId,
    recipientRole,
    title,
    message
) => {
    const [result] = await db.query(
        `INSERT INTO notifications
        (recipient_id, recipient_role, title, message)
        VALUES (?, ?, ?, ?)`,
        [
            recipientId,
            recipientRole,
            title,
            message
        ]
    );

    return result.insertId;
};


// Create notifications for multiple users
const createBulkNotifications = async (
    recipients,
    recipientRole,
    title,
    message
) => {

    if (!recipients || recipients.length === 0) {
        return 0;
    }

    const values = recipients.map(user => [
        user.id,
        recipientRole,
        title,
        message
    ]);

    await db.query(
        `INSERT INTO notifications
        (recipient_id, recipient_role, title, message)
        VALUES ?`,
        [values]
    );

    return recipients.length;
};


// Get notification history for Admin
const getAllNotifications = async () => {
    const [rows] = await db.query(
        `SELECT
            id,
            recipient_id,
            recipient_role,
            title,
            message,
            is_read,
            created_at,
            updated_at
         FROM notifications
         ORDER BY created_at DESC`
    );

    return rows;
};


module.exports = {
    getAllMembers,
    getAllTrainers,
    getMemberById,
    getTrainerById,
    createNotification,
    createBulkNotifications,
    getAllNotifications
};