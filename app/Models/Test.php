<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Test extends Model
{
    use HasFactory;

    protected $fillable = [
        'teacher_id',
        'paid_tuition_id',
        'title',
        'description',
        'subject',
        'class',
        'total_marks',
        'duration_minutes',
        'scheduled_date',
        'type',
        'status',
        'questions',
        'test_mode'
    ];

    protected $casts = [
        'questions' => 'array',
        'scheduled_date' => 'date',
    ];

    public function teacher()
    {
        return $this->belongsTo(User::class, 'teacher_id');
    }

    public function results()
    {
        return $this->hasMany(TestResult::class);
    }
}
