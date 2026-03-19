<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('wallets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->onDelete('cascade');
            $table->decimal('balance', 12, 2)->default(0.00);
            $table->decimal('total_earned', 12, 2)->default(0.00);
            $table->decimal('total_withdrawn', 12, 2)->default(0.00);
            $table->decimal('pending_amount', 12, 2)->default(0.00);
            $table->boolean('is_frozen')->default(false);
            $table->timestamps();
            
            $table->index('user_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wallets');
    }
};
