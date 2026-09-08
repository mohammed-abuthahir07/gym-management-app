const pool = require('../../config/db');


// =====================================================
// CHECK MEMBER IS ASSIGNED TO THIS TRAINER
// =====================================================
const checkMemberAssignedToTrainer = async (memberId, trainerId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            id,
            name,
            email,
            trainer_id,
            status
        FROM users
        WHERE id = ?
          AND role = 'MEMBER'
          AND trainer_id = ?
        LIMIT 1
        `,
        [memberId, trainerId]
    );

    return rows[0] || null;
};


// =====================================================
// CHECK ACTIVE EXERCISE
// =====================================================
const getActiveExercise = async (exerciseId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            id,
            name,
            muscle_group,
            equipment,
            instructions,
            image_url,
            video_url,
            difficulty
        FROM exercises
        WHERE id = ?
          AND status = 'ACTIVE'
        LIMIT 1
        `,
        [exerciseId]
    );

    return rows[0] || null;
};


// =====================================================
// CREATE PLAN
// =====================================================
const createWorkoutPlan = async (
    trainerId,
    memberId,
    planName
) => {
    const [result] = await pool.execute(
        `
        INSERT INTO workout_plans
        (
            trainer_id,
            member_id,
            plan_name
        )
        VALUES (?, ?, ?)
        `,
        [
            trainerId,
            memberId,
            planName
        ]
    );

    return result.insertId;
};


// =====================================================
// ADD EXERCISE TO PLAN
// =====================================================
const addWorkoutExercise = async (
    planId,
    exerciseId,
    workoutDay,
    sets,
    reps,
    durationMinutes,
    notes
) => {
    const [result] = await pool.execute(
        `
        INSERT INTO workout_plan_exercises
        (
            workout_plan_id,
            exercise_id,
            workout_day,
            sets,
            reps,
            duration_minutes,
            notes
        )
        VALUES (?, ?, ?, ?, ?, ?, ?)
        `,
        [
            planId,
            exerciseId,
            workoutDay,
            sets,
            reps,
            durationMinutes,
            notes
        ]
    );

    return result.insertId;
};


// =====================================================
// GET ALL TRAINER PLANS
// =====================================================
const getTrainerWorkoutPlans = async (trainerId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            wp.id,
            wp.trainer_id,
            wp.member_id,
            wp.plan_name,
            wp.created_at,
            wp.updated_at,

            m.name AS member_name,
            m.email AS member_email

        FROM workout_plans wp

        INNER JOIN users m
            ON m.id = wp.member_id
           AND m.role = 'MEMBER'

        WHERE wp.trainer_id = ?

        ORDER BY wp.created_at DESC
        `,
        [trainerId]
    );

    return rows;
};


// =====================================================
// GET SINGLE PLAN
// =====================================================
const getTrainerWorkoutPlan = async (
    planId,
    trainerId
) => {
    const [rows] = await pool.execute(
        `
        SELECT
            wp.id,
            wp.trainer_id,
            wp.member_id,
            wp.plan_name,
            wp.created_at,
            wp.updated_at,

            m.name AS member_name,
            m.email AS member_email

        FROM workout_plans wp

        INNER JOIN users m
            ON m.id = wp.member_id
           AND m.role = 'MEMBER'

        WHERE wp.id = ?
          AND wp.trainer_id = ?

        LIMIT 1
        `,
        [
            planId,
            trainerId
        ]
    );

    return rows[0] || null;
};


// =====================================================
// GET PLAN EXERCISES
// =====================================================
const getPlanExercises = async (
    planId,
    trainerId
) => {
    const [rows] = await pool.execute(
        `
        SELECT
            wpe.id,
            wpe.workout_plan_id,
            wpe.exercise_id,
            wpe.workout_day,
            wpe.sets,
            wpe.reps,
            wpe.duration_minutes,
            wpe.notes,

            e.name AS exercise_name,
            e.muscle_group,
            e.equipment,
            e.instructions,
            e.image_url,
            e.video_url,
            e.difficulty

        FROM workout_plan_exercises wpe

        INNER JOIN workout_plans wp
            ON wp.id = wpe.workout_plan_id

        INNER JOIN exercises e
            ON e.id = wpe.exercise_id

        WHERE wpe.workout_plan_id = ?
          AND wp.trainer_id = ?

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
            wpe.id
        `,
        [
            planId,
            trainerId
        ]
    );

    return rows;
};


// =====================================================
// CHECK PLAN EXERCISE BELONGS TO TRAINER
// =====================================================
const getPlanExercise = async (
    workoutExerciseId,
    planId,
    trainerId
) => {
    const [rows] = await pool.execute(
        `
        SELECT
            wpe.*
        FROM workout_plan_exercises wpe

        INNER JOIN workout_plans wp
            ON wp.id = wpe.workout_plan_id

        WHERE wpe.id = ?
          AND wpe.workout_plan_id = ?
          AND wp.trainer_id = ?

        LIMIT 1
        `,
        [
            workoutExerciseId,
            planId,
            trainerId
        ]
    );

    return rows[0] || null;
};


// =====================================================
// UPDATE PLAN NAME
// =====================================================
const updateWorkoutPlan = async (
    planId,
    trainerId,
    planName
) => {
    const [result] = await pool.execute(
        `
        UPDATE workout_plans
        SET plan_name = ?
        WHERE id = ?
          AND trainer_id = ?
        `,
        [
            planName,
            planId,
            trainerId
        ]
    );

    return result;
};


// =====================================================
// UPDATE PLAN EXERCISE
// =====================================================
const updateWorkoutExercise = async (
    workoutExerciseId,
    planId,
    trainerId,
    exerciseId,
    workoutDay,
    sets,
    reps,
    durationMinutes,
    notes
) => {
    const [result] = await pool.execute(
        `
        UPDATE workout_plan_exercises wpe

        INNER JOIN workout_plans wp
            ON wp.id = wpe.workout_plan_id

        SET
            wpe.exercise_id = ?,
            wpe.workout_day = ?,
            wpe.sets = ?,
            wpe.reps = ?,
            wpe.duration_minutes = ?,
            wpe.notes = ?

        WHERE wpe.id = ?
          AND wpe.workout_plan_id = ?
          AND wp.trainer_id = ?
        `,
        [
            exerciseId,
            workoutDay,
            sets,
            reps,
            durationMinutes,
            notes,
            workoutExerciseId,
            planId,
            trainerId
        ]
    );

    return result;
};


// =====================================================
// DELETE PLAN
// =====================================================
const deleteWorkoutPlan = async (
    planId,
    trainerId
) => {
    const [result] = await pool.execute(
        `
        DELETE FROM workout_plans
        WHERE id = ?
          AND trainer_id = ?
        `,
        [
            planId,
            trainerId
        ]
    );

    return result;
};


// =====================================================
// DELETE EXERCISE FROM PLAN
// =====================================================
const deleteWorkoutExercise = async (
    workoutExerciseId,
    planId,
    trainerId
) => {
    const [result] = await pool.execute(
        `
        DELETE wpe
        FROM workout_plan_exercises wpe

        INNER JOIN workout_plans wp
            ON wp.id = wpe.workout_plan_id

        WHERE wpe.id = ?
          AND wpe.workout_plan_id = ?
          AND wp.trainer_id = ?
        `,
        [
            workoutExerciseId,
            planId,
            trainerId
        ]
    );

    return result;
};


module.exports = {
    checkMemberAssignedToTrainer,
    getActiveExercise,
    createWorkoutPlan,
    addWorkoutExercise,
    getTrainerWorkoutPlans,
    getTrainerWorkoutPlan,
    getPlanExercises,
    getPlanExercise,
    updateWorkoutPlan,
    updateWorkoutExercise,
    deleteWorkoutPlan,
    deleteWorkoutExercise
};