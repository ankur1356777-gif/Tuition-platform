<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Area;

class LucknowAreasSeeder extends Seeder
{
    public function run(): void
    {
        $areas = [
            'Gomti Nagar',
            'Hazratganj',
            'Aliganj',
            'Indira Nagar',
            'Alambagh',
            'Mahanagar',
            'Rajajipuram',
            'Aminabad',
            'Chowk',
            'Nishatganj',
            'Jankipuram',
            'Vikas Nagar',
            'Ashiyana',
            'Chinhat',
            'Telibagh',
            'Daliganj',
            'Hussainganj',
            'Kaiserbagh',
            'Lucknow Cantonment',
            'Nirala Nagar',
            'Sarojini Nagar',
            'Scheme Road',
            'Sitapur Road',
            'Faizabad Road',
            'Hardoi Road',
            'Kanpur Road',
            'Raebareli Road',
            'Sultanpur Road',
            'Barabanki Road',
            'Gomti Nagar Extension',
            'Vrindavan Yojna',
            'Sushant Golf City',
            'Eldeco',
            'Ansal API',
            'Omaxe City',
            'Shaheed Path',
            'Amar Shaheed Path',
            'Kursi Road',
            'Rae Bareli Road',
            'IIM Road',
            'Engineering College Road',
            'Munshi Pulia',
            'Lekhraj Metro',
            'Bhootnath',
            'Lalbagh',
            'Naka Hindola',
            'Thakurganj',
            'Yahiyaganj',
            'Wazirganj',
            'Nakkhas',
        ];

        foreach ($areas as $area) {
            Area::create([
                'name' => $area,
                'city' => 'Lucknow',
                'state' => 'Uttar Pradesh',
                'is_active' => true,
            ]);
        }
    }
}
