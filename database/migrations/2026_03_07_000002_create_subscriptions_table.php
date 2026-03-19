<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration 
{
    public function up(): void
    {
        Schema::create('subscriptions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('parent_user_id')->nullable()->constrained('users')->onDelete('set null');
            $table->foreignId('student_id')->constrained()->onDelete('cascade');
            $table->foreignId('teacher_id')->constrained()->onDelete('cascade');
            $table->string('class_category'); // nursery_kg, class_1_5, class_6_8
            $table->decimal('monthly_fee', 10, 2);
            $table->decimal('teacher_commission', 10, 2);
            $table->decimal('platform_fee', 10, 2)->default(1000);
            $table->integer('billing_cycle_date'); // day of month (1-31)
            $table->date('start_date');
            $table->date('end_date')->nullable();
            $table->date('next_payment_due')->nullable();
            $table->enum('status', ['active', 'paused', 'cancelled', 'expired'])->default('active');
            $table->boolean('parent_relief_applied')->default(false);
            $table->decimal('relief_amount', 10, 2)->default(0);
            $table->timestamps();

            $table->index(['parent_user_id', 'status']);
            $table->index(['teacher_id', 'status']);
            $table->index(['student_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subscriptions');
    }
};
