<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TuitionRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'student_id',
        'guest_name',
        'guest_phone',
        'area_id',
        'class',
        'subjects',
        'budget',
        'location',
        'city',
        'state',
        'latitude',
        'longitude',
        'status',
    ];

    protected $casts = [
        'subjects' => 'array',
    ];

    public function student()
    {
        return $this->belongsTo(Student::class);
    }

    public function leads()
    {
        return $this->hasMany(Lead::class);
    }

    public function area()
    {
        return $this->belongsTo(Area::class);
    }
}
