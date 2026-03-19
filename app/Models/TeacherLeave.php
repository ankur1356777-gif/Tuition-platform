<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TeacherLeave extends Model
{
    use HasFactory;

    protected $fillable = [
        'teacher_id',
        'start_date',
        'end_date',
        'reason',
        'status',
        'leave_type',
        'approved_by',
        'approved_at',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'approved_at' => 'datetime',
    ];


    public function teacher()
    {
        return $this->belongsTo(Teacher::class);
    }
}
