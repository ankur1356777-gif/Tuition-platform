<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('students', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('parent_id')->nullable()->constrained('users')->onDelete('set null');
            $table->string('class');
            $table->json('subjects_needed'); // ["Math", "Science"]
            $table->string('school_name')->nullable();
            $table->decimal('latitude', 10, 7);
            $table->decimal('longitude', 10, 7);
            $table->string('address');
            $table->string('city');
            $table->string('state');
            $table->string('pincode', 10);
            $table->string('preferred_timing')->nullable(); // "Morning", "Evening"
            $table->text('special_requirements')->nullable();
            $table->decimal('performance_score', 5, 2)->default(0.00);
            $table->integer('total_tests_taken')->default(0);
            $table->timestamps();
            
            $table->index(['latitude', 'longitude']);
            $table->index('class');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('students');
    }
};
