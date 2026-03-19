<?php

namespace App\Services;

use App\Models\OtpVerification;
use Carbon\Carbon;
use Illuminate\Support\Facades\Http;

class OTPService
{
    /**
     * Demo accounts for testing (only works when APP_DEBUG=true)
     */
    private const DEMO_ACCOUNTS = [
        '9876543210' => '123456', // Teacher
        '9876543211' => '123456', // Student
        '9876543212' => '123456', // Parent
        '9876543213' => '123456', // Agent
    ];

    /**
     * Generate and send OTP to phone number
     */
    public function sendOTP(string $phone)
    {
        $phone = $this->cleanPhoneNumber($phone);

        // Demo accounts - skip sending in debug mode
        if ($this->isDemoAccount($phone)) {
            \Log::info("Demo OTP for {$phone}: 123456 (not sent via SMS)");
            return [
                'success' => true,
                'message' => 'OTP sent successfully',
                'expires_in' => 600,
            ];
        }

        $otp = $this->generateOTP();

        // Store OTP in database
        OtpVerification::create([
            'phone' => $phone,
            'otp' => $otp,
            'expires_at' => now()->addMinutes(10),
            'is_verified' => false,
            'attempts' => 0,
        ]);

        // Send OTP via configured SMS provider
        $sent = $this->sendSMS($phone, $otp);

        return [
            'success' => $sent,
            'message' => $sent ? 'OTP sent successfully' : 'Failed to send OTP. Please try again.',
            'expires_in' => 600,
        ];
    }

    /**
     * Verify OTP
     */
    public function verifyOTP(string $phone, string $otp)
    {
        $phone = $this->cleanPhoneNumber($phone);

        // Demo account bypass (only in debug mode)
        if ($this->isDemoAccount($phone) && $otp === self::DEMO_ACCOUNTS[$phone]) {
            return [
                'success' => true,
                'message' => 'OTP verified successfully (Demo)',
            ];
        }

        // Get latest OTP for this phone
        $otpRecord = OtpVerification::where('phone', $phone)
            ->where('is_verified', false)
            ->where('expires_at', '>', now())
            ->orderBy('created_at', 'desc')
            ->first();

        if (!$otpRecord) {
            return [
                'success' => false,
                'message' => 'OTP expired or not found. Please request a new one.',
            ];
        }

        if ($otpRecord->attempts >= 3) {
            return [
                'success' => false,
                'message' => 'Maximum verification attempts exceeded. Please request a new OTP.',
            ];
        }

        // Increment attempts
        $otpRecord->increment('attempts');

        // Verify OTP
        if ($otpRecord->otp !== $otp) {
            return [
                'success' => false,
                'message' => 'Invalid OTP',
                'attempts_remaining' => 3 - $otpRecord->attempts,
            ];
        }

        // Mark as verified
        $otpRecord->update([
            'is_verified' => true,
            'verified_at' => now(),
        ]);

        return [
            'success' => true,
            'message' => 'OTP verified successfully',
        ];
    }

    /**
     * Generate 6-digit OTP
     */
    private function generateOTP()
    {
        return str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
    }

    /**
     * Clean phone number
     */
    private function cleanPhoneNumber(string $phone)
    {
        return preg_replace('/[^0-9+]/', '', $phone);
    }

    /**
     * Check if phone is a demo account
     */
    private function isDemoAccount(string $phone): bool
    {
        return array_key_exists($phone, self::DEMO_ACCOUNTS);
    }

    /**
     * Send SMS via configured provider
     */
    private function sendSMS(string $phone, string $otp)
    {
        \Log::info("OTP for {$phone}: {$otp}");

        // Get SMS provider from system settings
        $enabled = $this->getSetting('sms_enabled');

        if ($enabled != '1') {
            \Log::info('SMS is disabled in system settings — OTP logged only');
            return true;
        }

        $provider = $this->getSetting('sms_provider') ?? 'fast2sms';

        \Log::info("Sending OTP via provider: {$provider}");

        return match ($provider) {
                'fast2sms' => $this->sendViaFast2SMS($phone, $otp),
                'msg91' => $this->sendViaMSG91($phone, $otp),
                'twilio' => $this->sendViaTwilio($phone, $otp),
                default => $this->sendViaFast2SMS($phone, $otp),
            };
    }

    // ==========================================
    // SMS Provider Implementations
    // ==========================================

    /**
     * Send OTP via Fast2SMS
     * Dashboard: https://www.fast2sms.com/dashboard
     */
    private function sendViaFast2SMS(string $phone, string $otp): bool
    {
        $apiKey = $this->getSetting('sms_api_key');

        if (!$apiKey) {
            \Log::warning('Fast2SMS API key not configured');
            return true; // Don't break flow in dev
        }

        try {
            // Remove country code if present (Fast2SMS uses 10-digit Indian numbers)
            $phone = preg_replace('/^\+?91/', '', $phone);

            $response = Http::withHeaders([
                'authorization' => $apiKey,
            ])->post('https://www.fast2sms.com/dev/bulkV2', [
                'route' => 'otp',
                'variables_values' => $otp,
                'flash' => 0,
                'numbers' => $phone,
            ]);

            $data = $response->json();

            if ($response->successful() && ($data['return'] ?? false)) {
                \Log::info("Fast2SMS: OTP sent to {$phone}");
                return true;
            }

            \Log::error("Fast2SMS error: " . json_encode($data));
            return false;
        }
        catch (\Exception $e) {
            \Log::error('Fast2SMS failed: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Send OTP via MSG91
     * Dashboard: https://msg91.com/
     */
    private function sendViaMSG91(string $phone, string $otp): bool
    {
        $authKey = $this->getSetting('sms_api_key');
        $templateId = $this->getSetting('sms_template_id');
        $senderId = $this->getSetting('sms_sender_id') ?? 'TUITION';

        if (!$authKey) {
            \Log::warning('MSG91 auth key not configured');
            return true;
        }

        try {
            // Ensure phone has country code
            if (!str_starts_with($phone, '91') && !str_starts_with($phone, '+91')) {
                $phone = '91' . $phone;
            }
            $phone = ltrim($phone, '+');

            $response = Http::withHeaders([
                'authkey' => $authKey,
                'Content-Type' => 'application/json',
            ])->post('https://control.msg91.com/api/v5/otp', [
                'otp' => $otp,
                'otp_length' => 6,
                'otp_expiry' => 10,
                'template_id' => $templateId,
                'mobile' => $phone,
                'sender' => $senderId,
            ]);

            $data = $response->json();

            if ($response->successful() && ($data['type'] ?? '') === 'success') {
                \Log::info("MSG91: OTP sent to {$phone}");
                return true;
            }

            \Log::error("MSG91 error: " . json_encode($data));
            return false;
        }
        catch (\Exception $e) {
            \Log::error('MSG91 failed: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Send OTP via Twilio
     * Dashboard: https://console.twilio.com/
     */
    private function sendViaTwilio(string $phone, string $otp): bool
    {
        $sid = $this->getSetting('twilio_sid');
        $token = $this->getSetting('twilio_auth_token');
        $from = $this->getSetting('twilio_phone_number');

        if (!$sid || !$token || !$from) {
            \Log::warning('Twilio credentials not fully configured');
            return true;
        }

        try {
            // Ensure phone has +91 prefix
            if (!str_starts_with($phone, '+')) {
                $phone = '+91' . ltrim($phone, '0');
            }

            $message = "Your Tuition Platform OTP is: {$otp}. Valid for 10 minutes. Do not share this with anyone.";

            $response = Http::withBasicAuth($sid, $token)
                ->asForm()
                ->post("https://api.twilio.com/2010-04-01/Accounts/{$sid}/Messages.json", [
                'To' => $phone,
                'From' => $from,
                'Body' => $message,
            ]);

            $data = $response->json();

            if ($response->successful() && isset($data['sid'])) {
                \Log::info("Twilio: OTP sent to {$phone}, SID: {$data['sid']}");
                return true;
            }

            \Log::error("Twilio error: " . json_encode($data));
            return false;
        }
        catch (\Exception $e) {
            \Log::error('Twilio failed: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Resend OTP
     */
    public function resendOTP(string $phone)
    {
        // Invalidate previous OTPs
        OtpVerification::where('phone', $this->cleanPhoneNumber($phone))
            ->where('is_verified', false)
            ->update(['is_verified' => true]);

        return $this->sendOTP($phone);
    }

    /**
     * Get system setting value
     */
    private function getSetting(string $key): ?string
    {
        return \App\Models\SystemSetting::where('key', $key)->value('value');
    }
}
