<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('leads', function (Blueprint $table) {
            $table->boolean('contact_requested')->default(false);
            $table->timestamp('contact_requested_at')->nullable();
            $table->timestamp('contact_shared_at')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('leads', function (Blueprint $table) {
            $table->dropColumn(['contact_requested', 'contact_requested_at', 'contact_shared_at']);
        });
    }
};
