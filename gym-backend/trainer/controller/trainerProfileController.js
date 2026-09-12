const {
    findTrainerById,
    findTrainerByEmailExceptId,
    updateTrainerProfile
} = require('../model/trainerProfileModel');


// ============================================================
// UPDATE TRAINER PROFILE
// ============================================================

const updateTrainerProfileController = async (
    req,
    res
) => {
    try {

        // Trainer ID comes from JWT.
        // Never accept trainer ID from request body.
        const trainerId = req.user.id;

        const {
            name,
            email,
            phone
        } = req.body;


        // ====================================================
        // NAME VALIDATION
        // ====================================================

        if (!name || !name.trim()) {
            return res.status(400).json({
                success: false,
                message: 'Name is required'
            });
        }


        // ====================================================
        // EMAIL VALIDATION
        // ====================================================

        if (!email || !email.trim()) {
            return res.status(400).json({
                success: false,
                message: 'Email is required'
            });
        }


        const emailRegex =
            /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (!emailRegex.test(email.trim())) {
            return res.status(400).json({
                success: false,
                message: 'Please provide a valid email address'
            });
        }


        // ====================================================
        // FIND CURRENT TRAINER
        // ====================================================

        const trainer =
            await findTrainerById(trainerId);

        if (!trainer) {
            return res.status(404).json({
                success: false,
                message: 'Trainer profile not found'
            });
        }


        // ====================================================
        // CHECK EMAIL DUPLICATE
        // ====================================================

        const existingUser =
            await findTrainerByEmailExceptId(
                email.trim(),
                trainerId
            );

        if (existingUser) {
            return res.status(409).json({
                success: false,
                message: 'Email is already in use'
            });
        }


        // ====================================================
        // UPDATE PROFILE
        // ====================================================

        await updateTrainerProfile({
            id: trainerId,
            name: name.trim(),
            email: email.trim(),
            phone: phone && phone.trim()
                ? phone.trim()
                : null
        });


        // ====================================================
        // GET UPDATED TRAINER
        // ====================================================

        const updatedTrainer =
            await findTrainerById(trainerId);


        return res.status(200).json({
            success: true,
            message: 'Trainer profile updated successfully',
            trainer: updatedTrainer
        });

    } catch (error) {

        console.error(
            'Update trainer profile error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to update trainer profile'
        });
    }
};


module.exports = {
    updateTrainerProfileController
};