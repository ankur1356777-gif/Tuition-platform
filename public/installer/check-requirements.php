<?php
header('Content-Type: application/json');

$requirements = [
    [
        'name' => 'PHP Version >= 8.2',
        'passed' => version_compare(PHP_VERSION, '8.2.0', '>='),
        'message' => 'Current: PHP ' . PHP_VERSION
    ],
    [
        'name' => 'PDO Extension',
        'passed' => extension_loaded('pdo'),
        'message' => extension_loaded('pdo') ? 'Installed' : 'Not installed'
    ],
    [
        'name' => 'PDO MySQL Extension',
        'passed' => extension_loaded('pdo_mysql'),
        'message' => extension_loaded('pdo_mysql') ? 'Installed' : 'Not installed'
    ],
    [
        'name' => 'OpenSSL Extension',
        'passed' => extension_loaded('openssl'),
        'message' => extension_loaded('openssl') ? 'Installed' : 'Not installed'
    ],
    [
        'name' => 'Mbstring Extension',
        'passed' => extension_loaded('mbstring'),
        'message' => extension_loaded('mbstring') ? 'Installed' : 'Not installed'
    ],
    [
        'name' => 'JSON Extension',
        'passed' => extension_loaded('json'),
        'message' => extension_loaded('json') ? 'Installed' : 'Not installed'
    ],
    [
        'name' => 'Writable Storage Directory',
        'passed' => is_writable(__DIR__ . '/../../storage'),
        'message' => is_writable(__DIR__ . '/../../storage') ? 'Writable' : 'Not writable - chmod 755 required'
    ],
    [
        'name' => 'Writable Bootstrap/Cache Directory',
        'passed' => is_writable(__DIR__ . '/../../bootstrap/cache'),
        'message' => is_writable(__DIR__ . '/../../bootstrap/cache') ? 'Writable' : 'Not writable - chmod 755 required'
    ]
];

echo json_encode(['requirements' => $requirements]);
