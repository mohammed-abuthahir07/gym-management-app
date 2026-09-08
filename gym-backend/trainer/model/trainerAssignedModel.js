const db = require('../../config/db');


// ==========================================
// GET MEMBERS ASSIGNED TO LOGGED-IN TRAINER
// ==========================================

const getAssignedMembers = async (trainerId) => {

    const [rows] = await db.query(
        `SELECT
            u.id,
            u.name,
            u.email,
            u.phone,
            mp.fitness_goal,
            u.status,
            u.created_at
         FROM users u
         LEFT JOIN member_profiles mp
            ON mp.member_id = u.id
         WHERE u.role = 'MEMBER'
         AND u.trainer_id = ?
         ORDER BY u.name ASC`,
        [trainerId]
    );

    return rows;
};


// ==========================================
// GET ONE ASSIGNED MEMBER PROFILE
// ==========================================

const getAssignedMemberProfile = async (
    memberId,
    trainerId
) => {

    const [rows] = await db.query(
        `SELECT
            u.id,
            u.name,
            u.email,
            u.phone,
            u.status,

            mp.age,
            mp.height,
            mp.weight,
            mp.fitness_goal,
            mp.medical_notes,

            mp.created_at AS profile_created_at,
            mp.updated_at AS profile_updated_at

         FROM users u

         LEFT JOIN member_profiles mp
            ON mp.member_id = u.id

         WHERE u.id = ?
         AND u.trainer_id = ?
         AND u.role = 'MEMBER'`,
        [
            memberId,
            trainerId
        ]
    );

    return rows[0];
};


module.exports = {
    getAssignedMembers,
    getAssignedMemberProfile
};