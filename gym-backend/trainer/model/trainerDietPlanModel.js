const pool = require('../../config/db');


// Check whether member is assigned to this trainer
const checkMemberAssignedToTrainer = async (memberId, trainerId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            id,
            name,
            email,
            status,
            trainer_id
        FROM users
        WHERE id = ?
          AND trainer_id = ?
          AND role = 'MEMBER'
        LIMIT 1
        `,
        [memberId, trainerId]
    );

    return rows.length > 0 ? rows[0] : null;
};


// Create diet plan
const createDietPlan = async (
    trainerId,
    memberId,
    title,
    planName,
    dailyCalories,
    dailyProtein,
    cheatDaysPerWeek
) => {
    const [result] = await pool.execute(
        `
        INSERT INTO diet_plans
        (
            trainer_id,
            member_id,
            title,
            plan_name,
            daily_calories,
            daily_protein,
            cheat_days_per_week
        )
        VALUES (?, ?, ?, ?, ?, ?, ?)
        `,
        [
            trainerId,
            memberId,
            title,
            planName,
            dailyCalories,
            dailyProtein,
            cheatDaysPerWeek
        ]
    );

    return result.insertId;
};


// Get all diet plans created by trainer
const getTrainerDietPlans = async (trainerId) => {
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

            member.name AS member_name,
            member.email AS member_email

        FROM diet_plans dp

        INNER JOIN users member
            ON member.id = dp.member_id
            AND member.role = 'MEMBER'

        WHERE dp.trainer_id = ?

        ORDER BY dp.created_at DESC
        `,
        [trainerId]
    );

    return rows;
};


// Get one diet plan created by trainer
const getTrainerDietPlanById = async (planId, trainerId) => {
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

            member.name AS member_name,
            member.email AS member_email

        FROM diet_plans dp

        INNER JOIN users member
            ON member.id = dp.member_id
            AND member.role = 'MEMBER'

        WHERE dp.id = ?
          AND dp.trainer_id = ?

        LIMIT 1
        `,
        [planId, trainerId]
    );

    return rows.length > 0 ? rows[0] : null;
};


// Delete diet plan
const deleteTrainerDietPlan = async (planId, trainerId) => {
    const [result] = await pool.execute(
        `
        DELETE FROM diet_plans
        WHERE id = ?
          AND trainer_id = ?
        `,
        [planId, trainerId]
    );

    return result.affectedRows > 0;
};

// Update diet plan
const updateTrainerDietPlan = async (
    planId,
    trainerId,
    title,
    planName,
    dailyCalories,
    dailyProtein,
    cheatDaysPerWeek
) => {
    const [result] = await pool.execute(
        `
        UPDATE diet_plans
        SET
            title = ?,
            plan_name = ?,
            daily_calories = ?,
            daily_protein = ?,
            cheat_days_per_week = ?
        WHERE id = ?
          AND trainer_id = ?
        `,
        [
            title,
            planName,
            dailyCalories,
            dailyProtein,
            cheatDaysPerWeek,
            planId,
            trainerId
        ]
    );

    return result.affectedRows > 0;
};


module.exports = {
    checkMemberAssignedToTrainer,
    createDietPlan,
    getTrainerDietPlans,
    getTrainerDietPlanById,
    updateTrainerDietPlan,
    deleteTrainerDietPlan
};