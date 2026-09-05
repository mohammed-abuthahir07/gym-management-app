const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { findTrainerByEmail, findTrainerById} = require('../model/trainerAuthModel');

const generateToken = (trainer) => {
    return jwt.sign(
        {
            id: trainer.id,
            email: trainer.email,
            role: trainer.role
        },
        process.env.JWT_SECRET,
        {
            expiresIn: process.env.JWT_EXPIRES_IN || '7d'
        }
    );
};

const login = async (req, res) => {
    try {
        const {
            email,
            password
        } = req.body;
        if (!email || !password) {
            return res.status(400).json({
                success: false,
                message: 'Email and password are required'
            });
        }

        const trainer = await findTrainerByEmail(email);
        if (!trainer) {
            return res.status(401).json({
                success: false,
                message: 'Invalid email or password'
            });
        }

        if (trainer.status !== 'ACTIVE') {
            return res.status(403).json({
                success: false,
                message: 'Trainer account is inactive'
            });
        }

        const passwordMatch = await bcrypt.compare(
            password,
            trainer.password
        );
        if (!passwordMatch) {
            return res.status(401).json({
                success: false,
                message: 'Invalid email or password'
            });
        }

        const token = generateToken(trainer);
        return res.status(200).json({
            success: true,
            message: 'Trainer login successful',
            token,
            trainer: {
                id: trainer.id,
                name: trainer.name,
                email: trainer.email,
                role: trainer.role,
                phone: trainer.phone,
                status: trainer.status
            }
        });
    } catch (error) {
        console.error(
            'Trainer login error:',
            error
        );
        return res.status(500).json({
            success: false,
            message: 'Server error during trainer login'
        });
    }
};


const getProfile = async (req, res) => {
    try {
        const trainerId = req.user.id;
        const trainer = await findTrainerById(
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
            message: 'Trainer profile fetched successfully',
            trainer: {
                id: trainer.id,
                name: trainer.name,
                email: trainer.email,
                role: trainer.role,
                phone: trainer.phone,
                status: trainer.status,
                created_at: trainer.created_at,
                updated_at: trainer.updated_at
            }
        });

    } catch (error) {
        console.error(
            'Trainer profile error:',
            error
        );
        return res.status(500).json({
            success: false,
            message: 'Server error while fetching trainer profile'
        });
    }
};

module.exports = {
    login,
    getProfile
};