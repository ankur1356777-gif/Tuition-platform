<?php
header('Content-Type: application/json');

$host = $_POST['db_host'] ?? '';
$name = $_POST['db_name'] ?? '';
$username = $_POST['db_username'] ?? '';
$password = $_POST['db_password'] ?? '';

try {
    $dsn = "mysql:host=$host;dbname=$name;charset=utf8mb4";
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
    
    // Test query
    $pdo->query('SELECT 1');
    
    echo json_encode([
        'success' => true,
        'message' => 'Database connection successful!'
    ]);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Connection failed: ' . $e->getMessage()
    ]);
}
