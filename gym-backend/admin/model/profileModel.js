const pool = require('../../config/db');

// Find admin profile by ID
const findAdminById = async (adminId) => {
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
           AND role = 'ADMIN'
         LIMIT 1`,
        [adminId]
    );

    return rows[0] || null;
};

// Check whether another user is already using this email
const findAdminByEmailExceptId = async (email, adminId) => {
    const [rows] = await pool.execute(
        `SELECT
            id,
            email,
            role
         FROM users
         WHERE email = ?
           AND id != ?
         LIMIT 1`,
        [email, adminId]
    );

    return rows[0] || null;
};

// Update only admin profile fields
const updateAdminProfile = async ({
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
           AND role = 'ADMIN'`,
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
    findAdminById,
    findAdminByEmailExceptId,
    updateAdminProfile
};