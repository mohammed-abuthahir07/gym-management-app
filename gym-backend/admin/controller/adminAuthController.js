const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const {
    findAdminByEmail,
    findAdminById
} = require('../model/adminAuthModel');


// ===============================
// GENERATE ADMIN TOKEN
// ===============================

const generateToken = (admin) => {

    return jwt.sign(
        {
            id: admin.id,
            email: admin.email,
            role: admin.role
        },
        process.env.JWT_SECRET,
        {
            expiresIn: process.env.JWT_EXPIRES_IN || '7d'
        }
    );
};


// ===============================
// ADMIN LOGIN
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


        // Find ADMIN only
        const admin = await findAdminByEmail(email);

        if (!admin) {

            return res.status(401).json({
                success: false,
                message: 'Invalid email or password'
            });
        }


        // Check account status
        if (admin.status !== 'ACTIVE') {

            return res.status(403).json({
                success: false,
                message: 'Admin account is inactive'
            });
        }


        // Compare password
        const passwordMatch = await bcrypt.compare(
            password,
            admin.password
        );

        if (!passwordMatch) {

            return res.status(401).json({
                success: false,
                message: 'Invalid email or password'
            });
        }


        // Generate JWT
        const token = generateToken(admin);


        return res.status(200).json({
            success: true,
            message: 'Admin login successful',
            token,
            admin: {
                id: admin.id,
                name: admin.name,
                email: admin.email,
                role: admin.role,
                phone: admin.phone,
                status: admin.status
            }
        });

    } catch (error) {

        console.error('Admin login error:', error);

        return res.status(500).json({
            success: false,
            message: 'Server error during admin login'
        });
    }
};


// ===============================
// ADMIN PROFILE
// ===============================

const getProfile = async (req, res) => {

    try {

        // Get admin ID from JWT
        const adminId = req.user.id;

        const admin = await findAdminById(adminId);

        if (!admin) {

            return res.status(404).json({
                success: false,
                message: 'Admin not found'
            });
        }


        return res.status(200).json({
            success: true,
            message: 'Admin profile fetched successfully',
            admin: {
                id: admin.id,
                name: admin.name,
                email: admin.email,
                role: admin.role,
                phone: admin.phone,
                status: admin.status,
                created_at: admin.created_at,
                updated_at: admin.updated_at
            }
        });

    } catch (error) {

        console.error('Admin profile error:', error);

        return res.status(500).json({
            success: false,
            message: 'Server error while fetching admin profile'
        });
    }
};


module.exports = {
    login,
    getProfile
};