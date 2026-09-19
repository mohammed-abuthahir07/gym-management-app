const publicPlansModel = require('../model/publicPlansModel');
const ttlCache = require('../../config/ttlCache');

const CACHE_KEY = 'public:plans';

const getPublicPlans = async (req, res) => {
    try {
        const cached = ttlCache.get(CACHE_KEY);
        if (cached) {
            return res.status(200).json(cached);
        }

        const plans = await publicPlansModel.getPublicPlans();
        const payload = {
            success: true,
            count: plans.length,
            plans
        };
        ttlCache.set(CACHE_KEY, payload, 30000);
        return res.status(200).json(payload);

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
