const {
    getMemberWorkoutPlans,
    getMemberWorkoutPlanById,
    markWorkoutExerciseCompleted,
    getWorkoutCompletionById
} = require('../model/memberWorkoutPlanModel');


/**
 * GET /api/member/workout-plans
 *
 * Get all workout plans assigned to logged-in member
 */
const getWorkoutPlans = async (req, res) => {
    try {
        const memberId = req.user.id;

        const plans = await getMemberWorkoutPlans(memberId);

        return res.status(200).json({
            count: plans.length,
            plans
        });

    } catch (error) {
        console.error('Get member workout plans error:', error);

        return res.status(500).json({
            message: 'Failed to get workout plans'
        });
    }
};

const markWorkoutDone = async (req, res) => {
    try {
        const memberId = req.user.id;
        const { planId, workoutExerciseId } = req.params;

        /*
         * First verify that this workout exercise
         * belongs to the member's own workout plan.
         */
        const workoutPlan = await getMemberWorkoutPlanById(
            planId,
            memberId
        );

        if (!workoutPlan) {
            return res.status(404).json({
                message: 'Workout plan not found'
            });
        }

        /*
         * Find the specific exercise inside the plan.
         */
        const workoutExercise = workoutPlan.exercises.find(
            exercise =>
                Number(exercise.id) === Number(workoutExerciseId)
        );

        if (!workoutExercise) {
            return res.status(404).json({
                message: 'Workout exercise not found'
            });
        }

        /*
         * Check whether today's workout
         * has already been completed.
         */
        const existingCompletion =
            await getWorkoutCompletionById(
                memberId,
                workoutExerciseId
            );

        if (existingCompletion) {
            return res.status(409).json({
                message: 'Workout already marked as completed for today',
                completion: existingCompletion
            });
        }

        /*
         * Mark today's workout as completed.
         */
        const completionId =
            await markWorkoutExerciseCompleted(
                memberId,
                workoutExerciseId
            );

        const completion =
            await getWorkoutCompletionById(
                memberId,
                workoutExerciseId
            );

        return res.status(201).json({
            message: 'Workout marked as completed',
            completion
        });

    } catch (error) {
        console.error(
            'Mark workout done error:',
            error
        );

        /*
         * Handle duplicate completion safely
         * even if database catches it first.
         */
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({
                message:
                    'Workout already marked as completed for today'
            });
        }

        return res.status(500).json({
            message: 'Failed to mark workout as completed'
        });
    }
};


/**
 * GET /api/member/workout-plans/:id
 *
 * Get one workout plan belonging to logged-in member
 */
const getWorkoutPlan = async (req, res) => {
    try {
        const memberId = req.user.id;
        const planId = req.params.id;

        const plan = await getMemberWorkoutPlanById(
            planId,
            memberId
        );

        if (!plan) {
            return res.status(404).json({
                message: 'Workout plan not found or not available to you'
            });
        }

        return res.status(200).json(plan);

    } catch (error) {
        console.error('Get member workout plan error:', error);

        return res.status(500).json({
            message: 'Failed to get workout plan'
        });
    }
};


module.exports = {
    getWorkoutPlans,
    getWorkoutPlan,
    markWorkoutDone
};