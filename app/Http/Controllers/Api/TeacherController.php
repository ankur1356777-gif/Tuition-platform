<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Teacher;
use App\Models\Lead;
use App\Models\TuitionRequest;
use App\Models\Attendance;
use App\Models\Test;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class TeacherController extends Controller
{
    protected $notificationService;

    public function __construct(\App\Services\NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    public function dashboard()
    {
        $user = Auth::user();
        $teacher = $user->teacher;

        if (!$teacher) {
            return response()->json(['message' => 'Teacher profile not found'], 404);
        }

        return response()->json([
            'stats' => [
                'total_earnings' => $user->wallet ? $user->wallet->balance : 0,
                'active_leads' => Lead::where('teacher_id', $teacher->id)->where('status', 'active')->count(),
                'total_classes' => Attendance::where('teacher_id', $teacher->id)->count(),
                'pending_dues' => 0, // Logic to be implemented
            ],
            'recent_leads' => Lead::with('tuitionRequest')
            ->where('teacher_id', $teacher->id)
            ->orderBy('created_at', 'desc')
            ->limit(5)
            ->get()
        ]);
    }

    public function getLeads()
    {
        $teacherId = Auth::user()->teacher->id;
        $leads = Lead::with('tuitionRequest.student.user')
            ->where('teacher_id', $teacherId)
            ->orderBy('created_at', 'desc')
            ->get();

        $formattedLeads = $leads->map(function ($lead) {
            $data = $lead->toArray();

            if (!$lead->is_contact_shared) {
                if (isset($data['tuition_request']['student']['user'])) {
                    $data['tuition_request']['student']['user']['phone'] = 'HIDDEN';
                }
                if (isset($data['tuition_request']['student'])) {
                    $data['tuition_request']['student']['address'] = 'HIDDEN';
                }
                // Handle guest fields
                $data['tuition_request']['guest_phone'] = 'HIDDEN';
            }

            return $data;
        });

        return response()->json($formattedLeads);
    }

    public function manageLeads(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'status' => 'required|in:accepted,rejected',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $lead = Lead::findOrFail($id);

        if ($lead->teacher_id !== Auth::user()->teacher->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $lead->status = $request->status;
        $lead->save();

        return response()->json([
            'message' => "Lead {$request->status} successfully",
            'lead' => $lead
        ]);
    }

    public function markAttendance(Request $request)
    {
        $request->validate([
            'tuition_id' => 'required|exists:paid_tuitions,id',
            'status' => 'required|in:present,absent',
            'latitude' => 'required',
            'longitude' => 'required',
            'today_target' => 'nullable|string',
            'homework_yesterday_status' => 'nullable|in:complete,partially_complete,incomplete',
        ]);

        $teacher = Auth::user()->teacher;
        $attendance = Attendance::create([
            'teacher_id' => $teacher->id,
            'paid_tuition_id' => $request->tuition_id,
            'status' => $request->status,
            'marked_at' => now(),
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'today_target' => $request->today_target,
            'homework_yesterday_status' => $request->homework_yesterday_status,
        ]);

        // Integrate with TeacherQualificationService for absence tracking
        if ($request->status === 'absent') {
            $qualificationService = app(\App\Services\TeacherQualificationService::class);
            $qualificationService->recordAbsence($teacher->id, false); // unapproved absence
        }
        else {
            // Reset consecutive absences on presence
            $teacher->update(['consecutive_absences' => 0]);
        }

        // Notify Student
        $tuition = \App\Models\PaidTuition::with('student')->find($request->tuition_id);
        if ($tuition && $tuition->student) {
            $this->notificationService->sendToUser(
                $tuition->student->user_id,
                'Attendance Marked',
                "Your teacher has marked attendance as {$request->status} for today.",
                'attendance_marked'
            );
        }

        return response()->json([
            'message' => 'Attendance marked successfully',
            'attendance' => $attendance
        ]);
    }

    public function createTest(Request $request)
    {
        $request->validate([
            'title' => 'required|string',
            'subject' => 'required|string',
            'total_marks' => 'required|integer',
            'tuition_id' => 'required|exists:paid_tuitions,id',
        ]);

        $test = Test::create([
            'teacher_id' => Auth::user()->teacher->id,
            'paid_tuition_id' => $request->tuition_id,
            'title' => $request->title,
            'subject' => $request->subject,
            'total_marks' => $request->total_marks,
            'created_at' => now(),
        ]);

        return response()->json([
            'message' => 'Test created successfully',
            'test' => $test
        ]);
    }

    public function demoClasses()
    {
        $teacherId = Auth::user()->teacher->id;

        // Get demos via leads
        $demos = \App\Models\DemoClass::whereHas('lead', function ($q) use ($teacherId) {
            $q->where('teacher_id', $teacherId);
        })->with(['lead.tuitionRequest.student.user'])->orderBy('scheduled_at', 'desc')->get();

        $formattedDemos = $demos->map(function ($demo) {
            $lead = $demo->lead;
            $student = $lead->tuitionRequest->student;
            $user = $student->user;

            $phone = $lead->is_contact_shared ? ($user->phone ?? 'Unknown') : 'HIDDEN';
            $address = $lead->is_contact_shared ? ($student->address ?? 'N/A') : 'HIDDEN';

            return [
            'id' => $demo->id,
            'status' => $demo->status,
            'scheduled_at' => $demo->scheduled_at,
            'student_name' => $user->name ?? 'Unknown',
            'phone' => $phone,
            'address' => $address,
            'subject' => is_array($lead->tuitionRequest->subjects)
            ? implode(', ', $lead->tuitionRequest->subjects)
            : $lead->tuitionRequest->subjects,
            'feedback' => $demo->feedback,
            'is_contact_shared' => $lead->is_contact_shared,
            ];
        });

        return response()->json($formattedDemos);
    }

    public function walletHistory()
    {
        $transactions = \App\Models\Transaction::where('user_id', Auth::id())
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($transactions);
    }

    // Leave Management
    public function applyLeave(Request $request)
    {
        $leaveQuotaService = app(\App\Services\LeaveQuotaService::class);
        $teacher = Auth::user()->teacher;

        // Check if reason is required (quota exceeded)
        $canAutoApprove = $leaveQuotaService->canAutoApprove($teacher->id);

        $rules = [
            'start_date' => 'required|date|after_or_equal:today',
            'end_date' => 'required|date|after_or_equal:start_date',
        ];

        // Reason is mandatory only if exceeding quota
        if (!$canAutoApprove) {
            $rules['reason'] = 'required|string';
        }
        else {
            $rules['reason'] = 'nullable|string';
        }

        $request->validate($rules);

        $result = $leaveQuotaService->applyLeave(
            $teacher->id,
            $request->start_date,
            $request->end_date,
            $request->reason
        );

        if (!$result['success']) {
            return response()->json([
                'message' => $result['message'],
                'requires_reason' => $result['requires_reason'] ?? false,
            ], 422);
        }

        return response()->json([
            'message' => $result['message'],
            'leave' => $result['leave'],
            'auto_approved' => $result['auto_approved'],
        ]);
    }

    public function getLeaveQuotaStatus()
    {
        $leaveQuotaService = app(\App\Services\LeaveQuotaService::class);
        $teacher = Auth::user()->teacher;

        return response()->json($leaveQuotaService->getLeaveQuotaStatus($teacher->id));
    }


    public function getLeaves()
    {
        $leaves = \App\Models\TeacherLeave::where('teacher_id', Auth::user()->teacher->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($leaves);
    }
    public function getActiveTuitions()
    {
        $teacherId = Auth::user()->teacher->id;
        $tuitions = \App\Models\PaidTuition::with(['student.user', 'lead.tuitionRequest'])
            ->where('teacher_id', $teacherId)
            ->where('status', 'active')
            ->get();

        return response()->json($tuitions);
    }

    public function updateMeetingId(Request $request, $id)
    {
        $tuition = \App\Models\PaidTuition::where('teacher_id', Auth::user()->teacher->id)->findOrFail($id);
        $tuition->meeting_id = $request->meeting_id;
        $tuition->save();

        return response()->json(['message' => 'Meeting updated successfully']);
    }
    public function getAvailableRequirements()
    {
        $teacher = Auth::user()->teacher;

        if (!$teacher || !$teacher->area_id) {
            return response()->json([]);
        }

        // Fetch requests from the same area that haven't been assigned to this teacher yet
        // and aren't already converted to active tuitions
        $assignedRequestIds = Lead::where('teacher_id', $teacher->id)
            ->pluck('tuition_request_id')
            ->toArray();

        $requirements = TuitionRequest::with(['student.user', 'area'])
            ->where('area_id', $teacher->area_id)
            ->whereNotIn('id', $assignedRequestIds)
            ->where('status', 'new')
            ->orderBy('created_at', 'desc')
            ->get();

        $formatted = $requirements->map(function ($req) {
            return [
            'id' => $req->id,
            'student_name' => $req->guest_name ?? ($req->student->user->name ?? 'Student'),
            'class' => $req->class,
            'subjects' => is_string($req->subjects) ? json_decode($req->subjects, true) : $req->subjects,
            'budget' => $req->budget,
            'location' => $req->location,
            'area_name' => $req->area ? $req->area->name : 'Lucknow',
            'created_at' => $req->created_at,
            ];
        });

        return response()->json($formatted);
    }

    public function expressInterest($id)
    {
        $teacher = Auth::user()->teacher;
        $tuitionRequest = TuitionRequest::findOrFail($id);

        // Check if lead already exists for this teacher and request
        $existingLead = Lead::where('teacher_id', $teacher->id)
            ->where('tuition_request_id', $tuitionRequest->id)
            ->first();

        if ($existingLead) {
            return response()->json(['message' => 'You have already expressed interest in this requirement.'], 400);
        }

        // Create a lead with status 'pending_approval'
        $lead = Lead::create([
            'teacher_id' => $teacher->id,
            'tuition_request_id' => $tuitionRequest->id,
            'status' => 'pending_approval',
            'is_contact_shared' => false,
            'sent_at' => now(),
            'expires_at' => now()->addDays(7),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Interest expressed successfully. Admin will review and share contact details shortly.',
            'lead' => $lead
        ]);
    }

    // ==================== CONTACT REQUEST APIs ====================

    /**
     * Get leads with limited student details (not contact shared)
     */
    public function getLeadsWithLimitedDetails()
    {
        $teacherId = Auth::user()->teacher->id;
        $leads = Lead::with(['tuitionRequest.student.user', 'tuitionRequest.area'])
            ->where('teacher_id', $teacherId)
            ->orderBy('created_at', 'desc')
            ->get();

        $formattedLeads = $leads->map(function ($lead) {
            $request = $lead->tuitionRequest;
            $student = $request->student ?? null;
            $user = $student ? $student->user : null;

            // Limited details visible to all teachers
            $limitedInfo = [
                'id' => $lead->id,
                'status' => $lead->status,
                'student_name' => $request->guest_name ?? ($user->name ?? 'Student'),
                'subjects' => $request->subjects,
                'class' => $request->class,
                'area' => $request->area->name ?? $request->location ?? 'Unknown',
                'contact_requested' => $lead->contact_requested,
                'is_contact_shared' => $lead->is_contact_shared,
                'created_at' => $lead->created_at,
            ];

            // Full details only if contact is shared
            if ($lead->is_contact_shared) {
                $limitedInfo['phone'] = $request->guest_phone ?? ($user->phone ?? 'N/A');
                $limitedInfo['address'] = $student->address ?? 'N/A';
                $limitedInfo['email'] = $user->email ?? null;
            }

            return $limitedInfo;
        });

        return response()->json($formattedLeads);
    }

    /**
     * Request contact details from admin
     */
    public function requestStudentContact($id)
    {
        $teacher = Auth::user()->teacher;
        $lead = Lead::where('teacher_id', $teacher->id)->findOrFail($id);

        if ($lead->is_contact_shared) {
            return response()->json(['message' => 'Contact already shared'], 400);
        }

        if ($lead->contact_requested) {
            return response()->json(['message' => 'Contact request already pending'], 400);
        }

        $lead->requestContact();

        // Notify admin
        $this->notificationService->sendToAdmins(
            'Contact Request',
            "Teacher {$teacher->user->name} requested contact for lead #{$lead->id}",
            'contact_request'
        );

        return response()->json([
            'success' => true,
            'message' => 'Contact request sent to admin. You will be notified once approved.'
        ]);
    }

    // ==================== HOMEWORK APIs ====================

    /**
     * Create homework assignment
     */
    public function createHomework(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'subject' => 'required|string',
            'class' => 'nullable|string',
            'due_date' => 'required|date|after:today',
            'tuition_id' => 'nullable|exists:paid_tuitions,id',
        ]);

        $teacher = Auth::user()->teacher;

        $homework = \App\Models\Homework::create([
            'teacher_id' => $teacher->id,
            'paid_tuition_id' => $request->tuition_id,
            'title' => $request->title,
            'description' => $request->description,
            'subject' => $request->subject,
            'class' => $request->class,
            'due_date' => $request->due_date,
            'status' => 'active',
        ]);

        // Notify students if tuition_id is provided
        if ($request->tuition_id) {
            $tuition = \App\Models\PaidTuition::with('student.user')->find($request->tuition_id);
            if ($tuition && $tuition->student && $tuition->student->user) {
                $this->notificationService->sendToUser(
                    $tuition->student->user->id,
                    'New Homework Assigned',
                    "New homework: {$homework->title} - Due: {$homework->due_date->format('d M Y')}",
                    'homework_assigned'
                );
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Homework created successfully',
            'homework' => $homework
        ], 201);
    }

    /**
     * Get all homework created by teacher
     */
    public function getHomework()
    {
        $teacher = Auth::user()->teacher;
        $homework = \App\Models\Homework::with(['submissions.student.user', 'paidTuition.student.user'])
            ->where('teacher_id', $teacher->id)
            ->orderBy('due_date', 'desc')
            ->get();

        return response()->json($homework);
    }

    /**
     * Get homework submissions for a specific homework
     */
    public function getHomeworkSubmissions($id)
    {
        $teacher = Auth::user()->teacher;
        $homework = \App\Models\Homework::where('teacher_id', $teacher->id)->findOrFail($id);

        $submissions = $homework->submissions()->with('student.user')->get();

        return response()->json([
            'homework' => $homework,
            'submissions' => $submissions
        ]);
    }

    /**
     * Review homework submission
     */
    public function reviewHomework(Request $request, $submissionId)
    {
        $request->validate([
            'teacher_remarks' => 'required|string',
            'marks' => 'nullable|integer|min:0',
        ]);

        $teacher = Auth::user()->teacher;
        $submission = \App\Models\HomeworkSubmission::with('homework')
            ->whereHas('homework', function ($q) use ($teacher) {
            $q->where('teacher_id', $teacher->id);
        })
            ->findOrFail($submissionId);

        $submission->teacher_remarks = $request->teacher_remarks;
        $submission->marks = $request->marks;
        $submission->status = 'reviewed';
        $submission->save();

        // Notify student
        if ($submission->student && $submission->student->user) {
            $this->notificationService->sendToUser(
                $submission->student->user->id,
                'Homework Reviewed',
                "Your homework '{$submission->homework->title}' has been reviewed.",
                'homework_reviewed'
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Homework reviewed successfully',
            'submission' => $submission
        ]);
    }

    // ==================== TEACHING PLAN APIs ====================

    /**
     * Create or update teaching plan for the week
     */
    public function createTeachingPlan(Request $request)
    {
        $request->validate([
            'week_start' => 'required|date',
            'planned_topics' => 'required|array',
            'tuition_id' => 'nullable|exists:paid_tuitions,id',
        ]);

        $teacher = Auth::user()->teacher;

        $plan = \App\Models\TeachingPlan::updateOrCreate(
        [
            'teacher_id' => $teacher->id,
            'paid_tuition_id' => $request->tuition_id,
            'week_start' => $request->week_start,
        ],
        [
            'planned_topics' => $request->planned_topics,
            'status' => 'planned',
        ]
        );

        return response()->json([
            'success' => true,
            'message' => 'Teaching plan saved successfully',
            'plan' => $plan
        ]);
    }

    /**
     * Get teaching plans
     */
    public function getTeachingPlans(Request $request)
    {
        $teacher = Auth::user()->teacher;
        $query = \App\Models\TeachingPlan::with('paidTuition.student.user')
            ->where('teacher_id', $teacher->id)
            ->orderBy('week_start', 'desc');

        if ($request->has('tuition_id')) {
            $query->where('paid_tuition_id', $request->tuition_id);
        }

        return response()->json($query->get());
    }

    /**
     * Update teaching plan (mark topics as completed or incomplete)
     */
    public function updateTeachingPlan(Request $request, $id)
    {
        $request->validate([
            'completed_topics' => 'nullable|array',
            'incomplete_reason' => 'nullable|string|required_if:status,incomplete',
            'status' => 'nullable|in:in_progress,completed,incomplete',
        ]);

        $teacher = Auth::user()->teacher;
        $plan = \App\Models\TeachingPlan::where('teacher_id', $teacher->id)->findOrFail($id);

        if ($request->has('completed_topics')) {
            $plan->completed_topics = $request->completed_topics;
        }

        if ($request->has('status')) {
            $plan->status = $request->status;

            // Require reason if marked as incomplete
            if ($request->status === 'incomplete' && !$request->incomplete_reason) {
                return response()->json([
                    'message' => 'Reason is required when marking plan as incomplete'
                ], 422);
            }
        }

        if ($request->has('incomplete_reason')) {
            $plan->incomplete_reason = $request->incomplete_reason;
        }

        $plan->save();

        return response()->json([
            'success' => true,
            'message' => 'Teaching plan updated',
            'plan' => $plan
        ]);
    }

    // ==================== WEEKLY TEST APIs ====================

    /**
     * Schedule a weekly test (25 marks)
     */
    public function scheduleWeeklyTest(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'subject' => 'required|string',
            'tuition_id' => 'required|exists:paid_tuitions,id',
            'scheduled_date' => 'required|date|after:today',
            'duration_minutes' => 'nullable|integer|min:10',
            'questions' => 'nullable|array',
        ]);

        $teacher = Auth::user()->teacher;

        $test = Test::create([
            'teacher_id' => $teacher->id,
            'paid_tuition_id' => $request->tuition_id,
            'title' => $request->title,
            'subject' => $request->subject,
            'total_marks' => 25, // Weekly tests are always 25 marks
            'duration_minutes' => $request->duration_minutes ?? 30,
            'scheduled_date' => $request->scheduled_date,
            'type' => 'weekly',
            'test_type' => 'weekly',
            'is_weekly_test' => true,
            'questions' => $request->questions,
            'status' => 'scheduled',
        ]);

        // Notify student
        $tuition = \App\Models\PaidTuition::with('student.user')->find($request->tuition_id);
        if ($tuition && $tuition->student && $tuition->student->user) {
            $this->notificationService->sendToUser(
                $tuition->student->user->id,
                'Weekly Test Scheduled',
                "A weekly test '{$test->title}' has been scheduled for {$test->scheduled_date->format('d M Y')}",
                'test_scheduled'
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Weekly test scheduled successfully',
            'test' => $test
        ], 201);
    }

    /**
     * Get all weekly tests
     */
    public function getWeeklyTests()
    {
        $teacher = Auth::user()->teacher;
        $tests = Test::with(['results.student.user', 'paidTuition.student.user'])
            ->where('teacher_id', $teacher->id)
            ->where('is_weekly_test', true)
            ->orderBy('scheduled_date', 'desc')
            ->get();

        return response()->json($tests);
    }

    /**
     * Get wallet with rewards summary
     */
    public function getWalletWithRewards()
    {
        $user = Auth::user();
        $wallet = \App\Models\Wallet::where('user_id', $user->id)->first();

        $transactions = \App\Models\Transaction::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->limit(20)
            ->get();

        $totalRewards = \App\Models\Transaction::where('user_id', $user->id)
            ->where('type', 'reward')
            ->sum('amount');

        return response()->json([
            'balance' => $wallet ? $wallet->balance : 0,
            'total_rewards' => $totalRewards,
            'transactions' => $transactions,
        ]);
    }
}
