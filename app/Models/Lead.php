<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Lead extends Model
{
    use HasFactory;

    protected $fillable = [
        'teacher_id',
        'tuition_request_id',
        'distance_km',
        'match_score',
        'status',
        'is_contact_shared',
        'contact_requested',
        'contact_requested_at',
        'contact_shared_at',
    ];

    protected $casts = [
        'is_contact_shared' => 'boolean',
        'contact_requested' => 'boolean',
        'contact_requested_at' => 'datetime',
        'contact_shared_at' => 'datetime',
    ];

    public function teacher()
    {
        return $this->belongsTo(Teacher::class);
    }

    public function tuitionRequest()
    {
        return $this->belongsTo(TuitionRequest::class);
    }

    public function demoClass()
    {
        return $this->hasOne(DemoClass::class);
    }

    // Scopes
    public function scopeContactRequested($query)
    {
        return $query->where('contact_requested', true)->where('is_contact_shared', false);
    }

    public function scopeContactShared($query)
    {
        return $query->where('is_contact_shared', true);
    }

    // Request contact from admin
    public function requestContact()
    {
        $this->contact_requested = true;
        $this->contact_requested_at = now();
        $this->save();
    }

    // Admin approves contact sharing
    public function approveContact()
    {
        $this->is_contact_shared = true;
        $this->contact_shared_at = now();
        $this->save();
    }
}
