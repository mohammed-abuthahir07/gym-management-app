const pool = require('../../config/db');

const createPromotion = async ({
    title,
    code,
    description = null,
    discount,
    discount_type,
    start_date,
    end_date
}) => {
    const [result] = await pool.execute(
        `INSERT INTO promotions
        (
            title,
            code,
            description,
            discount,
            discount_type,
            start_date,
            end_date,
            status
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
            title,
            code,
            description,
            discount,
            discount_type,
            start_date,
            end_date,
            'ACTIVE'
        ]
    );

    return result.insertId;
};

const findPromotionById = async (id) => {
    const [rows] = await pool.execute(
        `SELECT
            id,
            title,
            code,
            description,
            discount,
            discount_type,
            start_date,
            end_date,
            status,
            created_at,
            updated_at
         FROM promotions
         WHERE id = ?
         LIMIT 1`,
        [id]
    );

    return rows[0] || null;
};

const findPromotionByCode = async (code) => {
    const [rows] = await pool.execute(
        `SELECT
            id,
            title,
            code,
            description,
            discount,
            discount_type,
            start_date,
            end_date,
            status
         FROM promotions
         WHERE code = ?
         LIMIT 1`,
        [code]
    );

    return rows[0] || null;
};

const getAllPromotions = async () => {
    const [rows] = await pool.execute(
        `SELECT
            id,
            title,
            code,
            description,
            discount,
            discount_type,
            start_date,
            end_date,
            status,
            created_at,
            updated_at
         FROM promotions
         ORDER BY created_at DESC`
    );

    return rows;
};

const updatePromotion = async (
    id,
    {
        title,
        code,
        description,
        discount,
        discount_type,
        start_date,
        end_date,
        status
    }
) => {
    const [result] = await pool.execute(
        `UPDATE promotions
         SET
            title = ?,
            code = ?,
            description = ?,
            discount = ?,
            discount_type = ?,
            start_date = ?,
            end_date = ?,
            status = ?
         WHERE id = ?`,
        [
            title,
            code,
            description,
            discount,
            discount_type,
            start_date,
            end_date,
            status,
            id
        ]
    );

    return result.affectedRows;
};

const deletePromotion = async (id) => {
    const [result] = await pool.execute(
        `DELETE FROM promotions
         WHERE id = ?`,
        [id]
    );

    return result.affectedRows;
};

module.exports = {
    createPromotion,
    findPromotionById,
    findPromotionByCode,
    getAllPromotions,
    updatePromotion,
    deletePromotion
};