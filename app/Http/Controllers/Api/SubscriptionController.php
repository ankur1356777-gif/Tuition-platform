<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Subscription;
use App\Models\Student;
use App\Models\Teacher;
use App\Services\SubscriptionService;
use App\Services\DemoService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class SubscriptionController extends Controller
{
    protected $subscriptionService;
    protected $demoService;

    public function __construct(SubscriptionService $subscriptionService, DemoService $demoService)
    {
        $this->subscriptionService = $subscriptionService;
        $this->demoService = $demoService;
    }

    /**
     * Get fee structure for a class
     */
    public function getFeeStructure(Request $request)
    {
        $class = $request->query('class', 'nursery');
        $feeInfo = $this->subscriptionService->getFeeByClass($class);
        $category = Subscription::getClassCategory($class);

        return response()->json([
            'class' => $class,
            'category' => $category,
            'fee_structure' => $feeInfo,
            'platform_fee' => Subscription::PLATFORM_FEE,
            'all_fees' => Subscription::FEE_STRUCTURE,
        ]);
    }

    /**
     * Calculate parent relief
     */
    public function calculateRelief(Request $request)
    {
        $user = Auth::user();
        $validator = Validator::make($request->all(), [
            'teacher_id' => 'required|exists:teachers,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $relief = $this->subscriptionService->calculateParentRelief($user->id, $request->teacher_id);
        return response()->json($relief);
    }

    /**
     * Calculate pro-rata fee
     */
    public function calculateProRata(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'class' => 'required|string',
            'join_date' => 'required|date',
            'billing_cycle_date' => 'required|integer|min:1|max:31',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $feeInfo = $this->subscriptionService->getFeeByClass($request->class);
        $proRata = $this->subscriptionService->calculateProRata(
            $feeInfo['total_fee'],
            \Carbon\Carbon::parse($request->join_date),
            $request->billing_cycle_date
        );

        return response()->json($proRata);
    }

    /**
     * Activate subscription (after demo + payment)
     */
    public function activate(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'student_id' => 'required|exists:students,id',
            'teacher_id' => 'required|exists:teachers,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $parentUserId = Auth::id();
        $subscription = $this->subscriptionService->activateSubscription(
            $request->student_id,
            $request->teacher_id,
            $parentUserId
        );

        return response()->json([
            'message' => 'Subscription activated successfully.',
            'subscription' => $subscription,
        ]);
    }

    /**
     * Get active subscriptions for parent
     */
    public function getParentSubscriptions()
    {
        $subscriptions = Subscription::where('parent_user_id', Auth::id())
            ->with(['student.user', 'teacher.user'])
            ->orderByDesc('created_at')
            ->get();

        return response()->json($subscriptions);
    }

    /**
     * Get all subscriptions for a student
     */
    public function getStudentSubscription()
    {
        $user = Auth::user();
        $student = Student::where('user_id', $user->id)->first();

        if (!$student) {
            return response()->json(['message' => 'Student profile not found'], 404);
        }

        $subscription = Subscription::where('student_id', $student->id)
            ->where('status', 'active')
            ->with(['teacher.user'])
            ->first();

        return response()->json($subscription);
    }

    /**
     * Change teacher for subscription
     */
    public function changeTeacher(Request $request, $subscriptionId)
    {
        $validator = Validator::make($request->all(), [
            'new_teacher_id' => 'required|exists:teachers,id',
            'reason' => 'required|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $subscription = $this->subscriptionService->changeTeacher(
            $subscriptionId,
            $request->new_teacher_id,
            $request->reason
        );

        return response()->json([
            'message' => 'Teacher changed successfully.',
            'subscription' => $subscription,
        ]);
    }

    /**
     * Deactivate subscription
     */
    public function deactivate($subscriptionId)
    {
        $this->subscriptionService->deactivateStudent($subscriptionId);
        return response()->json(['message' => 'Subscription deactivated.']);
    }

    // === DEMO CLASS ENDPOINTS ===

    /**
     * Request a free demo class
     */
    public function requestDemo(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'student_id' => 'required|exists:students,id',
            'teacher_id' => 'required|exists:teachers,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $demo = $this->demoService->startDemo(
            $request->student_id,
            $request->teacher_id,
            $request->tuition_request_id
        );

        return response()->json([
            'message' => 'Free demo class started! It will last for 3 days.',
            'demo' => $demo,
        ]);
    }

    /**
     * Change teacher during demo
     */
    public function changeDemoTeacher(Request $request, $demoId)
    {
        $validator = Validator::make($request->all(), [
            'reason' => 'required|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $demo = $this->demoService->changeTeacher($demoId, $request->reason);
        return response()->json([
            'message' => 'Teacher changed for demo class.',
            'demo' => $demo,
        ]);
    }

    /**
     * Teacher confirms demo visit
     */
    public function confirmDemoVisit(Request $request, $demoId)
    {
        $demo = $this->demoService->confirmVisit($demoId, $request->all());
        return response()->json([
            'message' => 'Visit details confirmed.',
            'demo' => $demo,
        ]);
    }

    /**
     * Parent confirms changed details
     */
    public function parentConfirmDemo(Request $request, $demoId)
    {
        $demo = $this->demoService->parentConfirmDetails($demoId, $request->all());
        return response()->json([
            'message' => 'Details confirmed by parent.',
            'demo' => $demo,
        ]);
    }
}
