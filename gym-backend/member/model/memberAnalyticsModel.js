const pool = require('../../config/db');

/*
==================================================
1. CURRENT MONTH CHECK-IN DAYS
==================================================
*/

const getCurrentMonthCheckinDays = async (memberId) => {
    const [rows] = await pool.execute(`
        SELECT COUNT(DISTINCT completed_date) AS checkin_days
        FROM workout_completions
        WHERE member_id = ?
          AND completed_date >= DATE_FORMAT(CURDATE(), '%Y-%m-01')
          AND completed_date < DATE_ADD(
              DATE_FORMAT(CURDATE(), '%Y-%m-01'),
              INTERVAL 1 MONTH
          )
    `, [memberId]);

    return Number(rows[0].checkin_days || 0);
};


/*
==================================================
2. CURRENT MONTH PAYMENT STATUS
==================================================
*/

const getCurrentMonthPaymentStatus = async (memberId) => {
    const [rows] = await pool.execute(`
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
          AND YEAR(fee_date) = YEAR(CURDATE())
          AND MONTH(fee_date) = MONTH(CURDATE())
        ORDER BY fee_date DESC, id DESC
        LIMIT 1
    `, [memberId]);

    return rows.length > 0 ? rows[0] : null;
};


/*
==================================================
3. TOMORROW'S WORKOUT
==================================================
*/

const getTomorrowWorkout = async (memberId) => {
    const [rows] = await pool.execute(`
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
            CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 1 DAY))
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
    `, [memberId]);

    return rows;
};


/*
==================================================
4. CURRENT MONTH CHEAT MEALS
==================================================
*/

const getCurrentMonthCheatMeals = async (memberId) => {
    const [rows] = await pool.execute(`
        SELECT
            id,
            member_id,
            cheat_date,
            food_name,
            quantity,
            calories,
            notes,
            created_at,
            updated_at

        FROM cheat_days

        WHERE member_id = ?

          AND cheat_date >= DATE_FORMAT(
              CURDATE(),
              '%Y-%m-01'
          )

          AND cheat_date < DATE_ADD(
              DATE_FORMAT(CURDATE(), '%Y-%m-01'),
              INTERVAL 1 MONTH
          )

        ORDER BY cheat_date DESC, id DESC
    `, [memberId]);

    return rows;
};

const getCurrentMonthProgress = async (memberId) => {
    const [rows] = await pool.execute(`
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
              CURDATE(),
              '%Y-%m-01'
          )
          AND progress_date < DATE_ADD(
              DATE_FORMAT(
                  CURDATE(),
                  '%Y-%m-01'
              ),
              INTERVAL 1 MONTH
          )
        ORDER BY progress_date DESC, id DESC
    `, [memberId]);

    return rows;
};


module.exports = {
    getCurrentMonthCheckinDays,
    getCurrentMonthPaymentStatus,
    getTomorrowWorkout,
    getCurrentMonthCheatMeals,
    getCurrentMonthProgress
};