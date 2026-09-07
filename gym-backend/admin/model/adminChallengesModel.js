const pool = require('../../config/db');

const createChallenge = async ({
    title,
    description = null,
    start_date,
    end_date,
    reward = null
}) => {
    const [result] = await pool.execute(
        `INSERT INTO challenges
        (
            title,
            description,
            start_date,
            end_date,
            reward,
            status
        )
        VALUES (?, ?, ?, ?, ?, ?)`,
        [
            title,
            description,
            start_date,
            end_date,
            reward,
            'ACTIVE'
        ]
    );

    return result.insertId;
};


const findChallengeById = async (id) => {
    const [rows] = await pool.execute(
        `SELECT
            id,
            title,
            description,
            start_date,
            end_date,
            reward,
            status,
            created_at,
            updated_at
         FROM challenges
         WHERE id = ?
         LIMIT 1`,
        [id]
    );

    return rows[0] || null;
};


const getAllChallenges = async () => {
    const [rows] = await pool.execute(
        `SELECT
            id,
            title,
            description,
            start_date,
            end_date,
            reward,
            status,
            created_at,
            updated_at
         FROM challenges
         ORDER BY created_at DESC`
    );

    return rows;
};


const updateChallenge = async (
    id,
    {
        title,
        description,
        start_date,
        end_date,
        reward,
        status
    }
) => {
    const [result] = await pool.execute(
        `UPDATE challenges
         SET
            title = ?,
            description = ?,
            start_date = ?,
            end_date = ?,
            reward = ?,
            status = ?
         WHERE id = ?`,
        [
            title,
            description,
            start_date,
            end_date,
            reward,
            status,
            id
        ]
    );

    return result.affectedRows;
};


const deleteChallenge = async (id) => {
    const [result] = await pool.execute(
        `DELETE FROM challenges
         WHERE id = ?`,
        [id]
    );

    return result.affectedRows;
};


module.exports = {
    createChallenge,
    findChallengeById,
    getAllChallenges,
    updateChallenge,
    deleteChallenge
};