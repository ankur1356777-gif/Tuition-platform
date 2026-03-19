<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Student;
use App\Models\TuitionRequest;
use App\Models\Attendance;
use App\Models\TestResult;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class StudentController extends Controller
{
    protected $notificationService;

    public function __construct(\App\Services\NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    public function dashboard()
    {
        $user = Auth::user();
        $student = $user->student;

        // Auto-create student profile if it doesn't exist yet
        if (!$student) {
            $student = Student::create([
                'user_id' => $user->id,
                'gender' => 'other',
                'class' => 'Nursery',
                'address' => 'N/A',
                'landmark' => 'N/A',
                'latitude' => 0,
                'longitude' => 0,
                'city' => 'N/A',
                'state' => 'N/A',
                'pincode' => 'N/A',
                'subjects_needed' => [],
                'tutor_selection_mode' => 'expert',
            ]);
        }

        return response()->json([
            'stats' => [
                'active_tuitions' => 0,
                'attendance_percentage' => 0,
                'avg_test_score' => TestResult::where('student_id', $student->id)->avg('percentage') ?? 0,
                'batch' => $student->batch ?? 'bronze',
            ],
            'recent_requests' => TuitionRequest::where('student_id', $student->id)
            ->orderBy('created_at', 'desc')
            ->limit(5)
            ->get()
        ]);
    }

    public function createRequest(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'subject' => 'required|string',
            'grade' => 'required|string',
            'budget' => 'required|numeric',
            'description' => 'nullable|string',
            'preferred_timing' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $tuitionRequest = TuitionRequest::create([
            'student_id' => Auth::user()->student->id,
            'subjects' => is_array($request->subject) ? $request->subject : [$request->subject],
            'class' => $request->grade,
            'budget' => $request->budget,
            'description' => $request->description,
            'preferred_timing' => $request->preferred_timing,
            'status' => 'new',
            'created_at' => now(),
        ]);

        // Trigger matching service to find tutors and create leads
        app(\App\Services\MatchingService::class)->autoMatch($tuitionRequest);

        // Notify student
        $this->notificationService->sendToUser(
            Auth::id(),
            'Tuition Request Submitted',
            'We are matching the best teachers for you. You will be notified soon!',
            'tuition_request_created'
        );

        return response()->json([
            'message' => 'Tuition request created successfully',
            'request' => $tuitionRequest
        ], 201);
    }

    public function viewAttendance()
    {
        $student = Auth::user()->student;
        $attendance = Attendance::whereHas('paidTuition', function ($query) use ($student) {
            $query->where('student_id', $student->id);
        })->with('teacher.user')->orderBy('marked_at', 'desc')->get();

        return response()->json($attendance);
    }

    public function viewTestResults()
    {
        $student = Auth::user()->student;
        $results = TestResult::with('test.teacher.user')
            ->where('student_id', $student->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($results);
    }

    public function viewPaymentHistory()
    {
        $transactions = \App\Models\Transaction::where('user_id', Auth::id())
            ->orderBy('created_at', 'desc')
            ->get();
        return response()->json($transactions);
    }

    public function submitDemoFeedback(Request $request, $id)
    {
        $request->validate([
            'feedback' => 'required|string',
        ]);

        $studentId = Auth::user()->student->id;

        // Find demo by ID, ensure it belongs to student via Lead -> TuitionRequest
        $demo = \App\Models\DemoClass::whereHas('lead.tuitionRequest', function ($q) use ($studentId) {
            $q->where('student_id', $studentId);
        })->find($id);

        if (!$demo) {
            return response()->json(['message' => 'Demo class not found or unauthorized'], 404);
        }

        $demo->feedback = $request->feedback;
        $demo->save();

        return response()->json(['message' => 'Feedback submitted successfully']);
    }
    public function getTests()
    {
        $studentId = Auth::user()->student->id;

        // Fetch tests from tuitions the student is enrolled in
        $tests = \App\Models\Test::whereHas('paidTuition', function ($q) use ($studentId) {
            $q->where('student_id', $studentId);
        })
            ->with('teacher.user')
            ->where('status', 'scheduled')
            ->orderBy('scheduled_date', 'asc')
            ->get();

        return response()->json($tests);
    }

    public function submitTest(Request $request, $id)
    {
        $request->validate([
            'answers' => 'required|array',
        ]);

        $test = \App\Models\Test::findOrFail($id);
        $student = Auth::user()->student;
        $studentId = $student->id;

        // Simple MCQ grading
        $score = 0;
        $questions = $test->questions;
        $userAnswers = $request->answers;

        foreach ($questions as $index => $q) {
            if (isset($userAnswers[$index]) && $userAnswers[$index] == $q['correct_option']) {
                $score += $q['marks'] ?? ($test->total_marks / count($questions));
            }
        }

        $percentage = ($test->total_marks > 0) ? ($score / $test->total_marks) * 100 : 0;

        $result = TestResult::updateOrCreate(
        ['test_id' => $test->id, 'student_id' => $studentId],
        [
            'marks_obtained' => $score,
            'percentage' => $percentage,
            'teacher_remarks' => 'Auto-graded online test',
            'submitted_at' => now(),
        ]
        );

        // Check for rewards/badges if this is a weekly test
        $rewardResult = null;
        if ($test->is_weekly_test) {
            $rewardService = app(\App\Services\RewardService::class);

            // Check Silver Badge
            $rewardResult = $rewardService->checkSilverBadge($studentId, $percentage);

            // Update consecutive high scores in student model
            if ($percentage >= 80) {
                $student->increment('consecutive_high_scores');
                // Check Gold Badge
                $goldResult = $rewardService->checkGoldBadge($studentId);
                if ($goldResult) {
                    $rewardResult = array_merge($rewardResult ?? [], $goldResult);
                }
            }
            else {
                $student->update(['consecutive_high_scores' => 0]);
            }
        }

        return response()->json([
            'message' => 'Test submitted successfully',
            'result' => $result,
            'reward_result' => $rewardResult,
            'new_batch' => $student->fresh()->batch,
        ]);
    }

    public function getActiveTuitions()
    {
        $studentId = Auth::user()->student->id;
        $activeTuitions = \App\Models\PaidTuition::with(['teacher.user', 'lead.tuitionRequest'])
            ->where('student_id', $studentId)
            ->where('status', 'active')
            ->get();

        return response()->json($activeTuitions);
    }

    // ==================== HOMEWORK APIs ====================

    /**
     * Get assigned homework for student
     */
    public function getHomework()
    {
        $studentId = Auth::user()->student->id;

        // Get homework from student's active tuitions
        $homework = \App\Models\Homework::with(['teacher.user', 'submissions' => function ($q) use ($studentId) {
            $q->where('student_id', $studentId);
        }])
            ->whereHas('paidTuition', function ($q) use ($studentId) {
            $q->where('student_id', $studentId);
        })
            ->where('status', 'active')
            ->orderBy('due_date', 'asc')
            ->get();

        // Add submission status to each homework
        $homework = $homework->map(function ($hw) use ($studentId) {
            $submission = $hw->submissions->first();
            $hw->my_submission = $submission;
            $hw->is_submitted = $submission ? true : false;
            $hw->is_overdue = $hw->due_date->isPast() && !$submission;
            unset($hw->submissions);
            return $hw;
        });

        return response()->json($homework);
    }

    /**
     * Submit homework
     */
    public function submitHomework(Request $request, $id)
    {
        $request->validate([
            'content' => 'nullable|string',
            'file_url' => 'nullable|string',
        ]);

        $student = Auth::user()->student;
        $homework = \App\Models\Homework::findOrFail($id);

        // Check if already submitted
        $existingSubmission = \App\Models\HomeworkSubmission::where('homework_id', $id)
            ->where('student_id', $student->id)
            ->first();

        if ($existingSubmission) {
            return response()->json(['message' => 'Homework already submitted'], 400);
        }

        // Determine status (late if past due date)
        $status = $homework->due_date->isPast() ? 'late' : 'submitted';

        $submission = \App\Models\HomeworkSubmission::create([
            'homework_id' => $id,
            'student_id' => $student->id,
            'content' => $request->content,
            'file_url' => $request->file_url,
            'status' => $status,
            'submitted_at' => now(),
        ]);

        // Notify teacher
        $this->notificationService->sendToUser(
            $homework->teacher->user_id,
            'Homework Submitted',
            "Student {$student->user->name} submitted homework: {$homework->title}",
            'homework_submitted'
        );

        return response()->json([
            'success' => true,
            'message' => 'Homework submitted successfully',
            'submission' => $submission,
        ]);
    }

    // ==================== TEACHER RATING APIs ====================

    /**
     * Rate a teacher (only rating is public, feedback is hidden)
     */
    public function rateTeacher(Request $request, $teacherId)
    {
        $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'feedback' => 'nullable|string|max:1000',
        ]);

        $student = Auth::user()->student;
        $user = Auth::user();
        $teacher = \App\Models\Teacher::findOrFail($teacherId);

        // Check if student has an active tuition with this teacher
        $hasActiveTuition = \App\Models\PaidTuition::where('student_id', $student->id)
            ->where('teacher_id', $teacher->id)
            ->exists();

        if (!$hasActiveTuition) {
            return response()->json([
                'message' => 'You can only rate teachers you have taken tuition from'
            ], 403);
        }

        // Create or update rating
        $rating = \App\Models\TeacherRating::updateOrCreate(
        [
            'teacher_id' => $teacher->id,
            'student_id' => $student->id,
            'user_id' => $user->id,
        ],
        [
            'rating' => $request->rating,
            'feedback' => $request->feedback,
            'rated_by' => 'student',
        ]
        );

        // Recalculate teacher's average rating
        $teacher->calculateAverageRating();

        return response()->json([
            'success' => true,
            'message' => 'Thank you for your rating!',
            'teacher_rating' => $teacher->rating,
        ]);
    }

    /**
     * Get teacher rating (public rating only, no feedback)
     */
    public function getTeacherRating($teacherId)
    {
        $teacher = \App\Models\Teacher::findOrFail($teacherId);

        return response()->json([
            'teacher_id' => $teacher->id,
            'teacher_name' => $teacher->user->name ?? 'Unknown',
            'average_rating' => round($teacher->rating, 1),
            'rating_count' => $teacher->rating_count,
        ]);
    }

    // ==================== TEACHING PLAN APIs ====================

    /**
     * Get teaching plan for student's tuition
     */
    public function getTeachingPlan(Request $request)
    {
        $studentId = Auth::user()->student->id;

        $plans = \App\Models\TeachingPlan::with(['teacher.user', 'paidTuition'])
            ->whereHas('paidTuition', function ($q) use ($studentId) {
            $q->where('student_id', $studentId);
        })
            ->orderBy('week_start', 'desc')
            ->get();

        return response()->json($plans);
    }

    /**
     * Get student's batch status
     */
    public function getBatchStatus()
    {
        $student = Auth::user()->student;

        $recentResults = TestResult::with('test')
            ->where('student_id', $student->id)
            ->whereHas('test', function ($q) {
            $q->where('is_weekly_test', true);
        })
            ->orderBy('created_at', 'desc')
            ->limit(5)
            ->get();

        return response()->json([
            'current_batch' => $student->batch ?? 'bronze',
            'consecutive_high_scores' => $student->consecutive_high_scores ?? 0,
            'scores_needed_for_upgrade' => max(0, 3 - ($student->consecutive_high_scores ?? 0)),
            'recent_weekly_tests' => $recentResults->map(function ($r) {
            return [
                    'test_title' => $r->test->title ?? 'Test',
                    'percentage' => $r->percentage,
                    'is_high_score' => $r->percentage >= 80,
                    'date' => $r->created_at->format('d M Y'),
                ];
        }),
        ]);
    }
}
