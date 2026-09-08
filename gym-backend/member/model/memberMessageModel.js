const pool = require('../../config/db');

// Get the trainer assigned to this member
const getAssignedTrainer = async (memberId) => {
    const [rows] = await pool.execute(
        `SELECT
            trainer.id,
            trainer.name,
            trainer.email,
            trainer.phone,
            trainer.status
         FROM users member
         INNER JOIN users trainer
            ON trainer.id = member.trainer_id
           AND trainer.role = 'TRAINER'
         WHERE member.id = ?
           AND member.role = 'MEMBER'
           AND member.status = 'ACTIVE'`,
        [memberId]
    );

    return rows[0] || null;
};


// Send message from member to assigned trainer
const sendMessage = async (memberId, trainerId, message) => {
    const [result] = await pool.execute(
        `INSERT INTO messages
        (
            sender_id,
            sender_role,
            receiver_id,
            receiver_role,
            message
        )
        VALUES (?, 'MEMBER', ?, 'TRAINER', ?)`,
        [memberId, trainerId, message]
    );

    return result.insertId;
};


// Get conversation between member and assigned trainer
const getConversation = async (memberId, trainerId) => {
    const [rows] = await pool.execute(
        `SELECT
            id,
            sender_id,
            sender_role,
            receiver_id,
            receiver_role,
            message,
            is_read,
            created_at,
            updated_at
         FROM messages
         WHERE
            (
                sender_id = ?
                AND receiver_id = ?
            )
            OR
            (
                sender_id = ?
                AND receiver_id = ?
            )
         ORDER BY created_at ASC`,
        [
            memberId,
            trainerId,
            trainerId,
            memberId
        ]
    );

    return rows;
};


// Mark message as read by member
const markMessageAsRead = async (memberId, messageId) => {
    const [result] = await pool.execute(
        `UPDATE messages
         SET is_read = TRUE
         WHERE id = ?
           AND receiver_id = ?
           AND receiver_role = 'MEMBER'`,
        [messageId, memberId]
    );

    return result.affectedRows > 0;
};

module.exports = {
    getAssignedTrainer,
    sendMessage,
    getConversation,
    markMessageAsRead
};