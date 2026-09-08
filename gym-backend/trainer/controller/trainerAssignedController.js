const {
    getAssignedMembers,
    getAssignedMemberProfile
} = require('../model/trainerAssignedModel');


// ==========================================
// GET ALL ASSIGNED MEMBERS
// ==========================================

const getAssignedMembersController = async (req, res) => {

    try {

        // Logged-in trainer ID from JWT
        const trainerId = req.user.id;

        const members = await getAssignedMembers(
            trainerId
        );

        res.status(200).json({
            count: members.length,
            members
        });

    } catch (error) {

        console.error(
            'Get assigned members error:',
            error
        );

        res.status(500).json({
            message: 'Server error'
        });
    }
};


// ==========================================
// GET ONE ASSIGNED MEMBER PROFILE
// ==========================================

const getAssignedMemberProfileController = async (
    req,
    res
) => {

    try {

        // Logged-in trainer ID
        const trainerId = req.user.id;

        // Member ID from URL
        const memberId = req.params.id;

        const member = await getAssignedMemberProfile(
            memberId,
            trainerId
        );

        if (!member) {
            return res.status(404).json({
                message: 'Member not found or member is not assigned to you'
            });
        }

        res.status(200).json({
            member
        });

    } catch (error) {

        console.error(
            'Get assigned member profile error:',
            error
        );

        res.status(500).json({
            message: 'Server error'
        });
    }
};


module.exports = {
    getAssignedMembersController,
    getAssignedMemberProfileController
};