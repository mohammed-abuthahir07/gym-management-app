const pool = require('../../config/db');


/**
 * Get all diet plans belonging to logged-in member
 */
const getMemberDietPlans = async (memberId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            dp.id,
            dp.trainer_id,
            dp.member_id,
            dp.title,
            dp.plan_name,
            dp.daily_calories,
            dp.daily_protein,
            dp.cheat_days_per_week,
            dp.created_at,
            dp.updated_at,

            trainer.name AS trainer_name,
            trainer.email AS trainer_email

        FROM diet_plans dp

        INNER JOIN users trainer
            ON trainer.id = dp.trainer_id
            AND trainer.role = 'TRAINER'

        WHERE dp.member_id = ?

        ORDER BY dp.created_at DESC
        `,
        [memberId]
    );

    return rows;
};


/**
 * Get one diet plan belonging to logged-in member
 */
const getMemberDietPlanById = async (planId, memberId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            dp.id,
            dp.trainer_id,
            dp.member_id,
            dp.title,
            dp.plan_name,
            dp.daily_calories,
            dp.daily_protein,
            dp.cheat_days_per_week,
            dp.created_at,
            dp.updated_at,

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
        [planId, memberId]
    );

    return rows.length > 0 ? rows[0] : null;
};


module.exports = {
    getMemberDietPlans,
    getMemberDietPlanById
};