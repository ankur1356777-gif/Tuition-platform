<?php

namespace App\Services;

use App\Models\Teacher;
use App\Models\TuitionRequest;
use App\Models\Lead;
use App\Models\Student;
use Carbon\Carbon;

class MatchingService
{
    protected $notificationService;

    public function __construct(\App\Services\NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    /**
     * Find matching teachers for a tuition request
     *
     * @param TuitionRequest $tuitionRequest
     * @param int $limit Maximum number of teachers to match
     * @return \Illuminate\Support\Collection
     */
    public function findMatchingTeachers(TuitionRequest $tuitionRequest, int $limit = 5)
    {
        $student = $tuitionRequest->student;
        
        // Get verified and available teachers
        $teachers = Teacher::verified()
            ->available()
            ->byClass($tuitionRequest->class)
            ->get()
            ->filter(function ($teacher) use ($tuitionRequest) {
                // Check if teacher teaches any of the required subjects
                $teacherSubjects = $teacher->subjects ?? [];
                $requiredSubjects = $tuitionRequest->subjects ?? [];
                
                return count(array_intersect($teacherSubjects, $requiredSubjects)) > 0;
            })
            ->map(function ($teacher) use ($student, $tuitionRequest) {
                // Calculate distance
                $distance = $this->calculateDistance(
                    $tuitionRequest->latitude ?? $student->latitude,
                    $tuitionRequest->longitude ?? $student->longitude,
                    $teacher->latitude,
                    $teacher->longitude
                );
                
                $teacher->distance = $distance;
                $teacher->match_score = $this->calculateMatchScore($teacher, $student, $distance);
                
                return $teacher;
            })
            ->filter(function ($teacher) {
                // Filter by teacher's preferred radius
                return $teacher->distance <= $teacher->preferred_radius_km;
            })
            ->sortByDesc('match_score')
            ->take($limit);
        
        return $teachers;
    }

    /**
     * Create leads for matched teachers
     *
     * @param TuitionRequest $tuitionRequest
     * @param \Illuminate\Support\Collection $teachers
     * @return int Number of leads created
     */
    public function createLeads(TuitionRequest $tuitionRequest, $teachers)
    {
        $leadsCreated = 0;
        
        foreach ($teachers as $teacher) {
            // Check if lead already exists
            $existingLead = Lead::where('tuition_request_id', $tuitionRequest->id)
                ->where('teacher_id', $teacher->id)
                ->first();
            
            if (!$existingLead) {
                $lead = Lead::create([
                    'tuition_request_id' => $tuitionRequest->id,
                    'teacher_id' => $teacher->id,
                    'status' => 'sent',
                    'distance_km' => $teacher->distance,
                    'match_score' => $teacher->match_score,
                    'sent_at' => now(),
                    'expires_at' => now()->addHours(48), // 48 hours to respond
                ]);
                
                $leadsCreated++;

                // Notify teacher
                $this->notificationService->sendLeadReceivedNotification(
                    $teacher->user_id,
                    [
                        'lead_id' => $lead->id,
                        'class' => $tuitionRequest->class,
                        'subject' => is_array($tuitionRequest->subjects) ? implode(', ', $tuitionRequest->subjects) : $tuitionRequest->subjects,
                    ]
                );
            }
        }
        
        return $leadsCreated;
    }

    /**
     * Calculate distance between two coordinates using Haversine formula
     *
     * @param float $lat1
     * @param float $lon1
     * @param float $lat2
     * @param float $lon2
     * @return float Distance in kilometers
     */
    private function calculateDistance($lat1, $lon1, $lat2, $lon2)
    {
        if (is_null($lat1) || is_null($lon1) || is_null($lat2) || is_null($lon2)) {
            return PHP_FLOAT_MAX;
        }
        
        $earthRadius = 6371; // Earth's radius in kilometers
        
        $latFrom = deg2rad($lat1);
        $lonFrom = deg2rad($lon1);
        $latTo = deg2rad($lat2);
        $lonTo = deg2rad($lon2);
        
        $latDelta = $latTo - $latFrom;
        $lonDelta = $lonTo - $lonFrom;
        
        $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) +
            cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));
        
        return round($angle * $earthRadius, 2);
    }

    /**
     * Calculate match score based on various factors
     *
     * @param Teacher $teacher
     * @param Student $student
     * @param float $distance
     * @return int Score from 0-100
     */
    private function calculateMatchScore(Teacher $teacher, Student $student, float $distance)
    {
        $score = 0;
        
        // Distance score (40 points max)
        // Closer is better
        if ($distance <= 2) {
            $score += 40;
        } elseif ($distance <= 5) {
            $score += 30;
        } elseif ($distance <= 10) {
            $score += 20;
        } else {
            $score += 10;
        }
        
        // Rating score (30 points max)
        $score += ($teacher->rating / 5) * 30;
        
        // Experience score (20 points max)
        $experienceScore = min($teacher->experience_years * 2, 20);
        $score += $experienceScore;
        
        // Availability score (10 points max)
        // Teachers with fewer students get higher score
        if ($teacher->total_students == 0) {
            $score += 10;
        } elseif ($teacher->total_students <= 5) {
            $score += 7;
        } elseif ($teacher->total_students <= 10) {
            $score += 5;
        } else {
            $score += 2;
        }
        
        return min(100, round($score));
    }

    /**
     * Auto-match and create leads for a tuition request
     *
     * @param TuitionRequest $tuitionRequest
     * @param int $limit
     * @return array
     */
    public function autoMatch(TuitionRequest $tuitionRequest, int $limit = 5)
    {
        $teachers = $this->findMatchingTeachers($tuitionRequest, $limit);
        $leadsCreated = $this->createLeads($tuitionRequest, $teachers);
        
        // Update tuition request status
        $tuitionRequest->update(['status' => 'matching']);
        
        return [
            'teachers_found' => $teachers->count(),
            'leads_created' => $leadsCreated,
            'teachers' => $teachers->values(),
        ];
    }
}
