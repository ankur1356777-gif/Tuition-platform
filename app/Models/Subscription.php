<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Subscription extends Model
{
    use HasFactory;

    protected $fillable = [
        'parent_user_id',
        'student_id',
        'teacher_id',
        'class_category',
        'monthly_fee',
        'teacher_commission',
        'platform_fee',
        'billing_cycle_date',
        'start_date',
        'end_date',
        'next_payment_due',
        'status',
        'parent_relief_applied',
        'relief_amount',
    ];

    protected $casts = [
        'monthly_fee' => 'decimal:2',
        'teacher_commission' => 'decimal:2',
        'platform_fee' => 'decimal:2',
        'relief_amount' => 'decimal:2',
        'billing_cycle_date' => 'integer',
        'parent_relief_applied' => 'boolean',
        'start_date' => 'date',
        'end_date' => 'date',
        'next_payment_due' => 'date',
    ];

    // Fee structure constants
    const FEE_STRUCTURE = [
        'nursery_kg' => ['total_fee' => 2000, 'teacher_commission' => 1000],
        'class_1_5' => ['total_fee' => 2500, 'teacher_commission' => 1500],
        'class_6_8' => ['total_fee' => 3000, 'teacher_commission' => 2000],
    ];

    const PLATFORM_FEE = 1000;
    const PARENT_RELIEF_FEE = 2000;

    public function parentUser()
    {
        return $this->belongsTo(User::class , 'parent_user_id');
    }

    public function student()
    {
        return $this->belongsTo(Student::class);
    }

    public function teacher()
    {
        return $this->belongsTo(Teacher::class);
    }

    public static function getClassCategory($class)
    {
        $class = strtolower(trim($class));
        if (in_array($class, ['nursery', 'lkg', 'ukg', 'kg', 'pre-nursery'])) {
            return 'nursery_kg';
        }
        $numericClass = (int)filter_var($class, FILTER_SANITIZE_NUMBER_INT);
        if ($numericClass >= 1 && $numericClass <= 5) {
            return 'class_1_5';
        }
        if ($numericClass >= 6 && $numericClass <= 8) {
            return 'class_6_8';
        }
        return 'nursery_kg'; // default
    }

    public static function getFeeForClass($class)
    {
        $category = self::getClassCategory($class);
        return self::FEE_STRUCTURE[$category] ?? self::FEE_STRUCTURE['nursery_kg'];
    }

    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeForParent($query, $parentUserId)
    {
        return $query->where('parent_user_id', $parentUserId);
    }

    public function scopeForTeacher($query, $teacherId)
    {
        return $query->where('teacher_id', $teacherId);
    }
}
