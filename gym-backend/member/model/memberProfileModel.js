const db = require('../../config/db');


// =====================================================
// CREATE MEMBER PROFILE
// =====================================================

const createProfile = async (
    memberId,
    name,
    phone,
    age,
    height,
    weight,
    fitnessGoal,
    medicalNotes
) => {

    const [result] = await db.execute(
        `INSERT INTO member_profiles
        (
            member_id,
            name,
            phone,
            age,
            height,
            weight,
            fitness_goal,
            medical_notes
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
            memberId,
            name,
            phone,
            age,
            height,
            weight,
            fitnessGoal,
            medicalNotes
        ]
    );

    return result.insertId;
};


// =====================================================
// GET OWN PROFILE
// =====================================================

const getProfile = async (memberId) => {

    const [rows] = await db.execute(
        `SELECT
            id,
            member_id,
            name,
            phone,
            age,
            height,
            weight,
            fitness_goal,
            medical_notes,
            created_at,
            updated_at
         FROM member_profiles
         WHERE member_id = ?`,
        [memberId]
    );

    return rows[0];
};


// =====================================================
// UPDATE OWN PROFILE
// =====================================================

const updateProfile = async (
    memberId,
    name,
    phone,
    age,
    height,
    weight,
    fitnessGoal,
    medicalNotes
) => {

    const [result] = await db.execute(
        `UPDATE member_profiles
         SET
            name = ?,
            phone = ?,
            age = ?,
            height = ?,
            weight = ?,
            fitness_goal = ?,
            medical_notes = ?
         WHERE member_id = ?`,
        [
            name,
            phone,
            age,
            height,
            weight,
            fitnessGoal,
            medicalNotes,
            memberId
        ]
    );

    return result;
};


module.exports = {
    createProfile,
    getProfile,
    updateProfile
};