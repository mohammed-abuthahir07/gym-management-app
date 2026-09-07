const pool = require('../../config/db');

const getAllContacts = async () => {
    const [rows] = await pool.query(
        `SELECT
            id,
            name,
            email,
            phone,
            message,
            status,
            created_at,
            updated_at
         FROM contacts
         ORDER BY created_at DESC`
    );

    return rows;
};

const getContactById = async (id) => {
    const [rows] = await pool.query(
        `SELECT
            id,
            name,
            email,
            phone,
            message,
            status,
            created_at,
            updated_at
         FROM contacts
         WHERE id = ?`,
        [id]
    );

    return rows[0];
};

const markContactAsRead = async (id) => {
    const [result] = await pool.query(
        `UPDATE contacts
         SET status = 'READ'
         WHERE id = ?`,
        [id]
    );

    return result;
};

const deleteContact = async (id) => {
    const [result] = await pool.query(
        `DELETE FROM contacts
         WHERE id = ?`,
        [id]
    );

    return result;
};

module.exports = {
    getAllContacts,
    getContactById,
    markContactAsRead,
    deleteContact
};