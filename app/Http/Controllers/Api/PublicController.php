<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class PublicController extends Controller
{
    public function getLandingData()
    {
        try {
            $banners = \App\Models\Banner::where('is_active', true)
                ->orderBy('order')
                ->get()
                ->map(function ($banner) {
                    return [
                        'id' => $banner->id,
                        'image_url' => $banner->image_url ? url($banner->image_url) : null,
                        'title' => $banner->title,
                        'link' => $banner->link,
                        'type' => $banner->type,
                        'order' => $banner->order,
                    ];
                });
            
            // Publicly visible teachers
            $teachers = \App\Models\Teacher::with('user')
                ->where('is_available', true)
                ->where('is_verified', true)
                ->take(10)
                ->get()
                ->map(function ($t) {
                    $user = $t->user;
                    
                    // Parse JSON fields if they are strings
                    $subjects = $t->subjects;
                    if (is_string($subjects)) {
                        $subjects = json_decode($subjects, true) ?? [];
                    }
                    
                    $qualifications = $t->qualifications;
                    if (is_string($qualifications)) {
                        $qualifications = json_decode($qualifications, true) ?? [];
                    }
                    
                    return [
                        'id' => $t->id,
                        'name' => $user ? $user->name : 'Tutor',
                        'photo' => $user && $user->profile_image ? url($user->profile_image) : null,
                        'subjects' => $subjects,
                        'experience' => $t->experience_years ?? 0,
                        'qualifications' => $qualifications,
                    ];
                });

            return response()->json([
                'banners' => $banners,
                'teachers' => $teachers,
            ]);
        } catch (\Exception $e) {
            \Log::error('Landing Data Error: ' . $e->getMessage());
            return response()->json([
                'error' => 'Server Error',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function getAreas()
    {
        try {
            $areas = \App\Models\Area::where('is_active', 1)
                ->where('city', 'Lucknow')
                ->orderBy('name')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $areas,
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function submitTuitionRequest(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'phone' => 'required|string',
            'subject' => 'required|string',
            'grade' => 'required|string',
            'area_id' => 'required|exists:areas,id',
            'description' => 'nullable|string',
        ]);

        // Create a TuitionRequest
        $tuitionRequest = \App\Models\TuitionRequest::create([
            'guest_name' => $request->name,
            'guest_phone' => $request->phone,
            'area_id' => $request->area_id,
            'subjects' => [$request->subject],
            'class' => $request->grade,
            'description' => $request->description,
            'status' => 'new',
        ]);

        return response()->json(['message' => 'Request submitted successfully. Tutors in your area will be notified soon!']);
    }
}
