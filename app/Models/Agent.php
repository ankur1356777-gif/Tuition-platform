<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Agent extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'referral_code',
        'preferred_areas',
        'bank_name',
        'account_number',
        'ifsc_code',
        'upi_id',
        'commission_rate',
        'total_referrals',
        'active_referrals',
        'total_commission_earned',
        'address',
        'landmark',
        'city',
        'state',
        'pincode',
        'referrer_type',
    ];

    protected $casts = [
        'preferred_areas' => 'array',
        'commission_rate' => 'decimal:2',
        'total_commission_earned' => 'decimal:2',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function referrals()
    {
        return $this->hasMany(User::class , 'referred_by', 'user_id');
    }

    public function scopeParentReferrer($query)
    {
        return $query->where('referrer_type', 'parent');
    }

    public function scopeRegularReferrer($query)
    {
        return $query->where('referrer_type', 'regular');
    }
}
