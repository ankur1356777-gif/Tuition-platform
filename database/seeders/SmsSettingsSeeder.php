<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\SystemSetting;

class SmsSettingsSeeder extends Seeder
{
    public function run(): void
    {
        $settings = [
            // General SMS toggle
            ['key' => 'sms_enabled',       'value' => '0',         'description' => 'Enable/disable SMS sending (0=disabled, 1=enabled)'],
            ['key' => 'sms_provider',      'value' => 'fast2sms',  'description' => 'SMS provider: fast2sms, msg91, twilio'],
            
            // Fast2SMS settings
            ['key' => 'sms_api_key',       'value' => '',          'description' => 'Fast2SMS / MSG91 API key'],
            
            // MSG91 settings
            ['key' => 'sms_template_id',   'value' => '',          'description' => 'MSG91 template ID'],
            ['key' => 'sms_sender_id',     'value' => 'TUITION',   'description' => 'MSG91 sender ID (6 chars)'],
            
            // Twilio settings
            ['key' => 'twilio_sid',          'value' => '',         'description' => 'Twilio Account SID'],
            ['key' => 'twilio_auth_token',   'value' => '',         'description' => 'Twilio Auth Token'],
            ['key' => 'twilio_phone_number', 'value' => '',         'description' => 'Twilio phone number (with +country code)'],
        ];

        foreach ($settings as $setting) {
            SystemSetting::firstOrCreate(
                ['key' => $setting['key']],
                ['value' => $setting['value']]
            );
        }
    }
}
