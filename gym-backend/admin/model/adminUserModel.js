const pool = require('../../config/db');


// ================================
// GET ALL MEMBERS
// ================================
const getAllMembers = async () => {
    const [rows] = await pool.execute(
        `SELECT
            id,
            name,
            email,
            phone,
            fitness_goal,
            role,
            status,
            created_at,
            updated_at
         FROM users
         WHERE role = 'MEMBER'
         ORDER BY created_at DESC`
    );

    return rows;
};


// ================================
// GET SINGLE MEMBER
// ================================
const findMemberById = async (id) => {
    const [rows] = await pool.execute(
        `SELECT
            id,
            name,
            email,
            phone,
            fitness_goal,
            role,
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


// ================================
// SOFT DELETE MEMBER
// ================================
const deactivateMember = async (id) => {
    const [result] = await pool.execute(
        `UPDATE users
         SET status = 'INACTIVE'
         WHERE id = ?
         AND role = 'MEMBER'`,
        [id]
    );

    return result.affectedRows;
};


// ================================
// GET ALL TRAINERS
// ================================
const getAllTrainers = async () => {
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
         WHERE role = 'TRAINER'
         ORDER BY created_at DESC`
    );

    return rows;
};


// ================================
// GET SINGLE TRAINER
// ================================
const findTrainerById = async (id) => {
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
        [id]
    );

    return rows[0] || null;
};


// ================================
// SOFT DELETE TRAINER
// ================================
const deactivateTrainer = async (id) => {
    const [result] = await pool.execute(
        `UPDATE users
         SET status = 'INACTIVE'
         WHERE id = ?
         AND role = 'TRAINER'`,
        [id]
    );

    return result.affectedRows;
};


module.exports = {
    getAllMembers,
    findMemberById,
    deactivateMember,
    getAllTrainers,
    findTrainerById,
    deactivateTrainer
};