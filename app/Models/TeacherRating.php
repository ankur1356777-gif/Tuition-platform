<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TeacherRating extends Model
{
    use HasFactory;

    protected $fillable = [
        'teacher_id',
        'student_id',
        'user_id',
        'rating',
        'feedback',
        'rated_by',
    ];

    public function teacher()
    {
        return $this->belongsTo(Teacher::class);
    }

    public function student()
    {
        return $this->belongsTo(Student::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Calculate average rating for a teacher
    public static function getAverageRating($teacherId)
    {
        return self::where('teacher_id', $teacherId)->avg('rating') ?? 0;
    }

    // Get rating count for a teacher
    public static function getRatingCount($teacherId)
    {
        return self::where('teacher_id', $teacherId)->count();
    }
}
