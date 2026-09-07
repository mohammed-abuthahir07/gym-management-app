require('dotenv').config();
const express = require('express');
const cors = require('cors');
const pool = require('./config/db');
const memberAuthRoutes = require('./member/routes/memberAuthRoutes');
const adminAuthRoutes = require('./admin/routes/adminAuthRoutes');
const adminTrainerRoutes = require('./admin/routes/adminTrainerRoutes');
const trainerAuthRoutes = require('./trainer/routes/trainerAuthRoutes');
const adminPlanRoutes = require('./admin/routes/adminPlanRoutes');
const adminPromotionRoutes = require('./admin/routes/adminPromotionRoutes');
const adminChallengesRoutes = require('./admin/routes/adminChallengesRoutes');
const adminUserRoutes = require('./admin/routes/adminUserRoutes');
const contactRoutes = require('./contact/routes/contactRoutes');
const adminContactRoutes = require('./admin/routes/adminContactRoutes');
const adminExerciseRoutes = require('./admin/routes/adminExerciseRoutes');
const app = express();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// PUBLIC SIDE API
app.use('/api/contact', contactRoutes);

// MEMBER SIDE API
app.use('/api/member/auth', memberAuthRoutes);

// TRAINER SIDE API
app.use('/api/trainer/auth', trainerAuthRoutes);

// ADMIN SIDE API
app.use('/api/admin/auth', adminAuthRoutes);
app.use('/api/admin/trainers', adminTrainerRoutes);
app.use('/api/admin/plans', adminPlanRoutes);
app.use('/api/admin/promotions', adminPromotionRoutes);
app.use('/api/admin/challenges', adminChallengesRoutes);
app.use('/api/admin', adminUserRoutes);
app.use('/api/admin/exercises',adminExerciseRoutes);
app.use('/api/admin/contacts', adminContactRoutes);

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