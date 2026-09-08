const memberChallengeModel = require('../model/memberChallengeModel');

// =====================================================
// GET ALL ACTIVE CHALLENGES
// =====================================================

const getAllChallenges = async (req, res) => {
    try {
        const challenges = await memberChallengeModel.getAllChallenges();

        return res.status(200).json({
            success: true,
            message: 'Challenges fetched successfully',
            challenges
        });

    } catch (error) {
        console.error('Get member challenges error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch challenges'
        });
    }
};

module.exports = {
    getAllChallenges
};