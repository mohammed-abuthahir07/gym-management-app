const {
    createChallenge,
    findChallengeById,
    getAllChallenges,
    updateChallenge,
    deleteChallenge
} = require('../model/adminChallengesModel');


// CREATE CHALLENGE
const createAdminChallenge = async (req, res) => {
    try {
        const {
            title,
            description,
            start_date,
            end_date,
            reward
        } = req.body;


        // Validate required fields
        if (
            !title ||
            !start_date ||
            !end_date
        ) {
            return res.status(400).json({
                success: false,
                message: 'Title, start date and end date are required'
            });
        }


        // Clean title
        const cleanTitle = title.trim();


        if (!cleanTitle) {
            return res.status(400).json({
                success: false,
                message: 'Title cannot be empty'
            });
        }


        // Validate dates
        const startDate = new Date(start_date);
        const endDate = new Date(end_date);


        if (
            isNaN(startDate.getTime()) ||
            isNaN(endDate.getTime())
        ) {
            return res.status(400).json({
                success: false,
                message: 'Invalid start date or end date'
            });
        }


        // End date must be after start date
        if (endDate <= startDate) {
            return res.status(400).json({
                success: false,
                message: 'End date must be after start date'
            });
        }


        // Create challenge
        const challengeId =
            await createChallenge({
                title: cleanTitle,
                description: description
                    ? description.trim()
                    : null,
                start_date,
                end_date,
                reward: reward
                    ? reward.trim()
                    : null
            });


        // Fetch created challenge
        const createdChallenge =
            await findChallengeById(
                challengeId
            );


        return res.status(201).json({
            success: true,
            message: 'Challenge created successfully',
            challenge: createdChallenge
        });


    } catch (error) {

        console.error(
            'Create challenge error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while creating challenge'
        });
    }
};



// GET ALL CHALLENGES
const getChallenges = async (req, res) => {
    try {

        const challenges =
            await getAllChallenges();


        return res.status(200).json({
            success: true,
            message: 'Challenges fetched successfully',
            challenges
        });


    } catch (error) {

        console.error(
            'Get challenges error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while fetching challenges'
        });
    }
};



// GET SINGLE CHALLENGE
const getChallenge = async (req, res) => {
    try {

        const { id } = req.params;


        const challenge =
            await findChallengeById(id);


        if (!challenge) {
            return res.status(404).json({
                success: false,
                message: 'Challenge not found'
            });
        }


        return res.status(200).json({
            success: true,
            message: 'Challenge fetched successfully',
            challenge
        });


    } catch (error) {

        console.error(
            'Get challenge error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while fetching challenge'
        });
    }
};



// UPDATE CHALLENGE
const updateAdminChallenge = async (req, res) => {
    try {

        const { id } = req.params;


        const {
            title,
            description,
            start_date,
            end_date,
            reward,
            status
        } = req.body;


        // Check challenge exists
        const existingChallenge =
            await findChallengeById(id);


        if (!existingChallenge) {
            return res.status(404).json({
                success: false,
                message: 'Challenge not found'
            });
        }


        // Required fields
        if (
            !title ||
            !start_date ||
            !end_date
        ) {
            return res.status(400).json({
                success: false,
                message: 'Title, start date and end date are required'
            });
        }


        const cleanTitle = title.trim();


        if (!cleanTitle) {
            return res.status(400).json({
                success: false,
                message: 'Title cannot be empty'
            });
        }


        // Validate dates
        const startDate = new Date(start_date);
        const endDate = new Date(end_date);


        if (
            isNaN(startDate.getTime()) ||
            isNaN(endDate.getTime())
        ) {
            return res.status(400).json({
                success: false,
                message: 'Invalid start date or end date'
            });
        }


        if (endDate <= startDate) {
            return res.status(400).json({
                success: false,
                message: 'End date must be after start date'
            });
        }


        // Validate status
        const challengeStatus =
            status || existingChallenge.status;


        if (
            !['ACTIVE', 'INACTIVE']
                .includes(challengeStatus)
        ) {
            return res.status(400).json({
                success: false,
                message: 'Status must be ACTIVE or INACTIVE'
            });
        }


        // Update challenge
        await updateChallenge(
            id,
            {
                title: cleanTitle,

                description: description
                    ? description.trim()
                    : null,

                start_date,

                end_date,

                reward: reward
                    ? reward.trim()
                    : null,

                status: challengeStatus
            }
        );


        // Fetch updated challenge
        const updatedChallenge =
            await findChallengeById(id);


        return res.status(200).json({
            success: true,
            message: 'Challenge updated successfully',
            challenge: updatedChallenge
        });


    } catch (error) {

        console.error(
            'Update challenge error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while updating challenge'
        });
    }
};



// DELETE CHALLENGE
const deleteAdminChallenge = async (req, res) => {
    try {

        const { id } = req.params;


        // Check challenge exists
        const existingChallenge =
            await findChallengeById(id);


        if (!existingChallenge) {
            return res.status(404).json({
                success: false,
                message: 'Challenge not found'
            });
        }


        // Delete challenge
        await deleteChallenge(id);


        return res.status(200).json({
            success: true,
            message: 'Challenge deleted successfully'
        });


    } catch (error) {

        console.error(
            'Delete challenge error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while deleting challenge'
        });
    }
};



module.exports = {
    createAdminChallenge,
    getChallenges,
    getChallenge,
    updateAdminChallenge,
    deleteAdminChallenge
};