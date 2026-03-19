<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Teacher;
use App\Models\Student;
use App\Models\Agent;
use App\Models\Wallet;
use App\Services\OTPService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    protected $otpService;
    protected $notificationService;

    public function __construct(OTPService $otpService, \App\Services\NotificationService $notificationService)
    {
        $this->otpService = $otpService;
        $this->notificationService = $notificationService;
    }

    /**
     * Verify Firebase ID Token and login/register
     */
    public function verifyFirebase(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id_token' => 'required|string',
            'phone' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        try {
            $firebase = app('firebase.auth');
            $verifiedIdToken = $firebase->verifyIdToken($request->id_token);
            $firebaseUid = $verifiedIdToken->claims()->get('sub');
            $firebaseUser = $firebase->getUser($firebaseUid);
            $phone = $firebaseUser->phoneNumber;

            if (!$phone) {
                return response()->json(['message' => 'Phone number not found in Firebase token'], 400);
            }

            // Clean phone number (remove +91 or +)
            $cleanPhone = preg_replace('/^\+91|^\+/', '', $phone);

            $user = User::where('phone', $cleanPhone)->first();

            if (!$user) {
                return response()->json([
                    'message' => 'Phone verified via Firebase',
                    'is_new_user' => true,
                    'phone' => $cleanPhone
                ]);
            }

            if ($user->status !== 'approved' && $user->role !== 'admin') {
                return response()->json([
                    'message' => "Your account status is currently {$user->status}. Please contact admin.",
                    'status' => $user->status
                ], 403);
            }

            // Mark phone as verified
            $user->update(['phone_verified_at' => now()]);

            // Revoke current tokens and create new one
            $user->tokens()->delete();
            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'message' => 'Login successful via Firebase',
                'is_new_user' => false,
                'token' => $token,
                'user' => $user
            ]);

        }
        catch (\Exception $e) {
            \Log::error('Firebase verification failed: ' . $e->getMessage());
            return response()->json(['message' => 'Invalid Firebase token: ' . $e->getMessage()], 401);
        }
    }

    /**
     * Send OTP to phone number
     */
    public function sendOTP(Request $request)
    {
        $validator = Validator::make($request->all(), [
            "phone" => "required|string|min:10|max:15",
        ]);

        if ($validator->fails()) {
            return response()->json(["errors" => $validator->errors()], 422);
        }

        $result = $this->otpService->sendOTP($request->phone);

        return response()->json([
            "message" => $result['message'],
            "phone" => $request->phone,
            "success" => $result['success'],
        ]);
    }

    /**
     * Verify OTP and login
     */
    public function verifyOTP(Request $request)
    {
        $validator = Validator::make($request->all(), [
            "phone" => "required|string",
            "otp" => "required|string|size:6",
        ]);

        if ($validator->fails()) {
            return response()->json(["errors" => $validator->errors()], 422);
        }

        $verification = $this->otpService->verifyOTP($request->phone, $request->otp);

        if ($verification['success']) {
            $user = User::where("phone", $request->phone)->first();

            if (!$user) {
                return response()->json([
                    "message" => "Phone verified",
                    "is_new_user" => true,
                    "phone" => $request->phone
                ]);
            }

            if ($user->status !== 'approved' && $user->role !== 'admin') {
                return response()->json([
                    "message" => "Your account status is currently " . $user->status . ". Please contact admin.",
                    "status" => $user->status
                ], 403);
            }

            // Mark phone as verified
            $user->update(['phone_verified_at' => now()]);

            // Revoke current tokens and create new one
            $user->tokens()->delete();
            $token = $user->createToken("auth_token")->plainTextToken;

            return response()->json([
                "message" => "Login successful",
                "is_new_user" => false,
                "token" => $token,
                "user" => $user
            ]);
        }

        return response()->json(["message" => $verification['message'] ?? "Invalid or expired OTP"], 401);
    }

    /**
     * Login with email/phone + password
     */
    public function loginWithPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'login' => 'required|string', // Can be email or phone
            'password' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $login = $request->login;

        // Determine if login is email or phone
        $user = filter_var($login, FILTER_VALIDATE_EMAIL)
            ?User::where('email', $login)->first()
            : User::where('phone', $login)->first();

        if (!$user) {
            return response()->json([
                'message' => 'No account found with this email/phone number.'
            ], 404);
        }

        // Check if user has a password set
        if (!$user->password) {
            return response()->json([
                'message' => 'No password set for this account. Please login with OTP or set a password.',
                'has_password' => false,
            ], 400);
        }

        // Verify password
        if (!Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Invalid password.'
            ], 401);
        }

        // Check account status
        if ($user->status !== 'approved' && $user->role !== 'admin') {
            return response()->json([
                'message' => "Your account status is currently {$user->status}. Please contact admin.",
                'status' => $user->status
            ], 403);
        }

        // Revoke current tokens and create new one
        $user->tokens()->delete();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login successful',
            'token' => $token,
            'user' => $user,
        ]);
    }

    /**
     * Set or update password (for authenticated users)
     */
    public function setPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'password' => 'required|string|min:6|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = $request->user();
        $user->update([
            'password' => Hash::make($request->password),
        ]);

        return response()->json(['message' => 'Password set successfully']);
    }

    /**
     * Register a new user
     */
    public function register(Request $request)
    {
        try {
            \Log::info('Registration attempt', ['phone' => $request->phone, 'role' => $request->role]);

            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255',
                'phone' => 'required|string|unique:users,phone',
                'role' => 'required|in:teacher,student,parent,agent',
                'email' => 'nullable|email|unique:users,email',
                'password' => 'nullable|string|min:6',
                'referred_by' => 'nullable|string',
                'area_id' => 'nullable|exists:areas,id',
                'custom_area' => 'nullable|string|max:255',
                // Detailed teacher fields
                'whatsapp_number' => 'required_if:role,teacher|nullable|string',
                'bio' => 'nullable|string',
                'subjects' => 'nullable|array',
                'classes' => 'nullable|array',
                'qualifications' => 'nullable|array',
                'experience_years' => 'nullable|numeric',
            ]);

            if ($validator->fails()) {
                \Log::error('Registration validation failed', ['errors' => $validator->errors()->toArray()]);
                return response()->json(['errors' => $validator->errors()], 422);
            }

            $referralId = null;
            if ($request->referred_by) {
                $referrer = Agent::where('referral_code', $request->referred_by)->first();
                $referralId = $referrer ? $referrer->user_id : null;
            }

            // Create user with optional password
            // Students and parents are auto-approved; teachers and agents need admin approval
            $status = in_array($request->role, ['student', 'parent']) ? 'approved' : 'pending';
            $userData = [
                'name' => $request->name,
                'phone' => $request->phone,
                'role' => $request->role,
                'email' => $request->email,
                'status' => $status,
                'referred_by' => $referralId,
            ];

            if ($request->password) {
                $userData['password'] = Hash::make($request->password);
            }

            $user = User::create($userData);

            \Log::info('User created', ['user_id' => $user->id]);

            // Create role-specific profile
            if ($request->role === 'teacher') {
                $areaId = $request->area_id == '-1' ? null : $request->area_id;
                $customArea = $request->area_id == '-1' ? $request->custom_area : null;

                Teacher::create([
                    'user_id' => $user->id,
                    'whatsapp_number' => $request->whatsapp_number,
                    'area_id' => $areaId,
                    'custom_area' => $customArea,
                    'bio' => $request->bio,
                    'subjects' => $request->subjects ?? [],
                    'classes' => $request->classes ?? [],
                    'qualifications' => $request->qualifications ?? [],
                    'experience_years' => $request->experience_years ?? 0,
                    'city' => 'Lucknow',
                    'state' => 'Uttar Pradesh',
                ]);

                \Log::info('Teacher profile created', ['user_id' => $user->id]);

                // Create wallet
                Wallet::create(['user_id' => $user->id]);

                // Send notifications (non-blocking)
                try {
                    $notificationService = new \App\Services\NotificationService();
                    $notificationService->sendNewTeacherNotification($user);

                    if ($user->email) {
                        $notificationService->sendEmail(
                            $user->email,
                            'Registration Received - Under Review',
                            'emails.teacher_registration',
                        ['name' => $user->name]
                        );
                    }
                }
                catch (\Exception $e) {
                    \Log::warning('Notification failed but registration succeeded', ['error' => $e->getMessage()]);
                }
            }
            elseif ($request->role === 'student') {
                $student = Student::create([
                    'user_id' => $user->id,
                    'class' => 'N/A',
                    'address' => 'N/A',
                    'latitude' => 0,
                    'longitude' => 0,
                    'city' => 'N/A',
                    'state' => 'N/A',
                    'pincode' => 'N/A',
                    'subjects_needed' => json_encode([]),
                    'parent_phone' => $request->parent_phone,
                ]);

                \Log::info('Student profile created', ['user_id' => $user->id]);

                // Auto-link: Check if a parent with this phone already exists
                if ($request->parent_phone) {
                    $parentUser = User::where('phone', $request->parent_phone)
                        ->where('role', 'parent')
                        ->first();

                    if ($parentUser) {
                        \App\Models\ParentChild::firstOrCreate([
                            'parent_id' => $parentUser->id,
                            'student_id' => $student->id,
                        ], [
                            'relationship' => 'parent',
                            'is_primary' => true,
                        ]);
                        \Log::info('Auto-linked student to existing parent', [
                            'student_id' => $student->id,
                            'parent_id' => $parentUser->id,
                        ]);
                    }
                }
            }
            elseif ($request->role === 'parent') {
                // Auto-link: Find any students who listed this parent's phone
                $studentsWithThisParent = Student::where('parent_phone', $request->phone)->get();

                foreach ($studentsWithThisParent as $student) {
                    \App\Models\ParentChild::firstOrCreate([
                        'parent_id' => $user->id,
                        'student_id' => $student->id,
                    ], [
                        'relationship' => 'parent',
                        'is_primary' => true,
                    ]);
                    \Log::info('Auto-linked parent to student', [
                        'parent_id' => $user->id,
                        'student_id' => $student->id,
                    ]);
                }
            }
            elseif ($request->role === 'agent') {
                Agent::create([
                    'user_id' => $user->id,
                    'referral_code' => 'AGT' . strtoupper(substr(uniqid(), -6))
                ]);

                \Log::info('Agent profile created', ['user_id' => $user->id]);
            }

            $token = $user->createToken('auth_token')->plainTextToken;

            \Log::info('Registration successful', ['user_id' => $user->id]);

            $message = in_array($request->role, ['student', 'parent'])
                ? 'Registration successful. You can now login.'
                : 'Registration successful. Your account is awaiting admin approval.';

            return response()->json([
                'message' => $message,
                'token' => $token,
                'user' => $user
            ], 201);

        }
        catch (\Exception $e) {
            \Log::error('Registration failed with exception', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'request_data' => $request->except(['password'])
            ]);

            return response()->json([
                'message' => 'Registration failed. Please try again.',
                'error' => config('app.debug') ? $e->getMessage() : 'An error occurred'
            ], 500);
        }
    }

    /**
     * Logout
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logged out successfully']);
    }
}
