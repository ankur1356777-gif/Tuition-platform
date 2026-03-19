<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('teaching_plans', function (Blueprint $table) {
            $table->id();
            $table->foreignId('teacher_id')->constrained('teachers')->onDelete('cascade');
            $table->foreignId('paid_tuition_id')->nullable()->constrained('paid_tuitions')->onDelete('cascade');
            $table->date('week_start');
            $table->json('planned_topics')->nullable();
            $table->json('completed_topics')->nullable();
            $table->text('incomplete_reason')->nullable();
            $table->enum('status', ['planned', 'in_progress', 'completed', 'incomplete'])->default('planned');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('teaching_plans');
    }
};
