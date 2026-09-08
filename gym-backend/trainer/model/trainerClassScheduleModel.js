const pool = require('../../config/db');

// ==========================================
// CREATE CLASS SCHEDULE
// ==========================================
const createClassSchedule = async (
    trainerId,
    title,
    classDate,
    startTime,
    endTime,
    capacity
) => {
    const [result] = await pool.execute(
        `
        INSERT INTO class_schedules
        (
            trainer_id,
            title,
            class_date,
            start_time,
            end_time,
            capacity
        )
        VALUES (?, ?, ?, ?, ?, ?)
        `,
        [
            trainerId,
            title,
            classDate,
            startTime,
            endTime,
            capacity
        ]
    );

    return result.insertId;
};


// ==========================================
// GET ALL CLASSES CREATED BY TRAINER
// ==========================================
const getTrainerClassSchedules = async (trainerId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            id,
            trainer_id,
            title,
            class_date,
            start_time,
            end_time,
            capacity,
            created_at,
            updated_at
        FROM class_schedules
        WHERE trainer_id = ?
        ORDER BY class_date ASC, start_time ASC
        `,
        [trainerId]
    );

    return rows;
};


// ==========================================
// GET ONE CLASS CREATED BY TRAINER
// ==========================================
const getTrainerClassScheduleById = async (classId, trainerId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            id,
            trainer_id,
            title,
            class_date,
            start_time,
            end_time,
            capacity,
            created_at,
            updated_at
        FROM class_schedules
        WHERE id = ?
        AND trainer_id = ?
        `,
        [classId, trainerId]
    );

    return rows[0];
};


// ==========================================
// UPDATE CLASS SCHEDULE
// ==========================================
const updateClassSchedule = async (
    classId,
    trainerId,
    title,
    classDate,
    startTime,
    endTime,
    capacity
) => {
    const [result] = await pool.execute(
        `
        UPDATE class_schedules
        SET
            title = ?,
            class_date = ?,
            start_time = ?,
            end_time = ?,
            capacity = ?
        WHERE id = ?
        AND trainer_id = ?
        `,
        [
            title,
            classDate,
            startTime,
            endTime,
            capacity,
            classId,
            trainerId
        ]
    );

    return result.affectedRows;
};


// ==========================================
// DELETE CLASS SCHEDULE
// ==========================================
const deleteClassSchedule = async (classId, trainerId) => {
    const [result] = await pool.execute(
        `
        DELETE FROM class_schedules
        WHERE id = ?
        AND trainer_id = ?
        `,
        [classId, trainerId]
    );

    return result.affectedRows;
};


module.exports = {
    createClassSchedule,
    getTrainerClassSchedules,
    getTrainerClassScheduleById,
    updateClassSchedule,
    deleteClassSchedule
};