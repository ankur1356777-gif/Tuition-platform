<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('agents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('referral_code', 20)->unique();
            $table->json('preferred_areas')->nullable(); // ["City1", "City2"]
            $table->string('bank_name')->nullable();
            $table->string('account_number')->nullable();
            $table->string('ifsc_code')->nullable();
            $table->string('upi_id')->nullable();
            $table->decimal('commission_rate', 5, 2)->default(10.00); // Percentage
            $table->integer('total_referrals')->default(0);
            $table->integer('active_referrals')->default(0);
            $table->decimal('total_commission_earned', 10, 2)->default(0.00);
            $table->timestamps();
            
            $table->index('referral_code');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('agents');
    }
};
