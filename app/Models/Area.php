<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Area extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'city',
        'state',
        'pincode',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    // Relationships
    public function teachers()
    {
        return $this->hasMany(Teacher::class);
    }

    public function tuitionRequests()
    {
        return $this->hasMany(TuitionRequest::class);
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeLucknow($query)
    {
        return $query->where('city', 'Lucknow')->where('state', 'Uttar Pradesh');
    }
}
