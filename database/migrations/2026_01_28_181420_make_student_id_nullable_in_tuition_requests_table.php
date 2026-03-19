<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('tuition_requests', function (Blueprint $table) {
            $table->foreignId('student_id')->nullable()->change();
            $table->string('guest_name')->nullable()->after('student_id');
            $table->string('guest_phone')->nullable()->after('guest_name');
        });
    }

    public function down(): void
    {
        Schema::table('tuition_requests', function (Blueprint $table) {
            $table->foreignId('student_id')->nullable(false)->change();
            $table->dropColumn(['guest_name', 'guest_phone']);
        });
    }
};
