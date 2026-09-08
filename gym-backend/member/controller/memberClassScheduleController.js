const {
    getMemberClassSchedules,
    getMemberClassScheduleById
} = require('../model/memberClassScheduleModel');


// ==========================================
// GET ALL MEMBER CLASS SCHEDULES
// ==========================================
const getMemberClassSchedulesController = async (req, res) => {
    try {

        const memberId = req.user.id;

        const classes = await getMemberClassSchedules(memberId);

        res.status(200).json({
            count: classes.length,
            classes
        });

    } catch (error) {

        console.error(
            'Get member class schedules error:',
            error
        );

        res.status(500).json({
            message: 'Server error'
        });
    }
};


// ==========================================
// GET ONE MEMBER CLASS SCHEDULE
// ==========================================
const getMemberClassScheduleByIdController = async (req, res) => {
    try {

        const memberId = req.user.id;
        const classId = req.params.id;

        const classSchedule =
            await getMemberClassScheduleById(
                classId,
                memberId
            );


        if (!classSchedule) {
            return res.status(404).json({
                message: 'Class schedule not found or not available to you'
            });
        }


        res.status(200).json({
            class: classSchedule
        });

    } catch (error) {

        console.error(
            'Get member class schedule error:',
            error
        );

        res.status(500).json({
            message: 'Server error'
        });
    }
};


module.exports = {
    getMemberClassSchedulesController,
    getMemberClassScheduleByIdController
};