const pool = require('../../config/db');

const getTodayWorkoutAnalytics = async (trainerId) => {
    const [rows] = await pool.execute(`
        SELECT
            member.id AS member_id,
            member.name AS member_name,

            GROUP_CONCAT(
                DISTINCT wp.plan_name
                ORDER BY wp.id DESC
                SEPARATOR ', '
            ) AS workout_name,

            COUNT(DISTINCT wpe.id) AS total_exercises,

            COUNT(
                DISTINCT CASE
                    WHEN wc.id IS NOT NULL THEN wpe.id
                END
            ) AS completed_exercises

        FROM users member

        LEFT JOIN workout_plans wp
            ON wp.member_id = member.id
           AND wp.trainer_id = ?

        LEFT JOIN workout_plan_exercises wpe
            ON wpe.workout_plan_id = wp.id
           AND wpe.workout_day =
                CASE DAYOFWEEK(CURDATE())
                    WHEN 1 THEN 'SUNDAY'
                    WHEN 2 THEN 'MONDAY'
                    WHEN 3 THEN 'TUESDAY'
                    WHEN 4 THEN 'WEDNESDAY'
                    WHEN 5 THEN 'THURSDAY'
                    WHEN 6 THEN 'FRIDAY'
                    WHEN 7 THEN 'SATURDAY'
                END

        LEFT JOIN workout_completions wc
            ON wc.workout_plan_exercise_id = wpe.id
           AND wc.member_id = member.id
           AND wc.completed_date = CURDATE()

        WHERE member.trainer_id = ?
          AND member.role = 'MEMBER'
          AND member.status = 'ACTIVE'

        GROUP BY
            member.id,
            member.name

        ORDER BY member.name ASC
    `, [trainerId, trainerId]);

    return rows;
};

module.exports = {
    getTodayWorkoutAnalytics
};