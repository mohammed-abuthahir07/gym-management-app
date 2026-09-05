const pool = require('../../config/db');


// ======================================
// FIND TRAINER BY EMAIL
// ======================================

const findTrainerByEmail = async (email) => {

    const [rows] = await pool.execute(
        `SELECT id
         FROM users
         WHERE email = ?
         LIMIT 1`,
        [email]
    );

    return rows[0] || null;
};


// ======================================
// CREATE TRAINER
// ======================================

const createTrainer = async ({
    name,
    email,
    password,
    phone = null
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
            'TRAINER',
            phone,
            null,
            'ACTIVE'
        ]
    );

    return result.insertId;
};


module.exports = {
    findTrainerByEmail,
    createTrainer
};