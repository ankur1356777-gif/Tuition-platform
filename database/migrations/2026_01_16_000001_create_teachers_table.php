<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('teachers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->text('bio')->nullable();
            $table->json('subjects'); // ["Math", "Science", "English"]
            $table->json('classes'); // ["1", "2", "3", "4", "5"]
            $table->json('qualifications'); // ["B.Ed", "M.Sc"]
            $table->integer('experience_years')->default(0);
            $table->decimal('preferred_radius_km', 8, 2)->default(5.00);
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->string('address')->nullable();
            $table->string('city')->nullable();
            $table->string('state')->nullable();
            $table->string('pincode', 10)->nullable();
            $table->json('documents')->nullable(); // URLs to uploaded documents
            $table->boolean('is_verified')->default(false);
            $table->boolean('is_available')->default(true);
            $table->decimal('rating', 3, 2)->default(0.00);
            $table->integer('total_students')->default(0);
            $table->timestamps();
            
            $table->index(['latitude', 'longitude']);
            $table->index(['is_verified', 'is_available']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('teachers');
    }
};
