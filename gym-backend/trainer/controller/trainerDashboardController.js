const {
    getAssignedMembersCount,
    getDietPlansCount,
    getWorkoutPlansCount,
    getMemberCheckIns
} = require('../model/trainerDashboardModel');


/*
 * GET assigned member count
 *
 * GET /api/trainer/dashboard/assigned-members
 */
const getAssignedMembers = async (req, res) => {
    try {
        const trainerId = req.user.id;

        const total = await getAssignedMembersCount(trainerId);

        return res.status(200).json({
            total
        });

    } catch (error) {
        console.error(
            'Get assigned members dashboard error:',
            error
        );

        return res.status(500).json({
            message: 'Failed to get assigned members count'
        });
    }
};


/*
 * GET diet plan count
 *
 * GET /api/trainer/dashboard/diet-plans
 */
const getDietPlans = async (req, res) => {
    try {
        const trainerId = req.user.id;

        const total = await getDietPlansCount(trainerId);

        return res.status(200).json({
            total
        });

    } catch (error) {
        console.error(
            'Get diet plans dashboard error:',
            error
        );

        return res.status(500).json({
            message: 'Failed to get diet plans count'
        });
    }
};


/*
 * GET workout plan count
 *
 * GET /api/trainer/dashboard/workout-plans
 */
const getWorkoutPlans = async (req, res) => {
    try {
        const trainerId = req.user.id;

        const total = await getWorkoutPlansCount(trainerId);

        return res.status(200).json({
            total
        });

    } catch (error) {
        console.error(
            'Get workout plans dashboard error:',
            error
        );

        return res.status(500).json({
            message: 'Failed to get workout plans count'
        });
    }
};


/*
 * GET workout check-in days for every assigned member
 *
 * GET /api/trainer/dashboard/check-ins
 */
const getCheckIns = async (req, res) => {
    try {
        const trainerId = req.user.id;

        const members = await getMemberCheckIns(trainerId);

        return res.status(200).json({
            count: members.length,
            members
        });

    } catch (error) {
        console.error(
            'Get workout check-ins dashboard error:',
            error
        );

        return res.status(500).json({
            message: 'Failed to get workout check-ins'
        });
    }
};


module.exports = {
    getAssignedMembers,
    getDietPlans,
    getWorkoutPlans,
    getCheckIns
};