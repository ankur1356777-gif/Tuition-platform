<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Agent;
use App\Models\User;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AgentController extends Controller
{
    public function dashboard()
    {
        $user = Auth::user();
        $agent = $user->agent;

        if (!$agent) {
            return response()->json(['message' => 'Agent profile not found'], 404);
        }

        return response()->json([
            'stats' => [
                'total_referrals' => User::where('referred_by', $user->id)->count(),
                'active_referrals' => User::where('referred_by', $user->id)->where('status', 'active')->count(),
                'total_commissions' => $user->wallet ? $user->wallet->balance : 0,
            ],
            'referral_code' => $agent->referral_code,
            'recent_referrals' => User::where('referred_by', $user->id)
                ->orderBy('created_at', 'desc')
                ->limit(5)
                ->get()
        ]);
    }

    public function referrals()
    {
        $referrals = User::where('referred_by', Auth::id())
            ->orderBy('created_at', 'desc')
            ->paginate(15);

        return response()->json($referrals);
    }

    public function walletHistory()
    {
        $user = Auth::user();
        $transactions = Transaction::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($transactions);
    }
}
