const bcrypt = require('bcryptjs');
const pool = require('../config/db');

// =====================================
// CREATE ADMIN ACCOUNT
// ======================================

const createAdmin = async () => {
    try {
        // Admin account details
        const name = 'Gym Admin';
        const email = 'admin@gym.com';
        const phone = '9999999999';
        const password = 'Admin@123';

        // ======================================
        // CHECK IF ADMIN ALREADY EXISTS
        // ======================================

        const [existingAdmin] = await pool.execute(
            `SELECT id
             FROM users
             WHERE email = ?
             LIMIT 1`,
            [email]
        );

        if (existingAdmin.length > 0) {

            console.log('Admin account already exists.');
            process.exit(0);
        }

        // ======================================
        // HASH PASSWORD
        // ======================================

        const hashedPassword = await bcrypt.hash(
            password,
            10
        );

        // ======================================
        // INSERT ADMIN
        // ======================================
        const [result] = await pool.execute(
            `INSERT INTO users
            (
                name,
                email,
                password,
                role,
                phone,
                fitness_goal,
                status
            )
            VALUES (?, ?, ?, ?, ?, ?, ?)`,
            [
                name,
                email,
                hashedPassword,
                'ADMIN',
                phone,
                null,
                'ACTIVE'
            ]
        );
        console.log('======================================');
        console.log('Admin created successfully');
        console.log('======================================');
        console.log(`Admin ID: ${result.insertId}`);
        console.log(`Email: ${email}`);
        console.log(`Password: ${password}`);
        console.log('Role: ADMIN');
        console.log('Status: ACTIVE');
        console.log('======================================');
    } catch (error) {
        console.error('Error creating admin:', error);
    } finally {
        await pool.end();
    }
};


createAdmin();