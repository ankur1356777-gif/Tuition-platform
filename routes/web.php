<?php

use App\Http\Controllers\Web\AdminController;
use App\Http\Controllers\Web\BannerController;
use App\Http\Controllers\Web\WebAuthController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('landing');
});

// Web Authentication
Route::get('/login', [WebAuthController::class , 'showLogin'])->name('login');
Route::post('/login', [WebAuthController::class , 'login']);
Route::post('/logout', [WebAuthController::class , 'logout'])->name('logout');

// Admin Panel
Route::middleware(['auth', 'role:admin'])->prefix('admin')->group(function () {
    Route::get('/dashboard', [AdminController::class , 'index'])->name('admin.dashboard');
    Route::get('/teachers', [AdminController::class , 'teachers'])->name('admin.teachers');
    Route::get('/students', [AdminController::class , 'students'])->name('admin.students');
    Route::get('/agents', [AdminController::class , 'agents'])->name('admin.agents');
    Route::get('/leads', [AdminController::class , 'leads'])->name('admin.leads');
    Route::get('/attendance', [AdminController::class , 'attendance'])->name('admin.attendance');
    Route::get('/notifications', [AdminController::class , 'notifications'])->name('admin.notifications');
    Route::post('/notifications/send', [AdminController::class , 'sendNotification'])->name('admin.notifications.send');
    Route::get('/tests', [AdminController::class , 'tests'])->name('admin.tests');
    Route::get('/demo-classes', [AdminController::class , 'demoClasses'])->name('admin.demo');
    Route::get('/payments', [AdminController::class , 'payments'])->name('admin.payments');
    Route::post('/payments/{id}/update', [AdminController::class , 'updatePayoutStatus'])->name('admin.payments.update');
    Route::get('/transactions', [AdminController::class , 'transactions'])->name('admin.transactions');
    Route::get('/settings', [AdminController::class , 'settings'])->name('admin.settings');
    Route::post('/settings/update', [AdminController::class , 'updateSettings'])->name('admin.settings.update');
    Route::get('/system-settings', [AdminController::class , 'systemSettings'])->name('admin.system_settings');
    Route::post('/system-settings/update', [AdminController::class , 'updateSystemSettings'])->name('admin.system_settings.update');
    Route::post('/teachers/{id}/verify', [AdminController::class , 'verifyTeacher'])->name('admin.teachers.verify');
    Route::post('/agents/{id}/verify', [AdminController::class , 'verifyAgent'])->name('admin.agents.verify');
    Route::get('/users/create', [AdminController::class , 'createUser'])->name('admin.users.create');
    Route::post('/users', [AdminController::class , 'storeUser'])->name('admin.users.store');
    Route::get('/teachers/{id}', [AdminController::class , 'teacherDetail'])->name('admin.teachers.show');
    Route::get('/students/{id}', [AdminController::class , 'studentDetail'])->name('admin.students.show');
    Route::post('/leads/{id}/toggle-contact', [AdminController::class , 'toggleLeadContact'])->name('admin.leads.toggle_contact');
    Route::post('/leads/{id}/convert', [AdminController::class , 'convertLeadToTuition'])->name('admin.leads.convert');

    // Test Notifications
    Route::post('/test-whatsapp', [AdminController::class , 'testWhatsApp'])->name('admin.test-whatsapp');
    Route::post('/test-sms', [AdminController::class , 'testSMS'])->name('admin.test-sms');
    Route::post('/test-email', [AdminController::class , 'testEmail'])->name('admin.test-email');

    // Education Management
    Route::get('/homework', [AdminController::class , 'homework'])->name('admin.homework');
    Route::get('/teaching-plans', [AdminController::class , 'teachingPlans'])->name('admin.teaching_plans');
    Route::get('/batches', [AdminController::class , 'batches'])->name('admin.batches');
    Route::post('/students/{id}/batch', [AdminController::class , 'updateBatch'])->name('admin.students.batch');
    Route::get('/rewards', [AdminController::class , 'rewards'])->name('admin.rewards');
    Route::post('/teachers/{id}/reward', [AdminController::class , 'rewardTeacher'])->name('admin.teachers.reward');
    Route::get('/teacher-feedback', [AdminController::class , 'teacherFeedback'])->name('admin.teacher_feedback');
    Route::get('/contact-requests', [AdminController::class , 'contactRequests'])->name('admin.contact_requests');
    Route::post('/leads/{id}/approve-contact', [AdminController::class , 'approveLeadContact'])->name('admin.leads.approve_contact');
    Route::post('/leads/{id}/reject-contact', [AdminController::class , 'rejectLeadContact'])->name('admin.leads.reject_contact');
    Route::post('/leads/{id}/schedule-demo', [AdminController::class , 'scheduleDemoFromLead'])->name('admin.leads.schedule_demo');

    // Leave Management
    Route::get('/leaves', [AdminController::class , 'leaves'])->name('admin.leaves');
    Route::post('/leaves/{id}/approve', [AdminController::class , 'approveLeave'])->name('admin.leaves.approve');
    Route::post('/leaves/{id}/reject', [AdminController::class , 'rejectLeave'])->name('admin.leaves.reject');

    // Parent Management
    Route::get('/parents', [AdminController::class , 'parents'])->name('admin.parents');
    Route::get('/parents/{id}', [AdminController::class , 'parentDetail'])->name('admin.parents.show');
    Route::post('/parents/{id}/approve', [AdminController::class , 'approveParent'])->name('admin.parents.approve');
    Route::post('/parents/{id}/reject', [AdminController::class , 'rejectParent'])->name('admin.parents.reject');

    // Banner Management
    Route::resource('banners', BannerController::class)->names([
        'index' => 'admin.banners.index',
        'create' => 'admin.banners.create',
        'store' => 'admin.banners.store',
        'edit' => 'admin.banners.edit',
        'update' => 'admin.banners.update',
        'destroy' => 'admin.banners.destroy',
    ]);
    Route::patch('/banners/{banner}/toggle', [BannerController::class , 'toggleStatus'])->name('admin.banners.toggle');
});
