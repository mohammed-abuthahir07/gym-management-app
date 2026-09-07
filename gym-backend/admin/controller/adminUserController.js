const {
    getAllMembers,
    findMemberById,
    deactivateMember,

    getAllTrainers,
    findTrainerById,
    deactivateTrainer
} = require('../model/adminUserModel');


// ======================================
// GET ALL MEMBERS
// ======================================
const getMembers = async (req, res) => {
    try {

        const members = await getAllMembers();

        return res.status(200).json({
            success: true,
            message: 'Members fetched successfully',
            members
        });

    } catch (error) {

        console.error(
            'Get members error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while fetching members'
        });
    }
};


// ======================================
// GET SINGLE MEMBER
// ======================================
const getMember = async (req, res) => {
    try {

        const { id } = req.params;

        const member =
            await findMemberById(id);

        if (!member) {
            return res.status(404).json({
                success: false,
                message: 'Member not found'
            });
        }

        return res.status(200).json({
            success: true,
            message: 'Member fetched successfully',
            member
        });

    } catch (error) {

        console.error(
            'Get member error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while fetching member'
        });
    }
};


// ======================================
// DELETE / DEACTIVATE MEMBER
// ======================================
const deleteMember = async (req, res) => {
    try {

        const { id } = req.params;

        const existingMember =
            await findMemberById(id);

        if (!existingMember) {
            return res.status(404).json({
                success: false,
                message: 'Member not found'
            });
        }

        if (existingMember.status === 'INACTIVE') {
            return res.status(400).json({
                success: false,
                message: 'Member is already inactive'
            });
        }

        await deactivateMember(id);

        const updatedMember =
            await findMemberById(id);

        return res.status(200).json({
            success: true,
            message: 'Member deleted successfully',
            member: updatedMember
        });

    } catch (error) {

        console.error(
            'Delete member error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while deleting member'
        });
    }
};


// ======================================
// GET ALL TRAINERS
// ======================================
const getTrainers = async (req, res) => {
    try {

        const trainers =
            await getAllTrainers();

        return res.status(200).json({
            success: true,
            message: 'Trainers fetched successfully',
            trainers
        });

    } catch (error) {

        console.error(
            'Get trainers error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while fetching trainers'
        });
    }
};


// ======================================
// GET SINGLE TRAINER
// ======================================
const getTrainer = async (req, res) => {
    try {

        const { id } = req.params;

        const trainer =
            await findTrainerById(id);

        if (!trainer) {
            return res.status(404).json({
                success: false,
                message: 'Trainer not found'
            });
        }

        return res.status(200).json({
            success: true,
            message: 'Trainer fetched successfully',
            trainer
        });

    } catch (error) {

        console.error(
            'Get trainer error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while fetching trainer'
        });
    }
};


// ======================================
// DELETE / DEACTIVATE TRAINER
// ======================================
const deleteTrainer = async (req, res) => {
    try {

        const { id } = req.params;

        const existingTrainer =
            await findTrainerById(id);

        if (!existingTrainer) {
            return res.status(404).json({
                success: false,
                message: 'Trainer not found'
            });
        }

        if (existingTrainer.status === 'INACTIVE') {
            return res.status(400).json({
                success: false,
                message: 'Trainer is already inactive'
            });
        }

        await deactivateTrainer(id);

        const updatedTrainer =
            await findTrainerById(id);

        return res.status(200).json({
            success: true,
            message: 'Trainer deleted successfully',
            trainer: updatedTrainer
        });

    } catch (error) {

        console.error(
            'Delete trainer error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while deleting trainer'
        });
    }
};


module.exports = {
    getMembers,
    getMember,
    deleteMember,
    getTrainers,
    getTrainer,
    deleteTrainer
};