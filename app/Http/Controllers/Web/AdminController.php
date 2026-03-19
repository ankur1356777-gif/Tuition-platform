<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Teacher;
use App\Models\User;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function index()
    {
        $stats = [
            'total_teachers' => User::role('teacher')->count(),
            'total_students' => User::role('student')->count(),
            'pending_approvals' => User::pending()->count(),
            'active_tuitions' => \App\Models\PaidTuition::where('status', 'active')->count(),
            'total_revenue' => \App\Models\Transaction::where('type', 'credit')->sum('amount'),
            'pending_payouts' => \App\Models\PayoutRequest::where('status', 'pending')->count(),
            'recent_leads' => \App\Models\Lead::with(['teacher', 'tuitionRequest.student'])->latest()->take(5)->get(),
        ];

        return view('admin.dashboard', compact('stats'));
    }

    public function teachers()
    {
        $teachers = User::role('teacher')->with('teacher')->latest()->paginate(10);
        return view('admin.teachers', compact('teachers'));
    }

    public function students()
    {
        $students = User::role('student')->with('student')->latest()->paginate(10);
        return view('admin.students', compact('students'));
    }

    public function leads()
    {
        $leads = \App\Models\Lead::with(['teacher', 'tuitionRequest.student'])->latest()->paginate(20);
        return view('admin.leads', compact('leads'));
    }

    public function payments()
    {
        $payouts = \App\Models\PayoutRequest::with('user')->latest()->paginate(15);
        return view('admin.payments', compact('payouts'));
    }

    public function updatePayoutStatus($id, Request $request)
    {
        $payout = \App\Models\PayoutRequest::findOrFail($id);
        $payout->update(['status' => $request->status]);

        // If paid, you might want to deduct from wallet here if not already done

        return back()->with('success', 'Payout status updated');
    }

    public function demoClasses()
    {
        $demoClasses = \App\Models\DemoClass::with(['lead.teacher.user', 'lead.tuitionRequest.student.user'])->latest()->paginate(15);
        return view('admin.demo_classes', compact('demoClasses'));
    }

    public function transactions()
    {
        $transactions = \App\Models\Transaction::with('user')->latest()->paginate(20);
        return view('admin.transactions', compact('transactions'));
    }

    public function settings()
    {
        $settings = \App\Models\CommissionSetting::all()->pluck('value', 'key');
        return view('admin.settings', compact('settings'));
    }

    public function updateSettings(Request $request)
    {
        foreach ($request->except('_token') as $key => $value) {
            \App\Models\CommissionSetting::updateOrCreate(
            ['key' => $key],
            ['value' => $value]
            );
        }
        return back()->with('success', 'Settings updated successfully');
    }

    public function agents()
    {
        $agents = User::where('role', 'agent')
            ->with('agent')
            ->latest()
            ->paginate(20);

        return view('admin.agents', compact('agents'));
    }

    public function verifyAgent($id, Request $request)
    {
        $user = User::findOrFail($id);
        $user->update(['status' => $request->status]);
        return back()->with('success', 'Agent status updated');
    }

    public function verifyTeacher($id, Request $request)
    {
        $user = User::findOrFail($id);
        $oldStatus = $user->status;
        $user->update(['status' => $request->status]);

        if ($oldStatus !== 'approved' && $request->status === 'approved') {
            // Generate Password
            $password = \Illuminate\Support\Str::random(8); // 8 character random password
            $user->password = \Illuminate\Support\Facades\Hash::make($password);
            $user->save();

            $notificationService = new \App\Services\NotificationService();

            // Send Email
            if ($user->email) {
                $notificationService->sendEmail(
                    $user->email,
                    'Account Approved - Login Credentials',
                    'emails.teacher_approved',
                [
                    'name' => $user->name,
                    'password' => $password,
                    'phone' => $user->phone
                ]
                );
            }

            // Send WhatsApp
            $teacher = $user->teacher;
            if ($teacher && $teacher->whatsapp_number) {
                $notificationService->sendWhatsAppMessage(
                    $teacher->whatsapp_number,
                    "Congratulations {$user->name}! Your teacher account has been approved. \n\nYou can now login to the app with your phone number and OTP.\n\nYour system generated password for web access is: {$password}\n\nHappy Teaching!"
                );
            }
        }

        return back()->with('success', 'Teacher status updated successfully');
    }

    public function createUser()
    {
        $areas = \App\Models\Area::where('is_active', 1)->where('city', 'Lucknow')->orderBy('name')->get();
        return view('admin.users.create', compact('areas'));
    }

    public function attendance()
    {
        $attendance = \App\Models\Attendance::with(['teacher.user', 'paidTuition.student.user'])->latest()->paginate(20);
        return view('admin.attendance', compact('attendance'));
    }

    public function notifications()
    {
        $notifications = \App\Models\Notification::with('user')->latest()->paginate(20);
        return view('admin.notifications', compact('notifications'));
    }

    public function sendNotification(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'body' => 'required|string',
            'role' => 'nullable|in:teacher,student,agent',
        ]);

        $notificationService = new \App\Services\NotificationService();

        if ($request->role) {
            $notificationService->sendToRole($request->role, $request->title, $request->body);
        }
        else {
            $notificationService->broadcast($request->title, $request->body);
        }

        return back()->with('success', 'Notification broadcasted successfully');
    }

    public function systemSettings()
    {
        $allSettings = \App\Models\SystemSetting::all();

        // Group settings by their group
        $settings = [];
        foreach ($allSettings as $setting) {
            $settings[$setting->group][$setting->key] = $setting->value;
        }

        return view('admin.system_settings', compact('settings'));
    }

    public function updateSystemSettings(Request $request)
    {
        $group = $request->input('group', 'general');

        foreach ($request->except('_token', 'group') as $key => $value) {
            \App\Models\SystemSetting::updateOrCreate(
            ['key' => $key],
            [
                'group' => $group,
                'value' => $value,
                'type' => is_bool($value) ? 'boolean' : 'text'
            ]
            );
        }

        // Update .env file for email settings
        if ($group === 'email') {
            $this->updateEnvFile([
                'MAIL_HOST' => $request->mail_host,
                'MAIL_PORT' => $request->mail_port,
                'MAIL_USERNAME' => $request->mail_username,
                'MAIL_PASSWORD' => $request->mail_password,
                'MAIL_ENCRYPTION' => $request->mail_encryption,
                'MAIL_FROM_ADDRESS' => $request->mail_from_address,
                'MAIL_FROM_NAME' => $request->mail_from_name,
            ]);
        }

        // Update .env file for firebase settings
        if ($group === 'firebase') {
            $this->updateEnvFile([
                'FIREBASE_CREDENTIALS' => $request->firebase_credentials,
                'FIREBASE_DATABASE_URL' => $request->firebase_database_url,
                'FIREBASE_STORAGE_BUCKET' => $request->firebase_storage_bucket,
            ]);
        }

        return back()->with('success', ucfirst($group) . ' settings updated successfully');
    }


    private function updateEnvFile($data)
    {
        $envFile = base_path('.env');
        $envContent = file_get_contents($envFile);

        foreach ($data as $key => $value) {
            if ($value === null)
                continue;

            $value = str_replace('"', '\"', $value);
            $pattern = "/^{$key}=.*/m";
            $replacement = "{$key}=\"{$value}\"";

            if (preg_match($pattern, $envContent)) {
                $envContent = preg_replace($pattern, $replacement, $envContent);
            }
            else {
                $envContent .= "\n{$replacement}";
            }
        }

        file_put_contents($envFile, $envContent);
    }

    public function testWhatsApp(Request $request)
    {
        $request->validate(['phone' => 'required|string']);

        $notificationService = new \App\Services\NotificationService();
        $result = $notificationService->sendWhatsAppMessage(
            $request->phone,
            "This is a test message from Tuition Platform. If you received this, your WhatsApp integration is working correctly!"
        );

        return back()->with('success', 'WhatsApp test message sent! Check the logs or your phone.');
    }

    public function testSMS(Request $request)
    {
        $request->validate(['phone' => 'required|string']);

        $otpService = new \App\Services\OTPService();
        $result = $otpService->sendOTP($request->phone);

        return back()->with('success', 'SMS test sent! Check your phone or logs.');
    }

    public function testEmail(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $notificationService = new \App\Services\NotificationService();
        $result = $notificationService->sendEmail(
            $request->email,
            'Test Email from Tuition Platform',
            'emails.test',
        ['message' => 'This is a test email. Your email configuration is working!']
        );

        return back()->with('success', 'Test email sent! Check your inbox.');
    }

    public function storeUser(Request $request)
    {
        $validationRules = [
            'name' => 'required|string|max:255',
            'phone' => 'required|string|unique:users,phone',
            'email' => 'nullable|email|unique:users,email',
            'role' => 'required|in:teacher,student,agent',
            'password' => 'required|string|min:6',
        ];

        if ($request->role == 'teacher') {
            $validationRules = array_merge($validationRules, [
                'whatsapp_number' => 'required|string',
                'area_id' => 'required_without:custom_area|nullable|exists:areas,id',
                'custom_area' => 'required_without:area_id|nullable|string|max:255',
                'bio' => 'nullable|string',
                'experience_years' => 'nullable|numeric',
            ]);
        }

        $request->validate($validationRules);

        $user = User::create([
            'name' => $request->name,
            'phone' => $request->phone,
            'email' => $request->email,
            'password' => \Hash::make($request->password),
            'role' => $request->role,
            'status' => 'approved',
        ]);

        if ($request->role == 'teacher') {
            $areaId = $request->area_id == '-1' ? null : $request->area_id;
            $customArea = $request->area_id == '-1' ? $request->custom_area : null;

            Teacher::create([
                'user_id' => $user->id,
                'whatsapp_number' => $request->whatsapp_number,
                'area_id' => $areaId,
                'custom_area' => $customArea,
                'bio' => $request->bio,
                'experience_years' => $request->experience_years ?? 0,
                'subjects' => $request->subjects ? explode(',', $request->subjects) : [],
                'classes' => $request->classes ? explode(',', $request->classes) : [],
                'qualifications' => $request->qualifications ? explode(',', $request->qualifications) : [],
                'city' => 'Lucknow',
                'state' => 'Uttar Pradesh',
                'is_verified' => true,
                'is_available' => true,
            ]);
            \App\Models\Wallet::create(['user_id' => $user->id]);
        }
        elseif ($request->role == 'student') {
            \App\Models\Student::create(['user_id' => $user->id, 'class' => 'N/A', 'address' => 'N/A', 'latitude' => 0, 'longitude' => 0, 'city' => 'N/A', 'state' => 'N/A', 'pincode' => 'N/A', 'subjects_needed' => json_encode([])]);
        }
        elseif ($request->role == 'agent') {
            \App\Models\Agent::create(['user_id' => $user->id, 'referral_code' => 'AGT' . strtoupper(substr(uniqid(), -6))]);
        }

        return redirect()->route('admin.' . $request->role . 's')->with('success', 'User created successfully');
    }
    public function teacherDetail($id)
    {
        $teacher = User::role('teacher')->with(['teacher', 'payoutRequests', 'transactions', 'wallet'])->findOrFail($id);
        // Auto-create teacher profile if missing
        if (!$teacher->teacher) {
            \App\Models\Teacher::create([
                'user_id' => $teacher->id,
                'subjects' => json_encode([]),
                'classes' => json_encode([]),
                'qualifications' => json_encode([]),
                'experience_years' => 0,
            ]);
            $teacher->load('teacher');
        }
        $teacherId = $teacher->teacher->id;
        $activeTuitions = \App\Models\PaidTuition::where('teacher_id', $teacherId)->with('student.user')->get();
        $attendance = \App\Models\Attendance::where('teacher_id', $teacherId)->with('paidTuition.student.user')->latest()->take(10)->get();

        return view('admin.users.teacher_detail', compact('teacher', 'activeTuitions', 'attendance'));
    }

    public function studentDetail($id)
    {
        $student = User::role('student')->with(['student', 'transactions'])->findOrFail($id);
        // Auto-create student profile if missing
        if (!$student->student) {
            \App\Models\Student::create([
                'user_id' => $student->id,
                'class' => 'N/A',
                'subjects_needed' => json_encode([]),
                'address' => 'N/A',
                'latitude' => 0,
                'longitude' => 0,
                'city' => 'N/A',
                'state' => 'N/A',
                'pincode' => 'N/A',
            ]);
            $student->load('student');
        }
        // Load tuition requests after student profile exists
        $student->load('tuitionRequests');
        $studentId = $student->student->id;
        $activeTuitions = \App\Models\PaidTuition::where('student_id', $studentId)->with('teacher.user')->get();
        $attendance = \App\Models\Attendance::whereHas('paidTuition', function ($q) use ($studentId) {
            $q->where('student_id', $studentId);
        })->with('teacher.user')->latest()->take(10)->get();

        return view('admin.users.student_detail', compact('student', 'activeTuitions', 'attendance'));
    }

    public function parentDetail($id)
    {
        $parent = User::role('parent')->findOrFail($id);
        $children = \App\Models\ParentChild::with(['student.user'])->where('parent_id', $parent->id)->get();

        return view('admin.users.parent_detail', compact('parent', 'children'));
    }

    public function toggleLeadContact($id)
    {
        $lead = \App\Models\Lead::findOrFail($id);
        $lead->is_contact_shared = !$lead->is_contact_shared;
        $lead->save();

        return back()->with('success', 'Contact sharing status updated');
    }

    public function convertLeadToTuition($id)
    {
        $lead = \App\Models\Lead::with('tuitionRequest')->findOrFail($id);

        // Create Paid Tuition
        $paidTuition = \App\Models\PaidTuition::create([
            'lead_id' => $lead->id,
            'teacher_id' => $lead->teacher_id,
            'student_id' => $lead->tuitionRequest->student_id,
            'monthly_fee' => $lead->tuitionRequest->budget ?? 0,
            'status' => 'active',
            'started_at' => now(),
        ]);

        // Update Lead and Request status
        $lead->status = 'converted';
        $lead->save();

        $lead->tuitionRequest->update(['status' => 'converted']);

        // Distribute Commissions
        app(\App\Services\CommissionService::class)->distributeTuitionCommission($paidTuition);

        return back()->with('success', 'Tuition started successfully and commission distributed.');
    }

    public function tests()
    {
        $tests = \App\Models\Test::with(['teacher.user', 'paidTuition.student.user'])->latest()->paginate(10);
        return view('admin.tests', compact('tests'));
    }

    // ==================== EDUCATION MANAGEMENT ====================

    public function homework(Request $request)
    {
        $query = \App\Models\Homework::with(['teacher.user', 'paidTuition.student.user', 'submissions'])
            ->latest();

        if ($request->has('status') && $request->status) {
            $query->where('status', $request->status);
        }

        $homework = $query->paginate(20);
        return view('admin.homework', compact('homework'));
    }

    public function teachingPlans(Request $request)
    {
        $query = \App\Models\TeachingPlan::with(['teacher.user', 'paidTuition.student.user'])
            ->orderBy('week_start', 'desc');

        if ($request->has('status') && $request->status) {
            $query->where('status', $request->status);
        }

        $plans = $query->paginate(20);
        return view('admin.teaching_plans', compact('plans'));
    }

    public function batches(Request $request)
    {
        $query = \App\Models\Student::with('user');

        if ($request->has('batch') && $request->batch) {
            $query->where('batch', $request->batch);
        }

        $students = $query->latest()->paginate(20);

        $stats = [
            'gold' => \App\Models\Student::where('batch', 'gold')->count(),
            'silver' => \App\Models\Student::where('batch', 'silver')->count(),
            'bronze' => \App\Models\Student::where('batch', 'bronze')->count(),
        ];

        return view('admin.batches', compact('students', 'stats'));
    }

    public function updateBatch(Request $request, $id)
    {
        $request->validate(['batch' => 'required|in:bronze,silver,gold']);

        $student = \App\Models\Student::findOrFail($id);
        $student->batch = $request->batch;
        $student->consecutive_high_scores = 0;
        $student->save();

        return back()->with('success', "Student batch updated to {$request->batch}");
    }

    public function rewards()
    {
        // Get pending rewards (tests with 80%+ that haven't been rewarded)
        $pendingRewards = \App\Models\TestResult::with(['student.user', 'test.teacher.user'])
            ->where('percentage', '>=', 80)
            ->whereHas('test', function ($q) {
            $q->where('is_weekly_test', true);
        })
            ->where(function ($q) {
            $q->whereNull('rewards')
                ->orWhere('rewards', 'NOT LIKE', '%"rewarded":true%');
        })
            ->latest()
            ->get();

        // Get recent reward transactions
        $recentRewards = \App\Models\Transaction::with('user')
            ->where('type', 'reward')
            ->latest()
            ->take(20)
            ->get();

        // Total rewarded this month
        $totalRewardedThisMonth = \App\Models\Transaction::where('type', 'reward')
            ->whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year)
            ->sum('amount');

        return view('admin.rewards', compact('pendingRewards', 'recentRewards', 'totalRewardedThisMonth'));
    }

    public function rewardTeacher(Request $request, $id)
    {
        $request->validate([
            'amount' => 'required|numeric|min:1',
            'reason' => 'required|string',
            'test_result_id' => 'nullable|exists:test_results,id',
        ]);

        $teacher = \App\Models\Teacher::findOrFail($id);
        $rewardService = app(\App\Services\RewardService::class);

        $testResult = $request->test_result_id
            ?\App\Models\TestResult::find($request->test_result_id)
            : null;

        $rewardService->rewardTeacher($teacher, $request->amount, $request->reason, $testResult);

        return back()->with('success', "Reward of ₹{$request->amount} sent to teacher successfully!");
    }

    public function teacherFeedback(Request $request)
    {
        $query = \App\Models\TeacherRating::with(['teacher.user', 'student.user'])
            ->whereNotNull('feedback')
            ->latest();

        if ($request->has('teacher_id') && $request->teacher_id) {
            $query->where('teacher_id', $request->teacher_id);
        }

        $feedback = $query->paginate(20);
        $teachers = \App\Models\Teacher::with('user')->get();

        return view('admin.teacher_feedback', compact('feedback', 'teachers'));
    }

    public function contactRequests()
    {
        // Pending contact requests
        $requests = \App\Models\Lead::with(['teacher.user', 'tuitionRequest.student.user', 'tuitionRequest.area'])
            ->where('contact_requested', true)
            ->where('is_contact_shared', false)
            ->orderBy('contact_requested_at', 'asc')
            ->get();

        // Recently approved
        $approvedRequests = \App\Models\Lead::with(['teacher.user', 'tuitionRequest.student.user'])
            ->where('is_contact_shared', true)
            ->whereNotNull('contact_shared_at')
            ->orderBy('contact_shared_at', 'desc')
            ->take(10)
            ->get();

        return view('admin.contact_requests', compact('requests', 'approvedRequests'));
    }

    public function approveLeadContact($id)
    {
        $lead = \App\Models\Lead::with('teacher.user')->findOrFail($id);
        $lead->is_contact_shared = true;
        $lead->contact_shared_at = now();
        $lead->status = 'active';
        $lead->save();

        // Notify teacher
        if ($lead->teacher && $lead->teacher->user) {
            $notificationService = new \App\Services\NotificationService();
            $notificationService->sendToUser(
                $lead->teacher->user->id,
                'Contact Details Shared',
                'Student contact details have been shared with you. Check your leads!',
                'contact_shared'
            );
        }

        return back()->with('success', 'Contact sharing approved successfully');
    }

    public function rejectLeadContact($id)
    {
        $lead = \App\Models\Lead::with('teacher.user')->findOrFail($id);
        $lead->contact_requested = false;
        $lead->save();

        // Notify teacher
        if ($lead->teacher && $lead->teacher->user) {
            $notificationService = new \App\Services\NotificationService();
            $notificationService->sendToUser(
                $lead->teacher->user->id,
                'Contact Request Rejected',
                'Your request for student contact details was not approved.',
                'contact_rejected'
            );
        }

        return back()->with('success', 'Contact request rejected');
    }

    public function scheduleDemoFromLead(Request $request, $id)
    {
        $request->validate(['scheduled_at' => 'required|date']);

        $lead = \App\Models\Lead::findOrFail($id);

        $demo = \App\Models\DemoClass::create([
            'lead_id' => $lead->id,
            'scheduled_at' => $request->scheduled_at,
            'status' => 'scheduled',
        ]);

        // Auto-approve contact
        if (!$lead->is_contact_shared) {
            $lead->is_contact_shared = true;
            $lead->contact_shared_at = now();
        }
        $lead->status = 'demo_scheduled';
        $lead->save();

        return back()->with('success', 'Demo scheduled and contact shared successfully');
    }

    // ==================== LEAVE MANAGEMENT ====================

    public function leaves(Request $request)
    {
        $query = \App\Models\TeacherLeave::with(['teacher.user'])
            ->orderBy('created_at', 'desc');

        if ($request->has('status') && $request->status) {
            $query->where('status', $request->status);
        }

        if ($request->has('leave_type') && $request->leave_type) {
            $query->where('leave_type', $request->leave_type);
        }

        $leaves = $query->paginate(20);

        // Stats
        $stats = [
            'total' => \App\Models\TeacherLeave::count(),
            'pending' => \App\Models\TeacherLeave::where('status', 'pending')->count(),
            'approved' => \App\Models\TeacherLeave::where('status', 'approved')->count(),
            'rejected' => \App\Models\TeacherLeave::where('status', 'rejected')->count(),
        ];

        return view('admin.leaves', compact('leaves', 'stats'));
    }

    public function approveLeave($id)
    {
        $leave = \App\Models\TeacherLeave::with('teacher.user')->findOrFail($id);

        if ($leave->status !== 'pending') {
            return back()->with('error', 'Leave has already been processed');
        }

        $leave->status = 'approved';
        $leave->approved_by = auth()->id();
        $leave->approved_at = now();
        $leave->save();

        // Notify teacher
        if ($leave->teacher && $leave->teacher->user) {
            $notificationService = new \App\Services\NotificationService();
            $notificationService->sendToUser(
                $leave->teacher->user->id,
                'Leave Approved',
                "Your leave request from {$leave->start_date->format('d M')} to {$leave->end_date->format('d M')} has been approved.",
                'leave_approved'
            );
        }

        return back()->with('success', 'Leave approved successfully');
    }

    public function rejectLeave(Request $request, $id)
    {
        $leave = \App\Models\TeacherLeave::with('teacher.user')->findOrFail($id);

        if ($leave->status !== 'pending') {
            return back()->with('error', 'Leave has already been processed');
        }

        $leave->status = 'rejected';
        $leave->save();

        // Notify teacher
        if ($leave->teacher && $leave->teacher->user) {
            $notificationService = new \App\Services\NotificationService();
            $notificationService->sendToUser(
                $leave->teacher->user->id,
                'Leave Rejected',
                "Your leave request from {$leave->start_date->format('d M')} to {$leave->end_date->format('d M')} was rejected.",
                'leave_rejected'
            );
        }

        return back()->with('success', 'Leave rejected');
    }

    // Parent Management
    public function parents(Request $request)
    {
        $query = User::where('role', 'parent')->latest();

        if ($request->has('search') && $request->search) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('phone', 'like', "%{$search}%");
            });
        }

        $parents = $query->paginate(15);

        // Stats
        $totalParents = User::where('role', 'parent')->count();
        $totalLinks = \App\Models\ParentChild::count();
        $linkedParentIds = \App\Models\ParentChild::distinct('parent_id')->pluck('parent_id');
        $linkedParents = $linkedParentIds->count();

        $stats = [
            'total_parents' => $totalParents,
            'linked_parents' => $linkedParents,
            'unlinked_parents' => $totalParents - $linkedParents,
            'total_links' => $totalLinks,
        ];

        return view('admin.parents', compact('parents', 'stats'));
    }

    public function approveParent($id)
    {
        $user = User::where('role', 'parent')->where('id', $id)->firstOrFail();

        if ($user->status !== 'pending') {
            return redirect()->route('admin.parents')->with('error', 'Parent account has already been processed');
        }

        $user->status = 'approved';
        $user->save();

        return redirect()->route('admin.parents')->with('success', 'Parent account approved successfully');
    }

    public function rejectParent($id)
    {
        $user = User::where('role', 'parent')->where('id', $id)->firstOrFail();

        if ($user->status !== 'pending') {
            return redirect()->route('admin.parents')->with('error', 'Parent account has already been processed');
        }

        $user->status = 'rejected';
        $user->save();

        return redirect()->route('admin.parents')->with('success', 'Parent account rejected');
    }
}
