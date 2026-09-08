const db = require('../../config/db');

// Get all active exercises for members
const getAllExercises = async () => {
    const [rows] = await db.execute(
        `SELECT 
            id,
            name,
            muscle_group,
            equipment,
            instructions,
            image_url,
            video_url,
            difficulty
         FROM exercises
         WHERE status = 'ACTIVE'
         ORDER BY created_at DESC`
    );

    return rows;
};

module.exports = {
    getAllExercises
};