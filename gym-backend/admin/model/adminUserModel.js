const pool = require('../../config/db');


// =====================================================
// GET ALL MEMBERS
// =====================================================
const getAllMembers = async () => {

    const [rows] = await pool.execute(
        `SELECT
            member.id,
            member.name,
            member.email,
            member.phone,
            member.fitness_goal,
            member.role,
            member.status,
            member.created_at,
            member.updated_at,

            member.trainer_id,
            trainer.name AS trainer_name,
            trainer.email AS trainer_email

         FROM users AS member

         LEFT JOIN users AS trainer
            ON member.trainer_id = trainer.id
            AND trainer.role = 'TRAINER'

         WHERE member.role = 'MEMBER'

         ORDER BY member.created_at DESC`
    );

    return rows;
};


// =====================================================
// GET SINGLE MEMBER
// =====================================================
const findMemberById = async (id) => {

    const [rows] = await pool.execute(
        `SELECT
            member.id,
            member.name,
            member.email,
            member.phone,
            member.fitness_goal,
            member.role,
            member.status,
            member.created_at,
            member.updated_at,

            member.trainer_id,
            trainer.name AS trainer_name,
            trainer.email AS trainer_email

         FROM users AS member

         LEFT JOIN users AS trainer
            ON member.trainer_id = trainer.id
            AND trainer.role = 'TRAINER'

         WHERE member.id = ?
         AND member.role = 'MEMBER'

         LIMIT 1`,
        [id]
    );

    return rows[0] || null;
};


// =====================================================
// SOFT DELETE MEMBER
// =====================================================
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


// =====================================================
// GET ALL TRAINERS
// =====================================================
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


// =====================================================
// GET SINGLE TRAINER
// =====================================================
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


// =====================================================
// SOFT DELETE TRAINER
// =====================================================
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


// =====================================================
// ASSIGN TRAINER TO MEMBER
// =====================================================
const assignTrainerToMember = async (memberId, trainerId) => {

    const [result] = await pool.execute(
        `UPDATE users
         SET trainer_id = ?
         WHERE id = ?
         AND role = 'MEMBER'`,
        [trainerId, memberId]
    );

    return result.affectedRows;
};


// =====================================================
// REMOVE TRAINER FROM MEMBER
// =====================================================
const removeTrainerFromMember = async (memberId) => {

    const [result] = await pool.execute(
        `UPDATE users
         SET trainer_id = NULL
         WHERE id = ?
         AND role = 'MEMBER'`,
        [memberId]
    );

    return result.affectedRows;
};


module.exports = {

    // Members
    getAllMembers,
    findMemberById,
    deactivateMember,

    // Trainers
    getAllTrainers,
    findTrainerById,
    deactivateTrainer,

    // Trainer Assignment
    assignTrainerToMember,
    removeTrainerFromMember
};