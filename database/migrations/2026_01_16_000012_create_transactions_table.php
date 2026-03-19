<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wallet_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->enum('type', ['credit', 'debit']);
            $table->decimal('amount', 10, 2);
            $table->decimal('balance_before', 12, 2);
            $table->decimal('balance_after', 12, 2);
            $table->enum('category', [
                'payment_received',
                'commission_earned',
                'salary_credited',
                'payout_requested',
                'payout_approved',
                'payout_rejected',
                'refund',
                'adjustment'
            ]);
            $table->string('reference_type')->nullable(); // paid_tuitions, demo_classes, etc.
            $table->unsignedBigInteger('reference_id')->nullable();
            $table->text('description');
            $table->json('metadata')->nullable();
            $table->timestamps();
            
            $table->index(['wallet_id', 'created_at']);
            $table->index(['user_id', 'category']);
            $table->index(['reference_type', 'reference_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transactions');
    }
};
