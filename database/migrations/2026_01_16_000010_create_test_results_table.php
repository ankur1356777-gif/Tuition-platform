<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('test_results', function (Blueprint $table) {
            $table->id();
            $table->foreignId('test_id')->constrained()->onDelete('cascade');
            $table->foreignId('student_id')->constrained()->onDelete('cascade');
            $table->integer('marks_obtained');
            $table->decimal('percentage', 5, 2);
            $table->string('grade')->nullable(); // A+, A, B+, etc.
            $table->integer('rank')->nullable();
            $table->text('teacher_remarks')->nullable();
            $table->json('rewards')->nullable(); // ["badge_name", "discount_code"]
            $table->timestamp('submitted_at')->nullable();
            $table->timestamps();
            
            $table->unique(['test_id', 'student_id']);
            $table->index(['student_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('test_results');
    }
};
