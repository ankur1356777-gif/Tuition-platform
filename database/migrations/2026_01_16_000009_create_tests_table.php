<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('teacher_id')->constrained()->onDelete('cascade');
            $table->string('title');
            $table->text('description')->nullable();
            $table->string('subject');
            $table->string('class');
            $table->integer('total_marks');
            $table->integer('duration_minutes');
            $table->date('scheduled_date');
            $table->enum('type', ['weekly', 'monthly', 'unit', 'final'])->default('weekly');
            $table->enum('status', ['scheduled', 'ongoing', 'completed', 'cancelled'])->default('scheduled');
            $table->timestamps();
            
            $table->index(['teacher_id', 'scheduled_date']);
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tests');
    }
};
