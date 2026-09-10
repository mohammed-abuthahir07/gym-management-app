const pool = require('../../config/db');

const getPublicContent = async () => {
    const [rows] = await pool.execute(`
        SELECT
            id,
            title,
            image,
            description
        FROM content
        ORDER BY id DESC
    `);

    return rows;
};

module.exports = {
    getPublicContent
};