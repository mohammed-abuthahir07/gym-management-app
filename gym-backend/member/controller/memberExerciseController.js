const memberExerciseModel = require('../model/memberExerciseModel');

// Get all exercises for member
const getAllExercises = async (req, res) => {
    try {
        const exercises = await memberExerciseModel.getAllExercises();

        return res.status(200).json({
            success: true,
            message: 'Exercises fetched successfully',
            exercises
        });

    } catch (error) {
        console.error('Get member exercises error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch exercises'
        });
    }
};

module.exports = {
    getAllExercises
};