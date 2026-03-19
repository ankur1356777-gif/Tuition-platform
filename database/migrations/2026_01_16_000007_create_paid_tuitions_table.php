<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('paid_tuitions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained()->onDelete('cascade');
            $table->foreignId('teacher_id')->constrained()->onDelete('cascade');
            $table->foreignId('demo_class_id')->nullable()->constrained()->onDelete('set null');
            $table->foreignId('referred_by_agent_id')->nullable()->constrained('agents')->onDelete('set null');
            $table->string('subject');
            $table->string('class');
            $table->decimal('monthly_fee', 10, 2);
            $table->decimal('admin_commission', 10, 2);
            $table->decimal('teacher_salary', 10, 2);
            $table->decimal('agent_commission', 10, 2)->default(0.00);
            $table->date('start_date');
            $table->date('end_date')->nullable();
            $table->enum('status', ['active', 'paused', 'completed', 'cancelled'])->default('active');
            $table->json('schedule')->nullable(); // {"Monday": "5:00 PM", "Wednesday": "5:00 PM"}
            $table->text('cancellation_reason')->nullable();
            $table->timestamps();
            
            $table->index(['teacher_id', 'status']);
            $table->index(['student_id', 'status']);
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('paid_tuitions');
    }
};
