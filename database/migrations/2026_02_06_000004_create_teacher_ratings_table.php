<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('teacher_ratings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('teacher_id')->constrained('teachers')->onDelete('cascade');
            $table->foreignId('student_id')->nullable()->constrained('students')->onDelete('set null');
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('set null');
            $table->tinyInteger('rating')->unsigned()->comment('Rating from 1-5');
            $table->text('feedback')->nullable()->comment('Hidden feedback, only visible to admin');
            $table->enum('rated_by', ['student', 'parent'])->default('student');
            $table->timestamps();
            
            // Prevent duplicate ratings
            $table->unique(['teacher_id', 'student_id', 'user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('teacher_ratings');
    }
};
