const pool = require('../../config/db');

/**
 * Get all workout plans assigned to a member
 */
const getMemberWorkoutPlans = async (memberId) => {
    const [plans] = await pool.execute(
        `
        SELECT
            wp.id,
            wp.trainer_id,
            wp.member_id,
            wp.plan_name,
            wp.created_at,
            wp.updated_at,
            trainer.name AS trainer_name,
            trainer.email AS trainer_email
        FROM workout_plans wp
        INNER JOIN users trainer
            ON trainer.id = wp.trainer_id
            AND trainer.role = 'TRAINER'
        WHERE wp.member_id = ?
        ORDER BY wp.created_at DESC
        `,
        [memberId]
    );

    for (const plan of plans) {
        const [exercises] = await pool.execute(
            `
            SELECT
                wpe.id,
                wpe.workout_plan_id,
                wpe.exercise_id,
                e.name AS exercise_name,
                e.muscle_group,
                e.equipment,
                e.instructions,
                e.image_url,
                e.video_url,
                wpe.workout_day,
                wpe.sets,
                wpe.reps,
                wpe.duration_minutes,
                wpe.notes,
                wpe.created_at,
                wpe.updated_at
            FROM workout_plan_exercises wpe
            INNER JOIN exercises e
                ON e.id = wpe.exercise_id
            WHERE wpe.workout_plan_id = ?
            ORDER BY
                FIELD(
                    wpe.workout_day,
                    'MONDAY',
                    'TUESDAY',
                    'WEDNESDAY',
                    'THURSDAY',
                    'FRIDAY',
                    'SATURDAY',
                    'SUNDAY'
                ),
                wpe.id ASC
            `,
            [plan.id]
        );

        plan.exercises = exercises;
    }

    return plans;
};


/**
 * Get one workout plan belonging to a member
 */
const getMemberWorkoutPlanById = async (planId, memberId) => {
    const [plans] = await pool.execute(
        `
        SELECT
            wp.id,
            wp.trainer_id,
            wp.member_id,
            wp.plan_name,
            wp.created_at,
            wp.updated_at,
            trainer.name AS trainer_name,
            trainer.email AS trainer_email
        FROM workout_plans wp
        INNER JOIN users trainer
            ON trainer.id = wp.trainer_id
            AND trainer.role = 'TRAINER'
        WHERE wp.id = ?
          AND wp.member_id = ?
        LIMIT 1
        `,
        [planId, memberId]
    );

    if (plans.length === 0) {
        return null;
    }

    const plan = plans[0];

    const [exercises] = await pool.execute(
        `
        SELECT
            wpe.id,
            wpe.workout_plan_id,
            wpe.exercise_id,
            e.name AS exercise_name,
            e.muscle_group,
            e.equipment,
            e.instructions,
            e.image_url,
            e.video_url,
            wpe.workout_day,
            wpe.sets,
            wpe.reps,
            wpe.duration_minutes,
            wpe.notes,
            wpe.created_at,
            wpe.updated_at
        FROM workout_plan_exercises wpe
        INNER JOIN exercises e
            ON e.id = wpe.exercise_id
        WHERE wpe.workout_plan_id = ?
        ORDER BY
            FIELD(
                wpe.workout_day,
                'MONDAY',
                'TUESDAY',
                'WEDNESDAY',
                'THURSDAY',
                'FRIDAY',
                'SATURDAY',
                'SUNDAY'
            ),
            wpe.id ASC
        `,
        [plan.id]
    );

    plan.exercises = exercises;

    return plan;
};


module.exports = {
    getMemberWorkoutPlans,
    getMemberWorkoutPlanById
};