<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('students', function (Blueprint $table) {
            // Ensure parent_name exists (fix for migration error)
            if (!Schema::hasColumn('students', 'parent_name')) {
                $table->string('parent_name')->nullable()->after('user_id');
            }
            
            // Add parent_phone if missing
            if (!Schema::hasColumn('students', 'parent_phone')) {
                $table->string('parent_phone')->nullable()->after('user_id');
                $table->index('parent_phone');
            }
        });
    }

    public function down(): void
    {
        Schema::table('students', function (Blueprint $table) {
            if (Schema::hasColumn('students', 'parent_phone')) {
                $table->dropIndex(['parent_phone']);
                $table->dropColumn('parent_phone');
            }
        });
    }
};
