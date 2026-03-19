<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class ProfileController extends Controller
{
    public function show()
    {
        return response()->json(Auth::user()->load(['teacher', 'student', 'agent']));
    }

    public function update(Request $request)
    {
        $user = Auth::user();
        
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users,email,' . $user->id,
            'profile_image' => 'sometimes|image|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        if ($request->has('name')) {
            $user->name = $request->name;
        }

        if ($request->has('email')) {
            $user->email = $request->email;
        }

        if ($request->hasFile('profile_image')) {
            // Delete old image if exists
            if ($user->profile_image) {
                Storage::disk('public')->delete($user->profile_image);
            }
            $path = $request->file('profile_image')->store('profiles', 'public');
            $user->profile_image = $path;
        }

        $user->save();

        return response()->json([
            'message' => 'Profile updated successfully',
            'user' => $user
        ]);
    }

    public function updateTeacherProfile(Request $request)
    {
        $user = Auth::user();
        if ($user->role !== 'teacher') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $teacher = $user->teacher;
        
        $request->validate([
            'whatsapp_number' => 'sometimes|string',
            'area_id' => 'sometimes|nullable|exists:areas,id',
            'custom_area' => 'sometimes|nullable|string',
            'bio' => 'sometimes|string',
            'subjects' => 'sometimes|array',
            'classes' => 'sometimes|array',
            'qualifications' => 'sometimes|array',
            'experience_years' => 'sometimes|integer',
            'address' => 'sometimes|string',
            'city' => 'sometimes|string',
            'state' => 'sometimes|string',
            'pincode' => 'sometimes|string',
        ]);

        $updateData = $request->only([
            'whatsapp_number', 'area_id', 'custom_area', 'bio', 'subjects', 
            'classes', 'qualifications', 'experience_years', 'address', 
            'city', 'state', 'pincode'
        ]);

        $teacher->update($updateData);

        return response()->json([
            'message' => 'Teacher profile updated successfully',
            'teacher' => $teacher->fresh()
        ]);
    }

    public function updateStudentProfile(Request $request)
    {
        $user = Auth::user();
        if ($user->role !== 'student' && $user->role !== 'parent') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $student = $user->student;
        
        $request->validate([
            'class' => 'sometimes|string',
            'address' => 'sometimes|string',
            'city' => 'sometimes|string',
            'state' => 'sometimes|string',
            'pincode' => 'sometimes|string',
            'subjects_needed' => 'sometimes|array',
        ]);

        $updateData = $request->only([
            'class', 'address', 'city', 'state', 'pincode', 'subjects_needed'
        ]);

        $student->update($updateData);

        return response()->json([
            'message' => 'Student profile updated successfully',
            'student' => $student->fresh()
        ]);
    }
}
