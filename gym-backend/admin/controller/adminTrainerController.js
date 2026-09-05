const bcrypt = require('bcryptjs');

const { findTrainerByEmail, createTrainer} = require('../model/adminTrainerModel');

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

        const existingUser = await findTrainerByEmail(email);
        if (existingUser) {
            return res.status(409).json({
                success: false,
                message: 'User with this email already exists'
            });
        }

        const hashedPassword = await bcrypt.hash( password, 10);

        const trainerId = await createTrainer({
            name,
            email,
            password: hashedPassword,
            phone
        });

        return res.status(201).json({
            success: true,
            message: 'Trainer created successfully',
            trainer: {
                id: trainerId,
                name,
                email,
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


module.exports = {
    createTrainerAccount
};