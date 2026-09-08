const pool = require('../../config/db');

/*
 * Get total members assigned to this trainer
 */
const getAssignedMembersCount = async (trainerId) => {
    const [rows] = await pool.execute(
        `
        SELECT COUNT(*) AS total
        FROM users
        WHERE trainer_id = ?
          AND role = 'MEMBER'
          AND status = 'ACTIVE'
        `,
        [trainerId]
    );

    return rows[0].total;
};


/*
 * Get total diet plans created by this trainer
 */
const getDietPlansCount = async (trainerId) => {
    const [rows] = await pool.execute(
        `
        SELECT COUNT(*) AS total
        FROM diet_plans
        WHERE trainer_id = ?
        `,
        [trainerId]
    );

    return rows[0].total;
};


/*
 * Get total workout plans created by this trainer
 */
const getWorkoutPlansCount = async (trainerId) => {
    const [rows] = await pool.execute(
        `
        SELECT COUNT(*) AS total
        FROM workout_plans
        WHERE trainer_id = ?
        `,
        [trainerId]
    );

    return rows[0].total;
};


/*
 * Get workout check-in count for each assigned member
 *
 * Every record in workout_completions represents
 * a completed workout exercise for a particular date.
 *
 * COUNT(DISTINCT completed_date)
 * means:
 *
 * Monday completed = 1
 * Tuesday completed = 1
 * Wednesday completed = 1
 *
 * Total = 3 workout check-in days
 */
const getMemberCheckIns = async (trainerId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            member.id AS member_id,
            member.name AS member_name,
            COUNT(DISTINCT wc.completed_date) AS check_in_days

        FROM users member

        LEFT JOIN workout_completions wc
            ON wc.member_id = member.id

        WHERE member.trainer_id = ?
          AND member.role = 'MEMBER'
          AND member.status = 'ACTIVE'

        GROUP BY
            member.id,
            member.name

        ORDER BY
            member.name ASC
        `,
        [trainerId]
    );

    return rows;
};


module.exports = {
    getAssignedMembersCount,
    getDietPlansCount,
    getWorkoutPlansCount,
    getMemberCheckIns
};