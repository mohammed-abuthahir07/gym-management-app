const publicContentModel = require('../model/publicContentModel');
const ttlCache = require('../../config/ttlCache');

const CACHE_KEY = 'public:content';

const getPublicContent = async (req, res) => {
    try {
        const cached = ttlCache.get(CACHE_KEY);
        if (cached) {
            return res.status(200).json(cached);
        }

        const content = await publicContentModel.getPublicContent();
        const payload = {
            success: true,
            count: content.length,
            content
        };
        ttlCache.set(CACHE_KEY, payload, 30000);
        return res.status(200).json(payload);

    } catch (error) {
        console.error('Get public content error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch content'
        });
    }
};

module.exports = {
    getPublicContent
};
