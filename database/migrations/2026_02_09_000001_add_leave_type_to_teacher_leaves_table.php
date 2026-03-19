<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('teacher_leaves', function (Blueprint $table) {
            $table->enum('leave_type', ['auto', 'requested'])->default('auto')->after('status');
        });
    }

    public function down(): void
    {
        Schema::table('teacher_leaves', function (Blueprint $table) {
            $table->dropColumn('leave_type');
        });
    }
};
