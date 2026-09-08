const db = require('../../config/db');

// Get all active challenges for members
const getAllChallenges = async () => {
    const [rows] = await db.execute(
        `SELECT
            id,
            title,
            description,
            start_date,
            end_date,
            reward
         FROM challenges
         WHERE status = 'ACTIVE'
         ORDER BY created_at DESC`
    );

    return rows;
};

module.exports = {
    getAllChallenges
};