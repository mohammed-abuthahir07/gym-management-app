const pool = require('../../config/db');


/*
 * Get total workout check-in days
 * for the logged-in member.
 */
const getCheckInDays = async (memberId) => {
    const [rows] = await pool.execute(
        `
        SELECT COUNT(DISTINCT completed_date) AS total
        FROM workout_completions
        WHERE member_id = ?
        `,
        [memberId]
    );

    return rows[0].total;
};


/*
 * Get current diet plan
 * assigned to the logged-in member.
 *
 * Latest diet plan is treated as
 * the current diet plan.
 */
const getCurrentDietPlan = async (memberId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            dp.id,
            dp.title,
            dp.plan_name,
            dp.daily_calories,
            dp.daily_protein,
            dp.cheat_days_per_week,
            dp.created_at,
            dp.updated_at,

            trainer.id AS trainer_id,
            trainer.name AS trainer_name,
            trainer.email AS trainer_email

        FROM diet_plans dp

        INNER JOIN users trainer
            ON trainer.id = dp.trainer_id
            AND trainer.role = 'TRAINER'

        WHERE dp.member_id = ?

        ORDER BY dp.created_at DESC

        LIMIT 1
        `,
        [memberId]
    );

    return rows.length > 0 ? rows[0] : null;
};


/*
 * Get total workout plans
 * assigned to the logged-in member.
 */
const getWorkoutPlansCount = async (memberId) => {
    const [rows] = await pool.execute(
        `
        SELECT COUNT(*) AS total
        FROM workout_plans
        WHERE member_id = ?
        `,
        [memberId]
    );

    return rows[0].total;
};


/*
 * Get unread notification count
 * for the logged-in member.
 */
const getNotificationCount = async (memberId) => {
    const [rows] = await pool.execute(
        `
        SELECT COUNT(*) AS total
        FROM notifications
        WHERE recipient_id = ?
          AND recipient_role = 'MEMBER'
          AND is_read = FALSE
        `,
        [memberId]
    );

    return rows[0].total;
};
const getPreviousMonthProgress = async (memberId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            id,
            member_id,
            progress_date,
            weight,
            body_fat,
            waist_cm,
            arms_cm,
            notes,
            created_at,
            updated_at

        FROM progress

        WHERE member_id = ?

          AND progress_date >= DATE_FORMAT(
              DATE_SUB(CURDATE(), INTERVAL 1 MONTH),
              '%Y-%m-01'
          )

          AND progress_date < DATE_FORMAT(
              CURDATE(),
              '%Y-%m-01'
          )

        ORDER BY progress_date DESC

        LIMIT 1
        `,
        [memberId]
    );

    return rows.length > 0 ? rows[0] : null;
};

const getTodayWorkoutPlans = async (memberId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            wp.id AS workout_plan_id,
            wp.plan_name,

            wpe.id AS workout_plan_exercise_id,
            wpe.workout_day,
            wpe.sets,
            wpe.reps,
            wpe.duration_minutes,
            wpe.notes,

            e.id AS exercise_id,
            e.name AS exercise_name,
            e.muscle_group,
            e.equipment,
            e.instructions,
            e.image_url,
            e.video_url,
            e.difficulty

        FROM workout_plans wp

        INNER JOIN workout_plan_exercises wpe
            ON wpe.workout_plan_id = wp.id

        INNER JOIN exercises e
            ON e.id = wpe.exercise_id

        WHERE wp.member_id = ?

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

        AND e.status = 'ACTIVE'

        ORDER BY wp.id DESC, wpe.id ASC
        `,
        [memberId]
    );

    return rows;
};

module.exports = {
    getCheckInDays,
    getCurrentDietPlan,
    getWorkoutPlansCount,
    getNotificationCount,
    getPreviousMonthProgress,
    getTodayWorkoutPlans
};