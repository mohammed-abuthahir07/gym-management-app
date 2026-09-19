const pool = require('./db');

const INDEXES = [
    { table: 'users', name: 'idx_users_role_status', columns: 'role, status' },
    { table: 'users', name: 'idx_users_trainer_id', columns: 'trainer_id' },
    { table: 'users', name: 'idx_users_created_at', columns: 'created_at' },
    { table: 'fees', name: 'idx_fees_member_id', columns: 'member_id' },
    { table: 'fees', name: 'idx_fees_paid_period', columns: 'payment_status, fee_year, fee_month' },
    { table: 'workout_completions', name: 'idx_wc_member_date', columns: 'member_id, completed_date' },
    { table: 'notifications', name: 'idx_notif_recipient_read', columns: 'recipient_id, recipient_role, is_read' },
    { table: 'notifications', name: 'idx_notif_created_at', columns: 'created_at' },
    { table: 'diet_plans', name: 'idx_diet_member_day', columns: 'member_id, diet_day' },
    { table: 'diet_plans', name: 'idx_diet_trainer_id', columns: 'trainer_id' },
    { table: 'workout_plans', name: 'idx_wp_member_id', columns: 'member_id' },
    { table: 'workout_plans', name: 'idx_wp_trainer_id', columns: 'trainer_id' },
    { table: 'workout_plan_exercises', name: 'idx_wpe_plan_id', columns: 'workout_plan_id' },
    { table: 'workout_plan_exercises', name: 'idx_wpe_exercise_id', columns: 'exercise_id' },
    { table: 'progress', name: 'idx_progress_member_date', columns: 'member_id, progress_date' },
    { table: 'cheat_days', name: 'idx_cheat_member_date', columns: 'member_id, cheat_date' },
    { table: 'messages', name: 'idx_messages_sender_receiver', columns: 'sender_id, receiver_id' },
    { table: 'messages', name: 'idx_messages_receiver_read', columns: 'receiver_id, is_read' },
    { table: 'plans', name: 'idx_plans_status_created', columns: 'status, created_at' },
    { table: 'promotions', name: 'idx_promos_status_created', columns: 'status, created_at' },
    { table: 'challenges', name: 'idx_challenges_status_created', columns: 'status, created_at' },
    { table: 'exercises', name: 'idx_exercises_status', columns: 'status' },
    { table: 'content', name: 'idx_content_created_at', columns: 'created_at' },
    { table: 'contacts', name: 'idx_contacts_created_at', columns: 'created_at' },
    { table: 'class_schedules', name: 'idx_classes_trainer_date', columns: 'trainer_id, class_date' },
    { table: 'member_profiles', name: 'idx_member_profiles_member_id', columns: 'member_id' },
];

const tableExists = async (table) => {
    const [rows] = await pool.query(
        `SELECT 1
         FROM information_schema.tables
         WHERE table_schema = DATABASE()
           AND table_name = ?
         LIMIT 1`,
        [table]
    );
    return rows.length > 0;
};

const indexExists = async (table, name) => {
    const [rows] = await pool.query(
        `SELECT 1
         FROM information_schema.statistics
         WHERE table_schema = DATABASE()
           AND table_name = ?
           AND index_name = ?
         LIMIT 1`,
        [table, name]
    );
    return rows.length > 0;
};

const ensureIndexes = async () => {
    for (const index of INDEXES) {
        try {
            if (!(await tableExists(index.table))) continue;
            if (await indexExists(index.table, index.name)) continue;
            await pool.query(
                `CREATE INDEX \`${index.name}\` ON \`${index.table}\` (${index.columns})`
            );
            console.log(`Added index ${index.name} on ${index.table}(${index.columns})`);
        } catch (error) {
            console.error(`Skipped index ${index.name}:`, error.message);
        }
    }
};

module.exports = ensureIndexes;
