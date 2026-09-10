const publicTrainerModel = require('../model/publicTrainerModel');

const getPublicTrainers = async (req, res) => {
    try {
        const trainers =
            await publicTrainerModel.getPublicTrainers();

        return res.status(200).json({
            success: true,
            count: trainers.length,
            trainers
        });

    } catch (error) {
        console.error('Get public trainers error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch trainers'
        });
    }
};

module.exports = {
    getPublicTrainers
};