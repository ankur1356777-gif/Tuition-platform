<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class WebAuthController extends Controller
{
    public function showLogin()
    {
        if (Auth::check()) {
            return redirect()->route('admin.dashboard');
        }
        return view('auth.login');
    }

    public function login(Request $request)
    {
        $request->validate([
            'phone' => 'required|string',
            'password' => 'required|string', // Simple login for now, or we can use OTP
        ]);

        // For simplicity in this demo, we'll check if the user exists and has admin role
        // In a real app, you'd use OTP or proper password hashing
        $user = User::where('phone', $request->phone)->where('role', 'admin')->first();

        if ($user) {
            Auth::login($user);
            return redirect()->route('admin.dashboard');
        }

        return back()->withErrors(['phone' => 'Invalid credentials or not an admin.']);
    }

    public function logout()
    {
        Auth::logout();
        return redirect('/');
    }
}
