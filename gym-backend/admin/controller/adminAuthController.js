const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { findAdminByEmail, findAdminById } = require('../model/adminAuthModel');


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


const login = async (req, res) => {

    try {
        const { email, password } = req.body;
        if (!email || !password) {
            return res.status(400).json({
                success: false,
                message: 'Email and password are required'
            });
        }
        const admin = await findAdminByEmail(email);
        if (!admin) {

            return res.status(401).json({
                success: false,
                message: 'Invalid email or password'
            });
        }
        if (admin.status !== 'ACTIVE') {

            return res.status(403).json({
                success: false,
                message: 'Admin account is inactive'
            });
        }

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



const getProfile = async (req, res) => {
    try {
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