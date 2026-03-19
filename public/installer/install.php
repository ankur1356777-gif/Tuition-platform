<?php
header('Content-Type: application/json');

try {
    // Get form data
    $dbHost = $_POST['db_host'] ?? '';
    $dbName = $_POST['db_name'] ?? '';
    $dbUsername = $_POST['db_username'] ?? '';
    $dbPassword = $_POST['db_password'] ?? '';
    $adminName = $_POST['admin_name'] ?? '';
    $adminPhone = $_POST['admin_phone'] ?? '';
    $adminEmail = $_POST['admin_email'] ?? '';
    
    // Step 1: Create .env file
    $envContent = "APP_NAME=\"Tuition Platform\"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://{$_SERVER['HTTP_HOST']}

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST={$dbHost}
DB_PORT=3306
DB_DATABASE={$dbName}
DB_USERNAME={$dbUsername}
DB_PASSWORD={$dbPassword}

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=database
SESSION_DRIVER=file
SESSION_LIFETIME=120
";
    
    file_put_contents(__DIR__ . '/../../.env', $envContent);
    
    // Step 2: Generate APP_KEY
    $appKey = 'base64:' . base64_encode(random_bytes(32));
    $envContent = str_replace('APP_KEY=', "APP_KEY={$appKey}", $envContent);
    file_put_contents(__DIR__ . '/../../.env', $envContent);
    
    // Step 3: Connect to database
    $dsn = "mysql:host=$dbHost;dbname=$dbName;charset=utf8mb4";
    $pdo = new PDO($dsn, $dbUsername, $dbPassword, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);
    
    // Step 4: Run migrations
    $migrationFiles = glob(__DIR__ . '/../../database/migrations/*.php');
    sort($migrationFiles);
    
    foreach ($migrationFiles as $file) {
        $sql = file_get_contents($file);
        // This is simplified - in production, use Laravel's migrator
        // For now, we'll create a basic structure
    }
    
    // Create essential tables manually
    $pdo->exec("CREATE TABLE IF NOT EXISTS users (
        id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        phone VARCHAR(15) UNIQUE NOT NULL,
        role ENUM('admin', 'teacher', 'student', 'parent', 'agent') NOT NULL,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255),
        profile_image VARCHAR(255),
        status ENUM('pending', 'approved', 'rejected', 'suspended') DEFAULT 'approved',
        phone_verified_at TIMESTAMP NULL,
        remember_token VARCHAR(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        deleted_at TIMESTAMP NULL,
        INDEX idx_role_status (role, status)
    )");
    
    $pdo->exec("CREATE TABLE IF NOT EXISTS wallets (
        id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        user_id BIGINT UNSIGNED UNIQUE NOT NULL,
        balance DECIMAL(12, 2) DEFAULT 0.00,
        total_earned DECIMAL(12, 2) DEFAULT 0.00,
        total_withdrawn DECIMAL(12, 2) DEFAULT 0.00,
        pending_amount DECIMAL(12, 2) DEFAULT 0.00,
        is_frozen BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )");
    
    // Step 5: Create admin user
    $stmt = $pdo->prepare("INSERT INTO users (phone, role, name, email, status, phone_verified_at) VALUES (?, 'admin', ?, ?, 'approved', NOW())");
    $stmt->execute([$adminPhone, $adminName, $adminEmail]);
    $adminId = $pdo->lastInsertId();
    
    // Create wallet for admin
    $stmt = $pdo->prepare("INSERT INTO wallets (user_id) VALUES (?)");
    $stmt->execute([$adminId]);
    
    // Step 6: Create installed flag
    file_put_contents(__DIR__ . '/../../storage/installed', date('Y-m-d H:i:s'));
    
    // Step 7: Clear cache
    $cacheDirs = [
        __DIR__ . '/../../storage/framework/cache/*',
        __DIR__ . '/../../storage/framework/views/*',
        __DIR__ . '/../../bootstrap/cache/*'
    ];
    
    foreach ($cacheDirs as $dir) {
        array_map('unlink', glob($dir));
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Installation completed successfully!'
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
