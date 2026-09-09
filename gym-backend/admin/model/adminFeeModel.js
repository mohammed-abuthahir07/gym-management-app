const pool = require('../../config/db');


// Create fee
const createFee = async (
    memberId,
    memberName,
    memberEmail,
    fitnessGoal,
    feeAmount,
    feeDate,
    feeMonth,
    feeYear,
    paymentStatus
) => {
    const [result] = await pool.execute(
        `
        INSERT INTO fees
        (
            member_id,
            member_name,
            member_email,
            fitness_goal,
            fee_amount,
            fee_date,
            fee_month,
            fee_year,
            payment_status
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        `,
        [
            memberId,
            memberName,
            memberEmail,
            fitnessGoal || null,
            feeAmount,
            feeDate,
            feeMonth,
            feeYear,
            paymentStatus
        ]
    );

    return result.insertId;
};


// Get all fee records
const getAllFees = async () => {
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
        ORDER BY fee_year DESC, fee_date DESC, id DESC
        `
    );

    return rows;
};


// Get all fee history of one member
const getMemberFeeHistory = async (memberId) => {
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


// Get one fee by ID
const getFeeById = async (feeId) => {
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
        LIMIT 1
        `,
        [feeId]
    );

    return rows.length > 0 ? rows[0] : null;
};


// Update fee
const updateFee = async (
    feeId,
    memberName,
    memberEmail,
    fitnessGoal,
    feeAmount,
    feeDate,
    feeMonth,
    feeYear,
    paymentStatus
) => {
    const [result] = await pool.execute(
        `
        UPDATE fees
        SET
            member_name = ?,
            member_email = ?,
            fitness_goal = ?,
            fee_amount = ?,
            fee_date = ?,
            fee_month = ?,
            fee_year = ?,
            payment_status = ?
        WHERE id = ?
        `,
        [
            memberName,
            memberEmail,
            fitnessGoal || null,
            feeAmount,
            feeDate,
            feeMonth,
            feeYear,
            paymentStatus,
            feeId
        ]
    );

    return result.affectedRows;
};


// Delete fee
const deleteFee = async (feeId) => {
    const [result] = await pool.execute(
        `
        DELETE FROM fees
        WHERE id = ?
        `,
        [feeId]
    );

    return result.affectedRows;
};

const getCurrentMonthFeeStatus = async () => {
    const [rows] = await pool.execute(`
        SELECT
            member.id AS member_id,
            member.name AS member_name,
            member.email AS member_email,
            mp.fitness_goal,
            CASE
                WHEN f.payment_status = 'PAID' THEN 'PAID'
                ELSE 'UNPAID'
            END AS payment_status
        FROM users member
        LEFT JOIN member_profiles mp
            ON mp.member_id = member.id
        LEFT JOIN fees f
            ON f.member_id = member.id
            AND f.fee_year = YEAR(CURDATE())
            AND f.fee_month = UPPER(DATE_FORMAT(CURDATE(), '%M'))
        WHERE member.role = 'MEMBER'
          AND member.status = 'ACTIVE'
        ORDER BY member.name ASC
    `);

    return rows;
};


module.exports = {
    createFee,
    getAllFees,
    getMemberFeeHistory,
    getFeeById,
    updateFee,
    deleteFee,
    getCurrentMonthFeeStatus
};