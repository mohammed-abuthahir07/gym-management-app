const {
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
} = require('../model/trainerWorkoutPlanModel');


// =====================================================
// VALID DAYS
// =====================================================
const VALID_DAYS = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY'
];


// =====================================================
// ASSIGN WORKOUT PLAN
//
// This matches your screenshot.
//
// Member
// Plan Name
// Starter Exercise
// Day
// Assign Plan
//
// One API creates BOTH plan + first exercise.
// =====================================================
const assignWorkoutPlan = async (req, res) => {
    const connection = await require('../../config/db').getConnection();

    try {
        const trainerId = req.user.id;

        const {
            member_id,
            plan_name,
            exercise_id,
            workout_day,
            sets,
            reps,
            duration_minutes,
            notes
        } = req.body;

        // ---------------------------------------------
        // BASIC VALIDATION
        // ---------------------------------------------
        if (!member_id) {
            return res.status(400).json({
                message: 'member_id is required'
            });
        }

        if (!plan_name || !plan_name.trim()) {
            return res.status(400).json({
                message: 'plan_name is required'
            });
        }

        if (!exercise_id) {
            return res.status(400).json({
                message: 'exercise_id is required'
            });
        }

        if (!workout_day) {
            return res.status(400).json({
                message: 'workout_day is required'
            });
        }

        if (!VALID_DAYS.includes(workout_day)) {
            return res.status(400).json({
                message: 'Invalid workout_day'
            });
        }

        // ---------------------------------------------
        // CHECK MEMBER
        // ---------------------------------------------
        const member = await checkMemberAssignedToTrainer(
            member_id,
            trainerId
        );

        if (!member) {
            return res.status(404).json({
                message: 'Member not found or not assigned to you'
            });
        }

        if (member.status !== 'ACTIVE') {
            return res.status(400).json({
                message: 'Cannot assign workout to inactive member'
            });
        }

        // ---------------------------------------------
        // CHECK EXERCISE
        // ---------------------------------------------
        const exercise = await getActiveExercise(
            exercise_id
        );

        if (!exercise) {
            return res.status(404).json({
                message: 'Exercise not found or inactive'
            });
        }

        // ---------------------------------------------
        // TRANSACTION
        // ---------------------------------------------
        await connection.beginTransaction();

        // Create plan
        const [planResult] = await connection.execute(
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
                member_id,
                plan_name.trim()
            ]
        );

        const planId = planResult.insertId;

        // Add starter exercise
        const [exerciseResult] = await connection.execute(
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
                exercise_id,
                workout_day,
                sets ?? null,
                reps ?? null,
                duration_minutes ?? null,
                notes ?? null
            ]
        );

        await connection.commit();

        return res.status(201).json({
            message: 'Workout plan assigned successfully',

            plan: {
                id: planId,
                trainer_id: trainerId,
                member_id: member_id,
                member_name: member.name,
                plan_name: plan_name.trim()
            },

            starter_exercise: {
                id: exerciseResult.insertId,
                exercise_id: exercise_id,
                exercise_name: exercise.name,
                workout_day: workout_day,
                sets: sets ?? null,
                reps: reps ?? null,
                duration_minutes: duration_minutes ?? null,
                notes: notes ?? null
            }
        });

    } catch (error) {

        await connection.rollback();

        console.error(
            'Assign workout plan error:',
            error
        );

        return res.status(500).json({
            message: 'Failed to assign workout plan'
        });

    } finally {
        connection.release();
    }
};


// =====================================================
// GET ALL TRAINER PLANS
// =====================================================
const getPlans = async (req, res) => {
    try {
        const trainerId = req.user.id;

        const plans = await getTrainerWorkoutPlans(
            trainerId
        );

        return res.status(200).json({
            count: plans.length,
            plans
        });

    } catch (error) {

        console.error(
            'Get trainer workout plans error:',
            error
        );

        return res.status(500).json({
            message: 'Failed to fetch workout plans'
        });
    }
};


// =====================================================
// GET ONE PLAN
// =====================================================
const getPlan = async (req, res) => {
    try {
        const trainerId = req.user.id;
        const { id } = req.params;

        const plan = await getTrainerWorkoutPlan(
            id,
            trainerId
        );

        if (!plan) {
            return res.status(404).json({
                message: 'Workout plan not found'
            });
        }

        const exercises = await getPlanExercises(
            id,
            trainerId
        );

        return res.status(200).json({
            plan,
            exercises
        });

    } catch (error) {

        console.error(
            'Get workout plan error:',
            error
        );

        return res.status(500).json({
            message: 'Failed to fetch workout plan'
        });
    }
};


// =====================================================
// ADD MORE EXERCISE TO EXISTING PLAN
// =====================================================
const addExercise = async (req, res) => {
    try {
        const trainerId = req.user.id;
        const { id: planId } = req.params;

        const {
            exercise_id,
            workout_day,
            sets,
            reps,
            duration_minutes,
            notes
        } = req.body;

        if (!exercise_id) {
            return res.status(400).json({
                message: 'exercise_id is required'
            });
        }

        if (!workout_day) {
            return res.status(400).json({
                message: 'workout_day is required'
            });
        }

        if (!VALID_DAYS.includes(workout_day)) {
            return res.status(400).json({
                message: 'Invalid workout_day'
            });
        }

        // Check plan ownership
        const plan = await getTrainerWorkoutPlan(
            planId,
            trainerId
        );

        if (!plan) {
            return res.status(404).json({
                message: 'Workout plan not found'
            });
        }

        // Check exercise
        const exercise = await getActiveExercise(
            exercise_id
        );

        if (!exercise) {
            return res.status(404).json({
                message: 'Exercise not found or inactive'
            });
        }

        const workoutExerciseId =
            await addWorkoutExercise(
                planId,
                exercise_id,
                workout_day,
                sets ?? null,
                reps ?? null,
                duration_minutes ?? null,
                notes ?? null
            );

        return res.status(201).json({
            message: 'Exercise added successfully',
            workout_exercise_id: workoutExerciseId
        });

    } catch (error) {

        console.error(
            'Add workout exercise error:',
            error
        );

        return res.status(500).json({
            message: 'Failed to add exercise'
        });
    }
};


// =====================================================
// UPDATE PLAN NAME
// =====================================================
const updatePlan = async (req, res) => {
    try {
        const trainerId = req.user.id;
        const { id } = req.params;
        const { plan_name } = req.body;

        if (!plan_name || !plan_name.trim()) {
            return res.status(400).json({
                message: 'plan_name is required'
            });
        }

        const plan = await getTrainerWorkoutPlan(
            id,
            trainerId
        );

        if (!plan) {
            return res.status(404).json({
                message: 'Workout plan not found'
            });
        }

        await updateWorkoutPlan(
            id,
            trainerId,
            plan_name.trim()
        );

        const updatedPlan =
            await getTrainerWorkoutPlan(
                id,
                trainerId
            );

        return res.status(200).json({
            message: 'Workout plan updated successfully',
            plan: updatedPlan
        });

    } catch (error) {

        console.error(
            'Update workout plan error:',
            error
        );

        return res.status(500).json({
            message: 'Failed to update workout plan'
        });
    }
};


// =====================================================
// UPDATE EXERCISE
// =====================================================
const updateExercise = async (req, res) => {
    try {
        const trainerId = req.user.id;

        const {
            planId,
            workoutExerciseId
        } = req.params;

        const {
            exercise_id,
            workout_day,
            sets,
            reps,
            duration_minutes,
            notes
        } = req.body;

        if (!exercise_id) {
            return res.status(400).json({
                message: 'exercise_id is required'
            });
        }

        if (!workout_day) {
            return res.status(400).json({
                message: 'workout_day is required'
            });
        }

        if (!VALID_DAYS.includes(workout_day)) {
            return res.status(400).json({
                message: 'Invalid workout_day'
            });
        }

        // Check plan
        const plan = await getTrainerWorkoutPlan(
            planId,
            trainerId
        );

        if (!plan) {
            return res.status(404).json({
                message: 'Workout plan not found'
            });
        }

        // Check existing workout exercise
        const existing =
            await getPlanExercise(
                workoutExerciseId,
                planId,
                trainerId
            );

        if (!existing) {
            return res.status(404).json({
                message: 'Workout exercise not found'
            });
        }

        // Check new exercise
        const exercise = await getActiveExercise(
            exercise_id
        );

        if (!exercise) {
            return res.status(404).json({
                message: 'Exercise not found or inactive'
            });
        }

        await updateWorkoutExercise(
            workoutExerciseId,
            planId,
            trainerId,
            exercise_id,
            workout_day,
            sets ?? null,
            reps ?? null,
            duration_minutes ?? null,
            notes ?? null
        );

        return res.status(200).json({
            message: 'Workout exercise updated successfully'
        });

    } catch (error) {

        console.error(
            'Update workout exercise error:',
            error
        );

        return res.status(500).json({
            message: 'Failed to update workout exercise'
        });
    }
};


// =====================================================
// DELETE PLAN
// =====================================================
const removePlan = async (req, res) => {
    try {
        const trainerId = req.user.id;
        const { id } = req.params;

        const plan = await getTrainerWorkoutPlan(
            id,
            trainerId
        );

        if (!plan) {
            return res.status(404).json({
                message: 'Workout plan not found'
            });
        }

        await deleteWorkoutPlan(
            id,
            trainerId
        );

        return res.status(200).json({
            message: 'Workout plan deleted successfully'
        });

    } catch (error) {

        console.error(
            'Delete workout plan error:',
            error
        );

        return res.status(500).json({
            message: 'Failed to delete workout plan'
        });
    }
};


// =====================================================
// DELETE EXERCISE
// =====================================================
const removeExercise = async (req, res) => {
    try {
        const trainerId = req.user.id;

        const {
            planId,
            workoutExerciseId
        } = req.params;

        const existing =
            await getPlanExercise(
                workoutExerciseId,
                planId,
                trainerId
            );

        if (!existing) {
            return res.status(404).json({
                message: 'Workout exercise not found'
            });
        }

        await deleteWorkoutExercise(
            workoutExerciseId,
            planId,
            trainerId
        );

        return res.status(200).json({
            message: 'Workout exercise deleted successfully'
        });

    } catch (error) {

        console.error(
            'Delete workout exercise error:',
            error
        );

        return res.status(500).json({
            message: 'Failed to delete workout exercise'
        });
    }
};


module.exports = {
    assignWorkoutPlan,
    getPlans,
    getPlan,
    addExercise,
    updatePlan,
    updateExercise,
    removePlan,
    removeExercise
};