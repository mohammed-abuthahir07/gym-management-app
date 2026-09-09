const pool = require('../../config/db');


// ==========================================
// CURRENT MONTH REVENUE
// ==========================================

const getCurrentMonthRevenue = async () => {
    const [rows] = await pool.execute(`
        SELECT COALESCE(SUM(fee_amount), 0) AS revenue
        FROM fees
        WHERE payment_status = 'PAID'
          AND fee_year = YEAR(CURDATE())
          AND fee_month = UPPER(DATE_FORMAT(CURDATE(), '%M'))
    `);

    return Number(rows[0].revenue);
};


// ==========================================
// CURRENT YEAR REVENUE
// ==========================================

const getCurrentYearRevenue = async () => {
    const [rows] = await pool.execute(`
        SELECT COALESCE(SUM(fee_amount), 0) AS revenue
        FROM fees
        WHERE payment_status = 'PAID'
          AND fee_year = YEAR(CURDATE())
    `);

    return Number(rows[0].revenue);
};


// ==========================================
// TOTAL REVENUE
// ==========================================

const getTotalRevenue = async () => {
    const [rows] = await pool.execute(`
        SELECT COALESCE(SUM(fee_amount), 0) AS revenue
        FROM fees
        WHERE payment_status = 'PAID'
    `);

    return Number(rows[0].revenue);
};


// ==========================================
// CURRENT MONTH CHECK-INS
// ==========================================

const getCurrentMonthCheckIns = async () => {
    const [rows] = await pool.execute(`
        SELECT
            member.id AS member_id,
            member.name AS member_name,
            COUNT(DISTINCT wc.completed_date) AS check_in_days
        FROM users member

        LEFT JOIN workout_completions wc
            ON wc.member_id = member.id
            AND wc.completed_date >= DATE_FORMAT(
                CURDATE(),
                '%Y-%m-01'
            )
            AND wc.completed_date < DATE_ADD(
                DATE_FORMAT(CURDATE(), '%Y-%m-01'),
                INTERVAL 1 MONTH
            )

        WHERE member.role = 'MEMBER'
          AND member.status = 'ACTIVE'

        GROUP BY member.id, member.name

        ORDER BY member.name ASC
    `);

    return rows;
};


// ==========================================
// CURRENT YEAR CHECK-INS
// ==========================================

const getCurrentYearCheckIns = async () => {
    const [rows] = await pool.execute(`
        SELECT
            member.id AS member_id,
            member.name AS member_name,
            COUNT(DISTINCT wc.completed_date) AS check_in_days
        FROM users member

        LEFT JOIN workout_completions wc
            ON wc.member_id = member.id
            AND YEAR(wc.completed_date) = YEAR(CURDATE())

        WHERE member.role = 'MEMBER'
          AND member.status = 'ACTIVE'

        GROUP BY member.id, member.name

        ORDER BY member.name ASC
    `);

    return rows;
};


// ==========================================
// CURRENT MONTH UNPAID MEMBERS
// ==========================================

const getCurrentMonthUnpaidMembers = async () => {
    const [rows] = await pool.execute(`
        SELECT
            member.id AS member_id,
            member.name AS member_name,
            member.email AS member_email,
            mp.fitness_goal,

            'UNPAID' AS payment_status

        FROM users member

        LEFT JOIN member_profiles mp
            ON mp.member_id = member.id

        LEFT JOIN fees f
            ON f.member_id = member.id
            AND f.fee_year = YEAR(CURDATE())
            AND f.fee_month = UPPER(DATE_FORMAT(CURDATE(), '%M'))

        WHERE member.role = 'MEMBER'
          AND member.status = 'ACTIVE'

          AND (
              f.id IS NULL
              OR f.payment_status = 'UNPAID'
          )

        ORDER BY member.name ASC
    `);

    return rows;
};


module.exports = {
    getCurrentMonthRevenue,
    getCurrentYearRevenue,
    getTotalRevenue,
    getCurrentMonthCheckIns,
    getCurrentYearCheckIns,
    getCurrentMonthUnpaidMembers
};