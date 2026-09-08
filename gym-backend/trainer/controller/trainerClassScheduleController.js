const {
    createClassSchedule,
    getTrainerClassSchedules,
    getTrainerClassScheduleById,
    updateClassSchedule,
    deleteClassSchedule
} = require('../model/trainerClassScheduleModel');


// ==========================================
// CREATE CLASS SCHEDULE
// ==========================================
const createClassScheduleController = async (req, res) => {
    try {
        const trainerId = req.user.id;

        const {
            title,
            class_date,
            start_time,
            end_time,
            capacity
        } = req.body;


        // ==========================================
        // VALIDATION
        // ==========================================

        if (
            !title ||
            !class_date ||
            !start_time ||
            !end_time ||
            capacity === undefined
        ) {
            return res.status(400).json({
                message: 'Title, date, start time, end time and capacity are required'
            });
        }


        if (Number(capacity) <= 0) {
            return res.status(400).json({
                message: 'Capacity must be greater than 0'
            });
        }


        if (start_time >= end_time) {
            return res.status(400).json({
                message: 'End time must be after start time'
            });
        }


        // ==========================================
        // CREATE
        // ==========================================

        const classId = await createClassSchedule(
            trainerId,
            title,
            class_date,
            start_time,
            end_time,
            capacity
        );


        // ==========================================
        // RESPONSE
        // ==========================================

        res.status(201).json({
            message: 'Class schedule created successfully',
            class_id: classId
        });

    } catch (error) {

        console.error('Create class schedule error:', error);

        res.status(500).json({
            message: 'Server error'
        });
    }
};


// ==========================================
// GET ALL TRAINER CLASSES
// ==========================================
const getTrainerClassSchedulesController = async (req, res) => {
    try {

        const trainerId = req.user.id;

        const classes = await getTrainerClassSchedules(trainerId);

        res.status(200).json({
            count: classes.length,
            classes
        });

    } catch (error) {

        console.error('Get trainer class schedules error:', error);

        res.status(500).json({
            message: 'Server error'
        });
    }
};


// ==========================================
// GET ONE TRAINER CLASS
// ==========================================
const getTrainerClassScheduleByIdController = async (req, res) => {
    try {

        const trainerId = req.user.id;
        const classId = req.params.id;

        const classSchedule =
            await getTrainerClassScheduleById(
                classId,
                trainerId
            );


        if (!classSchedule) {
            return res.status(404).json({
                message: 'Class schedule not found'
            });
        }


        res.status(200).json({
            class: classSchedule
        });

    } catch (error) {

        console.error(
            'Get trainer class schedule error:',
            error
        );

        res.status(500).json({
            message: 'Server error'
        });
    }
};


// ==========================================
// UPDATE CLASS SCHEDULE
// ==========================================
const updateClassScheduleController = async (req, res) => {
    try {

        const trainerId = req.user.id;
        const classId = req.params.id;

        const {
            title,
            class_date,
            start_time,
            end_time,
            capacity
        } = req.body;


        // ==========================================
        // CHECK EXISTING CLASS
        // ==========================================

        const existingClass =
            await getTrainerClassScheduleById(
                classId,
                trainerId
            );


        if (!existingClass) {
            return res.status(404).json({
                message: 'Class schedule not found'
            });
        }


        // ==========================================
        // VALIDATION
        // ==========================================

        if (
            !title ||
            !class_date ||
            !start_time ||
            !end_time ||
            capacity === undefined
        ) {
            return res.status(400).json({
                message: 'Title, date, start time, end time and capacity are required'
            });
        }


        if (Number(capacity) <= 0) {
            return res.status(400).json({
                message: 'Capacity must be greater than 0'
            });
        }


        if (start_time >= end_time) {
            return res.status(400).json({
                message: 'End time must be after start time'
            });
        }


        // ==========================================
        // UPDATE
        // ==========================================

        await updateClassSchedule(
            classId,
            trainerId,
            title,
            class_date,
            start_time,
            end_time,
            capacity
        );


        // ==========================================
        // GET UPDATED CLASS
        // ==========================================

        const updatedClass =
            await getTrainerClassScheduleById(
                classId,
                trainerId
            );


        res.status(200).json({
            message: 'Class schedule updated successfully',
            class: updatedClass
        });

    } catch (error) {

        console.error(
            'Update class schedule error:',
            error
        );

        res.status(500).json({
            message: 'Server error'
        });
    }
};


// ==========================================
// DELETE CLASS SCHEDULE
// ==========================================
const deleteClassScheduleController = async (req, res) => {
    try {

        const trainerId = req.user.id;
        const classId = req.params.id;


        // ==========================================
        // CHECK EXISTING CLASS
        // ==========================================

        const existingClass =
            await getTrainerClassScheduleById(
                classId,
                trainerId
            );


        if (!existingClass) {
            return res.status(404).json({
                message: 'Class schedule not found'
            });
        }


        // ==========================================
        // DELETE
        // ==========================================

        await deleteClassSchedule(
            classId,
            trainerId
        );


        res.status(200).json({
            message: 'Class schedule deleted successfully'
        });

    } catch (error) {

        console.error(
            'Delete class schedule error:',
            error
        );

        res.status(500).json({
            message: 'Server error'
        });
    }
};


module.exports = {
    createClassScheduleController,
    getTrainerClassSchedulesController,
    getTrainerClassScheduleByIdController,
    updateClassScheduleController,
    deleteClassScheduleController
};