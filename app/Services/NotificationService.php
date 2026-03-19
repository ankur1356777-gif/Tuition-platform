<?php

namespace App\Services;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification as FirebaseNotification;
use Kreait\Firebase\Messaging\AndroidConfig;
use Kreait\Firebase\Messaging\ApnsConfig;
use App\Models\DeviceToken;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Support\Facades\Log;

class NotificationService
{
    protected $messaging;

    public function __construct()
    {
        // Firebase is optional - only initialize if credentials exist
        $credentialsPath = config('firebase.credentials');
        
        if ($credentialsPath && file_exists($credentialsPath) && filesize($credentialsPath) > 10) {
            try {
                $factory = (new Factory)->withServiceAccount($credentialsPath);
                $this->messaging = $factory->createMessaging();
            } catch (\Exception $e) {
                Log::warning('Firebase initialization failed (optional): ' . $e->getMessage());
                $this->messaging = null;
            }
        } else {
            Log::info('Firebase credentials not configured - push notifications disabled');
            $this->messaging = null;
        }
    }

    /**
     * Send notification to a single user
     *
     * @param int $userId
     * @param string $title
     * @param string $body
     * @param string $type
     * @param array $data
     * @return array
     */
    public function sendToUser(
        int $userId,
        string $title,
        string $body,
        string $type = 'system_announcement',
        array $data = []
    ) {
        // Save notification to database
        $notification = Notification::create([
            'user_id' => $userId,
            'title' => $title,
            'body' => $body,
            'type' => $type,
            'data' => $data,
        ]);

        // Get user's active device tokens
        $deviceTokens = DeviceToken::forUser($userId)
            ->active()
            ->pluck('device_token')
            ->toArray();

        if (empty($deviceTokens)) {
            return [
                'success' => false,
                'message' => 'No active device tokens found',
                'notification_id' => $notification->id,
            ];
        }

        // Send push notification
        $result = $this->sendPushNotification(
            $deviceTokens,
            $title,
            $body,
            array_merge($data, [
                'notification_id' => $notification->id,
                'type' => $type,
            ])
        );

        return [
            'success' => true,
            'notification_id' => $notification->id,
            'sent_to' => count($deviceTokens),
            'result' => $result,
        ];
    }

    /**
     * Send notification to multiple users
     *
     * @param array $userIds
     * @param string $title
     * @param string $body
     * @param string $type
     * @param array $data
     * @return array
     */
    public function sendToMultipleUsers(
        array $userIds,
        string $title,
        string $body,
        string $type = 'system_announcement',
        array $data = []
    ) {
        $results = [];

        foreach ($userIds as $userId) {
            $results[$userId] = $this->sendToUser($userId, $title, $body, $type, $data);
        }

        return $results;
    }

    /**
     * Send notification to all users with a specific role
     *
     * @param string $role
     * @param string $title
     * @param string $body
     * @param string $type
     * @param array $data
     * @return array
     */
    public function sendToRole(
        string $role,
        string $title,
        string $body,
        string $type = 'system_announcement',
        array $data = []
    ) {
        $userIds = User::where('role', $role)
            ->where('status', 'approved')
            ->pluck('id')
            ->toArray();

        return $this->sendToMultipleUsers($userIds, $title, $body, $type, $data);
    }

    /**
     * Broadcast notification to all users
     *
     * @param string $title
     * @param string $body
     * @param string $type
     * @param array $data
     * @return array
     */
    public function broadcast(
        string $title,
        string $body,
        string $type = 'system_announcement',
        array $data = []
    ) {
        $userIds = User::where('status', 'approved')
            ->pluck('id')
            ->toArray();

        return $this->sendToMultipleUsers($userIds, $title, $body, $type, $data);
    }

    /**
     * Send push notification via Firebase
     *
     * @param array $tokens
     * @param string $title
     * @param string $body
     * @param array $data
     * @return array
     */
    private function sendPushNotification(
        array $tokens,
        string $title,
        string $body,
        array $data = []
    ) {
        if (!$this->messaging) {
            return ['error' => 'Firebase messaging not initialized'];
        }

        try {
            $notification = FirebaseNotification::create($title, $body);

            $androidConfig = AndroidConfig::fromArray([
                'priority' => 'high',
                'notification' => [
                    'sound' => 'default',
                    'color' => '#4CAF50',
                ],
            ]);

            $apnsConfig = ApnsConfig::fromArray([
                'headers' => [
                    'apns-priority' => '10',
                ],
                'payload' => [
                    'aps' => [
                        'sound' => 'default',
                        'badge' => 1,
                    ],
                ],
            ]);

            $message = CloudMessage::new()
                ->withNotification($notification)
                ->withData($data)
                ->withAndroidConfig($androidConfig)
                ->withApnsConfig($apnsConfig);

            // Send to multiple devices
            $report = $this->messaging->sendMulticast($message, $tokens);

            // Handle invalid tokens
            if ($report->hasFailures()) {
                foreach ($report->failures()->getItems() as $failure) {
                    $failedToken = $failure->target()->value();
                    
                    // Deactivate invalid tokens
                    DeviceToken::where('device_token', $failedToken)
                        ->update(['is_active' => false]);
                    
                    Log::warning('Failed to send to token: ' . $failedToken);
                }
            }

            return [
                'success' => $report->successes()->count(),
                'failures' => $report->failures()->count(),
            ];
        } catch (\Exception $e) {
            Log::error('Firebase push notification failed: ' . $e->getMessage());
            return ['error' => $e->getMessage()];
        }
    }

    /**
     * Register device token
     *
     * @param int $userId
     * @param string $token
     * @param string $platform
     * @param array $deviceInfo
     * @return DeviceToken
     */
    public function registerDeviceToken(
        int $userId,
        string $token,
        string $platform = 'android',
        array $deviceInfo = []
    ) {
        return DeviceToken::updateOrCreate(
            [
                'user_id' => $userId,
                'device_token' => $token,
            ],
            [
                'platform' => $platform,
                'device_id' => $deviceInfo['device_id'] ?? null,
                'device_name' => $deviceInfo['device_name'] ?? null,
                'is_active' => true,
                'last_used_at' => now(),
            ]
        );
    }

    /**
     * Unregister device token
     *
     * @param int $userId
     * @param string $token
     * @return bool
     */
    public function unregisterDeviceToken(int $userId, string $token)
    {
        return DeviceToken::where('user_id', $userId)
            ->where('device_token', $token)
            ->delete();
    }

    /**
     * Send notification for specific events
     */

    public function sendLeadReceivedNotification(int $teacherId, array $leadData)
    {
        return $this->sendToUser(
            $teacherId,
            'New Lead Received!',
            "You have a new tuition request for {$leadData['class']} - {$leadData['subject']}",
            'lead_received',
            $leadData
        );
    }

    public function sendDemoScheduledNotification(int $userId, array $demoData)
    {
        return $this->sendToUser(
            $userId,
            'Demo Class Scheduled',
            "Your demo class is scheduled for {$demoData['scheduled_at']}",
            'demo_scheduled',
            $demoData
        );
    }

    public function sendAttendanceMarkedNotification(int $studentId, array $attendanceData)
    {
        return $this->sendToUser(
            $studentId,
            'Attendance Marked',
            "Your attendance has been marked as {$attendanceData['status']}",
            'attendance_marked',
            $attendanceData
        );
    }

    public function sendTestAssignedNotification(int $studentId, array $testData)
    {
        return $this->sendToUser(
            $studentId,
            'New Test Assigned',
            "You have a new test: {$testData['title']} on {$testData['scheduled_date']}",
            'test_assigned',
            $testData
        );
    }

    public function sendPaymentReceivedNotification(int $userId, array $paymentData)
    {
        return $this->sendToUser(
            $userId,
            'Payment Received',
            "Payment of ₹{$paymentData['amount']} has been received",
            'payment_received',
            $paymentData
        );
    }

    public function sendCommissionCreditedNotification(int $userId, array $commissionData)
    {
        return $this->sendToUser(
            $userId,
            'Commission Credited',
            "₹{$commissionData['amount']} has been credited to your wallet",
            'commission_credited',
            $commissionData
        );
    }

    public function sendPayoutApprovedNotification(int $userId, array $payoutData)
    {
        return $this->sendToUser(
            $userId,
            'Payout Approved',
            "Your payout request of ₹{$payoutData['amount']} has been approved",
            'payout_approved',
            $payoutData
        );
    }

    /**
     * Send WhatsApp Message
     *
     * @param string $phone
     * @param string $message
     * @return bool
     */
    public function sendWhatsAppMessage(string $whatsappNumber, string $message)
    {
        Log::info("WhatsApp Message to {$whatsappNumber}: {$message}");
        
        // Get settings from database
        $enabled = \App\Models\SystemSetting::where('key', 'whatsapp_enabled')->value('value');
        
        if ($enabled != '1') {
            Log::info('WhatsApp is disabled in settings');
            return true; // Return true to not break the flow
        }
        
        $apiUrl = \App\Models\SystemSetting::where('key', 'whatsapp_api_url')->value('value');
        $apiKey = \App\Models\SystemSetting::where('key', 'whatsapp_api_key')->value('value');
        
        if (!$apiUrl || !$apiKey) {
            Log::warning('WhatsApp API URL or Key not configured');
            return true;
        }
        
        try {
            \Illuminate\Support\Facades\Http::post($apiUrl, [
                'phone' => $whatsappNumber,
                'message' => $message,
                'key' => $apiKey
            ]);
            Log::info("WhatsApp sent successfully to {$whatsappNumber}");
            return true;
        } catch (\Exception $e) {
            Log::error('WhatsApp API failed: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Send Email Notification
     *
     * @param string $email
     * @param string $subject
     * @param string $view
     * @param array $data
     * @return bool
     */
    public function sendEmail(string $email, string $subject, string $view, array $data = [])
    {
        try {
            \Mail::send($view, $data, function ($message) use ($email, $subject) {
                $message->to($email)->subject($subject);
            });
            return true;
        } catch (\Exception $e) {
            Log::error('Email sending failed: ' . $e->getMessage());
            return false;
        }
    }
}
