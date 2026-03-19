<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('parent_children', function (Blueprint $table) {
            $table->id();
            $table->foreignId('parent_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('student_id')->constrained('students')->onDelete('cascade');
            $table->enum('relationship', ['parent', 'guardian', 'other'])->default('parent');
            $table->boolean('is_primary')->default(true);
            $table->timestamps();

            $table->unique(['parent_id', 'student_id']);
            $table->index('parent_id');
            $table->index('student_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('parent_children');
    }
};
