<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Authentication Routes
Route::prefix("auth")->group(function () {
    Route::post("/send-otp", [App\Http\Controllers\Api\AuthController::class , "sendOTP"]);
    Route::post("/verify-otp", [App\Http\Controllers\Api\AuthController::class , "verifyOTP"]);
    Route::post("/register", [App\Http\Controllers\Api\AuthController::class , "register"]);
    Route::post("/login", [App\Http\Controllers\Api\AuthController::class , "loginWithPassword"]);
    Route::post("/verify-firebase", [App\Http\Controllers\Api\AuthController::class , "verifyFirebase"]);
});

// Set password (requires auth)
Route::middleware("auth:sanctum")->post("/auth/set-password", [App\Http\Controllers\Api\AuthController::class , "setPassword"]);


// Public Landing Data Routes
Route::prefix("public")->group(function () {
    Route::get("/landing", [App\Http\Controllers\Api\PublicController::class , "getLandingData"]);
    Route::post("/request-tuition", [App\Http\Controllers\Api\PublicController::class , "submitTuitionRequest"]);
    Route::get("/areas", [App\Http\Controllers\Api\PublicController::class , "getAreas"]);
    Route::get("/areas/search", [App\Http\Controllers\Api\AreaController::class , "search"]);
    Route::get("/ping", [App\Http\Controllers\Api\PingController::class , "ping"]);
});

// Protected Routes
Route::middleware("auth:sanctum")->group(function () {
    Route::post("/logout", [App\Http\Controllers\Api\AuthController::class , "logout"]);

    Route::prefix("profile")->group(function () {
            Route::get("/", [App\Http\Controllers\Api\ProfileController::class , "show"]);
            Route::post("/", [App\Http\Controllers\Api\ProfileController::class , "update"]);
            Route::post("/teacher", [App\Http\Controllers\Api\ProfileController::class , "updateTeacherProfile"]);
            Route::post("/student", [App\Http\Controllers\Api\ProfileController::class , "updateStudentProfile"]);
        }
        );

        Route::get("/user", function (Request $request) {
            return $request->user();
        }
        );

        // Admin Mobile APIs
        Route::middleware("role:admin")->prefix("admin")->group(function () {
            Route::get("/dashboard", [App\Http\Controllers\Api\AdminApiController::class , "dashboard"]);
            Route::post("/users/{id}/status", [App\Http\Controllers\Api\AdminApiController::class , "manageUserStatus"]);
            Route::get("/leads", [App\Http\Controllers\Api\AdminApiController::class , "leadsOverview"]);
            Route::get("/payouts", [App\Http\Controllers\Api\AdminApiController::class , "payoutRequests"]);
            Route::post("/payouts/{id}/approve", [App\Http\Controllers\Api\AdminApiController::class , "approvePayout"]);
            Route::get("/leaderboard", [App\Http\Controllers\Api\AdminApiController::class , "getLeaderboard"]);

            // Subscription/Fee Management (Module 5)
            Route::get("/subscriptions", [App\Http\Controllers\Api\SubscriptionController::class , "getParentSubscriptions"]); // Admin can see all
            Route::post("/subscriptions/{id}/deactivate", [App\Http\Controllers\Api\SubscriptionController::class , "deactivate"]);

            // Commission Settings
            Route::get("/commission-settings", [App\Http\Controllers\Api\AdminApiController::class , "getCommissionSettings"]);
            Route::post("/commission-settings", [App\Http\Controllers\Api\AdminApiController::class , "updateCommissionSettings"]);

            // Extended Management
            Route::get("/teachers", [App\Http\Controllers\Api\AdminApiController::class , "getAllTeachers"]);
            Route::get("/teachers/{id}", [App\Http\Controllers\Api\AdminApiController::class , "getTeacherDetails"]);

            Route::get("/students", [App\Http\Controllers\Api\AdminApiController::class , "getAllStudents"]);
            Route::get("/students/{id}", [App\Http\Controllers\Api\AdminApiController::class , "getStudentDetails"]);
            Route::post("/students/{id}/batch", [App\Http\Controllers\Api\AdminApiController::class , "updateStudentBatch"]);

            Route::get("/agents", [App\Http\Controllers\Api\AdminApiController::class , "getAllAgents"]);

            Route::get("/demos", [App\Http\Controllers\Api\AdminApiController::class , "getAllDemos"]);

            // Monitoring
            Route::get("/attendance-logs", [App\Http\Controllers\Api\AdminApiController::class , "getAttendanceLogs"]);

            // Notifications
            Route::post("/notifications/broadcast", [App\Http\Controllers\Api\NotificationController::class , "broadcast"]);
            Route::post("/notifications/send-test", [App\Http\Controllers\Api\NotificationController::class , "sendTest"]);

            // Document Verification
            Route::get("/documents/pending", [App\Http\Controllers\Api\DocumentController::class , "pending"]);
            Route::post("/documents/{id}/verify", [App\Http\Controllers\Api\DocumentController::class , "verify"]);

            // Lead Management
            Route::get("/leads/pending", [App\Http\Controllers\Api\AdminApiController::class , "getPendingLeads"]);
            Route::get("/leads/contact-requests", [App\Http\Controllers\Api\AdminApiController::class , "getContactRequests"]);
            Route::post("/leads/{id}/approve-contact", [App\Http\Controllers\Api\AdminApiController::class , "approveLeadContact"]);
            Route::post("/leads/{id}/reject-contact", [App\Http\Controllers\Api\AdminApiController::class , "rejectLeadContact"]);
            Route::post("/leads/{id}/schedule-demo", [App\Http\Controllers\Api\AdminApiController::class , "scheduleDemoFromLead"]);

            // Reward System
            Route::get("/rewards/pending", [App\Http\Controllers\Api\AdminApiController::class , "getPendingRewards"]);
            Route::post("/teachers/{id}/reward", [App\Http\Controllers\Api\AdminApiController::class , "rewardTeacher"]);

            // Teacher Feedback
            Route::get("/teacher-feedback", [App\Http\Controllers\Api\AdminApiController::class , "getTeacherFeedback"]);

            // Activity Monitoring
            Route::get("/homework", [App\Http\Controllers\Api\AdminApiController::class , "getAllHomework"]);
            Route::get("/teaching-plans", [App\Http\Controllers\Api\AdminApiController::class , "getAllTeachingPlans"]);

            // Leave Management
            Route::get("/leaves", [App\Http\Controllers\Api\AdminApiController::class , "getAllLeaves"]);
            Route::get("/leaves/pending", [App\Http\Controllers\Api\AdminApiController::class , "getPendingLeaves"]);
            Route::post("/leaves/{id}/approve", [App\Http\Controllers\Api\AdminApiController::class , "approveLeave"]);
            Route::post("/leaves/{id}/reject", [App\Http\Controllers\Api\AdminApiController::class , "rejectLeave"]);
        }
        );

        // Common Protected Routes
        Route::post("/documents/upload", [App\Http\Controllers\Api\DocumentController::class , "upload"]);
        Route::get("/documents", [App\Http\Controllers\Api\DocumentController::class , "index"]);

        // Payment Routes
        Route::post("/payments/initiate", [App\Http\Controllers\Api\PaymentController::class , "initiate"]);
        Route::post("/payments/verify", [App\Http\Controllers\Api\PaymentController::class , "verify"]);

        // Teacher APIs
        Route::middleware(["role:teacher", "approved"])->prefix("teacher")->group(function () {
            Route::get("/dashboard", [App\Http\Controllers\Api\TeacherController::class , "dashboard"]);
            Route::get("/leads", [App\Http\Controllers\Api\TeacherController::class , "getLeads"]);
            Route::get("/leads/limited", [App\Http\Controllers\Api\TeacherController::class , "getLeadsWithLimitedDetails"]);
            Route::get("/available-requirements", [App\Http\Controllers\Api\TeacherController::class , "getAvailableRequirements"]);
            Route::post("/requirements/{id}/interest", [App\Http\Controllers\Api\TeacherController::class , "expressInterest"]);
            Route::post("/leads/{id}/manage", [App\Http\Controllers\Api\TeacherController::class , "manageLeads"]);
            Route::post("/leads/{id}/request-contact", [App\Http\Controllers\Api\TeacherController::class , "requestStudentContact"]);
            Route::post("/attendance", [App\Http\Controllers\Api\TeacherController::class , "markAttendance"]);
            Route::post("/tests", [App\Http\Controllers\Api\TeacherController::class , "createTest"]);
            Route::get("/demos", [App\Http\Controllers\Api\TeacherController::class , "demoClasses"]);
            Route::get("/wallet", [App\Http\Controllers\Api\TeacherController::class , "walletHistory"]);
            Route::get("/wallet/rewards", [App\Http\Controllers\Api\TeacherController::class , "getWalletWithRewards"]);
            Route::post("/leaves", [App\Http\Controllers\Api\TeacherController::class , "applyLeave"]);
            Route::get("/leaves", [App\Http\Controllers\Api\TeacherController::class , "getLeaves"]);
            Route::get("/leaves/quota", [App\Http\Controllers\Api\TeacherController::class , "getLeaveQuotaStatus"]);
            Route::get("/tuitions", [App\Http\Controllers\Api\TeacherController::class , "getActiveTuitions"]);
            Route::post("/tuition/{id}/meeting", [App\Http\Controllers\Api\TeacherController::class , "updateMeetingId"]);

            // Certificates
            Route::get("/certificate/download", [App\Http\Controllers\Api\CertificateController::class , "downloadTeacherCertificate"]);

            // Homework Management
            Route::get("/homework", [App\Http\Controllers\Api\TeacherController::class , "getHomework"]);
            Route::post("/homework", [App\Http\Controllers\Api\TeacherController::class , "createHomework"]);
            Route::get("/homework/{id}/submissions", [App\Http\Controllers\Api\TeacherController::class , "getHomeworkSubmissions"]);
            Route::post("/homework/submissions/{id}/review", [App\Http\Controllers\Api\TeacherController::class , "reviewHomework"]);

            // Teaching Plans
            Route::get("/teaching-plans", [App\Http\Controllers\Api\TeacherController::class , "getTeachingPlans"]);
            Route::post("/teaching-plans", [App\Http\Controllers\Api\TeacherController::class , "createTeachingPlan"]);
            Route::put("/teaching-plans/{id}", [App\Http\Controllers\Api\TeacherController::class , "updateTeachingPlan"]);

            // Weekly Tests
            Route::get("/weekly-tests", [App\Http\Controllers\Api\TeacherController::class , "getWeeklyTests"]);
            Route::post("/weekly-tests", [App\Http\Controllers\Api\TeacherController::class , "scheduleWeeklyTest"]);

            // Demo confirmation (Module 4)
            Route::post("/demos/{id}/confirm-visit", [App\Http\Controllers\Api\SubscriptionController::class , "confirmDemoVisit"]);
        }
        );

        // Student/Parent APIs
        Route::middleware(["role:student", "approved"])->prefix("student")->group(function () {
            Route::get("/dashboard", [App\Http\Controllers\Api\StudentController::class , "dashboard"]);
            Route::post("/request", [App\Http\Controllers\Api\StudentController::class , "createRequest"]);
            Route::get("/attendance", [App\Http\Controllers\Api\StudentController::class , "viewAttendance"]);
            Route::get("/test-results", [App\Http\Controllers\Api\StudentController::class , "viewTestResults"]);
            Route::get("/payments", [App\Http\Controllers\Api\StudentController::class , "viewPaymentHistory"]);
            Route::post("/demos/{id}/feedback", [App\Http\Controllers\Api\StudentController::class , "submitDemoFeedback"]);
            Route::get("/tests", [App\Http\Controllers\Api\StudentController::class , "getTests"]);
            Route::post("/tests/{id}/submit", [App\Http\Controllers\Api\StudentController::class , "submitTest"]);
            Route::get("/tuitions", [App\Http\Controllers\Api\StudentController::class , "getActiveTuitions"]);

            // Certificates
            Route::get("/certificate/download", [App\Http\Controllers\Api\CertificateController::class , "downloadStudentCertificate"]);

            // Homework
            Route::get("/homework", [App\Http\Controllers\Api\StudentController::class , "getHomework"]);
            Route::post("/homework/{id}/submit", [App\Http\Controllers\Api\StudentController::class , "submitHomework"]);

            // Teacher Rating
            Route::post("/teacher/{id}/rate", [App\Http\Controllers\Api\StudentController::class , "rateTeacher"]);
            Route::get("/teacher/{id}/rating", [App\Http\Controllers\Api\StudentController::class , "getTeacherRating"]);

            // Teaching Plans (view only)
            Route::get("/teaching-plans", [App\Http\Controllers\Api\StudentController::class , "getTeachingPlan"]);

            // Batch Status
            Route::get("/batch-status", [App\Http\Controllers\Api\StudentController::class , "getBatchStatus"]);

            // Subscriptions/Demos (Module 4 & 5)
            Route::get("/subscription", [App\Http\Controllers\Api\SubscriptionController::class , "getStudentSubscription"]);
            Route::post("/demos/request", [App\Http\Controllers\Api\SubscriptionController::class , "requestDemo"]);
            Route::post("/demos/{id}/parent-confirm", [App\Http\Controllers\Api\SubscriptionController::class , "parentConfirmDemo"]);
        }
        );

        // Agent APIs
        Route::middleware("role:agent")->prefix("agent")->group(function () {
            Route::get("/dashboard", [App\Http\Controllers\Api\AgentController::class , "dashboard"]);
            Route::get("/referrals", [App\Http\Controllers\Api\AgentController::class , "referrals"]);
            Route::get("/wallet", [App\Http\Controllers\Api\AgentController::class , "walletHistory"]);
        }
        );

        // Parent APIs
        Route::middleware("role:parent")->prefix("parent")->group(function () {
            Route::get("/dashboard", [App\Http\Controllers\Api\ParentController::class , "dashboard"]);
            Route::get("/children", [App\Http\Controllers\Api\ParentController::class , "getChildren"]);
            Route::post("/children/link", [App\Http\Controllers\Api\ParentController::class , "linkChild"]);
            Route::delete("/children/{id}/unlink", [App\Http\Controllers\Api\ParentController::class , "unlinkChild"]);
            Route::get("/children/{id}/progress", [App\Http\Controllers\Api\ParentController::class , "getChildProgress"]);
            Route::get("/children/{id}/attendance", [App\Http\Controllers\Api\ParentController::class , "getChildAttendance"]);
            Route::get("/children/{id}/tests", [App\Http\Controllers\Api\ParentController::class , "getChildTestResults"]);
            Route::get("/children/{id}/homework", [App\Http\Controllers\Api\ParentController::class , "getChildHomework"]);

            // Multi-student/Subs
            Route::get("/subscriptions", [App\Http\Controllers\Api\SubscriptionController::class , "getParentSubscriptions"]);
            Route::post("/relief-check", [App\Http\Controllers\Api\SubscriptionController::class , "calculateRelief"]);
        }
        );

        // Notifications
        Route::prefix("notifications")->group(function () {
            Route::get("/", [App\Http\Controllers\Api\NotificationController::class , "index"]);
            Route::post("/{id}/read", [App\Http\Controllers\Api\NotificationController::class , "markAsRead"]);
            Route::post("/tokens", [App\Http\Controllers\Api\NotificationController::class , "registerToken"]);
        }
        );    });
