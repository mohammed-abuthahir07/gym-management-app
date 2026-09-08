const pool = require('../../config/db');

// ==========================================
// GET CLASS SCHEDULES FOR ASSIGNED TRAINER
// ==========================================
const getMemberClassSchedules = async (memberId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            cs.id,
            cs.trainer_id,
            cs.title,
            cs.class_date,
            cs.start_time,
            cs.end_time,
            cs.capacity,
            cs.created_at,
            cs.updated_at,
            trainer.name AS trainer_name,
            trainer.email AS trainer_email
        FROM class_schedules cs

        INNER JOIN users member
            ON member.trainer_id = cs.trainer_id

        INNER JOIN users trainer
            ON trainer.id = cs.trainer_id
            AND trainer.role = 'TRAINER'

        WHERE member.id = ?
        AND member.role = 'MEMBER'
        AND member.status = 'ACTIVE'

        ORDER BY cs.class_date ASC, cs.start_time ASC
        `,
        [memberId]
    );

    return rows;
};


// ==========================================
// GET ONE CLASS FOR ASSIGNED TRAINER
// ==========================================
const getMemberClassScheduleById = async (
    classId,
    memberId
) => {
    const [rows] = await pool.execute(
        `
        SELECT
            cs.id,
            cs.trainer_id,
            cs.title,
            cs.class_date,
            cs.start_time,
            cs.end_time,
            cs.capacity,
            cs.created_at,
            cs.updated_at,
            trainer.name AS trainer_name,
            trainer.email AS trainer_email
        FROM class_schedules cs

        INNER JOIN users member
            ON member.trainer_id = cs.trainer_id

        INNER JOIN users trainer
            ON trainer.id = cs.trainer_id
            AND trainer.role = 'TRAINER'

        WHERE cs.id = ?
        AND member.id = ?
        AND member.role = 'MEMBER'
        AND member.status = 'ACTIVE'
        `,
        [classId, memberId]
    );

    return rows[0];
};


module.exports = {
    getMemberClassSchedules,
    getMemberClassScheduleById
};