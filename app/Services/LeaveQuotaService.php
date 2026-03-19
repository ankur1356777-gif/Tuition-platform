<?php

namespace App\Services;

use App\Models\TeacherLeave;
use Carbon\Carbon;

class LeaveQuotaService
{
    const MAX_PAID_LEAVES_PER_MONTH = 3;

    /**
     * Get count of leaves taken in the current month
     */
    public function getLeaveCountInMonth(int $teacherId): int
    {
        $startOfMonth = Carbon::now()->startOfMonth();
        $endOfMonth = Carbon::now()->endOfMonth();

        return TeacherLeave::where('teacher_id', $teacherId)
            ->whereBetween('start_date', [$startOfMonth, $endOfMonth])
            ->whereIn('status', ['approved', 'pending'])
            ->count();
    }

    /**
     * Check if teacher can take auto-approved leave (first 3 in month)
     */
    public function canAutoApprove(int $teacherId): bool
    {
        return $this->getLeaveCountInMonth($teacherId) < self::MAX_PAID_LEAVES_PER_MONTH;
    }

    /**
     * Apply for leave with quota validation
     */
    public function applyLeave(int $teacherId, string $startDate, string $endDate, ?string $reason = null, ?int $studentId = null): array
    {
        $canAutoApprove = $this->canAutoApprove($teacherId);

        // If exceeding quota, reason is mandatory
        if (!$canAutoApprove && empty($reason)) {
            return [
                'success' => false,
                'message' => 'You have exceeded your paid leave quota (3 leaves per month). Please provide a reason for your leave request.',
                'requires_reason' => true,
            ];
        }

        $leave = TeacherLeave::create([
            'teacher_id' => $teacherId,
            'start_date' => $startDate,
            'end_date' => $endDate,
            'reason' => $reason,
            'status' => $canAutoApprove ? 'approved' : 'pending',
            'leave_type' => $canAutoApprove ? 'auto' : 'requested',
            'approved_at' => $canAutoApprove ? now() : null,
            'is_student_specific' => $studentId ? true : false,
            'student_id' => $studentId,
        ]);

        // If beyond 3 leaves and temp teachers available, send notification
        if (!$canAutoApprove) {
            $this->notifyTemporaryTeachers($teacherId);
        }

        return [
            'success' => true,
            'leave' => $leave,
            'auto_approved' => $canAutoApprove,
            'message' => $canAutoApprove
            ? 'Leave has been auto-approved (paid leave).'
            : 'Leave request submitted. Temporary teachers have been notified. Awaiting admin approval.',
        ];
    }

    /**
     * Notify available temporary teachers for substitution
     */
    private function notifyTemporaryTeachers(int $teacherId): void
    {
        $teacher = \App\Models\Teacher::find($teacherId);
        if (!$teacher)
            return;

        $tempTeachers = \App\Models\Teacher::where('id', '!=', $teacherId)
            ->where('temporary_available', true)
            ->where('is_verified', true)
            ->where('is_available', true)
            ->whereRaw('allocated_houses < daily_capacity')
            ->get();

        $notificationService = app(NotificationService::class);
        foreach ($tempTeachers as $temp) {
            $notificationService->sendToUser(
                $temp->user_id,
                'Temporary Substitution Available',
                "A teacher needs a substitute. If you accept, you'll earn that day's commission for their students.",
                'temp_substitution'
            );
        }
    }

    /**
     * Get remaining paid leaves for teacher in current month
     */
    public function getRemainingPaidLeaves(int $teacherId): int
    {
        $used = $this->getLeaveCountInMonth($teacherId);
        return max(0, self::MAX_PAID_LEAVES_PER_MONTH - $used);
    }

    /**
     * Get full leave quota status
     */
    public function getLeaveQuotaStatus(int $teacherId): array
    {
        $used = $this->getLeaveCountInMonth($teacherId);
        $remaining = max(0, self::MAX_PAID_LEAVES_PER_MONTH - $used);

        return [
            'total_paid_leaves' => self::MAX_PAID_LEAVES_PER_MONTH,
            'used_this_month' => $used,
            'remaining' => $remaining,
            'can_auto_approve' => $remaining > 0,
            'month' => Carbon::now()->format('F Y'),
        ];
    }
}
