const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const {
    createUser,
    findUserByEmail,
    findUserById
} = require('../models/userModel');


// ======================================
// GENERATE JWT TOKEN
// ======================================

const generateToken = (user) => {

    if (!process.env.JWT_SECRET) {
        throw new Error('JWT_SECRET is missing in .env file');
    }

    return jwt.sign(
        {
            id: user.id,
            role: user.role,
            email: user.email
        },
        process.env.JWT_SECRET,
        {
            expiresIn: process.env.JWT_EXPIRES_IN || '7d'
        }
    );
};


// ======================================
// MEMBER REGISTER
// ======================================

const register = async (req, res) => {
    try {

        const {
            name,
            email,
            phone,
            fitness_goal,
            password
        } = req.body;


        // Validate required fields
        if (!name || !email || !password) {
            return res.status(400).json({
                success: false,
                message: 'Name, email and password are required'
            });
        }


        // Check existing email
        const existingUser = await findUserByEmail(email);

        if (existingUser) {
            return res.status(409).json({
                success: false,
                message: 'Email already registered'
            });
        }


        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);


        // Always create MEMBER
        const userId = await createUser({
            name,
            email,
            password: hashedPassword,
            role: 'MEMBER',
            phone: phone || null,
            fitness_goal: fitness_goal || null
        });


        return res.status(201).json({
            success: true,
            message: 'Member registered successfully',
            user: {
                id: userId,
                name,
                email,
                role: 'MEMBER',
                phone: phone || null,
                fitness_goal: fitness_goal || null
            }
        });

    } catch (error) {

        console.error('Register error:', error);

        return res.status(500).json({
            success: false,
            message: 'Server error during registration'
        });
    }
};


// ======================================
// LOGIN
// ======================================

const login = async (req, res) => {
    try {

        const {
            email,
            password
        } = req.body;


        // Validate input
        if (!email || !password) {
            return res.status(400).json({
                success: false,
                message: 'Email and password are required'
            });
        }


        // Find user
        const user = await findUserByEmail(email);

        if (!user) {
            return res.status(401).json({
                success: false,
                message: 'Invalid email or password'
            });
        }


        // Check account status
        if (user.status !== 'ACTIVE') {
            return res.status(403).json({
                success: false,
                message: 'Your account is inactive'
            });
        }


        // Check password
        const passwordMatch = await bcrypt.compare(
            password,
            user.password
        );

        if (!passwordMatch) {
            return res.status(401).json({
                success: false,
                message: 'Invalid email or password'
            });
        }


        // Generate JWT
        const token = generateToken(user);


        // Return response
        return res.status(200).json({
            success: true,
            message: 'Login successful',

            token,

            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role,
                phone: user.phone,
                fitness_goal: user.fitness_goal,
                status: user.status
            }
        });

    } catch (error) {

        console.error('Login error:', error);

        return res.status(500).json({
            success: false,
            message: 'Server error during login'
        });
    }
};

const getProfile = async (req, res) => {
    try {
        const userId = req.user.id;

        const user = await findUserById(userId);

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        return res.status(200).json({
            success: true,
            message: 'Profile fetched successfully',
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role,
                phone: user.phone,
                fitness_goal: user.fitness_goal,
                status: user.status,
                created_at: user.created_at,
                updated_at: user.updated_at
            }
        });

    } catch (error) {
        console.error('Get profile error:', error);

        return res.status(500).json({
            success: false,
            message: 'Server error while fetching profile'
        });
    }
};


module.exports = {
    register,
    login,
    getProfile
};