const dashboardModel = require('../model/adminDashboardModel');


// ========================================
// MEMBER COUNT
// ========================================

const getMemberDashboard = async (req, res) => {
    try {
        const data = await dashboardModel.getMemberDashboard();

        return res.status(200).json({
            success: true,
            data: {
                total_members: Number(data.total_members || 0),
                active_members: Number(data.active_members || 0),
                inactive_members: Number(data.inactive_members || 0)
            }
        });

    } catch (error) {
        console.error('Member dashboard error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to load member dashboard data'
        });
    }
};


// ========================================
// TRAINER COUNT
// ========================================

const getTrainerDashboard = async (req, res) => {
    try {
        const data = await dashboardModel.getTrainerDashboard();

        return res.status(200).json({
            success: true,
            data: {
                total_trainers: Number(data.total_trainers || 0),
                active_trainers: Number(data.active_trainers || 0),
                inactive_trainers: Number(data.inactive_trainers || 0)
            }
        });

    } catch (error) {
        console.error('Trainer dashboard error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to load trainer dashboard data'
        });
    }
};


// ========================================
// PLAN COUNT
// ========================================

const getPlanDashboard = async (req, res) => {
    try {
        const data = await dashboardModel.getPlanDashboard();

        return res.status(200).json({
            success: true,
            data: {
                total_plans: Number(data.total_plans || 0)
            }
        });

    } catch (error) {
        console.error('Plan dashboard error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to load plan dashboard data'
        });
    }
};


// ========================================
// PROMOTION COUNT
// ========================================

const getPromotionDashboard = async (req, res) => {
    try {
        const data = await dashboardModel.getPromotionDashboard();

        return res.status(200).json({
            success: true,
            data: {
                total_promotions: Number(data.total_promotions || 0)
            }
        });

    } catch (error) {
        console.error('Promotion dashboard error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to load promotion dashboard data'
        });
    }
};


// ========================================
// CHALLENGE COUNT
// ========================================

const getChallengeDashboard = async (req, res) => {
    try {
        const data = await dashboardModel.getChallengeDashboard();

        return res.status(200).json({
            success: true,
            data: {
                total_challenges: Number(data.total_challenges || 0)
            }
        });

    } catch (error) {
        console.error('Challenge dashboard error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to load challenge dashboard data'
        });
    }
};


// ========================================
// RECENT PLANS
// ========================================

const getRecentPlans = async (req, res) => {
    try {
        const plans = await dashboardModel.getRecentPlans();

        return res.status(200).json({
            success: true,
            data: plans
        });

    } catch (error) {
        console.error('Recent plans error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to load recent plans'
        });
    }
};


// ========================================
// RECENT PROMOTIONS
// ========================================

const getRecentPromotions = async (req, res) => {
    try {
        const promotions = await dashboardModel.getRecentPromotions();

        return res.status(200).json({
            success: true,
            data: promotions
        });

    } catch (error) {
        console.error('Recent promotions error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to load recent promotions'
        });
    }
};


// ========================================
// RECENT CHALLENGES
// ========================================

const getRecentChallenges = async (req, res) => {
    try {
        const challenges = await dashboardModel.getRecentChallenges();

        return res.status(200).json({
            success: true,
            data: challenges
        });

    } catch (error) {
        console.error('Recent challenges error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to load recent challenges'
        });
    }
};


// ========================================
// CURRENT MONTH REVENUE
// ========================================

const getAdminCurrentMonthRevenue = async (req, res) => {
    try {
        const revenue =
            await dashboardModel.getCurrentMonthRevenue();

        const month = new Date()
            .toLocaleString('en-US', {
                month: 'long'
            })
            .toUpperCase();

        const year = new Date().getFullYear();

        return res.status(200).json({
            success: true,
            month,
            year,
            revenue: Number(revenue || 0)
        });

    } catch (error) {
        console.error(
            'Admin current month revenue error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch current month revenue'
        });
    }
};


const getAdminCurrentYearRevenue = async (req, res) => {
    try {
        const revenue =
            await dashboardModel.getCurrentYearRevenue();

        const year = new Date().getFullYear();

        return res.status(200).json({
            success: true,
            year,
            revenue: Number(revenue || 0)
        });

    } catch (error) {
        console.error(
            'Admin current year revenue error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch current year revenue'
        });
    }
};
const getAdminTotalRevenue = async (req, res) => {
    try {
        const revenue =
            await dashboardModel.getTotalRevenue();

        return res.status(200).json({
            success: true,
            revenue: Number(revenue || 0)
        });

    } catch (error) {
        console.error(
            'Admin total revenue error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch total revenue'
        });
    }
};


// ========================================
// EXPORTS
// ========================================

module.exports = {
    getMemberDashboard,
    getTrainerDashboard,
    getPlanDashboard,
    getPromotionDashboard,
    getChallengeDashboard,

    getRecentPlans,
    getRecentPromotions,
    getRecentChallenges,

    getAdminCurrentMonthRevenue,
    getAdminCurrentYearRevenue,
    getAdminTotalRevenue
};