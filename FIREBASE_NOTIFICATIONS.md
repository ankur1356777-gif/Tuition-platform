# Firebase Notification System - Setup Guide

Complete guide for implementing Firebase Cloud Messaging in the Home Tuition Platform.

## Overview

The notification system provides:
- 📱 Push notifications to mobile apps (Android/iOS)
- 🔔 In-app notification center
- 📊 Notification history and tracking
- 🎯 Role-based notifications
- 📢 Broadcast messaging
- 🔄 Real-time delivery

---

## Backend Setup (Laravel)

### 1. Install Firebase PHP SDK

Already installed via Composer:
```bash
composer require kreait/firebase-php
```

### 2. Configure Firebase

**File**: `config/firebase.php`

```php
return [
    'credentials' => env('FIREBASE_CREDENTIALS', storage_path('app/firebase-credentials.json')),
    'database_url' => env('FIREBASE_DATABASE_URL', ''),
    'storage_bucket' => env('FIREBASE_STORAGE_BUCKET', ''),
];
```

### 3. Add to `.env`

```env
FIREBASE_CREDENTIALS=/path/to/firebase-credentials.json
FIREBASE_DATABASE_URL=https://your-project.firebaseio.com
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
```

### 4. Upload Firebase Credentials

**For Local Development:**
1. Download `firebase-credentials.json` from Firebase Console
2. Place in `storage/app/firebase-credentials.json`
3. Add to `.gitignore`:
   ```
   storage/app/firebase-credentials.json
   ```

**For Production (Hostinger):**
1. Upload via FTP to `/home/username/storage/firebase-credentials.json`
2. Update `.env` with correct path
3. Set permissions: `chmod 600 firebase-credentials.json`

### 5. Run Migration

```bash
php artisan migrate
```

This creates the `device_tokens` table.

### 6. Add API Routes

**File**: `routes/api.php`

```php
use App\Http\Controllers\Api\NotificationController;

Route::middleware('auth:sanctum')->group(function () {
    // Device token management
    Route::post('notifications/register-token', [NotificationController::class, 'registerToken']);
    Route::post('notifications/unregister-token', [NotificationController::class, 'unregisterToken']);
    
    // Notifications
    Route::get('notifications', [NotificationController::class, 'index']);
    Route::get('notifications/unread-count', [NotificationController::class, 'unreadCount']);
    Route::post('notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::post('notifications/read-all', [NotificationController::class, 'markAllAsRead']);
    Route::delete('notifications/{id}', [NotificationController::class, 'destroy']);
    
    // Admin only
    Route::post('notifications/test', [NotificationController::class, 'sendTest']);
    Route::post('notifications/broadcast', [NotificationController::class, 'broadcast']);
});
```

---

## Flutter Setup

### 1. Add Dependencies

**File**: `packages/common/pubspec.yaml`

Already added:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0
```

### 2. Install Dependencies

```bash
cd packages/common
flutter pub get
```

### 3. Android Configuration

**File**: `android/app/build.gradle`

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Required for FCM
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

**File**: `android/build.gradle`

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**File**: `android/app/build.gradle` (bottom)

```gradle
apply plugin: 'com.google.gms.google-services'
```

**File**: `android/app/google-services.json`

Download from Firebase Console and place here.

**File**: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest>
    <application>
        <!-- Firebase Messaging -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="default_channel" />
        
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@mipmap/ic_launcher" />
        
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_color"
            android:resource="@color/colorPrimary" />
    </application>
</manifest>
```

### 4. iOS Configuration

**File**: `ios/Runner/GoogleService-Info.plist`

Download from Firebase Console and add to Xcode project.

**File**: `ios/Runner/Info.plist`

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

**Enable Push Notifications in Xcode:**
1. Open `ios/Runner.xcworkspace`
2. Select Runner target
3. Go to **Signing & Capabilities**
4. Click **+ Capability**
5. Add **Push Notifications**
6. Add **Background Modes** (check Remote notifications)

### 5. Initialize in Flutter App

**File**: `lib/main.dart`

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:common/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );
  
  runApp(MyApp());
}
```

---

## Usage Examples

### Backend (Laravel)

#### Send Notification to Single User

```php
use App\Services\NotificationService;

$notificationService = new NotificationService();

$result = $notificationService->sendToUser(
    userId: 123,
    title: 'New Lead Received',
    body: 'You have a new tuition request for Class 10 Math',
    type: 'lead_received',
    data: [
        'lead_id' => 456,
        'class' => '10',
        'subject' => 'Math',
    ]
);
```

#### Send to Multiple Users

```php
$userIds = [123, 456, 789];

$results = $notificationService->sendToMultipleUsers(
    userIds: $userIds,
    title: 'System Maintenance',
    body: 'Platform will be under maintenance tonight',
    type: 'system_announcement'
);
```

#### Send to All Teachers

```php
$results = $notificationService->sendToRole(
    role: 'teacher',
    title: 'New Feature Available',
    body: 'Check out the new test creation feature',
    type: 'system_announcement'
);
```

#### Broadcast to Everyone

```php
$results = $notificationService->broadcast(
    title: 'Happy New Year!',
    body: 'Wishing you all a prosperous new year',
    type: 'system_announcement'
);
```

#### Event-Specific Notifications

```php
// Lead received
$notificationService->sendLeadReceivedNotification(
    teacherId: 123,
    leadData: [
        'lead_id' => 456,
        'class' => '10',
        'subject' => 'Math',
        'student_name' => 'John Doe',
    ]
);

// Demo scheduled
$notificationService->sendDemoScheduledNotification(
    userId: 123,
    demoData: [
        'demo_id' => 789,
        'scheduled_at' => '2026-01-20 10:00:00',
        'teacher_name' => 'Jane Smith',
    ]
);

// Payment received
$notificationService->sendPaymentReceivedNotification(
    userId: 123,
    paymentData: [
        'amount' => 3000,
        'payment_id' => 'PAY123',
    ]
);
```

### Frontend (Flutter)

#### Initialize Notification Service

```dart
import 'package:common/services/notification_service.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    
    // Handle notification tap
    _notificationService.onNotificationTap = (data) {
      print('Notification tapped: $data');
      _handleNotificationNavigation(data);
    };
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'];
    
    switch (type) {
      case 'lead_received':
        // Navigate to leads screen
        Navigator.pushNamed(context, '/leads');
        break;
      case 'demo_scheduled':
        // Navigate to demo classes
        Navigator.pushNamed(context, '/demo-classes');
        break;
      case 'payment_received':
        // Navigate to wallet
        Navigator.pushNamed(context, '/wallet');
        break;
      // Add more cases
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ...
    );
  }
}
```

#### Fetch Notifications

```dart
import 'package:common/services/api_service.dart';
import 'package:common/models/notification.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ApiService _api = ApiService();
  List<NotificationModel> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final response = await _api.get('notifications');
      setState(() {
        notifications = (response['data']['data'] as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading notifications: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await _api.post('notifications/$id/read', {});
      _loadNotifications(); // Refresh
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: notification.color,
            child: Icon(notification.icon, color: Colors.white),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead 
                  ? FontWeight.normal 
                  : FontWeight.bold,
            ),
          ),
          subtitle: Text(notification.body),
          trailing: Text(
            _formatTime(notification.createdAt),
            style: TextStyle(fontSize: 12),
          ),
          onTap: () => _markAsRead(notification.id),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
```

#### Unread Count Badge

```dart
class NotificationBadge extends StatefulWidget {
  @override
  _NotificationBadgeState createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  final ApiService _api = ApiService();
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    
    // Refresh every minute
    Timer.periodic(Duration(minutes: 1), (_) => _loadUnreadCount());
  }

  Future<void> _loadUnreadCount() async {
    try {
      final response = await _api.get('notifications/unread-count');
      setState(() {
        unreadCount = response['count'];
      });
    } catch (e) {
      print('Error loading unread count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
```

---

## Testing

### 1. Test Backend Notification

```bash
# Via Artisan Tinker
php artisan tinker

$service = new App\Services\NotificationService();
$service->sendToUser(1, 'Test', 'This is a test notification', 'system_announcement');
```

### 2. Test via API

```bash
# Register device token
curl -X POST https://yourdomain.com/api/notifications/register-token \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "device_token": "YOUR_FCM_TOKEN",
    "platform": "android"
  }'

# Send test notification (admin only)
curl -X POST https://yourdomain.com/api/notifications/test \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "title": "Test Notification",
    "body": "This is a test"
  }'
```

### 3. Test Flutter App

```dart
// In your app
final notificationService = NotificationService();
print('FCM Token: ${notificationService.fcmToken}');

// Copy this token and use it in backend testing
```

---

## Troubleshooting

### Issue: Notifications not received

**Check:**
1. FCM token registered in backend
2. Firebase credentials correct
3. Device has internet connection
4. App has notification permission
5. Check Firebase Console → Cloud Messaging logs

### Issue: iOS notifications not working

**Solutions:**
1. Enable Push Notifications capability in Xcode
2. Upload APNs certificate to Firebase
3. Test on physical device (not simulator)
4. Check iOS notification permissions

### Issue: Background notifications not working

**Android:**
- Ensure `FirebaseMessaging.onBackgroundMessage` is set
- Check battery optimization settings

**iOS:**
- Enable Background Modes in Xcode
- Check Background App Refresh in iOS settings

---

## Best Practices

1. **Token Management**
   - Refresh tokens on app launch
   - Remove tokens on logout
   - Handle token refresh events

2. **Notification Content**
   - Keep titles under 65 characters
   - Keep body under 240 characters
   - Include relevant data payload

3. **User Experience**
   - Allow users to customize notification preferences
   - Provide in-app notification center
   - Don't spam users with too many notifications

4. **Performance**
   - Batch notifications when possible
   - Use topics for group messaging
   - Clean up old notifications

---

## Production Checklist

- [ ] Firebase project created
- [ ] Service account key uploaded to server
- [ ] `google-services.json` added to Android app
- [ ] `GoogleService-Info.plist` added to iOS app
- [ ] Push notification capability enabled (iOS)
- [ ] APNs certificate uploaded to Firebase
- [ ] Device token registration tested
- [ ] Notification sending tested
- [ ] Background notifications tested
- [ ] Notification tap handling tested
- [ ] Error logging configured

---

**Last Updated**: January 16, 2026
