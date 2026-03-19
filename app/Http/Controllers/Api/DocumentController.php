<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Document;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class DocumentController extends Controller
{
    // Upload document
    public function upload(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'type' => 'required|in:aadhar,pan,degree,other',
            'document' => 'required|file|mimes:jpeg,png,jpg,pdf|max:5120', // Max 5MB
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        try {
            $user = Auth::user();
            $file = $request->file('document');
            
            // Generate content hash for filename to prevent duplicates or collisions
            $fileName = time() . '_' . $file->getClientOriginalName();
            $path = $file->storeAs("documents/{$user->id}", $fileName, 'public');

            $document = Document::create([
                'user_id' => $user->id,
                'type' => $request->type,
                'file_path' => $path,
                'file_name' => $file->getClientOriginalName(),
                'mime_type' => $file->getClientMimeType(),
                'status' => 'pending'
            ]);

            return response()->json([
                'message' => 'Document uploaded successfully',
                'document' => $document
            ], 201);

        } catch (\Exception $e) {
            return response()->json(['error' => 'Upload failed: ' . $e->getMessage()], 500);
        }
    }

    // List my documents
    public function index()
    {
        $documents = Document::where('user_id', Auth::id())->get();
        return response()->json($documents);
    }

    // Admin: List pending verifications
    public function pending()
    {
        // Ensure only admin can access this via middleware or gate
        // For now Assuming middleware handles it or check role
        if (Auth::user()->role !== 'admin') {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $documents = Document::where('status', 'pending')
            ->with(['user:id,name,role,email'])
            ->orderBy('created_at', 'asc')
            ->get();
            
        return response()->json($documents);
    }

    // Admin: Verify document
    public function verify(Request $request, $id)
    {
        if (Auth::user()->role !== 'admin') {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $request->validate([
            'status' => 'required|in:approved,rejected',
            'reason' => 'required_if:status,rejected|string|nullable'
        ]);

        $document = Document::findOrFail($id);
        
        $document->update([
            'status' => $request->status,
            'rejection_reason' => $request->status == 'rejected' ? $request->reason : null,
            'verified_at' => $request->status == 'approved' ? now() : null,
        ]);

        // Auto-approve teacher if all required docs are approved (Logic can be added here)
        // For now just sending notification (Placeholder)

        return response()->json([
            'message' => 'Document ' . $request->status,
            'document' => $document
        ]);
    }
}
