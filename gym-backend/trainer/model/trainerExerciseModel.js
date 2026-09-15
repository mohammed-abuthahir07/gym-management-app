const db = require('../../config/db');

// ==========================================
// GET ACTIVE EXERCISES FOR TRAINER
// ==========================================

const getTrainerExercises = async () => {

    const [rows] = await db.query(
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
         WHERE status = 'ACTIVE'
         ORDER BY name ASC`
    );

    return rows;
};

module.exports = {
    getTrainerExercises
};