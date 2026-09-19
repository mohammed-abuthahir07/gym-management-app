const publicTrainerModel = require('../model/publicTrainerModel');
const ttlCache = require('../../config/ttlCache');

const CACHE_KEY = 'public:trainers';

const getPublicTrainers = async (req, res) => {
    try {
        const cached = ttlCache.get(CACHE_KEY);
        if (cached) {
            return res.status(200).json(cached);
        }

        const trainers = await publicTrainerModel.getPublicTrainers();
        const payload = {
            success: true,
            count: trainers.length,
            trainers
        };
        ttlCache.set(CACHE_KEY, payload, 30000);
        return res.status(200).json(payload);

    } catch (error) {
        console.error('Get public trainers error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch trainers'
        });
    }
};

module.exports = {
    getPublicTrainers
};
