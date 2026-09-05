const express = require('express');
const cors = require('cors');
require('dotenv').config();

const pool = require('./config/db');
const authRoutes = require('./routes/authRoutes');

const app = express();



app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));


app.get('/', (req, res) => {
    res.json({
        success: true,
        message: 'Gym Management API is running'
    });
});

//members side
app.use('/api/auth', authRoutes);



const PORT = process.env.PORT || 5000;

const startServer = async () => {
    try {
        // Test MySQL connection before starting server
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