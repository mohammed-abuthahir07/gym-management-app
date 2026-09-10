const publicPlansModel = require('../model/publicPlansModel');

const getPublicPlans = async (req, res) => {
    try {
        const plans = await publicPlansModel.getPublicPlans();

        return res.status(200).json({
            success: true,
            count: plans.length,
            plans
        });

    } catch (error) {
        console.error('Get public plans error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch plans'
        });
    }
};

module.exports = {
    getPublicPlans
};