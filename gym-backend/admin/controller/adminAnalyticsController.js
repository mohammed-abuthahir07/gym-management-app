const {
    getMemberAnalytics,
    getTrainerAnalytics,
    getRecentPlans,
    getRecentPromotions,
    getRecentChallenges
} = require('../model/adminAnalyticsModel');


// ==========================================
// MEMBER ANALYTICS
// ==========================================

const memberAnalytics = async (req, res) => {
    try {

        const data = await getMemberAnalytics();

        res.json({
            success: true,
            message: 'Member analytics fetched successfully',
            data
        });

    } catch (error) {

        console.error('Member analytics error:', error);

        res.status(500).json({
            success: false,
            message: 'Failed to fetch member analytics'
        });
    }
};



// ==========================================
// TRAINER ANALYTICS
// ==========================================

const trainerAnalytics = async (req, res) => {
    try {

        const data = await getTrainerAnalytics();

        res.json({
            success: true,
            message: 'Trainer analytics fetched successfully',
            data
        });

    } catch (error) {

        console.error('Trainer analytics error:', error);

        res.status(500).json({
            success: false,
            message: 'Failed to fetch trainer analytics'
        });
    }
};


// ==========================================
// MOST RECENT PLANS
// ==========================================

const recentPlans = async (req, res) => {
    try {
        const data = await getRecentPlans();

        res.json({
            success: true,
            message: 'Recent plans fetched successfully',
            data
        });

    } catch (error) {
        console.error('Recent plans error:', error);

        res.status(500).json({
            success: false,
            message: 'Failed to fetch recent plans'
        });
    }
};


// ==========================================
// MOST RECENT PROMOTIONS
// ==========================================

const recentPromotions = async (req, res) => {
    try {
        const data = await getRecentPromotions();

        res.json({
            success: true,
            message: 'Recent promotions fetched successfully',
            data
        });

    } catch (error) {
        console.error('Recent promotions error:', error);

        res.status(500).json({
            success: false,
            message: 'Failed to fetch recent promotions'
        });
    }
};


// ==========================================
// MOST RECENT CHALLENGES
// ==========================================

const recentChallenges = async (req, res) => {
    try {
        const data = await getRecentChallenges();

        res.json({
            success: true,
            message: 'Recent challenges fetched successfully',
            data
        });

    } catch (error) {
        console.error('Recent challenges error:', error);

        res.status(500).json({
            success: false,
            message: 'Failed to fetch recent challenges'
        });
    }
};


module.exports = {
    memberAnalytics,
    trainerAnalytics,
    recentPlans,
    recentPromotions,
    recentChallenges
};