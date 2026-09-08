const pool = require('../../config/db');

// Check whether the member is assigned to this trainer
const checkMemberAssigned = async (trainerId, memberId) => {
    const [rows] = await pool.execute(
        `SELECT id
         FROM users
         WHERE id = ?
           AND role = 'MEMBER'
           AND trainer_id = ?
           AND status = 'ACTIVE'`,
        [memberId, trainerId]
    );

    return rows.length > 0;
};

// Send message from trainer to assigned member
const sendMessage = async (trainerId, memberId, message) => {
    const [result] = await pool.execute(
        `INSERT INTO messages
        (
            sender_id,
            sender_role,
            receiver_id,
            receiver_role,
            message
        )
        VALUES (?, 'TRAINER', ?, 'MEMBER', ?)`,
        [trainerId, memberId, message]
    );

    return result.insertId;
};

// Get all members who have conversations with this trainer
const getMessageMembers = async (trainerId) => {
    const [rows] = await pool.execute(
        `SELECT
            u.id,
            u.name,
            u.email,
            u.phone,
            u.status,
            MAX(m.created_at) AS last_message_at
         FROM users u
         INNER JOIN messages m
            ON (
                (m.sender_id = u.id AND m.receiver_id = ?)
                OR
                (m.receiver_id = u.id AND m.sender_id = ?)
            )
         WHERE u.role = 'MEMBER'
           AND u.trainer_id = ?
           AND u.status = 'ACTIVE'
         GROUP BY
            u.id,
            u.name,
            u.email,
            u.phone,
            u.status
         ORDER BY last_message_at DESC`,
        [trainerId, trainerId, trainerId]
    );

    return rows;
};

// Get complete conversation between trainer and assigned member
const getConversation = async (trainerId, memberId) => {
    const [rows] = await pool.execute(
        `SELECT
            m.id,
            m.sender_id,
            m.sender_role,
            m.receiver_id,
            m.receiver_role,
            m.message,
            m.is_read,
            m.created_at,
            m.updated_at
         FROM messages m
         INNER JOIN users member
            ON member.id = ?
           AND member.role = 'MEMBER'
           AND member.trainer_id = ?
         WHERE
            (
                m.sender_id = ?
                AND m.receiver_id = ?
            )
            OR
            (
                m.sender_id = ?
                AND m.receiver_id = ?
            )
         ORDER BY m.created_at ASC`,
        [
            memberId,
            trainerId,
            trainerId,
            memberId,
            memberId,
            trainerId
        ]
    );

    return rows;
};

// Mark a message as read by trainer
const markMessageAsRead = async (trainerId, messageId) => {
    const [result] = await pool.execute(
        `UPDATE messages
         SET is_read = TRUE
         WHERE id = ?
           AND receiver_id = ?
           AND receiver_role = 'TRAINER'`,
        [messageId, trainerId]
    );

    return result.affectedRows > 0;
};

module.exports = {
    checkMemberAssigned,
    sendMessage,
    getMessageMembers,
    getConversation,
    markMessageAsRead
};