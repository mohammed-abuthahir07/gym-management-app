const publicPromotionModel = require('../model/publicPromotionModel');

const getPublicPromotions = async (req, res) => {
    try {
        const promotions =
            await publicPromotionModel.getPublicPromotions();

        return res.status(200).json({
            success: true,
            count: promotions.length,
            promotions
        });

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