const {
    getCheckInDays,
    getTodayDietPlan,
    getWorkoutPlansCount,
    getNotificationCount,
    getPreviousMonthProgress,
    getTodayWorkoutPlans,
    getCurrentMonthCheatCount
} = require('../model/memberDashboardModel');


// ============================================================
// GET CHECK-IN DAYS
// ============================================================

const getCheckInDaysDashboard = async (req, res) => {
    try {

        const memberId = req.user.id;

        const total = await getCheckInDays(memberId);

        return res.status(200).json({
            success: true,
            total
        });

    } catch (error) {

        console.error(
            'Get member check-in days error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to get check-in days'
        });
    }
};


// ============================================================
// GET TODAY'S DIET PLAN
// ============================================================

const getDietPlanDashboard = async (req, res) => {
    try {

        const memberId = req.user.id;

        const dietPlans = await getTodayDietPlan(memberId);

        const today = new Date()
            .toLocaleDateString(
                'en-US',
                {
                    weekday: 'long'
                }
            )
            .toUpperCase();

        return res.status(200).json({
            success: true,
            day: today,
            count: dietPlans.length,
            diet_plans: dietPlans
        });

    } catch (error) {

        console.error(
            'Get member today diet plan error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to get today diet plan'
        });
    }
};


// ============================================================
// GET WORKOUT PLAN COUNT
// ============================================================

const getWorkoutPlansDashboard = async (req, res) => {
    try {

        const memberId = req.user.id;

        const total = await getWorkoutPlansCount(memberId);

        return res.status(200).json({
            success: true,
            total
        });

    } catch (error) {

        console.error(
            'Get member workout plans count error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to get workout plans count'
        });
    }
};


// ============================================================
// GET UNREAD NOTIFICATION COUNT
// ============================================================

const getNotificationDashboard = async (req, res) => {
    try {

        const memberId = req.user.id;

        const total = await getNotificationCount(memberId);

        return res.status(200).json({
            success: true,
            total
        });

    } catch (error) {

        console.error(
            'Get member notification count error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to get notification count'
        });
    }
};


// ============================================================
// GET PREVIOUS MONTH'S LATEST PROGRESS
// ============================================================

const getPreviousMonthProgressDashboard = async (req, res) => {
    try {

        const memberId = req.user.id;

        const progress = await getPreviousMonthProgress(
            memberId
        );

        return res.status(200).json({
            success: true,
            progress
        });

    } catch (error) {

        console.error(
            'Get previous month progress error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to get previous month progress'
        });
    }
};


// ============================================================
// GET TODAY'S WORKOUT
// ============================================================

const getTodayWorkoutDashboard = async (req, res) => {
    try {

        const memberId = req.user.id;

        const workouts = await getTodayWorkoutPlans(
            memberId
        );

        const today = new Date()
            .toLocaleDateString(
                'en-US',
                {
                    weekday: 'long'
                }
            )
            .toUpperCase();

        return res.status(200).json({
            success: true,
            day: today,
            count: workouts.length,
            workouts
        });

    } catch (error) {

        console.error(
            'Get today workout dashboard error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch today workout plans'
        });
    }
};


// ============================================================
// GET CURRENT MONTH CHEAT COUNT
// ============================================================

const getCurrentMonthCheatCountDashboard = async (req, res) => {
    try {

        const memberId = req.user.id;

        const total = await getCurrentMonthCheatCount(
            memberId
        );

        return res.status(200).json({
            success: true,
            total
        });

    } catch (error) {

        console.error(
            'Get current month cheat count error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to get current month cheat count'
        });
    }
};


// ============================================================
// EXPORT CONTROLLERS
// ============================================================

module.exports = {
    getCheckInDaysDashboard,
    getDietPlanDashboard,
    getWorkoutPlansDashboard,
    getNotificationDashboard,
    getPreviousMonthProgressDashboard,
    getTodayWorkoutDashboard,
    getCurrentMonthCheatCountDashboard
};