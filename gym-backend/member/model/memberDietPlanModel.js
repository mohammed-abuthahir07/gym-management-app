const pool = require('../../config/db');


// Get all diet plans for the logged-in member
const getMemberDietPlans = async (memberId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            dp.id,
            dp.diet_day,
            dp.meal_type,
            dp.food_name,
            dp.calories,
            dp.protein,
            dp.notes,
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

        ORDER BY
            FIELD(
                dp.diet_day,
                'MONDAY',
                'TUESDAY',
                'WEDNESDAY',
                'THURSDAY',
                'FRIDAY',
                'SATURDAY',
                'SUNDAY'
            ),
            FIELD(
                dp.meal_type,
                'BREAKFAST',
                'LUNCH',
                'DINNER'
            ),
            dp.id ASC
        `,
        [memberId]
    );

    return rows;
};


// Get one diet plan entry
const getMemberDietPlanById = async (dietPlanId, memberId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            dp.id,
            dp.diet_day,
            dp.meal_type,
            dp.food_name,
            dp.calories,
            dp.protein,
            dp.notes,
            dp.created_at,
            dp.updated_at,

            trainer.id AS trainer_id,
            trainer.name AS trainer_name,
            trainer.email AS trainer_email

        FROM diet_plans dp

        INNER JOIN users trainer
            ON trainer.id = dp.trainer_id
            AND trainer.role = 'TRAINER'

        WHERE dp.id = ?
          AND dp.member_id = ?

        LIMIT 1
        `,
        [dietPlanId, memberId]
    );

    return rows.length > 0 ? rows[0] : null;
};


// Get today's diet
const getTodayDietPlan = async (memberId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            dp.id,
            dp.diet_day,
            dp.meal_type,
            dp.food_name,
            dp.calories,
            dp.protein,
            dp.notes,

            trainer.id AS trainer_id,
            trainer.name AS trainer_name

        FROM diet_plans dp

        INNER JOIN users trainer
            ON trainer.id = dp.trainer_id
            AND trainer.role = 'TRAINER'

        WHERE dp.member_id = ?

          AND dp.diet_day =
            CASE DAYOFWEEK(CURDATE())
                WHEN 1 THEN 'SUNDAY'
                WHEN 2 THEN 'MONDAY'
                WHEN 3 THEN 'TUESDAY'
                WHEN 4 THEN 'WEDNESDAY'
                WHEN 5 THEN 'THURSDAY'
                WHEN 6 THEN 'FRIDAY'
                WHEN 7 THEN 'SATURDAY'
            END

        ORDER BY
            FIELD(
                dp.meal_type,
                'BREAKFAST',
                'LUNCH',
                'DINNER'
            )
        `,
        [memberId]
    );

    return rows;
};


module.exports = {
    getMemberDietPlans,
    getMemberDietPlanById,
    getTodayDietPlan
};