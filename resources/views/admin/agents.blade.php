@extends('layouts.admin')

@section('title', 'Manage Agents')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">User Management / Agents</div>
        <h1 class="page-title">Agent & Referral Management</h1>
    </div>
    <div class="header-btns">
        <a href="{{ route('admin.users.create', ['role' => 'agent']) }}" class="btn btn-primary">
            <i class="fas fa-plus"></i> Add New Agent
        </a>
    </div>
</div>

<div class="card">
    <div class="table-responsive">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Agent Name</th>
                    <th>Phone</th>
                    <th>Referral Code</th>
                    <th>Total Earnings</th>
                    <th>Wallet Balance</th>
                    <th>Status</th>
                    <th>Joined</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach($agents as $agentUser)
                <tr>
                    <td>
                        <div class="user-table-info">
                            <div class="user-avatar" style="background: rgba(245, 158, 11, 0.1); color: #f59e0b;">{{ substr($agentUser->name, 0, 1) }}</div>
                            <div>
                                <div style="font-weight: 600;">{{ $agentUser->name }}</div>
                                <div style="font-size: 11px; color: var(--text-muted);">{{ $agentUser->email }}</div>
                            </div>
                        </div>
                    </td>
                    <td>{{ $agentUser->phone }}</td>
                    <td><code style="background: #f1f5f9; padding: 4px 8px; border-radius: 4px;">{{ $agentUser->agent->referral_code ?? 'N/A' }}</code></td>
                    <td><span style="font-weight: 700; color: var(--success);">₹{{ number_format($agentUser->agent->total_earnings ?? 0, 2) }}</span></td>
                    <td><span style="font-weight: 700;">₹{{ number_format($agentUser->agent->wallet_balance ?? 0, 2) }}</span></td>
                    <td>
                        <span class="badge badge-{{ $agentUser->status == 'approved' ? 'success' : ($agentUser->status == 'pending' ? 'pending' : 'danger') }}">
                            {{ ucfirst($agentUser->status) }}
                        </span>
                    </td>
                    <td>{{ $agentUser->created_at->format('d M Y') }}</td>
                    <td>
                        <div style="display: flex; gap: 8px;">
                            @if($agentUser->status == 'pending')
                            <form action="{{ route('admin.agents.verify', $agentUser->id) }}" method="POST">
                                @csrf
                                <input type="hidden" name="status" value="approved">
                                <button type="submit" class="btn" style="background: rgba(16, 185, 129, 0.1); color: #10b981; padding: 6px 12px; font-size: 12px;">
                                    <i class="fas fa-check"></i>
                                </button>
                            </form>
                            @endif
                            <a href="#" class="btn" style="background: rgba(79, 70, 229, 0.1); color: #4f46e5; padding: 6px 12px; font-size: 12px;">
                                <i class="fas fa-eye"></i>
                            </a>
                            @if($agentUser->status != 'rejected')
                            <form action="{{ route('admin.agents.verify', $agentUser->id) }}" method="POST">
                                @csrf
                                <input type="hidden" name="status" value="rejected">
                                <button type="submit" class="btn" style="background: rgba(239, 68, 68, 0.1); color: #ef4444; padding: 6px 12px; font-size: 12px;">
                                    <i class="fas fa-ban"></i>
                                </button>
                            </form>
                            @endif
                        </div>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
    
    <div style="margin-top: 24px;">
        {{ $agents->links() }}
    </div>
</div>
@endsection
