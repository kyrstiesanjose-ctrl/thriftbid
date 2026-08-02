<?php
require_once __DIR__ . '/db.php';

/**
 * Shared admin audit-logging helper. Every admin action that changes
 * state should call this instead of hand-writing the AUDIT_LOGS INSERT
 * directly. Having one call site means there's only one place to get
 * the columns right, instead of copy-pasting the same INSERT across
 * every admin page - which is exactly how actions like `unverify` or
 * `force_close` previously ended up silently missing a log entry.
 */
function logAdminAction(int $adminId, string $action, string $table, int $recordId, $oldValue = null, $newValue = null): void {
    DB::query(
        'INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value) VALUES (?,?,?,?,?,?)',
        [$adminId, $action, $table, $recordId, $oldValue, $newValue]
    );
}