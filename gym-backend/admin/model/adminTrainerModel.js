const pool = require('../../config/db');


// ============================================================
// FIND TRAINER BY EMAIL
// ============================================================

const findTrainerByEmail = async (email) => {

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
         WHERE email = ?
         LIMIT 1`,
        [email]
    );

    return rows[0] || null;
};


// ============================================================
// FIND TRAINER BY ID
// ============================================================

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


// ============================================================
// GET ALL TRAINERS
// ============================================================

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
         ORDER BY id DESC`
    );

    return rows;
};


// ============================================================
// CREATE TRAINER
// ============================================================

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


// ============================================================
// CHECK EMAIL FOR UPDATE
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
        [
            email,
            trainerId
        ]
    );

    return rows[0] || null;
};


// ============================================================
// UPDATE TRAINER
// WITHOUT PASSWORD
// ============================================================

const updateTrainer = async ({
    id,
    name,
    email,
    phone,
    status
}) => {

    const [result] = await pool.execute(
        `UPDATE users
         SET
            name = ?,
            email = ?,
            phone = ?,
            status = ?
         WHERE id = ?
           AND role = 'TRAINER'`,
        [
            name,
            email,
            phone,
            status,
            id
        ]
    );

    return result;
};


// ============================================================
// UPDATE TRAINER
// WITH PASSWORD
// ============================================================

const updateTrainerWithPassword = async ({
    id,
    name,
    email,
    phone,
    password,
    status
}) => {

    const [result] = await pool.execute(
        `UPDATE users
         SET
            name = ?,
            email = ?,
            phone = ?,
            password = ?,
            status = ?
         WHERE id = ?
           AND role = 'TRAINER'`,
        [
            name,
            email,
            phone,
            password,
            status,
            id
        ]
    );

    return result;
};


// ============================================================
// DEACTIVATE TRAINER
// DELETE = SOFT DELETE
// ============================================================

const deactivateTrainer = async (id) => {

    const [result] = await pool.execute(
        `UPDATE users
         SET status = 'INACTIVE'
         WHERE id = ?
           AND role = 'TRAINER'
           AND status = 'ACTIVE'`,
        [id]
    );

    return result;
};


// ============================================================
// EXPORT
// ============================================================

module.exports = {
    findTrainerByEmail,
    findTrainerById,
    getAllTrainers,
    createTrainer,
    findTrainerByEmailExceptId,
    updateTrainer,
    updateTrainerWithPassword,
    deactivateTrainer
};