<?php

namespace App\Services;

use App\Models\Student;
use App\Models\TestResult;
use App\Models\Teacher;
use App\Models\Wallet;
use App\Models\Transaction;

class BatchUpgradeService
{
    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    /**
     * Process a test result and check for batch upgrade
     */
    public function processTestResult(TestResult $result)
    {
        $student = $result->student;
        $percentage = $result->percentage;

        if (!$student) {
            return null;
        }

        // Record the test score and check for upgrade
        $newBatch = $student->recordTestScore($percentage);

        if ($newBatch) {
            // Notify student about batch upgrade
            $this->notifyBatchUpgrade($student, $newBatch);
            
            // Notify admin about batch upgrade
            $this->notifyAdminBatchUpgrade($student, $newBatch);
        }

        return $newBatch;
    }

    /**
     * Check for 80%+ and trigger teacher reward
     */
    public function checkTeacherReward(TestResult $result)
    {
        if ($result->percentage >= 80 && $result->test && $result->test->is_weekly_test) {
            // Flag this result for admin to reward teacher
            $result->rewards = json_encode([
                'eligible' => true,
                'reason' => 'Student scored 80%+ in weekly test',
                'test_id' => $result->test_id,
                'percentage' => $result->percentage,
            ]);
            $result->save();

            return true;
        }

        return false;
    }

    /**
     * Manually upgrade student batch (admin action)
     */
    public function manualUpgrade(Student $student, string $newBatch)
    {
        $oldBatch = $student->batch;
        $student->batch = $newBatch;
        $student->consecutive_high_scores = 0;
        $student->save();

        // Notify student
        $this->notifyBatchUpgrade($student, $newBatch);

        return [
            'old_batch' => $oldBatch,
            'new_batch' => $newBatch,
        ];
    }

    /**
     * Notify student about batch upgrade
     */
    protected function notifyBatchUpgrade(Student $student, string $newBatch)
    {
        $batchNames = [
            'bronze' => 'Bronze',
            'silver' => 'Silver',
            'gold' => 'Gold',
        ];

        $title = 'Congratulations! Batch Upgrade';
        $message = "You have been upgraded to the {$batchNames[$newBatch]} batch for your excellent performance!";

        if ($student->user) {
            $this->notificationService->sendToUser(
                $student->user->id,
                $title,
                $message,
                'batch_upgrade'
            );
        }
    }

    /**
     * Notify admin about batch upgrade
     */
    protected function notifyAdminBatchUpgrade(Student $student, string $newBatch)
    {
        // Log for admin visibility
        \Log::info("Student batch upgrade", [
            'student_id' => $student->id,
            'student_name' => $student->user->name ?? 'Unknown',
            'new_batch' => $newBatch,
        ]);
    }
}
