const publicPromotionModel = require('../model/publicPromotionModel');
const ttlCache = require('../../config/ttlCache');

const CACHE_KEY = 'public:promotions';

const getPublicPromotions = async (req, res) => {
    try {
        const cached = ttlCache.get(CACHE_KEY);
        if (cached) {
            return res.status(200).json(cached);
        }

        const promotions = await publicPromotionModel.getPublicPromotions();
        const payload = {
            success: true,
            count: promotions.length,
            promotions
        };
        ttlCache.set(CACHE_KEY, payload, 30000);
        return res.status(200).json(payload);

    } catch (error) {
        console.error('Get public promotions error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch promotions'
        });
    }
};

module.exports = {
    getPublicPromotions
};
