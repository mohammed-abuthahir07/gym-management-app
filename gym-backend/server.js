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
const adminDashboardRoutes = require('./admin/routes/adminDashboardRoutes');
const adminContentRoutes = require('./admin/routes/adminContentRoutes');
const adminAnalyticsRoutes = require('./admin/routes/adminAnalyticsRoutes');
const memberExerciseRoutes = require('./member/routes/memberExerciseRoutes');
const memberChallengeRoutes = require('./member/routes/memberChallengeRoutes');
const memberProgressRoutes = require('./member/routes/memberProgressRoutes');
const memberProfileRoutes = require('./member/routes/memberProfileRoutes');
const adminNotificationRoutes = require('./admin/routes/adminNotificationRoutes');
const memberNotificationRoutes = require('./member/routes/memberNotificationRoutes');
const trainerAssignedRoutes =require('./trainer/routes/trainerAssignedRoutes');
const trainerClassScheduleRoutes = require('./trainer/routes/trainerClassScheduleRoutes');
const memberClassScheduleRoutes =require('./member/routes/memberClassScheduleRoutes');
const trainerWorkoutPlanRoutes = require('./trainer/routes/trainerWorkoutPlanRoutes');
const memberWorkoutPlanRoutes = require('./member/routes/memberWorkoutPlanRoutes');
const trainerDietPlanRoutes = require('./trainer/routes/trainerDietPlanRoutes');
const memberDietPlanRoutes = require('./member/routes/memberDietPlanRoutes');
const trainerMessageRoutes = require('./trainer/routes/trainerMessageRoutes');
const memberMessageRoutes = require('./member/routes/memberMessageRoutes');
const trainerDashboardRoutes = require('./trainer/routes/trainerDashboardRoutes');
const memberDashboardRoutes = require('./member/routes/memberDashboardRoutes');

const app = express();


app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static('uploads'));

// PUBLIC SIDE API
app.use('/api/contact', contactRoutes);

// MEMBER SIDE API
app.use('/api/member/auth', memberAuthRoutes);
app.use('/api/member', memberExerciseRoutes);
app.use('/api/member', memberChallengeRoutes);
app.use('/api/member', memberProgressRoutes);
app.use('/api/member', memberProfileRoutes);
app.use('/api/member',memberNotificationRoutes);
app.use('/api/member',memberClassScheduleRoutes);
app.use('/api/member', memberWorkoutPlanRoutes);
app.use('/api/member', memberDietPlanRoutes);
app.use('/api/member', memberMessageRoutes);
app.use('/api/member', memberDashboardRoutes);

// TRAINER SIDE API
app.use('/api/trainer/auth', trainerAuthRoutes);
app.use('/api/trainer',trainerAssignedRoutes);
app.use('/api/trainer',trainerClassScheduleRoutes);
app.use('/api/trainer', trainerWorkoutPlanRoutes);
app.use('/api/trainer', trainerDietPlanRoutes);
app.use('/api/trainer', trainerMessageRoutes);
app.use('/api/trainer', trainerDashboardRoutes);


// ADMIN SIDE API
app.use('/api/admin/auth', adminAuthRoutes);
app.use('/api/admin/trainers', adminTrainerRoutes);
app.use('/api/admin/plans', adminPlanRoutes);
app.use('/api/admin/promotions', adminPromotionRoutes);
app.use('/api/admin/challenges', adminChallengesRoutes);
app.use('/api/admin', adminUserRoutes);
app.use('/api/admin', adminNotificationRoutes);
app.use('/api/admin/exercises',adminExerciseRoutes);
app.use('/api/admin/contacts', adminContactRoutes);
app.use('/api/admin/dashboard', adminDashboardRoutes);
app.use('/api/admin/dashboard', adminDashboardRoutes);
app.use('/api/admin/content', adminContentRoutes);  
app.use('/api/admin/analytics', adminAnalyticsRoutes);

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