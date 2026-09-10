const publicContentModel = require('../model/publicContentModel');

const getPublicContent = async (req, res) => {
    try {
        const content = await publicContentModel.getPublicContent();

        return res.status(200).json({
            success: true,
            count: content.length,
            content
        });

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