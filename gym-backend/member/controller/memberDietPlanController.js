const {
    getMemberDietPlans,
    getMemberDietPlanById
} = require('../model/memberDietPlanModel');


/**
 * GET /api/member/diet-plans
 *
 * Member can see only their own diet plans
 */
const getDietPlans = async (req, res) => {
    try {
        const memberId = req.user.id;

        const plans = await getMemberDietPlans(memberId);

        return res.status(200).json({
            count: plans.length,
            diet_plans: plans
        });

    } catch (error) {
        console.error('Get member diet plans error:', error);

        return res.status(500).json({
            message: 'Failed to get diet plans'
        });
    }
};


/**
 * GET /api/member/diet-plans/:id
 *
 * Member can see one of their own diet plans
 */
const getDietPlan = async (req, res) => {
    try {
        const memberId = req.user.id;
        const planId = req.params.id;

        const dietPlan = await getMemberDietPlanById(
            planId,
            memberId
        );

        if (!dietPlan) {
            return res.status(404).json({
                message: 'Diet plan not found or not available to you'
            });
        }

        return res.status(200).json(dietPlan);

    } catch (error) {
        console.error('Get member diet plan error:', error);

        return res.status(500).json({
            message: 'Failed to get diet plan'
        });
    }
};


module.exports = {
    getDietPlans,
    getDietPlan
};