const pool = require('../../config/db');

// ======================================================
// CREATE CONTENT
// ======================================================

const createContent = async (contentData) => {

    const {
        title,
        image,
        description
    } = contentData;

    const [result] = await pool.execute(
        `
        INSERT INTO content
        (
            title,
            image,
            description
        )
        VALUES (?, ?, ?)
        `,
        [
            title,
            image,
            description
        ]
    );

    return result;
};

// ======================================================
// GET ALL CONTENT
// ======================================================

const getAllContent = async () => {

    const [rows] = await pool.execute(
        `
        SELECT
            id,
            title,
            image,
            description,
            created_at,
            updated_at
        FROM content
        ORDER BY created_at DESC
        `
    );

    return rows;
};

// ======================================================
// GET CONTENT BY ID
// ======================================================

const getContentById = async (id) => {

    const [rows] = await pool.execute(
        `
        SELECT
            id,
            title,
            image,
            description,
            created_at,
            updated_at
        FROM content
        WHERE id = ?
        LIMIT 1
        `,
        [id]
    );

    return rows.length > 0
        ? rows[0]
        : null;
};

// ======================================================
// UPDATE CONTENT
// ======================================================

const updateContent = async (
    id,
    contentData
) => {

    const {
        title,
        image,
        description
    } = contentData;

    const [result] = await pool.execute(
        `
        UPDATE content
        SET
            title = ?,
            image = ?,
            description = ?
        WHERE id = ?
        `,
        [
            title,
            image,
            description,
            id
        ]
    );

    return result;
};

// ======================================================
// DELETE CONTENT
// ======================================================

const deleteContent = async (id) => {

    const [result] = await pool.execute(
        `
        DELETE FROM content
        WHERE id = ?
        `,
        [id]
    );

    return result;
};

// ======================================================
// EXPORT
// ======================================================

module.exports = {
    createContent,
    getAllContent,
    getContentById,
    updateContent,
    deleteContent
};