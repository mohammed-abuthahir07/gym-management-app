const pool = require('../../config/db');

const createMember = async ({
    name,
    email,
    password,
    phone = null,
    fitness_goal = null
}) => {

    const [result] = await pool.execute(
        `INSERT INTO users
        (
            name,
            email,
            password,
            role,
            phone,
            fitness_goal,
            status
        )
        VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
            name,
            email,
            password,
            'MEMBER',
            phone,
            fitness_goal,
            'ACTIVE'
        ]
    );

    return result.insertId;
};

const findMemberByEmail = async (email) => {

    const [rows] = await pool.execute(
        `SELECT *
         FROM users
         WHERE email = ?
         AND role = 'MEMBER'
         LIMIT 1`,
        [email]
    );

    return rows[0] || null;
};

const findMemberById = async (id) => {

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
         AND role = 'MEMBER'
         LIMIT 1`,
        [id]
    );

    return rows[0] || null;
};

module.exports = {
    createMember,
    findMemberByEmail,
    findMemberById
};