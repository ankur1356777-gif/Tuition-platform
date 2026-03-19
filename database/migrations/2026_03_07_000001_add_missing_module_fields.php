<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration 
{
    public function up(): void
    {
        // === STUDENTS TABLE — Module 1 missing fields ===
        Schema::table('students', function (Blueprint $table) {
            if (!Schema::hasColumn('students', 'gender')) {
                $table->enum('gender', ['male', 'female', 'other'])->nullable()->after('user_id');
            }
            if (!Schema::hasColumn('students', 'landmark')) {
                $table->string('landmark')->nullable()->after('address');
            }
            if (!Schema::hasColumn('students', 'teacher_preference')) {
                $table->enum('teacher_preference', ['male', 'female', 'no_preference'])->default('no_preference')->after('special_requirements');
            }
            if (!Schema::hasColumn('students', 'tutor_selection_mode')) {
                $table->enum('tutor_selection_mode', ['self', 'expert'])->default('expert')->after('teacher_preference');
            }
            if (!Schema::hasColumn('students', 'class_locked')) {
                $table->boolean('class_locked')->default(false)->after('class');
            }
            if (!Schema::hasColumn('students', 'class_locked_at')) {
                $table->timestamp('class_locked_at')->nullable()->after('class_locked');
            }
        });

        // === TEACHERS TABLE — Module 2 + 7 missing fields ===
        Schema::table('teachers', function (Blueprint $table) {
            if (!Schema::hasColumn('teachers', 'gender')) {
                $table->enum('gender', ['male', 'female', 'other'])->nullable()->after('user_id');
            }
            if (!Schema::hasColumn('teachers', 'landmark')) {
                $table->string('landmark')->nullable()->after('address');
            }
            if (!Schema::hasColumn('teachers', 'daily_capacity')) {
                $table->integer('daily_capacity')->default(4)->after('total_students');
            }
            if (!Schema::hasColumn('teachers', 'allocated_houses')) {
                $table->integer('allocated_houses')->default(0)->after('daily_capacity');
            }
            if (!Schema::hasColumn('teachers', 'temporary_available')) {
                $table->boolean('temporary_available')->default(false)->after('allocated_houses');
            }
            if (!Schema::hasColumn('teachers', 'bank_account')) {
                $table->string('bank_account')->nullable()->after('temporary_available');
            }
            if (!Schema::hasColumn('teachers', 'upi_id')) {
                $table->string('upi_id')->nullable()->after('bank_account');
            }
            if (!Schema::hasColumn('teachers', 'disqualification_status')) {
                $table->enum('disqualification_status', ['active', 'disqualified', 'service_breach'])->default('active')->after('is_available');
            }
            if (!Schema::hasColumn('teachers', 'disqualified_at')) {
                $table->timestamp('disqualified_at')->nullable()->after('disqualification_status');
            }
            if (!Schema::hasColumn('teachers', 'reapply_after')) {
                $table->timestamp('reapply_after')->nullable()->after('disqualified_at');
            }
            if (!Schema::hasColumn('teachers', 'trial_demos_count')) {
                $table->integer('trial_demos_count')->default(0)->after('reapply_after');
            }
            if (!Schema::hasColumn('teachers', 'trial_rejections')) {
                $table->integer('trial_rejections')->default(0)->after('trial_demos_count');
            }
            if (!Schema::hasColumn('teachers', 'service_breach')) {
                $table->boolean('service_breach')->default(false)->after('trial_rejections');
            }
            if (!Schema::hasColumn('teachers', 'consecutive_absences')) {
                $table->integer('consecutive_absences')->default(0)->after('service_breach');
            }
        });

        // === AGENTS TABLE — Module 3 missing fields (only add truly new ones) ===
        Schema::table('agents', function (Blueprint $table) {
            if (!Schema::hasColumn('agents', 'address')) {
                $table->string('address')->nullable()->after('referral_code');
            }
            if (!Schema::hasColumn('agents', 'landmark')) {
                $table->string('landmark')->nullable()->after('address');
            }
            if (!Schema::hasColumn('agents', 'city')) {
                $table->string('city')->nullable()->after('landmark');
            }
            if (!Schema::hasColumn('agents', 'state')) {
                $table->string('state')->nullable()->after('city');
            }
            if (!Schema::hasColumn('agents', 'pincode')) {
                $table->string('pincode')->nullable()->after('state');
            }
            if (!Schema::hasColumn('agents', 'referrer_type')) {
                $table->enum('referrer_type', ['regular', 'parent'])->default('regular')->after('upi_id');
            }
        });

        // === DEMO CLASSES TABLE — Module 4 missing fields ===
        Schema::table('demo_classes', function (Blueprint $table) {
            if (!Schema::hasColumn('demo_classes', 'demo_start_date')) {
                $table->date('demo_start_date')->nullable()->after('status');
            }
            if (!Schema::hasColumn('demo_classes', 'demo_end_date')) {
                $table->date('demo_end_date')->nullable()->after('demo_start_date');
            }
            if (!Schema::hasColumn('demo_classes', 'change_reason')) {
                $table->text('change_reason')->nullable()->after('demo_end_date');
            }
            if (!Schema::hasColumn('demo_classes', 'teacher_confirmed')) {
                $table->boolean('teacher_confirmed')->default(false)->after('change_reason');
            }
            if (!Schema::hasColumn('demo_classes', 'parent_confirmed')) {
                $table->boolean('parent_confirmed')->default(false)->after('teacher_confirmed');
            }
            if (!Schema::hasColumn('demo_classes', 'details_confirmed_at')) {
                $table->timestamp('details_confirmed_at')->nullable()->after('parent_confirmed');
            }
            if (!Schema::hasColumn('demo_classes', 'change_count')) {
                $table->integer('change_count')->default(0)->after('details_confirmed_at');
            }
        });

        // === ATTENDANCES TABLE — Module 8 missing fields ===
        Schema::table('attendances', function (Blueprint $table) {
            if (!Schema::hasColumn('attendances', 'target_status')) {
                $table->enum('target_status', ['complete', 'partially_complete', 'incomplete'])->nullable()->after('notes');
            }
            if (!Schema::hasColumn('attendances', 'target_comment')) {
                $table->text('target_comment')->nullable()->after('target_status');
            }
            if (!Schema::hasColumn('attendances', 'today_target')) {
                $table->text('today_target')->nullable()->after('target_comment');
            }
            if (!Schema::hasColumn('attendances', 'homework_yesterday_status')) {
                $table->enum('homework_yesterday_status', ['complete', 'partially_complete', 'incomplete'])->nullable()->after('today_target');
            }
            if (!Schema::hasColumn('attendances', 'behaviour_remarks')) {
                $table->text('behaviour_remarks')->nullable()->after('homework_yesterday_status');
            }
            if (!Schema::hasColumn('attendances', 'parent_confirmed')) {
                $table->boolean('parent_confirmed')->default(false)->after('behaviour_remarks');
            }
            if (!Schema::hasColumn('attendances', 'confirmed_at')) {
                $table->timestamp('confirmed_at')->nullable()->after('parent_confirmed');
            }
            if (!Schema::hasColumn('attendances', 'visit_time')) {
                $table->time('visit_time')->nullable()->after('confirmed_at');
            }
            if (!Schema::hasColumn('attendances', 'leave_time')) {
                $table->time('leave_time')->nullable()->after('visit_time');
            }
        });

        // === TEACHING PLANS TABLE — Module 8 missing fields ===
        Schema::table('teaching_plans', function (Blueprint $table) {
            if (!Schema::hasColumn('teaching_plans', 'saturday_test_syllabus')) {
                $table->text('saturday_test_syllabus')->nullable()->after('status');
            }
            if (!Schema::hasColumn('teaching_plans', 'daily_entries')) {
                $table->json('daily_entries')->nullable()->after('saturday_test_syllabus');
            }
        });

        // === TEACHER LEAVES TABLE — Module 6 student-specific leave ===
        Schema::table('teacher_leaves', function (Blueprint $table) {
            if (!Schema::hasColumn('teacher_leaves', 'is_student_specific')) {
                $table->boolean('is_student_specific')->default(false)->after('reason');
            }
            if (!Schema::hasColumn('teacher_leaves', 'student_id')) {
                $table->unsignedBigInteger('student_id')->nullable()->after('is_student_specific');
            }
        });
    }

    public function down(): void
    {
        Schema::table('students', function (Blueprint $table) {
            $cols = ['gender', 'landmark', 'teacher_preference', 'tutor_selection_mode', 'class_locked', 'class_locked_at'];
            $table->dropColumn(array_filter($cols, fn($c) => Schema::hasColumn('students', $c)));
        });
        Schema::table('teachers', function (Blueprint $table) {
            $cols = ['gender', 'landmark', 'daily_capacity', 'allocated_houses', 'temporary_available', 'bank_account', 'upi_id', 'disqualification_status', 'disqualified_at', 'reapply_after', 'trial_demos_count', 'trial_rejections', 'service_breach', 'consecutive_absences'];
            $table->dropColumn(array_filter($cols, fn($c) => Schema::hasColumn('teachers', $c)));
        });
        Schema::table('agents', function (Blueprint $table) {
            $cols = ['address', 'landmark', 'city', 'state', 'pincode', 'referrer_type'];
            $table->dropColumn(array_filter($cols, fn($c) => Schema::hasColumn('agents', $c)));
        });
        Schema::table('demo_classes', function (Blueprint $table) {
            $cols = ['demo_start_date', 'demo_end_date', 'change_reason', 'teacher_confirmed', 'parent_confirmed', 'details_confirmed_at', 'change_count'];
            $table->dropColumn(array_filter($cols, fn($c) => Schema::hasColumn('demo_classes', $c)));
        });
        Schema::table('attendances', function (Blueprint $table) {
            $cols = ['target_status', 'target_comment', 'today_target', 'homework_yesterday_status', 'behaviour_remarks', 'parent_confirmed', 'confirmed_at'];
            $table->dropColumn(array_filter($cols, fn($c) => Schema::hasColumn('attendances', $c)));
        });
        Schema::table('teaching_plans', function (Blueprint $table) {
            $cols = ['saturday_test_syllabus', 'daily_entries'];
            $table->dropColumn(array_filter($cols, fn($c) => Schema::hasColumn('teaching_plans', $c)));
        });
        Schema::table('teacher_leaves', function (Blueprint $table) {
            $cols = ['is_student_specific', 'student_id'];
            $table->dropColumn(array_filter($cols, fn($c) => Schema::hasColumn('teacher_leaves', $c)));
        });
    }
};
