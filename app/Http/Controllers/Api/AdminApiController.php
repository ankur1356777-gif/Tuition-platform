<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Teacher;
use App\Models\Student;
use App\Models\TuitionRequest;
use App\Models\Lead;
use App\Models\Transaction;
use App\Models\PayoutRequest;
use App\Models\Homework;
use App\Models\TeachingPlan;
use App\Models\TeacherRating;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AdminApiController extends Controller
{
    protected $notificationService;
    protected $rewardService;

    public function __construct(
        \App\Services\NotificationService $notificationService,
        \App\Services\RewardService $rewardService
        )
    {
        $this->notificationService = $notificationService;
        $this->rewardService = $rewardService;
    }

    public function dashboard()
    {
        return response()->json([
            'stats' => [
                'total_teachers' => User::where('role', 'teacher')->count(),
                'total_students' => User::where('role', 'student')->count(),
                'pending_approvals' => User::where('status', 'pending')->count(),
                'monthly_revenue' => Transaction::where('type', 'commission')->whereMonth('created_at', now()->month)->sum('amount'),
                'active_tuitions' => TuitionRequest::where('status', 'active')->count(),
                'pending_contact_requests' => Lead::where('contact_requested', true)->where('is_contact_shared', false)->count(),
            ],
            'pending_teachers' => User::with('teacher')->where('role', 'teacher')->where('status', 'pending')->orderBy('created_at', 'desc')->limit(5)->get(),
            'recent_leads' => Lead::with(['teacher.user', 'tuitionRequest'])->limit(5)->orderBy('created_at', 'desc')->get()
        ]);
    }

    public function manageUserStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:pending,approved,rejected,active,inactive',
        ]);

        $user = User::findOrFail($id);
        $oldStatus = $user->status;
        $user->status = $request->status;
        $user->save();

        // If approved and was pending, send notifications
        if ($request->status === 'approved' && $oldStatus === 'pending' && $user->role === 'teacher') {
            // WhatsApp
            if ($user->teacher && $user->teacher->whatsapp_number) {
                $this->notificationService->sendWhatsAppMessage(
                    $user->teacher->whatsapp_number,
                    "Congratulations {$user->name}! Your teacher account has been approved. You can now log in and see available tuitions."
                );
            }

            // Email
            if ($user->email) {
                $this->notificationService->sendEmail(
                    $user->email,
                    'Account Approved',
                    'emails.teacher_approved',
                ['name' => $user->name]
                );
            }
        }

        return response()->json([
            'message' => "User status updated to {$request->status}",
            'user' => $user
        ]);
    }

    public function leadsOverview()
    {
        $leads = Lead::with(['teacher.user', 'tuitionRequest.student.user'])->orderBy('created_at', 'desc')->paginate(20);
        return response()->json($leads);
    }

    public function payoutRequests()
    {
        $requests = PayoutRequest::with('user')->where('status', 'pending')->orderBy('created_at', 'asc')->get();
        return response()->json($requests);
    }

    public function approvePayout(Request $request, $id)
    {
        $payout = PayoutRequest::findOrFail($id);
        $payout->status = 'approved';
        $payout->processed_at = now();
        $payout->save();

        return response()->json(['message' => 'Payout approved successfully']);
    }

    // Commission Management
    public function getCommissionSettings()
    {
        return response()->json(\App\Models\CommissionSetting::all());
    }

    public function updateCommissionSettings(Request $request)
    {
        $request->validate([
            'settings' => 'required|array',
            'settings.*.key' => 'required|exists:commission_settings,key',
            'settings.*.value' => 'required|numeric'
        ]);

        foreach ($request->settings as $settingData) {
            \App\Models\CommissionSetting::where('key', $settingData['key'])
                ->update(['value' => $settingData['value']]);
        }

        return response()->json(['message' => 'Commission settings updated successfully']);
    }

    // Teacher Management - SORTED BY NEWEST FIRST
    public function getAllTeachers()
    {
        // New registrations appear at the top
        $teachers = Teacher::with('user')->orderBy('created_at', 'desc')->paginate(20);
        return response()->json($teachers);
    }

    public function getTeacherDetails($id)
    {
        $teacher = Teacher::with(['user', 'leads', 'ratings'])->findOrFail($id);
        return response()->json($teacher);
    }

    // Student Management
    public function getAllStudents()
    {
        $students = Student::with('user')->orderBy('created_at', 'desc')->paginate(20);
        return response()->json($students);
    }

    public function getStudentDetails($id)
    {
        $student = Student::with(['user', 'tuitionRequests', 'testResults'])->findOrFail($id);
        return response()->json($student);
    }

    public function updateStudentBatch(Request $request, $id)
    {
        $request->validate([
            'batch' => 'required|in:bronze,silver,gold',
        ]);

        $student = Student::findOrFail($id);
        $oldBatch = $student->batch;
        $student->batch = $request->batch;
        $student->consecutive_high_scores = 0;
        $student->save();

        // Notify student
        if ($student->user) {
            $this->notificationService->sendToUser(
                $student->user->id,
                'Batch Updated',
                "Your batch has been changed to {$request->batch}",
                'batch_update'
            );
        }

        return response()->json([
            'message' => "Student batch updated from {$oldBatch} to {$request->batch}",
            'student' => $student
        ]);
    }

    // Demo Classes
    public function getAllDemos()
    {
        $demos = \App\Models\DemoClass::with(['lead.teacher.user', 'lead.tuitionRequest.student.user'])
            ->orderBy('created_at', 'desc')
            ->paginate(20);
        return response()->json($demos);
    }

    // Agent Management
    public function getAllAgents()
    {
        $agents = User::where('role', 'agent')->paginate(20);
        return response()->json($agents);
    }

    // Attendance Monitoring
    public function getAttendanceLogs(Request $request)
    {
        $query = \App\Models\Attendance::with(['teacher.user', 'paidTuition.student.user'])
            ->orderBy('marked_at', 'desc');

        if ($request->has('teacher_id')) {
            $query->where('teacher_id', $request->teacher_id);
        }

        if ($request->has('date')) {
            $query->whereDate('marked_at', $request->date);
        }

        return response()->json($query->paginate(20));
    }

    // Lead Management
    public function getPendingLeads()
    {
        $leads = Lead::with(['teacher.user', 'tuitionRequest.student.user'])
            ->where('status', 'pending_approval')
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json($leads);
    }

    // Get leads where teacher has requested contact
    public function getContactRequests()
    {
        $leads = Lead::with(['teacher.user', 'tuitionRequest.student.user', 'tuitionRequest.area'])
            ->where('contact_requested', true)
            ->where('is_contact_shared', false)
            ->orderBy('contact_requested_at', 'asc')
            ->get();

        return response()->json($leads);
    }

    public function approveLeadContact($id)
    {
        $lead = Lead::with('teacher.user')->findOrFail($id);
        $lead->approveContact();
        $lead->status = 'active';
        $lead->save();

        // Notify the teacher
        if ($lead->teacher && $lead->teacher->user) {
            $this->notificationService->sendToUser(
                $lead->teacher->user->id,
                'Contact Details Shared',
                'Student contact details have been shared with you. Check your leads!',
                'contact_shared'
            );
        }

        return response()->json(['message' => 'Lead contact sharing approved successfully']);
    }

    public function rejectLeadContact($id)
    {
        $lead = Lead::with('teacher.user')->findOrFail($id);
        $lead->status = 'rejected';
        $lead->contact_requested = false;
        $lead->save();

        // Notify the teacher
        if ($lead->teacher && $lead->teacher->user) {
            $this->notificationService->sendToUser(
                $lead->teacher->user->id,
                'Contact Request Rejected',
                'Your request for student contact details was not approved.',
                'contact_rejected'
            );
        }

        return response()->json(['message' => 'Lead contact sharing rejected']);
    }

    public function scheduleDemoFromLead(Request $request, $id)
    {
        $request->validate([
            'scheduled_at' => 'required|date|after:now',
        ]);

        $lead = Lead::findOrFail($id);

        $demo = \App\Models\DemoClass::create([
            'lead_id' => $lead->id,
            'scheduled_at' => $request->scheduled_at,
            'status' => 'scheduled',
        ]);

        // Share contact if not already shared
        if (!$lead->is_contact_shared) {
            $lead->approveContact();
        }

        $lead->status = 'demo_scheduled';
        $lead->save();

        return response()->json([
            'message' => 'Demo scheduled successfully',
            'demo' => $demo
        ]);
    }

    // ==================== REWARD SYSTEM ====================

    public function getPendingRewards()
    {
        return response()->json($this->rewardService->getPendingRewards());
    }

    public function rewardTeacher(Request $request, $id)
    {
        $request->validate([
            'amount' => 'required|numeric|min:1',
            'reason' => 'required|string',
        ]);

        $this->rewardService->rewardTeacher(
            $id,
            $request->amount,
            $request->reason
        );

        $teacher = Teacher::findOrFail($id);
        $wallet = \App\Models\Wallet::where('user_id', $teacher->user_id)->first();

        return response()->json([
            'message' => "Teacher rewarded ₹{$request->amount} successfully",
            'wallet_balance' => $wallet ? $wallet->balance : 0,
        ]);
    }

    /**
     * Get teacher leaderboard
     */
    public function getLeaderboard()
    {
        return response()->json($this->rewardService->getLeaderboard());
    }

    // ==================== TEACHER FEEDBACK (Hidden from public) ====================

    public function getTeacherFeedback(Request $request)
    {
        $query = TeacherRating::with(['teacher.user', 'student.user'])
            ->whereNotNull('feedback')
            ->orderBy('created_at', 'desc');

        if ($request->has('teacher_id')) {
            $query->where('teacher_id', $request->teacher_id);
        }

        return response()->json($query->paginate(20));
    }

    // ==================== MONITORING ====================

    public function getAllHomework(Request $request)
    {
        $query = Homework::with(['teacher.user', 'paidTuition.student.user', 'submissions'])
            ->orderBy('created_at', 'desc');

        if ($request->has('teacher_id')) {
            $query->where('teacher_id', $request->teacher_id);
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        return response()->json($query->paginate(20));
    }

    public function getAllTeachingPlans(Request $request)
    {
        $query = TeachingPlan::with(['teacher.user', 'paidTuition.student.user'])
            ->orderBy('week_start', 'desc');

        if ($request->has('teacher_id')) {
            $query->where('teacher_id', $request->teacher_id);
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Show incomplete plans with reasons
        if ($request->has('incomplete_only')) {
            $query->where('status', 'incomplete');
        }

        return response()->json($query->paginate(20));
    }

    // ==================== LEAVE MANAGEMENT ====================

    /**
     * Get all teacher leaves
     */
    public function getAllLeaves(Request $request)
    {
        $query = \App\Models\TeacherLeave::with(['teacher.user'])
            ->orderBy('created_at', 'desc');

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('teacher_id')) {
            $query->where('teacher_id', $request->teacher_id);
        }

        if ($request->has('leave_type')) {
            $query->where('leave_type', $request->leave_type);
        }

        return response()->json($query->paginate(20));
    }

    /**
     * Get pending leave requests
     */
    public function getPendingLeaves()
    {
        $leaves = \App\Models\TeacherLeave::with(['teacher.user'])
            ->where('status', 'pending')
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json($leaves);
    }

    /**
     * Approve a teacher leave request
     */
    public function approveLeave($id)
    {
        $leave = \App\Models\TeacherLeave::with('teacher.user')->findOrFail($id);

        if ($leave->status !== 'pending') {
            return response()->json(['message' => 'Leave already processed'], 400);
        }

        $leave->status = 'approved';
        $leave->approved_by = auth()->id();
        $leave->approved_at = now();
        $leave->save();

        // Notify teacher
        if ($leave->teacher && $leave->teacher->user) {
            $this->notificationService->sendToUser(
                $leave->teacher->user->id,
                'Leave Approved',
                "Your leave request from {$leave->start_date->format('d M')} to {$leave->end_date->format('d M')} has been approved.",
                'leave_approved'
            );
        }

        return response()->json([
            'message' => 'Leave approved successfully',
            'leave' => $leave
        ]);
    }

    /**
     * Reject a teacher leave request
     */
    public function rejectLeave(Request $request, $id)
    {
        $leave = \App\Models\TeacherLeave::with('teacher.user')->findOrFail($id);

        if ($leave->status !== 'pending') {
            return response()->json(['message' => 'Leave already processed'], 400);
        }

        $leave->status = 'rejected';
        $leave->approved_by = auth()->id();
        $leave->approved_at = now();
        $leave->save();

        // Notify teacher
        if ($leave->teacher && $leave->teacher->user) {
            $this->notificationService->sendToUser(
                $leave->teacher->user->id,
                'Leave Rejected',
                "Your leave request from {$leave->start_date->format('d M')} to {$leave->end_date->format('d M')} has been rejected.",
                'leave_rejected'
            );
        }

        return response()->json([
            'message' => 'Leave rejected',
            'leave' => $leave
        ]);
    }
}
