const pool = require('../../config/db');


// ========================================
// MEMBER COUNT
// ========================================

const getMemberDashboard = async () => {
    const [rows] = await pool.query(`
        SELECT
            COUNT(*) AS total_members,
            SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END) AS active_members,
            SUM(CASE WHEN status = 'INACTIVE' THEN 1 ELSE 0 END) AS inactive_members
        FROM users
        WHERE role = 'MEMBER'
    `);

    return rows[0];
};


// ========================================
// TRAINER COUNT
// ========================================

const getTrainerDashboard = async () => {
    const [rows] = await pool.query(`
        SELECT
            COUNT(*) AS total_trainers,
            SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END) AS active_trainers,
            SUM(CASE WHEN status = 'INACTIVE' THEN 1 ELSE 0 END) AS inactive_trainers
        FROM users
        WHERE role = 'TRAINER'
    `);

    return rows[0];
};


// ========================================
// PLAN COUNT
// ========================================

const getPlanDashboard = async () => {
    const [rows] = await pool.query(`
        SELECT COUNT(*) AS total_plans
        FROM plans
    `);

    return rows[0];
};


// ========================================
// PROMOTION COUNT
// ========================================

const getPromotionDashboard = async () => {
    const [rows] = await pool.query(`
        SELECT COUNT(*) AS total_promotions
        FROM promotions
    `);

    return rows[0];
};


// ========================================
// CHALLENGE COUNT
// ========================================

const getChallengeDashboard = async () => {
    const [rows] = await pool.query(`
        SELECT COUNT(*) AS total_challenges
        FROM challenges
    `);

    return rows[0];
};


// ========================================
// RECENT PLANS
// ========================================

const getRecentPlans = async () => {
    const [rows] = await pool.query(`
        SELECT
            id,
            name,
            description,
            duration_value,
            duration_unit,
            price,
            extra_features,
            status,
            created_at
        FROM plans
        ORDER BY created_at DESC
        LIMIT 5
    `);

    return rows;
};


// ========================================
// RECENT PROMOTIONS
// ========================================

const getRecentPromotions = async () => {
    const [rows] = await pool.query(`
        SELECT
            id,
            title,
            code,
            description,
            discount,
            discount_type,
            start_date,
            end_date,
            status,
            created_at
        FROM promotions
        ORDER BY created_at DESC
        LIMIT 5
    `);

    return rows;
};


// ========================================
// RECENT CHALLENGES
// ========================================

const getRecentChallenges = async () => {
    const [rows] = await pool.query(`
        SELECT
            id,
            title,
            description,
            start_date,
            end_date,
            reward,
            status,
            created_at
        FROM challenges
        ORDER BY created_at DESC
        LIMIT 5
    `);

    return rows;
};


module.exports = {
    getMemberDashboard,
    getTrainerDashboard,
    getPlanDashboard,
    getPromotionDashboard,
    getChallengeDashboard,

    getRecentPlans,
    getRecentPromotions,
    getRecentChallenges
};