const pool = require('../config/db');


// ======================================
// CREATE USER
// ======================================

const createUser = async ({
    name,
    email,
    password,
    role,
    phone = null,
    fitness_goal = null
}) => {

    const [result] = await pool.execute(
        `INSERT INTO users
        (name, email, password, role, phone, fitness_goal)
        VALUES (?, ?, ?, ?, ?, ?)`,
        [
            name,
            email,
            password,
            role,
            phone,
            fitness_goal
        ]
    );

    return result.insertId;
};


// ======================================
// FIND USER BY EMAIL
// ======================================

const findUserByEmail = async (email) => {

    const [rows] = await pool.execute(
        `SELECT *
         FROM users
         WHERE email = ?
         LIMIT 1`,
        [email]
    );

    return rows[0] || null;
};


// ======================================
// FIND USER BY ID
// ======================================

const findUserById = async (id) => {

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
         LIMIT 1`,
        [id]
    );

    return rows[0] || null;
};


module.exports = {
    createUser,
    findUserByEmail,
    findUserById
};