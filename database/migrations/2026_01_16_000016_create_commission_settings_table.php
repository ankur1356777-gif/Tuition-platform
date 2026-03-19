<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('commission_settings', function (Blueprint $table) {
            $table->id();
            $table->string('key')->unique();
            $table->decimal('value', 10, 2);
            $table->string('description')->nullable();
            $table->timestamps();
        });
        
        // Insert default commission settings
        DB::table('commission_settings')->insert([
            [
                'key' => 'admin_commission_percentage',
                'value' => 33.33,
                'description' => 'Admin commission percentage from total fee',
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'key' => 'teacher_salary_percentage',
                'value' => 66.67,
                'description' => 'Teacher salary percentage from total fee',
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'key' => 'agent_commission_percentage',
                'value' => 10.00,
                'description' => 'Agent commission percentage from total fee',
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'key' => 'default_monthly_fee',
                'value' => 3000.00,
                'description' => 'Default monthly tuition fee',
                'created_at' => now(),
                'updated_at' => now()
            ]
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('commission_settings');
    }
};
