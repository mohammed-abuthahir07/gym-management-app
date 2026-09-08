const memberProfileModel = require('../model/memberProfileModel');


// =====================================================
// CREATE PROFILE
// =====================================================

const createProfile = async (req, res) => {

    try {

        const memberId = req.user.id;

        const {
            name,
            phone,
            age,
            height,
            weight,
            fitness_goal,
            medical_notes
        } = req.body;


        // Validate required fields
        if (!name || !phone) {

            return res.status(400).json({
                success: false,
                message: 'Name and phone are required'
            });

        }


        // Check if profile already exists

        const existingProfile =
            await memberProfileModel.getProfile(memberId);


        if (existingProfile) {

            return res.status(409).json({
                success: false,
                message: 'Profile already exists'
            });

        }


        const profileId =
            await memberProfileModel.createProfile(
                memberId,
                name,
                phone,
                age ?? null,
                height ?? null,
                weight ?? null,
                fitness_goal ?? null,
                medical_notes ?? null
            );


        return res.status(201).json({

            success: true,

            message: 'Profile created successfully',

            profile: {
                id: profileId,
                name,
                phone,
                age: age ?? null,
                height: height ?? null,
                weight: weight ?? null,
                fitness_goal: fitness_goal ?? null,
                medical_notes: medical_notes ?? null
            }

        });

    } catch (error) {

        console.error('Create member profile error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to create profile'
        });
    }
};


// =====================================================
// GET OWN PROFILE
// =====================================================

const getProfile = async (req, res) => {

    try {

        const memberId = req.user.id;


        const profile =
            await memberProfileModel.getProfile(memberId);


        if (!profile) {

            return res.status(404).json({
                success: false,
                message: 'Profile not found'
            });

        }


        return res.status(200).json({

            success: true,

            message: 'Profile fetched successfully',

            profile

        });

    } catch (error) {

        console.error('Get member profile error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch profile'
        });
    }
};


// =====================================================
// UPDATE OWN PROFILE
// =====================================================

const updateProfile = async (req, res) => {

    try {

        const memberId = req.user.id;

        const {
            name,
            phone,
            age,
            height,
            weight,
            fitness_goal,
            medical_notes
        } = req.body;


        // Validate required fields

        if (!name || !phone) {

            return res.status(400).json({
                success: false,
                message: 'Name and phone are required'
            });

        }


        // Check profile exists

        const existingProfile =
            await memberProfileModel.getProfile(memberId);


        if (!existingProfile) {

            return res.status(404).json({
                success: false,
                message: 'Profile not found'
            });

        }


        await memberProfileModel.updateProfile(

            memberId,

            name,

            phone,

            age ?? null,

            height ?? null,

            weight ?? null,

            fitness_goal ?? null,

            medical_notes ?? null

        );


        const updatedProfile =
            await memberProfileModel.getProfile(memberId);


        return res.status(200).json({

            success: true,

            message: 'Profile updated successfully',

            profile: updatedProfile

        });

    } catch (error) {

        console.error('Update member profile error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to update profile'
        });
    }
};


module.exports = {
    createProfile,
    getProfile,
    updateProfile
};