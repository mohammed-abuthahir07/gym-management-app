const {
    getCheckInDays,
    getCurrentDietPlan,
    getWorkoutPlansCount,
    getNotificationCount,
    getPreviousMonthProgress,
    getTodayWorkoutPlans
} = require('../model/memberDashboardModel');

/*
 * GET check-in days
 *
 * GET /api/member/dashboard/checkin-days
 */
const getCheckInDaysDashboard = async (req, res) => {
    try {
        const memberId = req.user.id;

        const total = await getCheckInDays(memberId);

        return res.status(200).json({
            total
        });

    } catch (error) {
        console.error(
            'Get member check-in days error:',
            error
        );

        return res.status(500).json({
            message: 'Failed to get check-in days'
        });
    }
};


/*
 * GET current diet plan
 *
 * GET /api/member/dashboard/diet-plan
 */
const getDietPlanDashboard = async (req, res) => {
    try {
        const memberId = req.user.id;

        const dietPlan = await getCurrentDietPlan(memberId);

        return res.status(200).json({
            diet_plan: dietPlan
        });

    } catch (error) {
        console.error(
            'Get member current diet plan error:',
            error
        );

        return res.status(500).json({
            message: 'Failed to get current diet plan'
        });
    }
};


/*
 * GET workout plan count
 *
 * GET /api/member/dashboard/workout-plans
 */
const getWorkoutPlansDashboard = async (req, res) => {
    try {
        const memberId = req.user.id;

        const total = await getWorkoutPlansCount(memberId);

        return res.status(200).json({
            total
        });

    } catch (error) {
        console.error(
            'Get member workout plans count error:',
            error
        );

        return res.status(500).json({
            message: 'Failed to get workout plans count'
        });
    }
};


/*
 * GET unread notification count
 *
 * GET /api/member/dashboard/notifications
 */
const getNotificationDashboard = async (req, res) => {
    try {
        const memberId = req.user.id;

        const total = await getNotificationCount(memberId);

        return res.status(200).json({
            total
        });

    } catch (error) {
        console.error(
            'Get member notification count error:',
            error
        );

        return res.status(500).json({
            message: 'Failed to get notification count'
        });
    }
};

const getPreviousMonthProgressDashboard = async (req, res) => {
    try {
        const memberId = req.user.id;

        const progress = await getPreviousMonthProgress(
            memberId
        );

        return res.status(200).json({
            progress
        });

    } catch (error) {
        console.error(
            'Get previous month progress error:',
            error
        );

        return res.status(500).json({
            message: 'Failed to get previous month progress'
        });
    }
};

const getTodayWorkoutDashboard = async (req, res) => {
    try {
        const memberId = req.user.id;

        const workouts = await getTodayWorkoutPlans(memberId);

        const today = new Date().toLocaleDateString('en-US', {
            weekday: 'long'
        }).toUpperCase();

        res.status(200).json({
            success: true,
            day: today,
            count: workouts.length,
            workouts
        });

    } catch (error) {
        console.error('Get today workout dashboard error:', error);

        res.status(500).json({
            success: false,
            message: 'Failed to fetch today workout plans'
        });
    }
};


module.exports = {
    getCheckInDaysDashboard,
    getDietPlanDashboard,
    getWorkoutPlansDashboard,
    getNotificationDashboard,
    getPreviousMonthProgressDashboard,
    getTodayWorkoutDashboard
};