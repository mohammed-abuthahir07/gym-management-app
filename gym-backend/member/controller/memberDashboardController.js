const {
    getCheckInDays,
    getTodayDietPlan,
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
 * GET today's diet plan
 *
 * GET /api/member/dashboard/diet-plan
 *
 * Example:
 *
 * Monday:
 *   Breakfast
 *   Lunch
 *   Dinner
 *
 * Tuesday:
 *   Breakfast
 *   Lunch
 *   Dinner
 */
const getDietPlanDashboard = async (req, res) => {
    try {

        const memberId = req.user.id;

        const dietPlans = await getTodayDietPlan(memberId);

        /*
         * Get current weekday for response.
         *
         * This is only for displaying the day.
         * The actual filtering is done by MySQL.
         */
        const today = new Date().toLocaleDateString(
            'en-US',
            {
                weekday: 'long'
            }
        ).toUpperCase();

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


/*
 * GET previous month's latest progress
 *
 * GET /api/member/dashboard/previous-month-progress
 */
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


/*
 * GET today's workout
 *
 * GET /api/member/dashboard/today-workout
 *
 * Monday    -> Monday workouts
 * Tuesday   -> Tuesday workouts
 * Wednesday -> Wednesday workouts
 * etc.
 */
const getTodayWorkoutDashboard = async (req, res) => {
    try {

        const memberId = req.user.id;

        const workouts = await getTodayWorkoutPlans(
            memberId
        );

        /*
         * Used only for displaying today's day
         * in the API response.
         */
        const today = new Date().toLocaleDateString(
            'en-US',
            {
                weekday: 'long'
            }
        ).toUpperCase();

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


module.exports = {
    getCheckInDaysDashboard,
    getDietPlanDashboard,
    getWorkoutPlansDashboard,
    getNotificationDashboard,
    getPreviousMonthProgressDashboard,
    getTodayWorkoutDashboard
};