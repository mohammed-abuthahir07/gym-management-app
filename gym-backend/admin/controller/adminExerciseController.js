const {
    createExercise,
    findExerciseById,
    getAllExercises,
    findExerciseByName,
    updateExercise,
    deleteExercise
} = require('../model/adminExerciseModel');


// ======================================
// CREATE EXERCISE
// ======================================
const createAdminExercise = async (req, res) => {
    try {

        const {
            name,
            muscle_group,
            equipment,
            instructions,
            image_url,
            video_url,
            difficulty
        } = req.body;


        // Required fields
        if (!name || !difficulty) {
            return res.status(400).json({
                success: false,
                message: 'Name and difficulty are required'
            });
        }


        const cleanName = name.trim();


        if (!cleanName) {
            return res.status(400).json({
                success: false,
                message: 'Exercise name cannot be empty'
            });
        }


        // Validate difficulty
        const allowedDifficulties = [
            'BEGINNER',
            'INTERMEDIATE',
            'DIFFICULT'
        ];


        if (!allowedDifficulties.includes(difficulty)) {
            return res.status(400).json({
                success: false,
                message:
                    'Difficulty must be BEGINNER, INTERMEDIATE or DIFFICULT'
            });
        }


        // Check duplicate name
        const existingExercise =
            await findExerciseByName(cleanName);


        if (existingExercise) {
            return res.status(409).json({
                success: false,
                message: 'An exercise with this name already exists'
            });
        }


        // Create exercise
        const exerciseId =
            await createExercise({
                name: cleanName,

                muscle_group:
                    muscle_group
                        ? muscle_group.trim()
                        : null,

                equipment:
                    equipment
                        ? equipment.trim()
                        : null,

                instructions:
                    instructions
                        ? instructions.trim()
                        : null,

                image_url:
                    image_url
                        ? image_url.trim()
                        : null,

                video_url:
                    video_url
                        ? video_url.trim()
                        : null,

                difficulty
            });


        // Get created exercise
        const createdExercise =
            await findExerciseById(exerciseId);


        return res.status(201).json({
            success: true,
            message: 'Exercise created successfully',
            exercise: createdExercise
        });


    } catch (error) {

        console.error(
            'Create exercise error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while creating exercise'
        });
    }
};



// ======================================
// GET ALL EXERCISES
// ======================================
const getExercises = async (req, res) => {
    try {

        const exercises =
            await getAllExercises();


        return res.status(200).json({
            success: true,
            message: 'Exercises fetched successfully',
            exercises
        });


    } catch (error) {

        console.error(
            'Get exercises error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while fetching exercises'
        });
    }
};



// ======================================
// GET SINGLE EXERCISE
// ======================================
const getExercise = async (req, res) => {
    try {

        const { id } = req.params;


        const exercise =
            await findExerciseById(id);


        if (!exercise) {
            return res.status(404).json({
                success: false,
                message: 'Exercise not found'
            });
        }


        return res.status(200).json({
            success: true,
            message: 'Exercise fetched successfully',
            exercise
        });


    } catch (error) {

        console.error(
            'Get exercise error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while fetching exercise'
        });
    }
};



// ======================================
// UPDATE EXERCISE
// ======================================
const updateAdminExercise = async (req, res) => {
    try {

        const { id } = req.params;


        const {
            name,
            muscle_group,
            equipment,
            instructions,
            image_url,
            video_url,
            difficulty,
            status
        } = req.body;


        // Check exercise exists
        const existingExercise =
            await findExerciseById(id);


        if (!existingExercise) {
            return res.status(404).json({
                success: false,
                message: 'Exercise not found'
            });
        }


        // Required fields
        if (!name || !difficulty) {
            return res.status(400).json({
                success: false,
                message: 'Name and difficulty are required'
            });
        }


        const cleanName = name.trim();


        if (!cleanName) {
            return res.status(400).json({
                success: false,
                message: 'Exercise name cannot be empty'
            });
        }


        // Validate difficulty
        const allowedDifficulties = [
            'BEGINNER',
            'INTERMEDIATE',
            'DIFFICULT'
        ];


        if (!allowedDifficulties.includes(difficulty)) {
            return res.status(400).json({
                success: false,
                message:
                    'Difficulty must be BEGINNER, INTERMEDIATE or DIFFICULT'
            });
        }


        // Check duplicate name
        const duplicateExercise =
            await findExerciseByName(cleanName);


        if (
            duplicateExercise &&
            String(duplicateExercise.id) !== String(id)
        ) {
            return res.status(409).json({
                success: false,
                message: 'An exercise with this name already exists'
            });
        }


        // Validate status
        const exerciseStatus =
            status || existingExercise.status;


        if (
            !['ACTIVE', 'INACTIVE']
                .includes(exerciseStatus)
        ) {
            return res.status(400).json({
                success: false,
                message: 'Status must be ACTIVE or INACTIVE'
            });
        }


        // Update
        await updateExercise(
            id,
            {
                name: cleanName,

                muscle_group:
                    muscle_group
                        ? muscle_group.trim()
                        : null,

                equipment:
                    equipment
                        ? equipment.trim()
                        : null,

                instructions:
                    instructions
                        ? instructions.trim()
                        : null,

                image_url:
                    image_url
                        ? image_url.trim()
                        : null,

                video_url:
                    video_url
                        ? video_url.trim()
                        : null,

                difficulty,

                status: exerciseStatus
            }
        );


        // Get updated exercise
        const updatedExercise =
            await findExerciseById(id);


        return res.status(200).json({
            success: true,
            message: 'Exercise updated successfully',
            exercise: updatedExercise
        });


    } catch (error) {

        console.error(
            'Update exercise error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while updating exercise'
        });
    }
};



// ======================================
// DELETE EXERCISE
// ======================================
const deleteAdminExercise = async (req, res) => {
    try {

        const { id } = req.params;


        // Check exercise exists
        const existingExercise =
            await findExerciseById(id);


        if (!existingExercise) {
            return res.status(404).json({
                success: false,
                message: 'Exercise not found'
            });
        }


        // Delete
        await deleteExercise(id);


        return res.status(200).json({
            success: true,
            message: 'Exercise deleted successfully'
        });


    } catch (error) {

        console.error(
            'Delete exercise error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while deleting exercise'
        });
    }
};



module.exports = {
    createAdminExercise,
    getExercises,
    getExercise,
    updateAdminExercise,
    deleteAdminExercise
};