const pool = require('../../config/db');

const createPlan = async ({
    name,
    description = null,
    duration_value,
    duration_unit,
    price,
    extra_features = null
}) => {
    const [result] = await pool.execute(
        `INSERT INTO plans
        (
            name,
            description,
            duration_value,
            duration_unit,
            price,
            extra_features,
            status
        )
        VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
            name,
            description,
            duration_value,
            duration_unit,
            price,
            extra_features,
            'ACTIVE'
        ]
    );

    return result.insertId;
};

const findPlanById = async (id) => {
    const [rows] = await pool.execute(
        `SELECT
            id,
            name,
            description,
            duration_value,
            duration_unit,
            price,
            extra_features,
            status,
            created_at,
            updated_at
         FROM plans
         WHERE id = ?
         LIMIT 1`,
        [id]
    );

    return rows[0] || null;
};

const findPlanByName = async (name) => {
    const [rows] = await pool.execute(
        `SELECT
            id,
            name,
            status
         FROM plans
         WHERE name = ?
         LIMIT 1`,
        [name]
    );

    return rows[0] || null;
};

const getAllPlans = async () => {
    const [rows] = await pool.execute(
        `SELECT
            id,
            name,
            description,
            duration_value,
            duration_unit,
            price,
            extra_features,
            status,
            created_at,
            updated_at
         FROM plans
         ORDER BY created_at DESC`
    );

    return rows;
};

module.exports = {
    createPlan,
    findPlanById,
    findPlanByName,
    getAllPlans
};