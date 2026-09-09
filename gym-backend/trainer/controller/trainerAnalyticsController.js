const analyticsModel = require('../model/trainerAnalyticsModel');

const getTodayWorkoutAnalytics = async (req, res) => {
    try {
        const trainerId = req.user.id;

        const analytics =
            await analyticsModel.getTodayWorkoutAnalytics(trainerId);

        const data = analytics.map((member) => {
            const totalExercises = Number(member.total_exercises);
            const completedExercises = Number(member.completed_exercises);

            let status = 'NOT_STARTED';

            if (totalExercises > 0 && completedExercises === totalExercises) {
                status = 'COMPLETED';
            } else if (completedExercises > 0) {
                status = 'IN_PROGRESS';
            }

            return {
                member_id: member.member_id,
                member_name: member.member_name,
                workout_name: member.workout_name || 'No Workout',
                total_exercises: totalExercises,
                completed_exercises: completedExercises,
                remaining_exercises:
                    totalExercises - completedExercises,
                status
            };
        });

        return res.status(200).json({
            success: true,
            count: data.length,
            members: data
        });

    } catch (error) {
        console.error(
            'Trainer today workout analytics error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch today workout analytics'
        });
    }
};

module.exports = {
    getTodayWorkoutAnalytics
};