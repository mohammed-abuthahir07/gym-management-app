const pool = require('../../config/db');


// ===============================
// FIND ADMIN BY EMAIL
// ===============================

const findAdminByEmail = async (email) => {

    const [rows] = await pool.execute(
        `SELECT *
         FROM users
         WHERE email = ?
         AND role = 'ADMIN'
         LIMIT 1`,
        [email]
    );

    return rows[0] || null;
};


// ===============================
// FIND ADMIN BY ID
// ===============================

const findAdminById = async (id) => {

    const [rows] = await pool.execute(
        `SELECT
            id,
            name,
            email,
            role,
            phone,
            fitness_goal,
            status,
            created_at,
            updated_at
         FROM users
         WHERE id = ?
         AND role = 'ADMIN'
         LIMIT 1`,
        [id]
    );

    return rows[0] || null;
};


module.exports = {
    findAdminByEmail,
    findAdminById
};