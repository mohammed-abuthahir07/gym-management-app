const pool = require('../../config/db');


// Check whether member is assigned to trainer
const checkMemberAssignedToTrainer = async (memberId, trainerId) => {
    const [rows] = await pool.execute(
        `
        SELECT id
        FROM users
        WHERE id = ?
          AND trainer_id = ?
          AND role = 'MEMBER'
          AND status = 'ACTIVE'
        LIMIT 1
        `,
        [memberId, trainerId]
    );

    return rows.length > 0;
};


// Create diet plan entry
const createDietPlan = async (
    trainerId,
    memberId,
    dietDay,
    mealType,
    foodName,
    calories,
    protein,
    notes
) => {
    const [result] = await pool.execute(
        `
        INSERT INTO diet_plans
        (
            trainer_id,
            member_id,
            diet_day,
            meal_type,
            food_name,
            calories,
            protein,
            notes
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        `,
        [
            trainerId,
            memberId,
            dietDay,
            mealType,
            foodName,
            calories,
            protein,
            notes || null
        ]
    );

    return result.insertId;
};


// Get all diet entries created by trainer
const getTrainerDietPlans = async (trainerId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            dp.id,
            dp.member_id,
            member.name AS member_name,
            member.email AS member_email,

            dp.diet_day,
            dp.meal_type,
            dp.food_name,
            dp.calories,
            dp.protein,
            dp.notes,

            dp.created_at,
            dp.updated_at

        FROM diet_plans dp

        INNER JOIN users member
            ON member.id = dp.member_id
            AND member.role = 'MEMBER'

        WHERE dp.trainer_id = ?

        ORDER BY
            dp.member_id,
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
            )
        `,
        [trainerId]
    );

    return rows;
};


// Get one diet entry
const getTrainerDietPlanById = async (dietPlanId, trainerId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            dp.id,
            dp.member_id,
            member.name AS member_name,
            member.email AS member_email,

            dp.diet_day,
            dp.meal_type,
            dp.food_name,
            dp.calories,
            dp.protein,
            dp.notes,

            dp.created_at,
            dp.updated_at

        FROM diet_plans dp

        INNER JOIN users member
            ON member.id = dp.member_id
            AND member.role = 'MEMBER'

        WHERE dp.id = ?
          AND dp.trainer_id = ?

        LIMIT 1
        `,
        [dietPlanId, trainerId]
    );

    return rows.length > 0 ? rows[0] : null;
};


// Update diet entry
const updateDietPlan = async (
    dietPlanId,
    trainerId,
    dietDay,
    mealType,
    foodName,
    calories,
    protein,
    notes
) => {
    const [result] = await pool.execute(
        `
        UPDATE diet_plans

        SET
            diet_day = ?,
            meal_type = ?,
            food_name = ?,
            calories = ?,
            protein = ?,
            notes = ?

        WHERE id = ?
          AND trainer_id = ?
        `,
        [
            dietDay,
            mealType,
            foodName,
            calories,
            protein,
            notes || null,
            dietPlanId,
            trainerId
        ]
    );

    return result.affectedRows;
};


// Delete diet entry
const deleteDietPlan = async (dietPlanId, trainerId) => {
    const [result] = await pool.execute(
        `
        DELETE FROM diet_plans
        WHERE id = ?
          AND trainer_id = ?
        `,
        [dietPlanId, trainerId]
    );

    return result.affectedRows;
};


module.exports = {
    checkMemberAssignedToTrainer,
    createDietPlan,
    getTrainerDietPlans,
    getTrainerDietPlanById,
    updateDietPlan,
    deleteDietPlan
};