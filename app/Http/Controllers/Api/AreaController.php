<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Area;
use Illuminate\Http\Request;

class AreaController extends Controller
{
    public function index()
    {
        // Try simple fetch first to bypass scope issues if any
        $areas = Area::where('is_active', 1)
            ->where('city', 'Lucknow')
            ->orderBy('name')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $areas,
        ]);
    }

    public function search(Request $request)
    {
        $query = $request->get('q');
        
        if (!$query) {
            return $this->index();
        }

        $areas = Area::where('is_active', 1)
            ->where('city', 'Lucknow')
            ->where('name', 'like', "%{$query}%")
            ->orderBy('name')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $areas,
        ]);
    }
}
