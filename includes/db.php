<?php
// ============================================================
// ThriftBid - Database Connection (PDO singleton)
// ============================================================
require_once __DIR__ . '/config.php';

class DB {
    private static ?PDO $instance = null;

    public static function get(): PDO {
        if (self::$instance === null) {
            
            // ========================================================
            // DYNAMIC RBAC CREDENTIAL MAPPING 
            // ========================================================
            // Default to your master/default config credentials for guests, 
            // registration, and the login page (where no session role exists yet)
            $dbUser = DB_USER;
            $dbPass = DB_PASSWORD;

            if (isset($_SESSION['user_role'])) {
                $role = $_SESSION['user_role'];
                if ($role === 'admin') {
                    $dbUser = 'tb_admin';
                    $dbPass = 'AdminSecure2026!';
                } elseif ($role === 'seller') {
                    $dbUser = 'tb_seller';
                    $dbPass = 'SellerSecure2026!';
                } elseif ($role === 'buyer') {
                    $dbUser = 'tb_buyer';
                    $dbPass = 'BuyerSecure2026!';
                }
            }
            // ========================================================

            // Uses your config host/port/name, but swaps out the user/pass dynamically
            $dsn = 'mysql:host=' . DB_HOST . ';port=' . DB_PORT . ';dbname=' . DB_NAME . ';charset=utf8mb4';
            self::$instance = new PDO($dsn, $dbUser, $dbPass, [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
            ]);
            self::$instance->exec("SET time_zone = '+08:00'");

            /* Lazy auto-close: preserves your existing auction logic */
            $expired = self::$instance
                ->query("SELECT auction_id FROM AUCTIONS WHERE status='Active' AND end_time <= NOW()")
                ->fetchAll(PDO::FETCH_COLUMN);
            foreach ($expired as $auctionId) {
                $stmt = self::$instance->prepare('CALL sp_close_auction(?)');
                $stmt->execute([$auctionId]);
                $stmt->closeCursor();
            }
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
    public static function callOne(string $proc, array $params = []): array|false {
        $placeholders = implode(',', array_fill(0, count($params), '?'));
        $stmt = self::query("CALL $proc($placeholders)", $params);
        $row = $stmt->fetch();
        $stmt->closeCursor();
        return $row;
    }

    public static function callAll(string $proc, array $params = []): array {
        $placeholders = implode(',', array_fill(0, count($params), '?'));
        $stmt = self::query("CALL $proc($placeholders)", $params);
        $rows = $stmt->fetchAll();
        $stmt->closeCursor();
        return $rows;
    }

    public static function callProc(string $proc, array $params = []): void {
        $placeholders = implode(',', array_fill(0, count($params), '?'));
        self::query("CALL $proc($placeholders)", $params)->closeCursor();
    }

    public static function callProcGetLastId(string $proc, array $params = []): int {
        $placeholders = implode(',', array_fill(0, count($params), '?'));
        self::query("CALL $proc($placeholders)", $params)->closeCursor();
        return (int) self::get()->lastInsertId();
    }

    public static function transaction(callable $fn): mixed {
        $pdo = self::get();
        $pdo->beginTransaction();
        try {
            $result = $fn();
            $pdo->commit();
            return $result;
        } catch (\Throwable $e) {
            $pdo->rollBack();
            throw $e;
        }
    }
}
?>