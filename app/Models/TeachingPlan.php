<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TeachingPlan extends Model
{
    use HasFactory;

    protected $fillable = [
        'teacher_id',
        'paid_tuition_id',
        'week_start',
        'planned_topics',
        'completed_topics',
        'incomplete_reason',
        'status',
    ];

    protected $casts = [
        'week_start' => 'date',
        'planned_topics' => 'array',
        'completed_topics' => 'array',
    ];

    public function teacher()
    {
        return $this->belongsTo(Teacher::class);
    }

    public function paidTuition()
    {
        return $this->belongsTo(PaidTuition::class);
    }

    // Check if all planned topics are completed
    public function isComplete()
    {
        if (empty($this->planned_topics)) return true;
        if (empty($this->completed_topics)) return false;
        
        return count($this->completed_topics) >= count($this->planned_topics);
    }

    // Get incomplete topics
    public function getIncompleteTopics()
    {
        if (empty($this->planned_topics)) return [];
        if (empty($this->completed_topics)) return $this->planned_topics;
        
        return array_diff($this->planned_topics, $this->completed_topics);
    }

    // Scopes
    public function scopeThisWeek($query)
    {
        $weekStart = now()->startOfWeek();
        return $query->where('week_start', $weekStart);
    }

    public function scopeIncomplete($query)
    {
        return $query->where('status', 'incomplete');
    }
}
