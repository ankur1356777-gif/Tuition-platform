<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('tuition_requests', function (Blueprint $table) {
            $table->decimal('budget', 10, 2)->nullable()->after('subjects');
            $table->string('address')->nullable()->after('budget');
            $table->decimal('latitude', 10, 7)->nullable()->after('address');
            $table->decimal('longitude', 10, 7)->nullable()->after('latitude');
        });
    }

    public function down(): void
    {
        Schema::table('tuition_requests', function (Blueprint $table) {
            $table->dropColumn(['budget', 'address', 'latitude', 'longitude']);
        });
    }
};
