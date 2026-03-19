@extends('layouts.admin')

@section('title', 'Transactions')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">Finance / Transactions</div>
        <h1 class="page-title">Transaction History</h1>
    </div>
    <div class="header-btns">
        <a href="#" class="btn btn-primary">
            <i class="fas fa-file-export"></i> Export CSV
        </a>
    </div>
</div>

<div class="card">
    <div class="table-responsive">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Reference ID</th>
                    <th>User</th>
                    <th>Amount</th>
                    <th>Type</th>
                    <th>Status</th>
                    <th>Description</th>
                    <th>Date</th>
                </tr>
            </thead>
            <tbody>
                @forelse($transactions as $transaction)
                <tr>
                    <td><code style="font-size: 11px;">{{ $transaction->reference_id ?? '#'.$transaction->id }}</code></td>
                    <td>
                        <div style="font-weight: 600;">{{ $transaction->user->name ?? 'N/A' }}</div>
                        <div style="font-size: 11px; color: var(--text-muted); text-transform: capitalize;">{{ $transaction->user->role ?? '' }}</div>
                    </td>
                    <td>
                        <span style="font-weight: 700; color: {{ $transaction->type == 'credit' ? 'var(--success)' : 'var(--danger)' }}">
                            {{ $transaction->type == 'credit' ? '+' : '-' }}₹{{ number_format($transaction->amount, 2) }}
                        </span>
                    </td>
                    <td>
                        <span style="text-transform: capitalize; font-size: 12px; font-weight: 500;">{{ $transaction->type }}</span>
                    </td>
                    <td>
                        <span class="badge badge-{{ $transaction->status == 'completed' ? 'success' : ($transaction->status == 'pending' ? 'warning' : 'danger') }}">
                            {{ ucfirst($transaction->status) }}
                        </span>
                    </td>
                    <td style="font-size: 13px;">{{ $transaction->description }}</td>
                    <td style="font-size: 12px; color: var(--text-muted);">{{ $transaction->created_at->format('d M Y, H:i') }}</td>
                </tr>
                @empty
                <tr>
                    <td colspan="7" style="text-align: center; padding: 40px; color: var(--text-muted);">
                        <i class="fas fa-exchange-alt" style="font-size: 24px; margin-bottom: 12px; display: block;"></i>
                        No transactions found.
                    </td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
    
    <div style="margin-top: 24px;">
        {{ $transactions->links() }}
    </div>
</div>
@endsection
