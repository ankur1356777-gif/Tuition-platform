<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tuition_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained()->onDelete('cascade');
            $table->string('class');
            $table->json('subjects'); // ["Math", "Science"]
            $table->string('preferred_timing')->nullable();
            $table->text('description')->nullable();
            $table->enum('status', ['new', 'matching', 'demo_scheduled', 'demo_completed', 'converted', 'cancelled'])->default('new');
            $table->foreignId('referred_by_agent_id')->nullable()->constrained('agents')->onDelete('set null');
            $table->timestamps();
            
            $table->index(['status', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tuition_requests');
    }
};
