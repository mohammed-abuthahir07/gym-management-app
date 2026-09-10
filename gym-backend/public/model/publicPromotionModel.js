const pool = require('../../config/db');

const getPublicPromotions = async () => {
    const [rows] = await pool.execute(`
        SELECT
            id,
            title,
            code,
            description,
            discount,
            discount_type,
            start_date,
            end_date
        FROM promotions
        WHERE status = 'ACTIVE'
        ORDER BY start_date ASC, id ASC
    `);

    return rows;
};

module.exports = {
    getPublicPromotions
};