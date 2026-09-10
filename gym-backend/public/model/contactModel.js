const pool = require('../../config/db');

const createContact = async (contactData) => {
    const {
        name,
        email,
        phone,
        message
    } = contactData;

    const [result] = await pool.query(
        `INSERT INTO contacts
        (name, email, phone, message)
        VALUES (?, ?, ?, ?)`,
        [
            name,
            email,
            phone || null,
            message
        ]
    );

    return result;
};

module.exports = {
    createContact
};