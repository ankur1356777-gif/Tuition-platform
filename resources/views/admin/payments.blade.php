@extends('layouts.admin')

@section('title', 'Payout Requests')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">Finance / Payouts</div>
        <h1 class="page-title">Payout & Withdrawal Management</h1>
    </div>
</div>

<div class="card">
    <div class="table-responsive">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Request ID</th>
                    <th>User</th>
                    <th>Role</th>
                    <th>Amount</th>
                    <th>Method</th>
                    <th>Status</th>
                    <th>Requested At</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach($payouts as $payout)
                <tr>
                    <td>#{{ $payout->id }}</td>
                    <td>
                        <div style="font-weight: 600;">{{ $payout->user->name }}</div>
                        <div style="font-size: 11px; color: var(--text-muted);">{{ $payout->user->phone }}</div>
                    </td>
                    <td><span style="text-transform: capitalize;">{{ $payout->user->role }}</span></td>
                    <td><span style="font-weight: 700; color: var(--text-main);">₹{{ number_format($payout->amount, 2) }}</span></td>
                    <td>
                        <div style="font-size: 12px;">{{ $payout->payment_method }}</div>
                        <div style="font-size: 10px; color: var(--text-muted);">{{ $payout->account_details['account_number'] ?? 'N/A' }}</div>
                    </td>
                    <td>
                        <span class="badge badge-{{ $payout->status == 'paid' ? 'success' : ($payout->status == 'pending' ? 'warning' : 'danger') }}">
                            {{ ucfirst($payout->status) }}
                        </span>
                    </td>
                    <td style="font-size: 12px;">{{ $payout->created_at->format('d M, H:i') }}</td>
                    <td>
                        @if($payout->status == 'pending')
                        <div style="display: flex; gap: 8px;">
                            <form action="{{ route('admin.payments.update', $payout->id) }}" method="POST">
                                @csrf
                                <input type="hidden" name="status" value="paid">
                                <button type="submit" class="btn" style="background: rgba(16, 185, 129, 0.1); color: #10b981; padding: 6px 10px;">
                                    <i class="fas fa-check"></i>
                                </button>
                            </form>
                            <form action="{{ route('admin.payments.update', $payout->id) }}" method="POST">
                                @csrf
                                <input type="hidden" name="status" value="rejected">
                                <button type="submit" class="btn" style="background: rgba(239, 68, 68, 0.1); color: #ef4444; padding: 6px 10px;">
                                    <i class="fas fa-times"></i>
                                </button>
                            </form>
                        </div>
                        @else
                        <span class="badge badge-{{ $payout->status == 'paid' ? 'success' : 'danger' }}" style="font-size: 11px;">
                            {{ ucfirst($payout->status) }}
                        </span>
                        @endif
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
    
    <div style="margin-top: 24px;">
        {{ $payouts->links() }}
    </div>
</div>
@endsection
