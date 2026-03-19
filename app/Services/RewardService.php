<?php

namespace App\Services;

use App\Models\Student;
use App\Models\Teacher;
use App\Models\User;
use App\Models\Wallet;
use App\Models\Transaction;
use App\Models\PayoutRequest;
use App\Models\Subscription;
use App\Models\Attendance;
use App\Models\Homework;
use App\Models\HomeworkSubmission;
use App\Models\TeacherRating;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class RewardService
{
    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    // =============================
    // STUDENT REWARDS (Module 10A)
    // =============================

    /**
     * Check and award Silver Badge — ≥80% on weekly test
     * Reward: ₹40 worth stationery credit
     */
    public function checkSilverBadge(int $studentId, float $scorePercent): ?array
    {
        if ($scorePercent < 80)
            return null;

        $student = Student::findOrFail($studentId);

        // Award ₹40 stationery credit
        $wallet = Wallet::firstOrCreate(['user_id' => $student->user_id], ['balance' => 0]);
        $wallet->increment('balance', 40);

        Transaction::create([
            'user_id' => $student->user_id,
            'amount' => 40,
            'type' => 'student_reward',
            'status' => 'completed',
            'description' => 'Silver Badge Reward — ₹40 stationery credit for scoring ≥80% on weekly test',
        ]);

        $this->notificationService->sendToUser(
            $student->user_id,
            '🥈 Silver Badge Earned!',
            'Congratulations! You scored ≥80% on the weekly test and earned a ₹40 stationery reward!',
            'silver_badge'
        );

        // Update batch if not already silver+
        if ($student->batch === 'bronze') {
            $student->update(['batch' => 'silver']);
        }

        return ['badge' => 'silver', 'reward' => 40, 'type' => 'stationery'];
    }

    /**
     * Check and award Gold Badge — 3 consecutive ≥80% weekly tests
     * Reward: ₹50 + Certificate
     */
    public function checkGoldBadge(int $studentId): ?array
    {
        $student = Student::findOrFail($studentId);

        if ($student->consecutive_high_scores < 3)
            return null;

        // Award ₹50 reward credit
        $wallet = Wallet::firstOrCreate(['user_id' => $student->user_id], ['balance' => 0]);
        $wallet->increment('balance', 50);

        Transaction::create([
            'user_id' => $student->user_id,
            'amount' => 50,
            'type' => 'student_reward',
            'status' => 'completed',
            'description' => 'Gold Badge Reward — ₹50 credit + Certificate for 3 consecutive ≥80% tests',
        ]);

        $student->update(['batch' => 'gold']);

        $this->notificationService->sendToUser(
            $student->user_id,
            '🥇 Gold Badge Earned!',
            'Outstanding! You scored ≥80% on 3 consecutive tests! You earned ₹50 + a Golden Student Award Certificate!',
            'gold_badge'
        );

        return ['badge' => 'gold', 'reward' => 50, 'certificate' => true, 'type' => 'reward_and_certificate'];
    }

    /**
     * Check homework consistency — 100% completion for 2 weeks
     * Makes student "Rival Batch Eligible"
     */
    public function checkHomeworkConsistency(int $studentId): bool
    {
        $twoWeeksAgo = Carbon::now()->subWeeks(2);

        $totalHomework = Homework::whereHas('submission', function ($q) use ($studentId) {
            $q->where('student_id', $studentId);
        })->where('created_at', '>=', $twoWeeksAgo)->count();

        $completedHomework = HomeworkSubmission::where('student_id', $studentId)
            ->where('status', 'completed')
            ->where('created_at', '>=', $twoWeeksAgo)
            ->count();

        if ($totalHomework > 0 && $completedHomework >= $totalHomework) {
            $student = Student::find($studentId);
            $this->notificationService->sendToUser(
                $student->user_id,
                '📚 Rival Batch Eligible!',
                'Amazing homework consistency! You completed 100% homework for 2 weeks. You are now eligible for the Rival Batch!',
                'rival_batch_eligible'
            );
            return true;
        }

        return false;
    }

    // =============================
    // TEACHER REWARDS (Module 10B)
    // =============================

    /**
     * Evaluate Teacher Hero Badge
     * Criteria: ≥4 star rating + 100% attendance over 2-month cycle
     */
    public function evaluateTeacherHeroBadge(int $teacherId): ?array
    {
        $teacher = Teacher::findOrFail($teacherId);

        // Check rating ≥ 4
        $avgRating = TeacherRating::where('teacher_id', $teacherId)->avg('rating') ?? 0;
        if ($avgRating < 4)
            return null;

        // Check 100% attendance in last 2 months
        $twoMonthsAgo = Carbon::now()->subMonths(2);
        $totalDays = Attendance::where('teacher_id', $teacherId)
            ->where('date', '>=', $twoMonthsAgo)
            ->count();
        $presentDays = Attendance::where('teacher_id', $teacherId)
            ->where('date', '>=', $twoMonthsAgo)
            ->where('status', 'present')
            ->count();

        if ($totalDays === 0 || $presentDays < $totalDays)
            return null;

        // Award Hero Badge
        $wallet = Wallet::firstOrCreate(['user_id' => $teacher->user_id], ['balance' => 0]);
        $wallet->increment('balance', 500); // ₹500 hero badge reward

        Transaction::create([
            'user_id' => $teacher->user_id,
            'amount' => 500,
            'type' => 'hero_badge',
            'status' => 'completed',
            'description' => 'Hero Teacher Badge — ₹500 reward for ≥4 star rating + 100% attendance over 2 months',
        ]);

        $this->notificationService->sendToUser(
            $teacher->user_id,
            '🏆 Hero Teacher Badge Earned!',
            'Congratulations! You maintained ≥4 star rating and 100% attendance for 2 months! ₹500 reward credited!',
            'hero_badge'
        );

        return ['badge' => 'hero_teacher', 'reward' => 500, 'rating' => round($avgRating, 2)];
    }

    /**
     * Get teacher leaderboard (ranked by rating)
     */
    public function getLeaderboard(int $limit = 20): array
    {
        $teachers = Teacher::where('is_verified', true)
            ->where('disqualification_status', 'active')
            ->withCount('ratings')
            ->get()
            ->map(function ($teacher) {
            $avgRating = $teacher->ratings_count > 0
                ?TeacherRating::where('teacher_id', $teacher->id)->avg('rating')
                : 0;

            $totalStudents = Subscription::where('teacher_id', $teacher->id)
                ->where('status', 'active')
                ->count();

            return [
            'teacher_id' => $teacher->id,
            'name' => $teacher->user->name ?? 'Unknown',
            'avg_rating' => round($avgRating, 2),
            'total_ratings' => $teacher->ratings_count,
            'total_students' => $totalStudents,
            'experience_years' => $teacher->experience_years,
            ];
        })
            ->sortByDesc('avg_rating')
            ->values()
            ->take($limit)
            ->toArray();

        return $teachers;
    }

    /**
     * Reward teacher for scoring high on weekly test (legacy)
     */
    public function rewardTeacher(int $teacherId, float $amount, string $reason): void
    {
        $teacher = Teacher::find($teacherId);
        if (!$teacher)
            return;

        $wallet = Wallet::firstOrCreate(['user_id' => $teacher->user_id], ['balance' => 0]);
        $wallet->increment('balance', $amount);

        Transaction::create([
            'user_id' => $teacher->user_id,
            'amount' => $amount,
            'type' => 'admin_reward',
            'status' => 'completed',
            'description' => $reason,
        ]);

        $this->notificationService->sendToUser(
            $teacher->user_id,
            'Reward Received!',
            "You received a ₹{$amount} reward! Reason: {$reason}",
            'teacher_reward'
        );
    }

    /**
     * Request payout from wallet
     */
    public function requestPayout(int $userId, float $amount): PayoutRequest
    {
        $wallet = Wallet::where('user_id', $userId)->firstOrFail();

        if ($wallet->balance < $amount) {
            throw new \Exception('Insufficient wallet balance.');
        }

        $wallet->decrement('balance', $amount);

        return PayoutRequest::create([
            'user_id' => $userId,
            'amount' => $amount,
            'status' => 'pending',
        ]);
    }

    /**
     * Get pending rewards for admin
     */
    public function getPendingRewards()
    {
        return PayoutRequest::where('status', 'pending')
            ->with('user')
            ->orderByDesc('created_at')
            ->get();
    }
}
