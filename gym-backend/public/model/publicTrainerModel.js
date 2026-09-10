const pool = require('../../config/db');

const getPublicTrainers = async () => {
    const [rows] = await pool.execute(`
        SELECT
            id,
            name,
            email,
            phone,
            status
        FROM users
        WHERE role = 'TRAINER'
        ORDER BY name ASC
    `);

    return rows;
};

module.exports = {
    getPublicTrainers
};