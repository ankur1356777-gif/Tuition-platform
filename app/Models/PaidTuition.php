<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PaidTuition extends Model
{
    use HasFactory;

    protected $fillable = [
        'lead_id',
        'teacher_id',
        'student_id',
        'monthly_fee',
        'platform_fee',
        'agent_commission',
        'status',
        'started_at',
        'meeting_id',
    ];

    public function lead()
    {
        return $this->belongsTo(Lead::class);
    }

    public function teacher()
    {
        return $this->belongsTo(Teacher::class);
    }

    public function student()
    {
        return $this->belongsTo(Student::class);
    }
}
