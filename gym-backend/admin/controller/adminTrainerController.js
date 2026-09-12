const bcrypt = require('bcryptjs');

const {
    findTrainerByEmail,
    findTrainerById,
    getAllTrainers,
    createTrainer,
    findTrainerByEmailExceptId,
    updateTrainer,
    updateTrainerWithPassword,
    deactivateTrainer
} = require('../model/adminTrainerModel');


// ============================================================
// CREATE TRAINER
//
// POST /api/admin/trainers
// ============================================================

const createTrainerAccount = async (req, res) => {

    try {

        const {
            name,
            email,
            phone,
            password
        } = req.body;


        if (!name || !email || !password) {

            return res.status(400).json({
                success: false,
                message: 'Name, email and password are required'
            });
        }


        const existingUser =
            await findTrainerByEmail(
                email.trim()
            );

        if (existingUser) {

            return res.status(409).json({
                success: false,
                message: 'User with this email already exists'
            });
        }


        const hashedPassword =
            await bcrypt.hash(
                password,
                10
            );


        const trainerId =
            await createTrainer({
                name: name.trim(),
                email: email.trim(),
                password: hashedPassword,
                phone: phone
                    ? phone.trim()
                    : null
            });


        return res.status(201).json({
            success: true,
            message: 'Trainer created successfully',
            trainer: {
                id: trainerId,
                name: name.trim(),
                email: email.trim(),
                phone: phone || null,
                role: 'TRAINER',
                status: 'ACTIVE'
            }
        });

    } catch (error) {

        console.error(
            'Create trainer error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while creating trainer'
        });
    }
};


// ============================================================
// GET ALL TRAINERS
//
// GET /api/admin/trainers
// ============================================================

const getTrainers = async (req, res) => {

    try {

        const trainers =
            await getAllTrainers();

        return res.status(200).json({
            success: true,
            message: 'Trainers fetched successfully',
            trainers
        });

    } catch (error) {

        console.error(
            'Get trainers error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while fetching trainers'
        });
    }
};


// ============================================================
// GET SINGLE TRAINER
//
// GET /api/admin/trainers/:id
// ============================================================

const getTrainer = async (req, res) => {

    try {

        const trainerId =
            Number(req.params.id);


        if (!Number.isInteger(trainerId)) {

            return res.status(400).json({
                success: false,
                message: 'Invalid trainer ID'
            });
        }


        const trainer =
            await findTrainerById(
                trainerId
            );


        if (!trainer) {

            return res.status(404).json({
                success: false,
                message: 'Trainer not found'
            });
        }


        return res.status(200).json({
            success: true,
            message: 'Trainer fetched successfully',
            trainer
        });

    } catch (error) {

        console.error(
            'Get trainer error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while fetching trainer'
        });
    }
};


// ============================================================
// UPDATE TRAINER
//
// PUT /api/admin/trainers/:id
//
// Supported:
// name
// email
// phone
// password
// status
//
// status = ACTIVE / INACTIVE
// ============================================================

const updateTrainerAccount = async (req, res) => {

    try {

        const trainerId =
            Number(req.params.id);


        const {
            name,
            email,
            phone,
            password,
            status
        } = req.body;


        // ------------------------------------------------------
        // VALIDATE ID
        // ------------------------------------------------------

        if (!Number.isInteger(trainerId)) {

            return res.status(400).json({
                success: false,
                message: 'Invalid trainer ID'
            });
        }


        // ------------------------------------------------------
        // GET EXISTING TRAINER
        // ------------------------------------------------------

        const trainer =
            await findTrainerById(
                trainerId
            );


        if (!trainer) {

            return res.status(404).json({
                success: false,
                message: 'Trainer not found'
            });
        }


        // ------------------------------------------------------
        // KEEP OLD VALUES IF NOT PROVIDED
        // ------------------------------------------------------

        const updatedName =
            name !== undefined
                ? name.trim()
                : trainer.name;


        const updatedEmail =
            email !== undefined
                ? email.trim()
                : trainer.email;


        const updatedPhone =
            phone !== undefined
                ? (
                    phone === null ||
                    phone === ''
                        ? null
                        : phone.trim()
                )
                : trainer.phone;


        const updatedStatus =
            status !== undefined
                ? status.toUpperCase()
                : trainer.status;


        // ------------------------------------------------------
        // VALIDATE NAME
        // ------------------------------------------------------

        if (!updatedName) {

            return res.status(400).json({
                success: false,
                message: 'Name cannot be empty'
            });
        }


        // ------------------------------------------------------
        // VALIDATE EMAIL
        // ------------------------------------------------------

        if (!updatedEmail) {

            return res.status(400).json({
                success: false,
                message: 'Email cannot be empty'
            });
        }


        // ------------------------------------------------------
        // VALIDATE STATUS
        // ------------------------------------------------------

        if (
            updatedStatus !== 'ACTIVE' &&
            updatedStatus !== 'INACTIVE'
        ) {

            return res.status(400).json({
                success: false,
                message: 'Status must be ACTIVE or INACTIVE'
            });
        }


        // ------------------------------------------------------
        // CHECK DUPLICATE EMAIL
        // ------------------------------------------------------

        const existingUser =
            await findTrainerByEmailExceptId(
                updatedEmail,
                trainerId
            );


        if (existingUser) {

            return res.status(409).json({
                success: false,
                message: 'User with this email already exists'
            });
        }


        // ------------------------------------------------------
        // UPDATE WITH PASSWORD
        // ------------------------------------------------------

        if (
            password !== undefined &&
            password !== null &&
            password.trim() !== ''
        ) {

            const hashedPassword =
                await bcrypt.hash(
                    password,
                    10
                );


            await updateTrainerWithPassword({
                id: trainerId,
                name: updatedName,
                email: updatedEmail,
                phone: updatedPhone,
                password: hashedPassword,
                status: updatedStatus
            });

        }

        // ------------------------------------------------------
        // UPDATE WITHOUT PASSWORD
        // ------------------------------------------------------

        else {

            await updateTrainer({
                id: trainerId,
                name: updatedName,
                email: updatedEmail,
                phone: updatedPhone,
                status: updatedStatus
            });
        }


        // ------------------------------------------------------
        // GET UPDATED TRAINER
        // ------------------------------------------------------

        const updatedTrainer =
            await findTrainerById(
                trainerId
            );


        return res.status(200).json({
            success: true,
            message: 'Trainer updated successfully',
            trainer: updatedTrainer
        });

    } catch (error) {

        console.error(
            'Update trainer error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while updating trainer'
        });
    }
};


// ============================================================
// DELETE / DEACTIVATE TRAINER
//
// DELETE /api/admin/trainers/:id
//
// ACTIVE -> INACTIVE
// ============================================================

const deleteTrainer = async (req, res) => {

    try {

        const trainerId =
            Number(req.params.id);


        if (!Number.isInteger(trainerId)) {

            return res.status(400).json({
                success: false,
                message: 'Invalid trainer ID'
            });
        }


        const trainer =
            await findTrainerById(
                trainerId
            );


        if (!trainer) {

            return res.status(404).json({
                success: false,
                message: 'Trainer not found'
            });
        }


        if (
            trainer.status === 'INACTIVE'
        ) {

            return res.status(400).json({
                success: false,
                message: 'Trainer is already inactive'
            });
        }


        await deactivateTrainer(
            trainerId
        );


        const updatedTrainer =
            await findTrainerById(
                trainerId
            );


        return res.status(200).json({
            success: true,
            message: 'Trainer deactivated successfully',
            trainer: updatedTrainer
        });

    } catch (error) {

        console.error(
            'Delete trainer error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while deactivating trainer'
        });
    }
};


// ============================================================
// EXPORT
// ============================================================

module.exports = {
    createTrainerAccount,
    getTrainers,
    getTrainer,
    updateTrainerAccount,
    deleteTrainer
};