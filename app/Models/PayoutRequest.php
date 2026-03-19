<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PayoutRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'amount',
        'status',
        'payment_method',
        'account_details',
    ];

    protected $casts = [
        'account_details' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
