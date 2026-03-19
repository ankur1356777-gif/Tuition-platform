<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Student extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'gender',
        'class',
        'class_locked',
        'class_locked_at',
        'subjects_needed',
        'school_name',
        'address',
        'landmark',
        'latitude',
        'longitude',
        'city',
        'state',
        'pincode',
        'preferred_timing',
        'special_requirements',
        'teacher_preference',
        'tutor_selection_mode',
        'parent_name',
        'parent_phone',
        'batch',
        'consecutive_high_scores',
    ];

    protected $casts = [
        'consecutive_high_scores' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function tuitionRequests()
    {
        return $this->hasMany(TuitionRequest::class);
    }

    public function testResults()
    {
        return $this->hasMany(TestResult::class);
    }

    public function homeworkSubmissions()
    {
        return $this->hasMany(HomeworkSubmission::class);
    }

    public function ratings()
    {
        return $this->hasMany(TeacherRating::class);
    }

    public function parentLinks()
    {
        return $this->hasMany(ParentChild::class , 'student_id');
    }

    // Check and upgrade batch based on consecutive high scores
    public function checkBatchUpgrade()
    {
        if ($this->consecutive_high_scores >= 3 && $this->batch === 'bronze') {
            $this->batch = 'silver';
            $this->consecutive_high_scores = 0;
            $this->save();
            return 'silver';
        }

        if ($this->consecutive_high_scores >= 3 && $this->batch === 'silver') {
            $this->batch = 'gold';
            $this->consecutive_high_scores = 0;
            $this->save();
            return 'gold';
        }

        return null;
    }

    // Record a test score and check for streak
    public function recordTestScore($percentage)
    {
        if ($percentage >= 80) {
            $this->consecutive_high_scores++;
        }
        else {
            $this->consecutive_high_scores = 0;
        }
        $this->save();

        return $this->checkBatchUpgrade();
    }

    // Scopes
    public function scopeByBatch($query, $batch)
    {
        return $query->where('batch', $batch);
    }

    public function scopeGold($query)
    {
        return $query->where('batch', 'gold');
    }

    public function scopeSilver($query)
    {
        return $query->where('batch', 'silver');
    }

    public function scopeBronze($query)
    {
        return $query->where('batch', 'bronze');
    }
}
