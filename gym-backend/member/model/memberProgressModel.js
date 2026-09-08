const db = require('../../config/db');

// =====================================================
// CREATE PROGRESS
// =====================================================

const createProgress = async (
    memberId,
    progressDate,
    weight,
    bodyFat,
    waistCm,
    armsCm,
    notes
) => {
    const [result] = await db.execute(
        `INSERT INTO progress
        (
            member_id,
            progress_date,
            weight,
            body_fat,
            waist_cm,
            arms_cm,
            notes
        )
        VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
            memberId,
            progressDate,
            weight,
            bodyFat,
            waistCm,
            armsCm,
            notes
        ]
    );

    return result.insertId;
};


// =====================================================
// GET ALL PROGRESS FOR ONE MEMBER
// =====================================================

const getAllProgress = async (memberId) => {
    const [rows] = await db.execute(
        `SELECT
            id,
            progress_date,
            weight,
            body_fat,
            waist_cm,
            arms_cm,
            notes,
            created_at,
            updated_at
         FROM progress
         WHERE member_id = ?
         ORDER BY progress_date DESC`,
        [memberId]
    );

    return rows;
};


// =====================================================
// GET SINGLE PROGRESS
// =====================================================

const getProgressById = async (progressId, memberId) => {
    const [rows] = await db.execute(
        `SELECT
            id,
            progress_date,
            weight,
            body_fat,
            waist_cm,
            arms_cm,
            notes,
            created_at,
            updated_at
         FROM progress
         WHERE id = ?
         AND member_id = ?`,
        [progressId, memberId]
    );

    return rows[0];
};


// =====================================================
// UPDATE PROGRESS
// =====================================================

const updateProgress = async (
    progressId,
    memberId,
    progressDate,
    weight,
    bodyFat,
    waistCm,
    armsCm,
    notes
) => {
    const [result] = await db.execute(
        `UPDATE progress
         SET
            progress_date = ?,
            weight = ?,
            body_fat = ?,
            waist_cm = ?,
            arms_cm = ?,
            notes = ?
         WHERE id = ?
         AND member_id = ?`,
        [
            progressDate,
            weight,
            bodyFat,
            waistCm,
            armsCm,
            notes,
            progressId,
            memberId
        ]
    );

    return result;
};


// =====================================================
// DELETE PROGRESS
// =====================================================

const deleteProgress = async (progressId, memberId) => {
    const [result] = await db.execute(
        `DELETE FROM progress
         WHERE id = ?
         AND member_id = ?`,
        [progressId, memberId]
    );

    return result;
};


module.exports = {
    createProgress,
    getAllProgress,
    getProgressById,
    updateProgress,
    deleteProgress
};