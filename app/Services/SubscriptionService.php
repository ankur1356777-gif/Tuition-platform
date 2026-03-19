<?php

namespace App\Services;

use App\Models\Subscription;
use App\Models\Student;
use App\Models\Teacher;
use App\Models\User;
use App\Models\Transaction;
use App\Models\Wallet;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class SubscriptionService
{
    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    /**
     * Get fee structure for a given class
     */
    public function getFeeByClass(string $class): array
    {
        return Subscription::getFeeForClass($class);
    }

    /**
     * Calculate parent relief for multiple students under same teacher
     */
    public function calculateParentRelief(int $parentUserId, int $teacherId): array
    {
        $activeSubscriptions = Subscription::where('parent_user_id', $parentUserId)
            ->where('teacher_id', $teacherId)
            ->where('status', 'active')
            ->with('student')
            ->get();

        if ($activeSubscriptions->count() <= 1) {
            return ['relief_applicable' => false, 'total_fee' => $activeSubscriptions->sum('monthly_fee')];
        }

        // Sort by fee descending — highest pays full, rest pay ₹2000
        $sorted = $activeSubscriptions->sortByDesc('monthly_fee');
        $totalFee = 0;
        $totalRelief = 0;
        $details = [];

        foreach ($sorted->values() as $index => $sub) {
            if ($index === 0) {
                // Highest class student pays full fee
                $fee = $sub->monthly_fee;
                $details[] = ['student_id' => $sub->student_id, 'fee' => $fee, 'relief' => false];
            }
            else {
                // All others pay ₹2000 flat
                $originalFee = $sub->monthly_fee;
                $fee = Subscription::PARENT_RELIEF_FEE;
                $relief = $originalFee - $fee;
                $totalRelief += max(0, $relief);
                $details[] = ['student_id' => $sub->student_id, 'fee' => $fee, 'relief' => true, 'saved' => max(0, $relief)];
            }
            $totalFee += $fee;
        }

        return [
            'relief_applicable' => true,
            'total_fee' => $totalFee,
            'total_relief' => $totalRelief,
            'details' => $details,
        ];
    }

    /**
     * Calculate pro-rata fee for mid-cycle joining
     */
    public function calculateProRata(float $monthlyFee, Carbon $joinDate, int $billingCycleDate): array
    {
        $daysInMonth = $joinDate->daysInMonth;
        $nextBillingDate = $joinDate->copy()->day($billingCycleDate);

        if ($nextBillingDate->lte($joinDate)) {
            $nextBillingDate->addMonth();
        }

        $remainingDays = $joinDate->diffInDays($nextBillingDate);

        if ($remainingDays >= $daysInMonth) {
            return ['pro_rata_fee' => $monthlyFee, 'remaining_days' => $daysInMonth, 'full_month' => true];
        }

        $dailyRate = $monthlyFee / $daysInMonth;
        $proRataFee = round($dailyRate * $remainingDays, 2);

        return [
            'pro_rata_fee' => $proRataFee,
            'daily_rate' => round($dailyRate, 2),
            'remaining_days' => $remainingDays,
            'days_in_month' => $daysInMonth,
            'next_billing_date' => $nextBillingDate->toDateString(),
            'full_month' => false,
        ];
    }

    /**
     * Activate subscription after demo + payment
     */
    public function activateSubscription(int $studentId, int $teacherId, ?int $parentUserId = null): Subscription
    {
        $student = Student::findOrFail($studentId);
        $feeInfo = $this->getFeeByClass($student->class);
        $startDate = Carbon::today();
        $billingCycleDate = $startDate->day;

        $subscription = Subscription::create([
            'parent_user_id' => $parentUserId,
            'student_id' => $studentId,
            'teacher_id' => $teacherId,
            'class_category' => Subscription::getClassCategory($student->class),
            'monthly_fee' => $feeInfo['total_fee'],
            'teacher_commission' => $feeInfo['teacher_commission'],
            'platform_fee' => Subscription::PLATFORM_FEE,
            'billing_cycle_date' => $billingCycleDate,
            'start_date' => $startDate,
            'next_payment_due' => $startDate->copy()->addMonth(),
            'status' => 'active',
        ]);

        // Apply parent relief if applicable
        if ($parentUserId) {
            $this->applyParentRelief($parentUserId, $teacherId);
        }

        // Update teacher allocated houses
        $teacher = Teacher::find($teacherId);
        if ($teacher) {
            $teacher->increment('allocated_houses');
            $teacher->increment('total_students');
            if ($teacher->allocated_houses >= $teacher->daily_capacity) {
                $teacher->update(['is_available' => false]);
            }
        }

        return $subscription;
    }

    /**
     * Apply parent relief across all subscriptions for a parent+teacher combo
     */
    public function applyParentRelief(int $parentUserId, int $teacherId): void
    {
        $subscriptions = Subscription::where('parent_user_id', $parentUserId)
            ->where('teacher_id', $teacherId)
            ->where('status', 'active')
            ->orderByDesc('monthly_fee')
            ->get();

        if ($subscriptions->count() <= 1)
            return;

        foreach ($subscriptions->values() as $index => $sub) {
            if ($index === 0) {
                $sub->update(['parent_relief_applied' => false, 'relief_amount' => 0]);
            }
            else {
                $originalFee = Subscription::FEE_STRUCTURE[$sub->class_category]['total_fee'];
                $reliefAmount = max(0, $originalFee - Subscription::PARENT_RELIEF_FEE);
                $sub->update([
                    'monthly_fee' => Subscription::PARENT_RELIEF_FEE,
                    'teacher_commission' => Subscription::PARENT_RELIEF_FEE - Subscription::PLATFORM_FEE,
                    'parent_relief_applied' => true,
                    'relief_amount' => $reliefAmount,
                ]);
            }
        }
    }

    /**
     * Deactivate student subscription on non-payment
     */
    public function deactivateStudent(int $subscriptionId): void
    {
        $subscription = Subscription::findOrFail($subscriptionId);
        $subscription->update(['status' => 'cancelled', 'end_date' => Carbon::today()]);

        // Decrease teacher allocated houses
        $teacher = Teacher::find($subscription->teacher_id);
        if ($teacher) {
            $teacher->decrement('allocated_houses');
            $teacher->decrement('total_students');
            if ($teacher->allocated_houses < $teacher->daily_capacity) {
                $teacher->update(['is_available' => true]);
            }
        }

        $this->notificationService->sendToUser(
            $subscription->student->user_id,
            'Subscription Deactivated',
            'Your subscription has been deactivated due to non-payment. Please contact support.',
            'subscription_deactivated'
        );
    }

    /**
     * Change teacher for a subscription
     */
    public function changeTeacher(int $subscriptionId, int $newTeacherId, string $reason): Subscription
    {
        $subscription = Subscription::findOrFail($subscriptionId);
        $oldTeacherId = $subscription->teacher_id;

        // Update teacher counts
        $oldTeacher = Teacher::find($oldTeacherId);
        if ($oldTeacher) {
            $oldTeacher->decrement('allocated_houses');
            $oldTeacher->decrement('total_students');
            if ($oldTeacher->allocated_houses < $oldTeacher->daily_capacity) {
                $oldTeacher->update(['is_available' => true]);
            }
        }

        $newTeacher = Teacher::find($newTeacherId);
        if ($newTeacher) {
            $newTeacher->increment('allocated_houses');
            $newTeacher->increment('total_students');
            if ($newTeacher->allocated_houses >= $newTeacher->daily_capacity) {
                $newTeacher->update(['is_available' => false]);
            }
        }

        $subscription->update(['teacher_id' => $newTeacherId]);

        // Notify old teacher
        $this->notificationService->sendToUser(
            $oldTeacher->user_id ?? 0,
            'Student Removed',
            "A student has been reassigned. Reason: {$reason}",
            'student_removed'
        );

        return $subscription;
    }
}
