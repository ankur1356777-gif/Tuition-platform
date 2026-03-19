<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\SystemSetting;

class FirebaseSettingsSeeder extends Seeder
{
    public function run(): void
    {
        $settings = [
            [
                'key' => 'firebase_credentials',
                'value' => 'storage/app/firebase-credentials.json',
                'group' => 'firebase',
                'type' => 'text',
            ],
            [
                'key' => 'firebase_database_url',
                'value' => '',
                'group' => 'firebase',
                'type' => 'text',
            ],
            [
                'key' => 'firebase_storage_bucket',
                'value' => 'tuition-platform.appspot.com',
                'group' => 'firebase',
                'type' => 'text',
            ],
        ];

        foreach ($settings as $setting) {
            SystemSetting::updateOrCreate(
                ['key' => $setting['key']],
                $setting
            );
        }
    }
}
