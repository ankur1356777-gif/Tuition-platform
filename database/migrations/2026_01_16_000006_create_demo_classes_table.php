<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('demo_classes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tuition_request_id')->constrained()->onDelete('cascade');
            $table->foreignId('student_id')->constrained()->onDelete('cascade');
            $table->foreignId('teacher_id')->constrained()->onDelete('cascade');
            $table->foreignId('lead_id')->constrained()->onDelete('cascade');
            $table->dateTime('scheduled_at');
            $table->integer('duration_minutes')->default(60);
            $table->enum('status', ['scheduled', 'completed', 'cancelled', 'no_show'])->default('scheduled');
            $table->text('teacher_feedback')->nullable();
            $table->text('student_feedback')->nullable();
            $table->integer('teacher_rating')->nullable(); // 1-5
            $table->integer('student_rating')->nullable(); // 1-5
            $table->boolean('converted_to_paid')->default(false);
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();
            
            $table->index(['teacher_id', 'scheduled_at']);
            $table->index(['student_id', 'scheduled_at']);
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('demo_classes');
    }
};
