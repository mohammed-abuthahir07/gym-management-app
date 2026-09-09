const pool = require('../../config/db');

// Get all fees for the logged-in member
const getMemberFees = async (memberId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            id,
            member_id,
            member_name,
            member_email,
            fitness_goal,
            fee_amount,
            fee_date,
            fee_month,
            fee_year,
            payment_status,
            created_at,
            updated_at
        FROM fees
        WHERE member_id = ?
        ORDER BY fee_year DESC, fee_date DESC, id DESC
        `,
        [memberId]
    );

    return rows;
};


// Get one specific fee for the logged-in member
const getMemberFeeById = async (feeId, memberId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            id,
            member_id,
            member_name,
            member_email,
            fitness_goal,
            fee_amount,
            fee_date,
            fee_month,
            fee_year,
            payment_status,
            created_at,
            updated_at
        FROM fees
        WHERE id = ?
          AND member_id = ?
        LIMIT 1
        `,
        [feeId, memberId]
    );

    return rows.length > 0 ? rows[0] : null;
};

const getCurrentMonthFeeStatus = async (memberId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            id,
            member_id,
            member_name,
            member_email,
            fitness_goal,
            fee_amount,
            fee_date,
            fee_month,
            fee_year,
            payment_status
        FROM fees
        WHERE member_id = ?
          AND fee_year = YEAR(CURDATE())
          AND fee_month = UPPER(DATE_FORMAT(CURDATE(), '%M'))
        ORDER BY fee_date DESC, id DESC
        LIMIT 1
        `,
        [memberId]
    );

    return rows.length > 0 ? rows[0] : null;
};

const getMemberPaidFeeHistory = async (memberId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            fee_month,
            fee_year,
            payment_status
        FROM fees
        WHERE member_id = ?
          AND payment_status = 'PAID'
        ORDER BY fee_year DESC, fee_date DESC, id DESC
        `,
        [memberId]
    );

    return rows;
};
module.exports = {
    getMemberFees,
    getMemberFeeById,
    getCurrentMonthFeeStatus,
    getMemberPaidFeeHistory
};