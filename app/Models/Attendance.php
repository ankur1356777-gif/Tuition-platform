<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Attendance extends Model
{
    use HasFactory;

    protected $fillable = [
        'paid_tuition_id',
        'student_id',
        'teacher_id',
        'date',
        'status',
        'class_time',
        'duration_minutes',
        'notes',
        'latitude',
        'longitude',
        'marked_by',
        'marked_at',
        'is_verified',
    ];

    public function paidTuition()
    {
        return $this->belongsTo(PaidTuition::class);
    }

    public function teacher()
    {
        return $this->belongsTo(Teacher::class);
    }
}
