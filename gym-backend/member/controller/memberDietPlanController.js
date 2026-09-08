const {
    getMemberDietPlans,
    getMemberDietPlanById,
    getTodayDietPlan
} = require('../model/memberDietPlanModel');


// Get complete weekly diet
const getDietPlans = async (req, res) => {
    try {

        const memberId = req.user.id;

        const dietPlans = await getMemberDietPlans(memberId);

        return res.status(200).json({
            success: true,
            count: dietPlans.length,
            diet_plans: dietPlans
        });

    } catch (error) {

        console.error('Get member diet plans error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch diet plans'
        });
    }
};


// Get one diet entry
const getDietPlan = async (req, res) => {
    try {

        const memberId = req.user.id;
        const dietPlanId = req.params.id;

        const dietPlan = await getMemberDietPlanById(
            dietPlanId,
            memberId
        );

        if (!dietPlan) {
            return res.status(404).json({
                success: false,
                message: 'Diet plan not found'
            });
        }

        return res.status(200).json({
            success: true,
            diet_plan: dietPlan
        });

    } catch (error) {

        console.error('Get member diet plan error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch diet plan'
        });
    }
};


// Get today's diet
const getTodayDiet = async (req, res) => {
    try {

        const memberId = req.user.id;

        const dietPlans = await getTodayDietPlan(memberId);

        const today = new Date().toLocaleDateString(
            'en-US',
            {
                weekday: 'long'
            }
        ).toUpperCase();

        return res.status(200).json({
            success: true,
            day: today,
            count: dietPlans.length,
            diet_plans: dietPlans
        });

    } catch (error) {

        console.error('Get today diet error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch today diet'
        });
    }
};


module.exports = {
    getDietPlans,
    getDietPlan,
    getTodayDiet
};