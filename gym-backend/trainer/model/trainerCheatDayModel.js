const pool = require('../../config/db');


// =====================================================
// GET ALL MEMBERS ASSIGNED TO LOGGED-IN TRAINER
// =====================================================

const getAssignedMembers = async (trainerId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            id,
            name,
            email,
            phone,
            status,
            created_at
        FROM users
        WHERE trainer_id = ?
          AND role = 'MEMBER'
          AND status = 'ACTIVE'
        ORDER BY name ASC
        `,
        [trainerId]
    );

    return rows;
};


// =====================================================
// GET ALL CHEAT ACTIVITIES OF ONE ASSIGNED MEMBER
// =====================================================

const getMemberCheatDays = async (memberId, trainerId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            cd.id,
            cd.member_id,
            cd.cheat_date,
            cd.food_name,
            cd.quantity,
            cd.calories,
            cd.notes,
            cd.created_at,
            cd.updated_at
        FROM cheat_days cd

        INNER JOIN users member
            ON member.id = cd.member_id
            AND member.role = 'MEMBER'

        WHERE cd.member_id = ?
          AND member.trainer_id = ?
          AND member.status = 'ACTIVE'

        ORDER BY cd.cheat_date DESC, cd.id DESC
        `,
        [memberId, trainerId]
    );

    return rows;
};


// =====================================================
// GET ONE CHEAT ACTIVITY
// =====================================================

const getMemberCheatDayById = async (
    cheatDayId,
    memberId,
    trainerId
) => {
    const [rows] = await pool.execute(
        `
        SELECT
            cd.id,
            cd.member_id,
            cd.cheat_date,
            cd.food_name,
            cd.quantity,
            cd.calories,
            cd.notes,
            cd.created_at,
            cd.updated_at
        FROM cheat_days cd

        INNER JOIN users member
            ON member.id = cd.member_id
            AND member.role = 'MEMBER'

        WHERE cd.id = ?
          AND cd.member_id = ?
          AND member.trainer_id = ?
          AND member.status = 'ACTIVE'

        LIMIT 1
        `,
        [
            cheatDayId,
            memberId,
            trainerId
        ]
    );

    return rows.length > 0 ? rows[0] : null;
};


// =====================================================
// GET CURRENT MONTH CHEAT ACTIVITIES
// OF ALL ASSIGNED MEMBERS
// =====================================================

const getCurrentMonthCheatDays = async (trainerId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            cd.id,
            cd.member_id,
            member.name AS member_name,
            member.email AS member_email,
            cd.cheat_date,
            cd.food_name,
            cd.quantity,
            cd.calories,
            cd.notes,
            cd.created_at,
            cd.updated_at
        FROM cheat_days cd

        INNER JOIN users member
            ON member.id = cd.member_id
            AND member.role = 'MEMBER'

        WHERE member.trainer_id = ?
          AND member.status = 'ACTIVE'

          AND cd.cheat_date >= DATE_FORMAT(
              CURDATE(),
              '%Y-%m-01'
          )

          AND cd.cheat_date < DATE_FORMAT(
              DATE_ADD(CURDATE(), INTERVAL 1 MONTH),
              '%Y-%m-01'
          )

        ORDER BY
            member.name ASC,
            cd.cheat_date DESC,
            cd.id DESC
        `,
        [trainerId]
    );

    return rows;
};


// =====================================================
// GET PREVIOUS MONTH CHEAT ACTIVITIES
// OF ALL ASSIGNED MEMBERS
// =====================================================

const getPreviousMonthCheatDays = async (trainerId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            cd.id,
            cd.member_id,
            member.name AS member_name,
            member.email AS member_email,
            cd.cheat_date,
            cd.food_name,
            cd.quantity,
            cd.calories,
            cd.notes,
            cd.created_at,
            cd.updated_at
        FROM cheat_days cd

        INNER JOIN users member
            ON member.id = cd.member_id
            AND member.role = 'MEMBER'

        WHERE member.trainer_id = ?
          AND member.status = 'ACTIVE'

          AND cd.cheat_date >= DATE_FORMAT(
              DATE_SUB(CURDATE(), INTERVAL 1 MONTH),
              '%Y-%m-01'
          )

          AND cd.cheat_date < DATE_FORMAT(
              CURDATE(),
              '%Y-%m-01'
          )

        ORDER BY
            member.name ASC,
            cd.cheat_date DESC,
            cd.id DESC
        `,
        [trainerId]
    );

    return rows;
};


module.exports = {
    getAssignedMembers,
    getMemberCheatDays,
    getMemberCheatDayById,
    getCurrentMonthCheatDays,
    getPreviousMonthCheatDays
};