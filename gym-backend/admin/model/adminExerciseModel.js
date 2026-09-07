const pool = require('../../config/db');


// ======================================
// CREATE EXERCISE
// ======================================
const createExercise = async ({
    name,
    muscle_group = null,
    equipment = null,
    instructions = null,
    image_url = null,
    video_url = null,
    difficulty
}) => {
    const [result] = await pool.execute(
        `INSERT INTO exercises
        (
            name,
            muscle_group,
            equipment,
            instructions,
            image_url,
            video_url,
            difficulty,
            status
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
            name,
            muscle_group,
            equipment,
            instructions,
            image_url,
            video_url,
            difficulty,
            'ACTIVE'
        ]
    );

    return result.insertId;
};


// ======================================
// GET EXERCISE BY ID
// ======================================
const findExerciseById = async (id) => {
    const [rows] = await pool.execute(
        `SELECT
            id,
            name,
            muscle_group,
            equipment,
            instructions,
            image_url,
            video_url,
            difficulty,
            status,
            created_at,
            updated_at
         FROM exercises
         WHERE id = ?
         LIMIT 1`,
        [id]
    );

    return rows[0] || null;
};


// ======================================
// GET ALL EXERCISES
// ======================================
const getAllExercises = async () => {
    const [rows] = await pool.execute(
        `SELECT
            id,
            name,
            muscle_group,
            equipment,
            instructions,
            image_url,
            video_url,
            difficulty,
            status,
            created_at,
            updated_at
         FROM exercises
         ORDER BY created_at DESC`
    );

    return rows;
};


// ======================================
// CHECK EXERCISE NAME
// ======================================
const findExerciseByName = async (name) => {
    const [rows] = await pool.execute(
        `SELECT
            id,
            name,
            status
         FROM exercises
         WHERE name = ?
         LIMIT 1`,
        [name]
    );

    return rows[0] || null;
};


// ======================================
// UPDATE EXERCISE
// ======================================
const updateExercise = async (
    id,
    {
        name,
        muscle_group,
        equipment,
        instructions,
        image_url,
        video_url,
        difficulty,
        status
    }
) => {
    const [result] = await pool.execute(
        `UPDATE exercises
         SET
            name = ?,
            muscle_group = ?,
            equipment = ?,
            instructions = ?,
            image_url = ?,
            video_url = ?,
            difficulty = ?,
            status = ?
         WHERE id = ?`,
        [
            name,
            muscle_group,
            equipment,
            instructions,
            image_url,
            video_url,
            difficulty,
            status,
            id
        ]
    );

    return result.affectedRows;
};


// ======================================
// DELETE EXERCISE
// ======================================
const deleteExercise = async (id) => {
    const [result] = await pool.execute(
        `DELETE FROM exercises
         WHERE id = ?`,
        [id]
    );

    return result.affectedRows;
};


module.exports = {
    createExercise,
    findExerciseById,
    getAllExercises,
    findExerciseByName,
    updateExercise,
    deleteExercise
};