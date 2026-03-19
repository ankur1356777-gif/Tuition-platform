<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ParentChild;
use App\Models\Student;
use App\Models\Attendance;
use App\Models\TestResult;
use App\Models\HomeworkSubmission;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ParentController extends Controller
{
    /**
     * Get parent dashboard summary
     */
    public function dashboard()
    {
        $parent = Auth::user();
        
        $children = ParentChild::with(['student.user', 'student.testResults', 'student.homeworkSubmissions'])
            ->where('parent_id', $parent->id)
            ->get();

        $totalChildren = $children->count();
        $activeTuitions = 0;
        $avgPerformance = 0;
        $pendingHomework = 0;

        foreach ($children as $child) {
            $student = $child->student;
            
            // Count active tuitions
            $activeTuitions += \App\Models\PaidTuition::where('student_id', $student->id)
                ->where('status', 'active')
                ->count();

            // Calculate average test performance
            $testResults = $student->testResults;
            if ($testResults->count() > 0) {
                $avgPerformance += $testResults->avg('percentage');
            }

            // Count pending homework
            $pendingHomework += HomeworkSubmission::where('student_id', $student->id)
                ->where('status', 'pending')
                ->count();
        }

        if ($totalChildren > 0) {
            $avgPerformance = round($avgPerformance / $totalChildren, 1);
        }

        return response()->json([
            'total_children' => $totalChildren,
            'active_tuitions' => $activeTuitions,
            'avg_performance' => $avgPerformance,
            'pending_homework' => $pendingHomework,
            'children' => $children->map(function ($child) {
                $student = $child->student;
                $latestTest = $student->testResults()->latest()->first();
                
                return [
                    'id' => $student->id,
                    'name' => $student->user->name ?? 'N/A',
                    'phone' => $student->user->phone ?? '',
                    'class' => $student->class ?? $student->grade ?? 'N/A',
                    'school' => $student->school ?? $student->school_name ?? 'N/A',
                    'batch' => $student->batch ?? 'bronze',
                    'latest_test_score' => $latestTest ? $latestTest->percentage : null,
                    'relationship' => $child->relationship,
                ];
            }),
        ]);
    }

    /**
     * Get list of linked children
     */
    public function getChildren()
    {
        $parent = Auth::user();
        
        $children = ParentChild::with(['student.user'])
            ->where('parent_id', $parent->id)
            ->get()
            ->map(function ($child) {
                $student = $child->student;
                return [
                    'id' => $student->id,
                    'name' => $student->user->name ?? 'N/A',
                    'phone' => $student->user->phone ?? '',
                    'class' => $student->class ?? $student->grade ?? 'N/A',
                    'school' => $student->school ?? $student->school_name ?? 'N/A',
                    'batch' => $student->batch ?? 'bronze',
                    'relationship' => $child->relationship,
                    'is_primary' => $child->is_primary,
                ];
            });

        return response()->json($children);
    }

    /**
     * Get detailed progress for a specific child
     */
    public function getChildProgress($studentId)
    {
        $parent = Auth::user();
        
        // Verify parent has access to this child
        $link = ParentChild::where('parent_id', $parent->id)
            ->where('student_id', $studentId)
            ->first();

        if (!$link) {
            return response()->json(['message' => 'Child not found'], 404);
        }

        $student = Student::with(['user', 'testResults.test', 'homeworkSubmissions.homework'])
            ->findOrFail($studentId);

        // Get active tuitions
        $tuitions = \App\Models\PaidTuition::with(['teacher.user'])
            ->where('student_id', $studentId)
            ->where('status', 'active')
            ->get();

        // Calculate stats
        $testResults = $student->testResults;
        $avgScore = $testResults->count() > 0 ? round($testResults->avg('percentage'), 1) : 0;
        $totalTests = $testResults->count();
        $passedTests = $testResults->where('percentage', '>=', 40)->count();

        $homeworkSubmissions = $student->homeworkSubmissions;
        $totalHomework = $homeworkSubmissions->count();
        $completedHomework = $homeworkSubmissions->whereIn('status', ['submitted', 'reviewed'])->count();

        // Recent attendance
        $recentAttendance = Attendance::whereHas('paidTuition', function ($q) use ($studentId) {
            $q->where('student_id', $studentId);
        })
            ->with('teacher.user')
            ->latest()
            ->take(10)
            ->get();

        $attendanceRate = 0;
        $last30DaysAttendance = Attendance::whereHas('paidTuition', function ($q) use ($studentId) {
            $q->where('student_id', $studentId);
        })
            ->where('date', '>=', now()->subDays(30))
            ->get();

        if ($last30DaysAttendance->count() > 0) {
            $presentCount = $last30DaysAttendance->where('status', 'present')->count();
            $attendanceRate = round(($presentCount / $last30DaysAttendance->count()) * 100, 1);
        }

        return response()->json([
            'student' => [
                'id' => $student->id,
                'name' => $student->user->name ?? 'N/A',
                'class' => $student->class ?? $student->grade ?? 'N/A',
                'school' => $student->school ?? $student->school_name ?? 'N/A',
                'batch' => $student->batch ?? 'bronze',
                'consecutive_high_scores' => $student->consecutive_high_scores ?? 0,
            ],
            'stats' => [
                'avg_test_score' => $avgScore,
                'total_tests' => $totalTests,
                'passed_tests' => $passedTests,
                'total_homework' => $totalHomework,
                'completed_homework' => $completedHomework,
                'attendance_rate' => $attendanceRate,
            ],
            'active_tuitions' => $tuitions->map(function ($t) {
                return [
                    'id' => $t->id,
                    'teacher_name' => $t->teacher->user->name ?? 'N/A',
                    'subject' => $t->subject ?? 'General',
                    'monthly_fee' => $t->monthly_fee,
                    'started_at' => $t->started_at,
                ];
            }),
            'recent_attendance' => $recentAttendance,
        ]);
    }

    /**
     * Get child's attendance records
     */
    public function getChildAttendance($studentId)
    {
        $parent = Auth::user();
        
        $link = ParentChild::where('parent_id', $parent->id)
            ->where('student_id', $studentId)
            ->first();

        if (!$link) {
            return response()->json(['message' => 'Child not found'], 404);
        }

        $attendance = Attendance::whereHas('paidTuition', function ($q) use ($studentId) {
            $q->where('student_id', $studentId);
        })
            ->with(['teacher.user', 'paidTuition'])
            ->orderBy('date', 'desc')
            ->paginate(30);

        return response()->json($attendance);
    }

    /**
     * Get child's test results
     */
    public function getChildTestResults($studentId)
    {
        $parent = Auth::user();
        
        $link = ParentChild::where('parent_id', $parent->id)
            ->where('student_id', $studentId)
            ->first();

        if (!$link) {
            return response()->json(['message' => 'Child not found'], 404);
        }

        $results = TestResult::with(['test.teacher.user'])
            ->where('student_id', $studentId)
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json($results);
    }

    /**
     * Get child's homework status
     */
    public function getChildHomework($studentId)
    {
        $parent = Auth::user();
        
        $link = ParentChild::where('parent_id', $parent->id)
            ->where('student_id', $studentId)
            ->first();

        if (!$link) {
            return response()->json(['message' => 'Child not found'], 404);
        }

        $homework = HomeworkSubmission::with(['homework.teacher.user'])
            ->where('student_id', $studentId)
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json($homework);
    }

    /**
     * Link a child to parent using child's phone number
     */
    public function linkChild(Request $request)
    {
        $request->validate([
            'child_phone' => 'required|string',
        ]);

        $parent = Auth::user();

        // Find the student user by phone
        $childUser = \App\Models\User::where('phone', $request->child_phone)
            ->where('role', 'student')
            ->first();

        if (!$childUser) {
            return response()->json([
                'message' => 'No student found with this phone number. Make sure the child is registered as a student.'
            ], 404);
        }

        $student = Student::where('user_id', $childUser->id)->first();

        if (!$student) {
            return response()->json(['message' => 'Student profile not found'], 404);
        }

        // Check if already linked
        $existing = ParentChild::where('parent_id', $parent->id)
            ->where('student_id', $student->id)
            ->first();

        if ($existing) {
            return response()->json(['message' => 'This child is already linked to your account'], 409);
        }

        // Create the link
        ParentChild::create([
            'parent_id' => $parent->id,
            'student_id' => $student->id,
            'relationship' => $request->relationship ?? 'parent',
            'is_primary' => ParentChild::where('parent_id', $parent->id)->count() === 0,
        ]);

        // Update student's parent_phone if not set
        if (!$student->parent_phone) {
            $student->parent_phone = $parent->phone;
            $student->save();
        }

        return response()->json([
            'message' => 'Child linked successfully',
            'child' => [
                'id' => $student->id,
                'name' => $childUser->name,
                'phone' => $childUser->phone,
                'class' => $student->class ?? $student->grade ?? 'N/A',
            ],
        ]);
    }

    /**
     * Unlink a child from parent
     */
    public function unlinkChild($studentId)
    {
        $parent = Auth::user();

        $link = ParentChild::where('parent_id', $parent->id)
            ->where('student_id', $studentId)
            ->first();

        if (!$link) {
            return response()->json(['message' => 'Child not linked to your account'], 404);
        }

        $link->delete();

        return response()->json(['message' => 'Child unlinked successfully']);
    }
}
