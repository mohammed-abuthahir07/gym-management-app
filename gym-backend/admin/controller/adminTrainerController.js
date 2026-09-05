const bcrypt = require('bcryptjs');

const {
    findTrainerByEmail,
    createTrainer
} = require('../model/adminTrainerModel');


// ======================================
// CREATE TRAINER
// ADMIN ONLY
// ======================================

const createTrainerAccount = async (req, res) => {

    try {

        const {
            name,
            email,
            phone,
            password
        } = req.body;


        // ==============================
        // REQUIRED FIELDS
        // ==============================

        if (!name || !email || !password) {

            return res.status(400).json({
                success: false,
                message: 'Name, email and password are required'
            });
        }


        // ==============================
        // CHECK EXISTING EMAIL
        // ==============================

        const existingUser = await findTrainerByEmail(email);

        if (existingUser) {

            return res.status(409).json({
                success: false,
                message: 'User with this email already exists'
            });
        }


        // ==============================
        // HASH PASSWORD
        // ==============================

        const hashedPassword = await bcrypt.hash(
            password,
            10
        );


        // ==============================
        // CREATE TRAINER
        // ==============================

        const trainerId = await createTrainer({
            name,
            email,
            password: hashedPassword,
            phone
        });


        // ==============================
        // RESPONSE
        // ==============================

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