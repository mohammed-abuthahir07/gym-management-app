const pool = require('../../config/db');


// ==========================================
// MEMBER ANALYTICS
// Month-wise member joining
// ==========================================

const getMemberAnalytics = async () => {

    // Total members
    const [totalRows] = await pool.query(`
        SELECT COUNT(*) AS total_members
        FROM users
        WHERE role = 'MEMBER'
    `);


    // Members joined in current month
    const [currentMonthRows] = await pool.query(`
        SELECT
            id,
            name,
            email,
            phone,
            created_at AS joined_date
        FROM users
        WHERE role = 'MEMBER'
          AND created_at >= DATE_FORMAT(CURDATE(), '%Y-%m-01')
          AND created_at < DATE_ADD(
              DATE_FORMAT(CURDATE(), '%Y-%m-01'),
              INTERVAL 1 MONTH
          )
        ORDER BY created_at DESC
    `);


    return {
        total_members: totalRows[0].total_members,
        current_month_joined: currentMonthRows.length,
        current_month_members: currentMonthRows
    };
};



// ==========================================
// TRAINER ANALYTICS
// ==========================================

const getTrainerAnalytics = async () => {

    // Total trainers
    const [totalRows] = await pool.query(`
        SELECT COUNT(*) AS total_trainers
        FROM users
        WHERE role = 'TRAINER'
    `);


    // Trainers joined in current month
    const [currentMonthRows] = await pool.query(`
        SELECT
            id,
            name,
            email,
            phone,
            created_at AS joined_date
        FROM users
        WHERE role = 'TRAINER'
          AND created_at >= DATE_FORMAT(CURDATE(), '%Y-%m-01')
          AND created_at < DATE_ADD(
              DATE_FORMAT(CURDATE(), '%Y-%m-01'),
              INTERVAL 1 MONTH
          )
        ORDER BY created_at DESC
    `);


    return {
        total_trainers: totalRows[0].total_trainers,
        current_month_joined: currentMonthRows.length,
        current_month_trainers: currentMonthRows
    };
};

// ==========================================
// MOST RECENT PLANS
// ==========================================

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


// ==========================================
// MOST RECENT PROMOTIONS
// ==========================================

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


// ==========================================
// MOST RECENT CHALLENGES
// ==========================================

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
    getMemberAnalytics,
    getTrainerAnalytics,
    getRecentPlans,
    getRecentPromotions,
    getRecentChallenges
};