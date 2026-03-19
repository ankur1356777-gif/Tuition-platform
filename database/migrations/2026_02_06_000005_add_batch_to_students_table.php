<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('students', function (Blueprint $table) {
            $table->enum('batch', ['bronze', 'silver', 'gold'])->default('bronze');
            $table->integer('consecutive_high_scores')->default(0);
        });
    }

    public function down(): void
    {
        Schema::table('students', function (Blueprint $table) {
            $table->dropColumn(['batch', 'consecutive_high_scores']);
        });
    }
};
