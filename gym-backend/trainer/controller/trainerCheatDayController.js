const {
    getAssignedMembers,
    getMemberCheatDays,
    getMemberCheatDayById,
    getCurrentMonthCheatDays,
    getPreviousMonthCheatDays
} = require('../model/trainerCheatDayModel');


// =====================================================
// GET ASSIGNED MEMBERS
// =====================================================

const getTrainerAssignedMembers = async (req, res) => {
    try {

        const trainerId = req.user.id;

        const members = await getAssignedMembers(trainerId);

        return res.status(200).json({
            success: true,
            count: members.length,
            members
        });

    } catch (error) {

        console.error(
            'Get trainer assigned members error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch assigned members'
        });
    }
};


// =====================================================
// GET ALL CHEAT ACTIVITIES OF ONE ASSIGNED MEMBER
// =====================================================

const getAssignedMemberCheatDays = async (req, res) => {
    try {

        const trainerId = req.user.id;
        const memberId = req.params.memberId;

        const cheatDays = await getMemberCheatDays(
            memberId,
            trainerId
        );

        return res.status(200).json({
            success: true,
            member_id: Number(memberId),
            count: cheatDays.length,
            cheat_days: cheatDays
        });

    } catch (error) {

        console.error(
            'Get assigned member cheat days error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch member cheat activities'
        });
    }
};


// =====================================================
// GET ONE CHEAT ACTIVITY
// =====================================================

const getAssignedMemberCheatDay = async (req, res) => {
    try {

        const trainerId = req.user.id;
        const memberId = req.params.memberId;
        const cheatDayId = req.params.id;

        const cheatDay = await getMemberCheatDayById(
            cheatDayId,
            memberId,
            trainerId
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

        console.error(
            'Get assigned member cheat day error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch cheat activity'
        });
    }
};


// =====================================================
// GET CURRENT MONTH CHEAT DETAILS
// FOR ALL ASSIGNED MEMBERS
// =====================================================

const getCurrentMonthCheatDetails = async (req, res) => {
    try {

        const trainerId = req.user.id;

        const cheatDays = await getCurrentMonthCheatDays(
            trainerId
        );

        return res.status(200).json({
            success: true,
            month: 'CURRENT_MONTH',
            count: cheatDays.length,
            cheat_days: cheatDays
        });

    } catch (error) {

        console.error(
            'Get current month cheat details error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch current month cheat details'
        });
    }
};


// =====================================================
// GET PREVIOUS MONTH CHEAT DETAILS
// FOR ALL ASSIGNED MEMBERS
// =====================================================

const getPreviousMonthCheatDetails = async (req, res) => {
    try {

        const trainerId = req.user.id;

        const cheatDays = await getPreviousMonthCheatDays(
            trainerId
        );

        return res.status(200).json({
            success: true,
            month: 'PREVIOUS_MONTH',
            count: cheatDays.length,
            cheat_days: cheatDays
        });

    } catch (error) {

        console.error(
            'Get previous month cheat details error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch previous month cheat details'
        });
    }
};


module.exports = {
    getTrainerAssignedMembers,
    getAssignedMemberCheatDays,
    getAssignedMemberCheatDay,
    getCurrentMonthCheatDetails,
    getPreviousMonthCheatDetails
};