<?php

namespace App\Services;

use App\Models\User;
use App\Models\PaidTuition;
use App\Models\Transaction;
use App\Models\CommissionSetting;
use App\Models\Wallet;
use App\Models\Subscription;
use App\Models\Agent;
use App\Models\Teacher;
use App\Models\TeacherLeave;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class CommissionService
{
    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    /**
     * Calculate teacher commission based on fixed platform fee model
     * Commission = Total Fee - ₹1000 platform fee
     */
    public function calculateTeacherCommission(string $classCategory, bool $parentReliefApplied = false): float
    {
        if ($parentReliefApplied) {
            return Subscription::PARENT_RELIEF_FEE - Subscription::PLATFORM_FEE; // ₹2000 - ₹1000 = ₹1000
        }

        $feeStructure = Subscription::FEE_STRUCTURE[$classCategory] ?? Subscription::FEE_STRUCTURE['nursery_kg'];
        return $feeStructure['teacher_commission'];
    }

    /**
     * Calculate daily commission
     * Formula: Monthly Commission ÷ Total Days in Month
     */
    public function calculateDailyCommission(float $monthlyCommission, ?Carbon $date = null): float
    {
        $date = $date ?? Carbon::now();
        $daysInMonth = $date->daysInMonth;
        return round($monthlyCommission / $daysInMonth, 2);
    }

    /**
     * Apply leave deduction for teacher
     * Deduction = Daily commission for that student
     */
    public function applyLeaveDeduction(int $teacherId, int $studentId, Carbon $date): float
    {
        $subscription = Subscription::where('teacher_id', $teacherId)
            ->where('student_id', $studentId)
            ->where('status', 'active')
            ->first();

        if (!$subscription)
            return 0;

        $dailyCommission = $this->calculateDailyCommission($subscription->teacher_commission, $date);

        // Deduct from teacher wallet
        $wallet = Wallet::firstOrCreate(['user_id' => Teacher::find($teacherId)->user_id], ['balance' => 0]);
        $wallet->decrement('balance', $dailyCommission);

        Transaction::create([
            'user_id' => $wallet->user_id,
            'amount' => -$dailyCommission,
            'type' => 'leave_deduction',
            'status' => 'completed',
            'description' => "Leave deduction for student #{$studentId} on {$date->toDateString()}",
        ]);

        return $dailyCommission;
    }

    /**
     * Apply penalty for absence without approval
     * Penalty = 1 Day Commission + 5% Inconvenience Charge
     */
    public function applyAbsencePenalty(int $teacherId, int $studentId, Carbon $date): float
    {
        $subscription = Subscription::where('teacher_id', $teacherId)
            ->where('student_id', $studentId)
            ->where('status', 'active')
            ->first();

        if (!$subscription)
            return 0;

        $dailyCommission = $this->calculateDailyCommission($subscription->teacher_commission, $date);
        $inconvenienceCharge = $dailyCommission * 0.05;
        $totalPenalty = $dailyCommission + $inconvenienceCharge;

        $teacher = Teacher::find($teacherId);
        $wallet = Wallet::firstOrCreate(['user_id' => $teacher->user_id], ['balance' => 0]);
        $wallet->decrement('balance', $totalPenalty);

        Transaction::create([
            'user_id' => $wallet->user_id,
            'amount' => -$totalPenalty,
            'type' => 'absence_penalty',
            'status' => 'completed',
            'description' => "Absence penalty for student #{$studentId}: ₹{$dailyCommission} + 5% inconvenience ₹{$inconvenienceCharge}",
        ]);

        $this->notificationService->sendToUser(
            $teacher->user_id,
            'Absence Penalty Applied',
            "A penalty of ₹{$totalPenalty} has been deducted for unauthorized absence on {$date->toDateString()}.",
            'absence_penalty'
        );

        return $totalPenalty;
    }

    /**
     * Distribute monthly teacher salary (1st of every month)
     */
    public function distributeMonthlyTeacherSalary(int $teacherId): array
    {
        $teacher = Teacher::findOrFail($teacherId);
        $subscriptions = Subscription::where('teacher_id', $teacherId)
            ->where('status', 'active')
            ->get();

        $totalCommission = $subscriptions->sum('teacher_commission');

        // Calculate leave deductions for the month
        $monthStart = Carbon::now()->startOfMonth();
        $leaveDeductions = Transaction::where('user_id', $teacher->user_id)
            ->whereIn('type', ['leave_deduction', 'absence_penalty'])
            ->where('created_at', '>=', $monthStart)
            ->sum('amount');

        $netSalary = $totalCommission + $leaveDeductions; // deductions are negative

        // Credit to wallet
        $wallet = Wallet::firstOrCreate(['user_id' => $teacher->user_id], ['balance' => 0]);
        $wallet->increment('balance', max(0, $netSalary));

        Transaction::create([
            'user_id' => $teacher->user_id,
            'amount' => max(0, $netSalary),
            'type' => 'monthly_salary',
            'status' => 'completed',
            'description' => "Monthly salary for " . Carbon::now()->format('F Y'),
        ]);

        return [
            'total_commission' => $totalCommission,
            'leave_deductions' => abs($leaveDeductions),
            'net_salary' => max(0, $netSalary),
            'students' => $subscriptions->count(),
        ];
    }

    /**
     * Distribute referral commission — ₹300 flat per successful student
     */
    public function distributeReferralCommission(int $referredStudentUserId): void
    {
        $student = User::find($referredStudentUserId);
        if (!$student || !$student->referred_by)
            return;

        $referrer = User::find($student->referred_by);
        if (!$referrer)
            return;

        DB::transaction(function () use ($referrer, $student) {
            // Give ₹300 to direct referrer
            $wallet = Wallet::firstOrCreate(['user_id' => $referrer->id], ['balance' => 0]);
            $wallet->increment('balance', 300);

            Transaction::create([
                'user_id' => $referrer->id,
                'amount' => 300,
                'type' => 'referral_commission',
                'status' => 'completed',
                'description' => "Referral commission for student: {$student->name}",
            ]);

            $this->notificationService->sendToUser(
                $referrer->id,
                'Referral Commission Earned',
                "You earned ₹300 for referring {$student->name}!",
                'referral_commission'
            );

            // Check if referrer is under a Parent Referrer — Level 1 override
            if ($referrer->referred_by) {
                $parentReferrer = User::find($referrer->referred_by);
                if ($parentReferrer) {
                    $agent = Agent::where('user_id', $parentReferrer->id)->first();
                    if ($agent && $agent->referrer_type === 'parent') {
                        // Give ₹200 override commission to Parent Referrer
                        $parentWallet = Wallet::firstOrCreate(['user_id' => $parentReferrer->id], ['balance' => 0]);
                        $parentWallet->increment('balance', 200);

                        Transaction::create([
                            'user_id' => $parentReferrer->id,
                            'amount' => 200,
                            'type' => 'referral_override',
                            'status' => 'completed',
                            'description' => "Level-1 override from referrer {$referrer->name} for student {$student->name}",
                        ]);

                        $this->notificationService->sendToUser(
                            $parentReferrer->id,
                            'Override Commission Earned',
                            "You earned ₹200 override commission from your referrer {$referrer->name}'s referral!",
                            'referral_override'
                        );
                    }
                }
            }
        });
    }

    /**
     * Legacy: Distribute commission for a new paid tuition (kept for backward compatibility)
     */
    public function distributeTuitionCommission(PaidTuition $paidTuition)
    {
        DB::beginTransaction();
        try {
            $student = $paidTuition->student->user;
            $agentId = $student->referred_by;

            if ($agentId) {
                $this->distributeReferralCommission($student->id);
            }

            DB::commit();
        }
        catch (\Exception $e) {
            DB::rollBack();
            \Log::error('Commission distribution failed: ' . $e->getMessage());
        }
    }
}
