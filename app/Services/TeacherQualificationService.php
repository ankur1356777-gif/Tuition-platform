<?php

namespace App\Services;

use App\Models\Teacher;
use App\Models\DemoClass;
use App\Models\Student;
use App\Models\Subscription;
use Carbon\Carbon;

class TeacherQualificationService
{
    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    /**
     * Record a demo result for a teacher (trial evaluation)
     */
    public function recordDemoResult(int $teacherId, bool $accepted): array
    {
        $teacher = Teacher::findOrFail($teacherId);
        $teacher->increment('trial_demos_count');

        if (!$accepted) {
            $teacher->increment('trial_rejections');
        }
        else {
            $teacher->update(['trial_rejections' => 0]); // Reset on acceptance
        }

        // Check for disqualification: 3 consecutive rejections in first 3 demos
        if ($teacher->trial_rejections >= 3 && $teacher->trial_demos_count <= 3) {
            return $this->disqualifyTeacher($teacher, 'Rejected in 3 consecutive demo house visits.');
        }

        return ['status' => 'ok', 'trial_demos_count' => $teacher->trial_demos_count, 'rejections' => $teacher->trial_rejections];
    }

    /**
     * Disqualify a teacher (9-month lockout)
     */
    public function disqualifyTeacher(Teacher $teacher, string $reason): array
    {
        $reapplyDate = Carbon::now()->addMonths(9);

        $teacher->update([
            'disqualification_status' => 'disqualified',
            'disqualified_at' => now(),
            'reapply_after' => $reapplyDate,
            'is_available' => false,
            'is_verified' => false,
        ]);

        // Update user status
        $teacher->user->update(['status' => 'rejected']);

        $this->notificationService->sendToUser(
            $teacher->user_id,
            'Profile Disqualified',
            "Your teacher profile has been disqualified. Reason: {$reason}. You may reapply after {$reapplyDate->format('d M Y')}.",
            'teacher_disqualified'
        );

        return ['status' => 'disqualified', 'reason' => $reason, 'reapply_after' => $reapplyDate->toDateString()];
    }

    /**
     * Detect service breach
     */
    public function checkServiceBreach(int $teacherId): ?array
    {
        $teacher = Teacher::findOrFail($teacherId);

        // Check: 2 houses discontinued mid-year AND fee unpaid
        $discontinuedCount = Subscription::where('teacher_id', $teacherId)
            ->where('status', 'cancelled')
            ->where('updated_at', '>=', Carbon::now()->subMonths(6))
            ->count();

        if ($discontinuedCount >= 2) {
            return $this->applyServiceBreach($teacher);
        }

        return null;
    }

    /**
     * Apply service breach — permanent lock
     */
    public function applyServiceBreach(Teacher $teacher): array
    {
        $teacher->update([
            'disqualification_status' => 'service_breach',
            'service_breach' => true,
            'is_available' => false,
            'is_verified' => false,
        ]);

        $teacher->user->update(['status' => 'rejected']);

        // Notify affected students
        $activeStudents = Subscription::where('teacher_id', $teacher->id)
            ->where('status', 'active')
            ->with('student.user')
            ->get();

        foreach ($activeStudents as $subscription) {
            $this->notificationService->sendToUser(
                $subscription->student->user_id,
                'Teacher Change Notice',
                'We apologize for the inconvenience. Your teacher has been changed due to a service breach. A new teacher will be assigned shortly.',
                'teacher_breach_apology'
            );
        }

        // Auto-reallocate students would be triggered separately
        return ['status' => 'service_breach', 'affected_students' => $activeStudents->count()];
    }

    /**
     * Handle voluntary discontinuation
     */
    public function handleVoluntaryDiscontinuation(int $teacherId): array
    {
        $teacher = Teacher::findOrFail($teacherId);

        $teacher->update([
            'is_available' => false,
            'is_verified' => false,
        ]);

        $teacher->user->update(['status' => 'inactive']);

        // Notify and reallocate students
        $activeSubscriptions = Subscription::where('teacher_id', $teacherId)
            ->where('status', 'active')
            ->with('student.user')
            ->get();

        foreach ($activeSubscriptions as $subscription) {
            $this->notificationService->sendToUser(
                $subscription->student->user_id,
                'Teacher Discontinued',
                'We apologize for the inconvenience. Your teacher has discontinued services. A new teacher will be auto-assigned.',
                'teacher_discontinued_apology'
            );
        }

        return ['status' => 'discontinued', 'affected_students' => $activeSubscriptions->count()];
    }

    /**
     * Check for consecutive absence and auto-deactivate
     */
    public function checkConsecutiveAbsence(int $teacherId): ?array
    {
        $teacher = Teacher::findOrFail($teacherId);

        if ($teacher->consecutive_absences >= 2) {
            $teacher->update([
                'is_available' => false,
                'is_verified' => false,
                'consecutive_absences' => 0,
            ]);

            $teacher->user->update(['status' => 'inactive']);

            // Notify students
            $activeSubscriptions = Subscription::where('teacher_id', $teacherId)
                ->where('status', 'active')
                ->with('student.user')
                ->get();

            foreach ($activeSubscriptions as $subscription) {
                $this->notificationService->sendToUser(
                    $subscription->student->user_id,
                    'Teacher Reassignment',
                    'Your teacher has been absent for consecutive days. A new teacher will be assigned automatically.',
                    'teacher_absent_reallocation'
                );
            }

            return ['status' => 'auto_deactivated', 'affected_students' => $activeSubscriptions->count()];
        }

        return null;
    }

    /**
     * Record teacher absence (called from attendance)
     */
    public function recordAbsence(int $teacherId, bool $approved): void
    {
        $teacher = Teacher::findOrFail($teacherId);

        if (!$approved) {
            $teacher->increment('consecutive_absences');
            $this->checkConsecutiveAbsence($teacherId);
        }
        else {
            $teacher->update(['consecutive_absences' => 0]);
        }
    }
}
