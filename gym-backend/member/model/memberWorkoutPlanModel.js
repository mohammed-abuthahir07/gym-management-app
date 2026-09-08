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


const markWorkoutExerciseCompleted = async (
    memberId,
    workoutPlanExerciseId
) => {
    const [result] = await pool.execute(
        `
        INSERT INTO workout_completions
        (
            member_id,
            workout_plan_exercise_id,
            completed_date
        )
        VALUES (?, ?, CURDATE())
        `,
        [
            memberId,
            workoutPlanExerciseId
        ]
    );

    return result.insertId;
};

const getWorkoutCompletionById = async (
    memberId,
    workoutPlanExerciseId
) => {
    const [rows] = await pool.execute(
        `
        SELECT
            wc.id,
            wc.member_id,
            wc.workout_plan_exercise_id,
            wc.completed_date,
            wc.completed_at
        FROM workout_completions wc
        WHERE wc.member_id = ?
          AND wc.workout_plan_exercise_id = ?
          AND wc.completed_date = CURDATE()
        LIMIT 1
        `,
        [
            memberId,
            workoutPlanExerciseId
        ]
    );

    return rows.length > 0 ? rows[0] : null;
};


module.exports = {
    getMemberWorkoutPlans,
    getMemberWorkoutPlanById,
    markWorkoutExerciseCompleted,
    getWorkoutCompletionById
};