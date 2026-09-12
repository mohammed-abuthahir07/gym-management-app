const pool = require('../../config/db');


// ======================================================
// CREATE PLAN
// ======================================================

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


// ======================================================
// FIND PLAN BY ID
// ======================================================

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


// ======================================================
// FIND PLAN BY NAME
// ======================================================

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


// ======================================================
// FIND PLAN BY NAME EXCEPT CURRENT ID
// ======================================================

const findPlanByNameExceptId = async (name, id) => {
    const [rows] = await pool.execute(
        `SELECT
            id,
            name,
            status
         FROM plans
         WHERE name = ?
           AND id != ?
         LIMIT 1`,
        [name, id]
    );

    return rows[0] || null;
};


// ======================================================
// GET ALL PLANS
// ======================================================

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


// ======================================================
// UPDATE PLAN
// ======================================================

const updatePlan = async ({
    id,
    name,
    description,
    duration_value,
    duration_unit,
    price,
    extra_features,
    status
}) => {
    const [result] = await pool.execute(
        `UPDATE plans
         SET
            name = ?,
            description = ?,
            duration_value = ?,
            duration_unit = ?,
            price = ?,
            extra_features = ?,
            status = ?
         WHERE id = ?`,
        [
            name,
            description,
            duration_value,
            duration_unit,
            price,
            extra_features,
            status,
            id
        ]
    );

    return result;
};


// ======================================================
// DELETE PLAN - PERMANENT DELETE
// ======================================================

const deletePlan = async (id) => {
    const [result] = await pool.execute(
        `DELETE FROM plans
         WHERE id = ?`,
        [id]
    );

    return result;
};


module.exports = {
    createPlan,
    findPlanById,
    findPlanByName,
    findPlanByNameExceptId,
    getAllPlans,
    updatePlan,
    deletePlan
};