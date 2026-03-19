<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration 
{
    public function up(): void
    {
        Schema::create('leads', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tuition_request_id')->constrained()->onDelete('cascade');
            $table->foreignId('teacher_id')->constrained()->onDelete('cascade');
            $table->enum('status', ['sent', 'viewed', 'accepted', 'rejected', 'expired'])->default('sent');
            $table->decimal('distance_km', 8, 2)->nullable();
            $table->integer('match_score')->default(0); // 0-100
            $table->timestamp('sent_at')->nullable();
            $table->timestamp('viewed_at')->nullable();
            $table->timestamp('responded_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->timestamps();

            $table->index(['teacher_id', 'status']);
            $table->index(['tuition_request_id', 'status']);
            $table->unique(['tuition_request_id', 'teacher_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('leads');
    }
};
