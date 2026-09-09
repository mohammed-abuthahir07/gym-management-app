const analyticsModel = require('../model/memberAnalyticsModel');


/*
==================================================
1. CURRENT MONTH CHECK-IN DAYS
==================================================
*/

const getCurrentMonthCheckinDays = async (req, res) => {
    try {

        // IMPORTANT:
        // Member ID comes ONLY from JWT
        const memberId = req.user.id;

        const checkinDays =
            await analyticsModel.getCurrentMonthCheckinDays(memberId);

        const now = new Date();

        const month = now.toLocaleString('en-US', {
            month: 'long'
        }).toUpperCase();

        const year = now.getFullYear();

        return res.status(200).json({
            success: true,
            month,
            year,
            checkin_days: checkinDays
        });

    } catch (error) {

        console.error(
            'Member current month check-in analytics error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch current month check-in days'
        });
    }
};

const getCurrentMonthProgress = async (req, res) => {
    try {

        // IMPORTANT:
        // Member ID comes only from JWT
        const memberId = req.user.id;

        const progress =
            await analyticsModel.getCurrentMonthProgress(memberId);

        const now = new Date();

        const month = now.toLocaleString('en-US', {
            month: 'long'
        }).toUpperCase();

        const year = now.getFullYear();

        return res.status(200).json({
            success: true,
            month,
            year,
            progress
        });

    } catch (error) {

        console.error(
            'Member current month progress analytics error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch current month progress'
        });
    }
};


/*
==================================================
2. CURRENT MONTH PAYMENT STATUS
==================================================
*/

const getCurrentMonthPaymentStatus = async (req, res) => {
    try {

        // IMPORTANT:
        // Never accept member_id from request
        const memberId = req.user.id;

        const fee =
            await analyticsModel.getCurrentMonthPaymentStatus(memberId);

        const now = new Date();

        const month = now.toLocaleString('en-US', {
            month: 'long'
        }).toUpperCase();

        const year = now.getFullYear();

        if (!fee) {
            return res.status(200).json({
                success: true,
                month,
                year,
                payment_status: 'UNPAID',
                paid: false,
                fee_amount: null
            });
        }

        return res.status(200).json({
            success: true,
            month,
            year,
            payment_status: fee.payment_status,
            paid: fee.payment_status === 'PAID',
            fee_amount: fee.fee_amount
        });

    } catch (error) {

        console.error(
            'Member current month payment analytics error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch current month payment status'
        });
    }
};


/*
==================================================
3. TOMORROW'S WORKOUT
==================================================
*/

const getTomorrowWorkout = async (req, res) => {
    try {

        // IMPORTANT:
        // Logged-in member only
        const memberId = req.user.id;

        const workouts =
            await analyticsModel.getTomorrowWorkout(memberId);

        const tomorrow = new Date();

        tomorrow.setDate(
            tomorrow.getDate() + 1
        );

        const date =
            tomorrow.toISOString().split('T')[0];

        const workoutDay =
            tomorrow.toLocaleString('en-US', {
                weekday: 'long'
            }).toUpperCase();

        return res.status(200).json({
            success: true,
            date,
            workout_day: workoutDay,
            workouts
        });

    } catch (error) {

        console.error(
            'Member tomorrow workout analytics error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch tomorrow workout'
        });
    }
};


/*
==================================================
4. CURRENT MONTH CHEAT MEALS
==================================================
*/

const getCurrentMonthCheatMeals = async (req, res) => {
    try {

        // IMPORTANT:
        // Logged-in member only
        const memberId = req.user.id;

        const cheatMeals =
            await analyticsModel.getCurrentMonthCheatMeals(memberId);

        const now = new Date();

        const month = now.toLocaleString('en-US', {
            month: 'long'
        }).toUpperCase();

        const year = now.getFullYear();

        return res.status(200).json({
            success: true,
            month,
            year,
            cheat_meals_count: cheatMeals.length,
            cheat_meals: cheatMeals
        });

    } catch (error) {

        console.error(
            'Member current month cheat meal analytics error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch current month cheat meals'
        });
    }
};


module.exports = {
    getCurrentMonthCheckinDays,
    getCurrentMonthPaymentStatus,
    getTomorrowWorkout,
    getCurrentMonthCheatMeals,
    getCurrentMonthProgress
};