const db = require('../../config/db');


// ======================================================
// GET ALL MEMBERS
// ======================================================

const getAllMembers = async () => {
    const [rows] = await db.query(
        `SELECT id
         FROM users
         WHERE role = 'MEMBER'`
    );

    return rows;
};


// ======================================================
// GET ALL TRAINERS
// ======================================================

const getAllTrainers = async () => {
    const [rows] = await db.query(
        `SELECT id
         FROM users
         WHERE role = 'TRAINER'`
    );

    return rows;
};


// ======================================================
// GET MEMBER BY ID
// ======================================================

const getMemberById = async (id) => {
    const [rows] = await db.query(
        `SELECT
            id,
            name,
            email
         FROM users
         WHERE id = ?
           AND role = 'MEMBER'
         LIMIT 1`,
        [id]
    );

    return rows[0] || null;
};


// ======================================================
// GET TRAINER BY ID
// ======================================================

const getTrainerById = async (id) => {
    const [rows] = await db.query(
        `SELECT
            id,
            name,
            email
         FROM users
         WHERE id = ?
           AND role = 'TRAINER'
         LIMIT 1`,
        [id]
    );

    return rows[0] || null;
};


// ======================================================
// CREATE NOTIFICATION FOR ONE USER
// ======================================================

const createNotification = async (
    recipientId,
    recipientRole,
    title,
    message
) => {
    const [result] = await db.query(
        `INSERT INTO notifications
        (
            recipient_id,
            recipient_role,
            title,
            message
        )
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


// ======================================================
// CREATE NOTIFICATIONS FOR MULTIPLE USERS
// ======================================================

const createBulkNotifications = async (
    recipients,
    recipientRole,
    title,
    message
) => {

    if (!recipients || recipients.length === 0) {
        return 0;
    }

    const values = recipients.map((user) => [
        user.id,
        recipientRole,
        title,
        message
    ]);

    await db.query(
        `INSERT INTO notifications
        (
            recipient_id,
            recipient_role,
            title,
            message
        )
        VALUES ?`,
        [values]
    );

    return recipients.length;
};


// ======================================================
// GET ALL NOTIFICATIONS
// ======================================================

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


// ======================================================
// GET SINGLE NOTIFICATION
// ======================================================

const getNotificationById = async (id) => {
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
         WHERE id = ?
         LIMIT 1`,
        [id]
    );

    return rows[0] || null;
};


// ======================================================
// UPDATE NOTIFICATION
// ======================================================

const updateNotification = async ({
    id,
    title,
    message,
    is_read
}) => {
    const [result] = await db.query(
        `UPDATE notifications
         SET
            title = ?,
            message = ?,
            is_read = ?
         WHERE id = ?`,
        [
            title,
            message,
            is_read,
            id
        ]
    );

    return result;
};


// ======================================================
// DELETE NOTIFICATION PERMANENTLY
// ======================================================

const deleteNotification = async (id) => {
    const [result] = await db.query(
        `DELETE FROM notifications
         WHERE id = ?`,
        [id]
    );

    return result;
};


// ======================================================
// EXPORT
// ======================================================

module.exports = {
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
};