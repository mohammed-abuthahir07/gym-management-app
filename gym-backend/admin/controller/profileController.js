const {
    findAdminById,
    findAdminByEmailExceptId,
    updateAdminProfile
} = require('../model/profileModel');


// ============================================================
// UPDATE ADMIN PROFILE
// ============================================================

const updateAdminProfileController = async (req, res) => {
    try {
        // Admin ID comes ONLY from JWT
        const adminId = req.user.id;

        const {
            name,
            email,
            phone
        } = req.body;

        // --------------------------------------------------------
        // Validation
        // --------------------------------------------------------

        if (!name || !name.trim()) {
            return res.status(400).json({
                success: false,
                message: 'Name is required'
            });
        }

        if (!email || !email.trim()) {
            return res.status(400).json({
                success: false,
                message: 'Email is required'
            });
        }

        // Basic email validation
        const emailRegex =
            /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (!emailRegex.test(email.trim())) {
            return res.status(400).json({
                success: false,
                message: 'Please provide a valid email address'
            });
        }

        // --------------------------------------------------------
        // Check admin exists
        // --------------------------------------------------------

        const admin = await findAdminById(adminId);

        if (!admin) {
            return res.status(404).json({
                success: false,
                message: 'Admin profile not found'
            });
        }

        // --------------------------------------------------------
        // Check duplicate email
        // --------------------------------------------------------

        const existingUser =
            await findAdminByEmailExceptId(
                email.trim(),
                adminId
            );

        if (existingUser) {
            return res.status(409).json({
                success: false,
                message: 'Email is already in use'
            });
        }

        // --------------------------------------------------------
        // Update profile
        // --------------------------------------------------------

        await updateAdminProfile({
            id: adminId,
            name: name.trim(),
            email: email.trim(),
            phone: phone ? phone.trim() : null
        });

        // --------------------------------------------------------
        // Get updated profile
        // --------------------------------------------------------

        const updatedAdmin =
            await findAdminById(adminId);

        return res.status(200).json({
            success: true,
            message: 'Admin profile updated successfully',
            admin: updatedAdmin
        });

    } catch (error) {
        console.error(
            'Update admin profile error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to update admin profile'
        });
    }
};


module.exports = {
    updateAdminProfileController
};