const pool = require('../../config/db');

const getPublicPlans = async () => {
    const [rows] = await pool.execute(`
        SELECT
            id,
            name,
            description,
            duration_value,
            duration_unit,
            price,
            extra_features
        FROM plans
        WHERE status = 'ACTIVE'
        ORDER BY duration_value ASC, id ASC
    `);

    return rows;
};

module.exports = {
    getPublicPlans
};