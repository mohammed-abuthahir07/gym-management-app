const {
    getMemberWorkoutPlans,
    getMemberWorkoutPlanById
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
    getWorkoutPlan
};