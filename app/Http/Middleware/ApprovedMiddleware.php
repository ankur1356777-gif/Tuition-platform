<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class ApprovedMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if ($user && $user->status !== 'approved' && $user->role !== 'admin') {
            return response()->json([
                'message' => 'Your account is currently awaiting admin approval or has been suspended.',
                'status' => $user->status
            ], 403);
        }

        return $next($request);
    }
}
