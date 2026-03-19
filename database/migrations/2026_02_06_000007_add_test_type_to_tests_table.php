<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('tests', function (Blueprint $table) {
            $table->enum('test_type', ['regular', 'weekly', 'monthly', 'final'])->default('regular')->after('test_mode');
            $table->boolean('is_weekly_test')->default(false)->after('test_type');
        });
    }

    public function down(): void
    {
        Schema::table('tests', function (Blueprint $table) {
            $table->dropColumn(['test_type', 'is_weekly_test']);
        });
    }
};
