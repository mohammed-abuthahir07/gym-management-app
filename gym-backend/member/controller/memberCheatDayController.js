const {
    createCheatDay,
    getMemberCheatDays,
    getMemberCheatDayById,
    updateCheatDay,
    deleteCheatDay
} = require('../model/memberCheatDayModel');


// ============================================
// CREATE CHEAT DAY ACTIVITY
// ============================================

const addCheatDay = async (req, res) => {
    try {
        const memberId = req.user.id;

        const {
            cheat_date,
            food_name,
            quantity,
            calories,
            notes
        } = req.body;

        // Required field validation
        if (!cheat_date || !food_name) {
            return res.status(400).json({
                success: false,
                message: 'cheat_date and food_name are required'
            });
        }

        // Calories validation
        if (
            calories !== undefined &&
            calories !== null &&
            calories !== '' &&
            Number(calories) < 0
        ) {
            return res.status(400).json({
                success: false,
                message: 'Calories cannot be negative'
            });
        }

        const cheatDayId = await createCheatDay(
            memberId,
            cheat_date,
            food_name,
            quantity,
            calories,
            notes
        );

        return res.status(201).json({
            success: true,
            message: 'Cheat activity added successfully',
            id: cheatDayId
        });

    } catch (error) {
        console.error('Add cheat day error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to add cheat activity'
        });
    }
};


// ============================================
// GET ALL CHEAT ACTIVITIES
// ============================================

const getCheatDays = async (req, res) => {
    try {
        const memberId = req.user.id;

        const cheatDays = await getMemberCheatDays(memberId);

        return res.status(200).json({
            success: true,
            count: cheatDays.length,
            cheat_days: cheatDays
        });

    } catch (error) {
        console.error('Get cheat days error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch cheat activities'
        });
    }
};


// ============================================
// GET ONE CHEAT ACTIVITY
// ============================================

const getCheatDay = async (req, res) => {
    try {
        const memberId = req.user.id;
        const cheatDayId = req.params.id;

        const cheatDay = await getMemberCheatDayById(
            cheatDayId,
            memberId
        );

        if (!cheatDay) {
            return res.status(404).json({
                success: false,
                message: 'Cheat activity not found'
            });
        }

        return res.status(200).json({
            success: true,
            cheat_day: cheatDay
        });

    } catch (error) {
        console.error('Get cheat day error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch cheat activity'
        });
    }
};


// ============================================
// UPDATE CHEAT ACTIVITY
// ============================================

const editCheatDay = async (req, res) => {
    try {
        const memberId = req.user.id;
        const cheatDayId = req.params.id;

        const {
            cheat_date,
            food_name,
            quantity,
            calories,
            notes
        } = req.body;

        // Required field validation
        if (!cheat_date || !food_name) {
            return res.status(400).json({
                success: false,
                message: 'cheat_date and food_name are required'
            });
        }

        // Check ownership first
        const existingCheatDay = await getMemberCheatDayById(
            cheatDayId,
            memberId
        );

        if (!existingCheatDay) {
            return res.status(404).json({
                success: false,
                message: 'Cheat activity not found'
            });
        }

        // Calories validation
        if (
            calories !== undefined &&
            calories !== null &&
            calories !== '' &&
            Number(calories) < 0
        ) {
            return res.status(400).json({
                success: false,
                message: 'Calories cannot be negative'
            });
        }

        const affectedRows = await updateCheatDay(
            cheatDayId,
            memberId,
            cheat_date,
            food_name,
            quantity,
            calories,
            notes
        );

        if (affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: 'Cheat activity not found'
            });
        }

        return res.status(200).json({
            success: true,
            message: 'Cheat activity updated successfully'
        });

    } catch (error) {
        console.error('Update cheat day error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to update cheat activity'
        });
    }
};


// ============================================
// DELETE CHEAT ACTIVITY
// ============================================

const removeCheatDay = async (req, res) => {
    try {
        const memberId = req.user.id;
        const cheatDayId = req.params.id;

        const affectedRows = await deleteCheatDay(
            cheatDayId,
            memberId
        );

        if (affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: 'Cheat activity not found'
            });
        }

        return res.status(200).json({
            success: true,
            message: 'Cheat activity deleted successfully'
        });

    } catch (error) {
        console.error('Delete cheat day error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to delete cheat activity'
        });
    }
};


module.exports = {
    addCheatDay,
    getCheatDays,
    getCheatDay,
    editCheatDay,
    removeCheatDay
};