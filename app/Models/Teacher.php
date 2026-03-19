<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Teacher extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'gender',
        'whatsapp_number',
        'area_id',
        'custom_area',
        'bio',
        'subjects',
        'classes',
        'qualifications',
        'experience_years',
        'preferred_radius_km',
        'latitude',
        'longitude',
        'address',
        'landmark',
        'city',
        'state',
        'pincode',
        'documents',
        'is_verified',
        'is_available',
        'rating',
        'total_students',
        'daily_capacity',
        'allocated_houses',
        'temporary_available',
        'bank_account',
        'upi_id',
        'disqualification_status',
        'disqualified_at',
        'reapply_after',
        'trial_demos_count',
        'trial_rejections',
        'service_breach',
        'consecutive_absences',
    ];

    protected $casts = [
        'subjects' => 'array',
        'classes' => 'array',
        'qualifications' => 'array',
        'documents' => 'array',
        'is_verified' => 'boolean',
        'is_available' => 'boolean',
        'rating' => 'decimal:2',
        'preferred_radius_km' => 'decimal:2',
        'latitude' => 'decimal:7',
        'longitude' => 'decimal:7',
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function leads()
    {
        return $this->hasMany(Lead::class);
    }

    public function demoClasses()
    {
        return $this->hasMany(DemoClass::class);
    }

    public function paidTuitions()
    {
        return $this->hasMany(PaidTuition::class);
    }

    public function tests()
    {
        return $this->hasMany(Test::class);
    }

    public function leaves()
    {
        return $this->hasMany(TeacherLeave::class);
    }

    // Scopes
    public function scopeVerified($query)
    {
        return $query->where('is_verified', true);
    }

    public function scopeAvailable($query)
    {
        return $query->where('is_available', true);
    }

    public function scopeNearLocation($query, $latitude, $longitude, $radiusKm = null)
    {
        // Haversine formula for distance calculation
        $haversine = "(6371 * acos(cos(radians(?)) 
                     * cos(radians(latitude)) 
                     * cos(radians(longitude) - radians(?)) 
                     + sin(radians(?)) 
                     * sin(radians(latitude))))";

        $query->selectRaw("*, {$haversine} AS distance", [$latitude, $longitude, $latitude])
            ->whereNotNull('latitude')
            ->whereNotNull('longitude');

        if ($radiusKm) {
            $query->havingRaw("distance <= ?", [$radiusKm]);
        }

        return $query->orderBy('distance');
    }

    public function scopeBySubject($query, $subject)
    {
        return $query->whereJsonContains('subjects', $subject);
    }

    public function scopeByClass($query, $class)
    {
        return $query->whereJsonContains('classes', $class);
    }

    // Rating relationships
    public function ratings()
    {
        return $this->hasMany(TeacherRating::class);
    }

    public function homework()
    {
        return $this->hasMany(Homework::class);
    }

    public function teachingPlans()
    {
        return $this->hasMany(TeachingPlan::class);
    }

    // Calculate and update average rating
    public function calculateAverageRating()
    {
        $avgRating = $this->ratings()->avg('rating') ?? 0;
        $this->rating = round($avgRating, 2);
        $this->save();
        return $this->rating;
    }

    // Get rating count
    public function getRatingCountAttribute()
    {
        return $this->ratings()->count();
    }
}
