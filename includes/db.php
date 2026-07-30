<?php
// ============================================================
// ThriftBid - Database Connection (PDO singleton)
// ============================================================
require_once __DIR__ . '/config.php';

class DB {
    private static ?PDO $instance = null;

    public static function get(): PDO {
        if (self::$instance === null) {
            $dsn = 'mysql:host=' . DB_HOST . ';port=' . DB_PORT . ';dbname=' . DB_NAME . ';charset=utf8mb4';
            self::$instance = new PDO($dsn, DB_USER, DB_PASSWORD, [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
            ]);
        }
        return self::$instance;
    }

    // query helpers
    public static function query(string $sql, array $params = []): \PDOStatement {
        $stmt = self::get()->prepare($sql);
        $stmt->execute($params);
        return $stmt;
    }

    public static function fetch(string $sql, array $params = []): array|false {
        return self::query($sql, $params)->fetch();
    }

    public static function fetchAll(string $sql, array $params = []): array {
        return self::query($sql, $params)->fetchAll();
    }

    public static function insert(string $sql, array $params = []): int {
        self::query($sql, $params);
        return (int) self::get()->lastInsertId();
    }

  
    // Stored procedure helpers.



    // For procedures that return exactly one row (like a stats summary).
    public static function callOne(string $proc, array $params = []): array|false {
        $placeholders = implode(',', array_fill(0, count($params), '?'));
        $stmt = self::query("CALL $proc($placeholders)", $params);
        $row = $stmt->fetch();
        $stmt->closeCursor();
        return $row;
    }

    // For procedures that return multiple rows (like  a top 10 list).
    public static function callAll(string $proc, array $params = []): array {
        $placeholders = implode(',', array_fill(0, count($params), '?'));
        $stmt = self::query("CALL $proc($placeholders)", $params);
        $rows = $stmt->fetchAll();
        $stmt->closeCursor();
        return $rows;
    }

    // For procedures that don't return a result set at all (they just
    // INSERT/UPDATE). Still calls closeCursor() to be safe.
    public static function callProc(string $proc, array $params = []): void {
        $placeholders = implode(',', array_fill(0, count($params), '?'));
        self::query("CALL $proc($placeholders)", $params)->closeCursor();
    }

   // For procedures that just insert a row and return the new ID.
    public static function callProcGetLastId(string $proc, array $params = []): int {
        $placeholders = implode(',', array_fill(0, count($params), '?'));
        self::query("CALL $proc($placeholders)", $params)->closeCursor();
        return (int) self::get()->lastInsertId();
    }
}

/*
// ============================================================
//  STEP 3: PASTE THE DIAGNOSTIC BLOCK HERE (AT THE BOTTOM)
// ============================================================
try {
    $result = DB::fetch("SELECT DATABASE() as active_db, NOW() as db_time");
    echo "<h2>✅ Connected Successfully!</h2>";
    echo "Connected Database: <strong>" . $result['active_db'] . "</strong><br>";
    echo "Cloud Server Time: <strong>" . $result['db_time'] . "</strong>";
} catch (Exception $e) {
    echo "<h2>❌ Connection Failed</h2>";
    echo "Error Details: " . $e->getMessage();
}

*/
?>