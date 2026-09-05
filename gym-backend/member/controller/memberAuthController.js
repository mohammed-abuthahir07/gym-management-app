const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const {
    createMember,
    findMemberByEmail,
    findMemberById
} = require('../model/memberAuthModel');

const generateToken = (member) => {

    return jwt.sign(
        {
            id: member.id,
            email: member.email,
            role: member.role
        },
        process.env.JWT_SECRET,
        {
            expiresIn: process.env.JWT_EXPIRES_IN || '7d'
        }
    );
};


// ===============================
// MEMBER REGISTER
// ===============================

const register = async (req, res) => {

    try {

        const {
            name,
            email,
            phone,
            fitness_goal,
            password
        } = req.body;


        // Required fields
        if (!name || !email || !password) {

            return res.status(400).json({
                success: false,
                message: 'Name, email and password are required'
            });
        }


        // Check existing member
        const existingMember = await findMemberByEmail(email);

        if (existingMember) {

            return res.status(409).json({
                success: false,
                message: 'Member with this email already exists'
            });
        }


        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);


        // Create member
        const memberId = await createMember({
            name,
            email,
            password: hashedPassword,
            phone,
            fitness_goal
        });


        return res.status(201).json({
            success: true,
            message: 'Member registered successfully',
            memberId
        });

    } catch (error) {

        console.error('Member registration error:', error);

        return res.status(500).json({
            success: false,
            message: 'Server error during member registration'
        });
    }
};


// ===============================
// MEMBER LOGIN
// ===============================

const login = async (req, res) => {

    try {

        const {
            email,
            password
        } = req.body;


        // Required fields
        if (!email || !password) {

            return res.status(400).json({
                success: false,
                message: 'Email and password are required'
            });
        }


        // Find MEMBER only
        const member = await findMemberByEmail(email);

        if (!member) {

            return res.status(401).json({
                success: false,
                message: 'Invalid email or password'
            });
        }


        // Check status
        if (member.status !== 'ACTIVE') {

            return res.status(403).json({
                success: false,
                message: 'Member account is inactive'
            });
        }


        // Compare password
        const passwordMatch = await bcrypt.compare(
            password,
            member.password
        );

        if (!passwordMatch) {

            return res.status(401).json({
                success: false,
                message: 'Invalid email or password'
            });
        }


        // Generate JWT
        const token = generateToken(member);


        return res.status(200).json({
            success: true,
            message: 'Member login successful',
            token,
            user: {
                id: member.id,
                name: member.name,
                email: member.email,
                role: member.role,
                phone: member.phone,
                fitness_goal: member.fitness_goal,
                status: member.status
            }
        });

    } catch (error) {

        console.error('Member login error:', error);

        return res.status(500).json({
            success: false,
            message: 'Server error during member login'
        });
    }
};


// ===============================
// MEMBER PROFILE
// ===============================

const getProfile = async (req, res) => {
    try {

        // Get logged-in member ID from JWT
        const memberId = req.user.id;

        const member = await findMemberById(memberId);

        if (!member) {
            return res.status(404).json({
                success: false,
                message: 'Member not found'
            });
        }

        return res.status(200).json({
            success: true,
            message: 'Member profile fetched successfully',
            member: {
                id: member.id,
                name: member.name,
                email: member.email,
                role: member.role,
                phone: member.phone,
                fitness_goal: member.fitness_goal,
                status: member.status,
                created_at: member.created_at,
                updated_at: member.updated_at
            }
        });

    } catch (error) {

        console.error('Member profile error:', error);

        return res.status(500).json({
            success: false,
            message: 'Server error while fetching member profile'
        });
    }
};


module.exports = {
    register,
    login,
    getProfile
};