<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Area;

$localities = [
    'Gomti Nagar', 'Hazratganj', 'Aliganj', 'Indira Nagar', 'Aminabad', 
    'Mahanagar', 'Rajajipuram', 'Alambagh', 'Chowk', 'Nishatganj', 
    'Jankipuram', 'Vikas Nagar', 'Charbagh', 'Chinhat', 'Telibagh', 
    'Daliganj', 'Hussainganj', 'Kaiserbagh', 'Lucknow Cantonment', 'Nirala Nagar', 
    'Sarojini Nagar', 'Scheme Road', 'Sitapur Road', 'Faizabad Road', 'Hardoi Road', 
    'Kanpur Road', 'Raebareli Road', 'Sultanpur Road', 'Behta Saboli', 'Gomti Nagar Extension', 
    'Vrindavan Yojna', 'Sushant Golf City', 'Eldeco', 'Aashiana', 'Omaxe City', 
    'Shaheed Path', 'Amar Shaheed Path', 'Kursi Road', 'Rae Bareli Road', 'IIM Road', 
    'Engineering College Road', 'Munshi Pulia', 'Lekhraj Metro', 'Bhootnath', 'Lalbagh', 
    'Naka Hindola', 'Thakurganj', 'Yahiyaganj', 'Wazirganj', 'Nakkhas'
];

foreach ($localities as $name) {
    Area::updateOrCreate(
        ['name' => $name],
        ['city' => 'Lucknow', 'state' => 'Uttar Pradesh', 'is_active' => true]
    );
}

echo "SUCCESS: " . Area::count() . " areas populated.";
