const pool = require('../../config/db');


// ============================================================
// FIND TRAINER BY ID
// ============================================================

const findTrainerById = async (trainerId) => {
    const [rows] = await pool.execute(
        `SELECT
            id,
            name,
            email,
            phone,
            role,
            status,
            created_at,
            updated_at
         FROM users
         WHERE id = ?
           AND role = 'TRAINER'
         LIMIT 1`,
        [trainerId]
    );

    return rows[0] || null;
};


// ============================================================
// CHECK EMAIL ALREADY EXISTS
// ============================================================

const findTrainerByEmailExceptId = async (
    email,
    trainerId
) => {
    const [rows] = await pool.execute(
        `SELECT
            id,
            email,
            role
         FROM users
         WHERE email = ?
           AND id != ?
         LIMIT 1`,
        [email, trainerId]
    );

    return rows[0] || null;
};


// ============================================================
// UPDATE TRAINER PROFILE
// ============================================================

const updateTrainerProfile = async ({
    id,
    name,
    email,
    phone
}) => {
    const [result] = await pool.execute(
        `UPDATE users
         SET
            name = ?,
            email = ?,
            phone = ?
         WHERE id = ?
           AND role = 'TRAINER'`,
        [
            name,
            email,
            phone,
            id
        ]
    );

    return result;
};


module.exports = {
    findTrainerById,
    findTrainerByEmailExceptId,
    updateTrainerProfile
};