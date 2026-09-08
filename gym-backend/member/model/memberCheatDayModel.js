const pool = require('../../config/db');

// Create cheat day activity
const createCheatDay = async (
    memberId,
    cheatDate,
    foodName,
    quantity,
    calories,
    notes
) => {
    const [result] = await pool.execute(
        `
        INSERT INTO cheat_days
        (
            member_id,
            cheat_date,
            food_name,
            quantity,
            calories,
            notes
        )
        VALUES (?, ?, ?, ?, ?, ?)
        `,
        [
            memberId,
            cheatDate,
            foodName,
            quantity || null,
            calories || null,
            notes || null
        ]
    );

    return result.insertId;
};


// Get all cheat activities of a member
const getMemberCheatDays = async (memberId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            id,
            member_id,
            cheat_date,
            food_name,
            quantity,
            calories,
            notes,
            created_at,
            updated_at
        FROM cheat_days
        WHERE member_id = ?
        ORDER BY cheat_date DESC, id DESC
        `,
        [memberId]
    );

    return rows;
};


// Get one cheat activity of a member
const getMemberCheatDayById = async (cheatDayId, memberId) => {
    const [rows] = await pool.execute(
        `
        SELECT
            id,
            member_id,
            cheat_date,
            food_name,
            quantity,
            calories,
            notes,
            created_at,
            updated_at
        FROM cheat_days
        WHERE id = ?
          AND member_id = ?
        LIMIT 1
        `,
        [cheatDayId, memberId]
    );

    return rows.length > 0 ? rows[0] : null;
};


// Update member's own cheat activity
const updateCheatDay = async (
    cheatDayId,
    memberId,
    cheatDate,
    foodName,
    quantity,
    calories,
    notes
) => {
    const [result] = await pool.execute(
        `
        UPDATE cheat_days
        SET
            cheat_date = ?,
            food_name = ?,
            quantity = ?,
            calories = ?,
            notes = ?
        WHERE id = ?
          AND member_id = ?
        `,
        [
            cheatDate,
            foodName,
            quantity || null,
            calories || null,
            notes || null,
            cheatDayId,
            memberId
        ]
    );

    return result.affectedRows;
};


// Delete member's own cheat activity
const deleteCheatDay = async (cheatDayId, memberId) => {
    const [result] = await pool.execute(
        `
        DELETE FROM cheat_days
        WHERE id = ?
          AND member_id = ?
        `,
        [cheatDayId, memberId]
    );

    return result.affectedRows;
};


module.exports = {
    createCheatDay,
    getMemberCheatDays,
    getMemberCheatDayById,
    updateCheatDay,
    deleteCheatDay
};