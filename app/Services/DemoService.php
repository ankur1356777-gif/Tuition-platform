<?php

namespace App\Services;

use App\Models\DemoClass;
use App\Models\Student;
use App\Models\Teacher;
use App\Models\TuitionRequest;
use Carbon\Carbon;

class DemoService
{
    protected $matchingService;
    protected $notificationService;

    public function __construct(MatchingService $matchingService, NotificationService $notificationService)
    {
        $this->matchingService = $matchingService;
        $this->notificationService = $notificationService;
    }

    /**
     * Start a free demo class (3 days)
     */
    public function startDemo(int $studentId, int $teacherId, ?int $tuitionRequestId = null): DemoClass
    {
        $startDate = Carbon::today();
        $endDate = $startDate->copy()->addDays(3);

        $demo = DemoClass::create([
            'student_id' => $studentId,
            'teacher_id' => $teacherId,
            'tuition_request_id' => $tuitionRequestId,
            'status' => 'demo_active',
            'demo_start_date' => $startDate,
            'demo_end_date' => $endDate,
            'scheduled_date' => $startDate,
        ]);

        // Notify teacher
        $student = Student::with('user')->find($studentId);
        $this->notificationService->sendToUser(
            Teacher::find($teacherId)->user_id,
            'New Demo Class Assigned',
            "You have been assigned a 3-day demo class with {$student->user->name}.",
            'demo_assigned'
        );

        // Notify student
        $this->notificationService->sendToUser(
            $student->user_id,
            'Demo Class Started',
            'Your free demo class has been started! It will last for 3 days.',
            'demo_started'
        );

        return $demo;
    }

    /**
     * Change teacher during demo
     */
    public function changeTeacher(int $demoId, string $reason): DemoClass
    {
        $demo = DemoClass::findOrFail($demoId);
        $oldTeacherId = $demo->teacher_id;
        $student = Student::with('user')->find($demo->student_id);

        // Find a new teacher via matching
        $tuitionRequest = $demo->tuitionRequest;
        if ($tuitionRequest) {
            $matchedTeachers = $this->matchingService->findMatchingTeachers($tuitionRequest, 5);
            $newTeacher = $matchedTeachers->where('id', '!=', $oldTeacherId)->first();
        }
        else {
            $newTeacher = Teacher::where('id', '!=', $oldTeacherId)
                ->where('is_available', true)
                ->where('is_verified', true)
                ->inRandomOrder()
                ->first();
        }

        if (!$newTeacher) {
            throw new \Exception('No available teacher found for replacement.');
        }

        $demo->update([
            'teacher_id' => $newTeacher->id,
            'change_reason' => $reason,
            'change_count' => $demo->change_count + 1,
        ]);

        // Notify old teacher
        $oldTeacher = Teacher::find($oldTeacherId);
        if ($oldTeacher) {
            $this->notificationService->sendToUser(
                $oldTeacher->user_id,
                'Demo Class Reassigned',
                "The demo class has been reassigned to another teacher. Reason: {$reason}",
                'demo_reassigned'
            );
        }

        // Notify new teacher
        $this->notificationService->sendToUser(
            $newTeacher->user_id,
            'New Demo Class Assigned',
            "You have been assigned a demo class with {$student->user->name}.",
            'demo_assigned'
        );

        return $demo;
    }

    /**
     * Teacher confirms visit details
     */
    public function confirmVisit(int $demoId, array $confirmedData): DemoClass
    {
        $demo = DemoClass::findOrFail($demoId);
        $student = Student::find($demo->student_id);

        $hasChanges = false;
        if (isset($confirmedData['class']) && $confirmedData['class'] !== $student->class) {
            $hasChanges = true;
        }
        if (isset($confirmedData['address']) && $confirmedData['address'] !== $student->address) {
            $hasChanges = true;
        }

        if ($hasChanges) {
            // If teacher modifies data, parent must confirm
            $demo->update([
                'teacher_confirmed' => true,
                'parent_confirmed' => false,
            ]);

            // Notify parent/student to confirm changes
            $this->notificationService->sendToUser(
                $student->user_id,
                'Please Confirm Updated Details',
                'Your teacher has updated some class details during the demo visit. Please confirm the changes.',
                'confirm_details'
            );
        }
        else {
            // No changes — auto-confirm
            $demo->update([
                'teacher_confirmed' => true,
                'parent_confirmed' => true,
                'details_confirmed_at' => now(),
            ]);
        }

        return $demo;
    }

    /**
     * Parent confirms modified details
     */
    public function parentConfirmDetails(int $demoId, array $confirmedData): DemoClass
    {
        $demo = DemoClass::findOrFail($demoId);
        $student = Student::find($demo->student_id);

        // Update student details if changed
        if (isset($confirmedData['class'])) {
            $student->update(['class' => $confirmedData['class']]);
        }
        if (isset($confirmedData['address'])) {
            $student->update(['address' => $confirmedData['address']]);
        }

        $demo->update([
            'parent_confirmed' => true,
            'details_confirmed_at' => now(),
        ]);

        return $demo;
    }

    /**
     * Lock student's class for academic year
     */
    public function lockClass(int $studentId): void
    {
        Student::where('id', $studentId)->update([
            'class_locked' => true,
            'class_locked_at' => now(),
        ]);
    }

    /**
     * Complete demo and prompt payment
     */
    public function completeDemoAndPromptPayment(int $demoId): array
    {
        $demo = DemoClass::findOrFail($demoId);
        $demo->update(['status' => 'completed']);

        // Lock the class
        $this->lockClass($demo->student_id);

        // Notify student/parent
        $student = Student::with('user')->find($demo->student_id);
        $feeInfo = \App\Models\Subscription::getFeeForClass($student->class);

        $this->notificationService->sendToUser(
            $student->user_id,
            'Demo Completed — Please Complete Payment',
            "Your 3-day demo has been completed. Please pay ₹{$feeInfo['total_fee']}/month to continue services.",
            'payment_required'
        );

        return [
            'demo' => $demo,
            'fee_info' => $feeInfo,
            'message' => 'Please complete payment to continue services.',
        ];
    }

    /**
     * Check and auto-complete expired demos
     */
    public function checkExpiredDemos(): int
    {
        $expiredDemos = DemoClass::where('status', 'demo_active')
            ->where('demo_end_date', '<=', Carbon::today())
            ->get();

        $count = 0;
        foreach ($expiredDemos as $demo) {
            $this->completeDemoAndPromptPayment($demo->id);
            $count++;
        }

        return $count;
    }
}
