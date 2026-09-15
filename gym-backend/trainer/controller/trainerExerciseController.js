const {
    getTrainerExercises
} = require('../model/trainerExerciseModel');


// ==========================================
// GET ACTIVE EXERCISES FOR TRAINER
// ==========================================

const getTrainerExercisesController = async (req, res) => {

    try {

        const exercises = await getTrainerExercises();

        res.status(200).json({
            success: true,
            message: 'Exercises fetched successfully',
            exercises
        });

    } catch (error) {

        console.error(
            'Get trainer exercises error:',
            error
        );

        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
};


module.exports = {
    getTrainerExercisesController
};