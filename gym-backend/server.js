require('dotenv').config();
const express = require('express');
const cors = require('cors');
const pool = require('./config/db');
const memberAuthRoutes = require('./member/routes/memberAuthRoutes');
const adminAuthRoutes = require('./admin/routes/adminAuthRoutes');
const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));



// MEMBER SIDE API
app.use('/api/member/auth', memberAuthRoutes);

// ADMIN SIDE API
app.use('/api/admin/auth', adminAuthRoutes);

const PORT = process.env.PORT || 5000;

const startServer = async () => {
    try {
        const connection = await pool.getConnection();
        console.log('MySQL connected successfully');
        connection.release();
        app.listen(PORT, () => {
            console.log(`Server running on port ${PORT}`);
        });
    } catch (error) {
        console.error('MySQL connection failed:', error);
        process.exit(1);
    }
};

startServer();