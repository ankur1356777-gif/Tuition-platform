@extends('layouts.admin')

@section('title', 'Teacher Leaves')

@section('content')
<div class="page-header">
    <div>
        <p class="breadcrumb">Operations / Teacher Leaves</p>
        <h1 class="page-title">Teacher Leave Management</h1>
    </div>
</div>

<!-- Stats -->
<div class="row mb-4">
    <div class="col-md-3">
        <div class="card text-center" style="border-left: 4px solid var(--primary);">
            <div class="h4 mb-0">{{ $stats['total'] }}</div>
            <div class="text-muted">Total Requests</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card text-center" style="border-left: 4px solid var(--warning);">
            <div class="h4 mb-0">{{ $stats['pending'] }}</div>
            <div class="text-muted">Pending</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card text-center" style="border-left: 4px solid var(--success);">
            <div class="h4 mb-0">{{ $stats['approved'] }}</div>
            <div class="text-muted">Approved</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card text-center" style="border-left: 4px solid var(--danger);">
            <div class="h4 mb-0">{{ $stats['rejected'] }}</div>
            <div class="text-muted">Rejected</div>
        </div>
    </div>
</div>

<!-- Filters -->
<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">Leave Requests</h5>
        <form method="GET" class="d-flex gap-2">
            <select name="status" class="form-select" style="width: 150px;" onchange="this.form.submit()">
                <option value="">All Status</option>
                <option value="pending" {{ request('status') == 'pending' ? 'selected' : '' }}>Pending</option>
                <option value="approved" {{ request('status') == 'approved' ? 'selected' : '' }}>Approved</option>
                <option value="rejected" {{ request('status') == 'rejected' ? 'selected' : '' }}>Rejected</option>
            </select>
            <select name="leave_type" class="form-select" style="width: 150px;" onchange="this.form.submit()">
                <option value="">All Types</option>
                <option value="auto" {{ request('leave_type') == 'auto' ? 'selected' : '' }}>Auto-Approved</option>
                <option value="requested" {{ request('leave_type') == 'requested' ? 'selected' : '' }}>Requested</option>
            </select>
        </form>
    </div>
    <div class="card-body">
        @if($leaves->count() > 0)
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Teacher</th>
                        <th>Duration</th>
                        <th>Days</th>
                        <th>Reason</th>
                        <th>Type</th>
                        <th>Status</th>
                        <th>Requested At</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($leaves as $leave)
                    <tr>
                        <td>
                            <strong>{{ $leave->teacher->user->name ?? 'N/A' }}</strong>
                            <br><small class="text-muted">{{ $leave->teacher->user->phone ?? '' }}</small>
                        </td>
                        <td>
                            {{ $leave->start_date->format('d M') }} - {{ $leave->end_date->format('d M Y') }}
                        </td>
                        <td>
                            <span class="badge bg-secondary">
                                {{ $leave->end_date->diffInDays($leave->start_date) + 1 }} day(s)
                            </span>
                        </td>
                        <td style="max-width: 200px;">
                            {{ $leave->reason ?: '-' }}
                        </td>
                        <td>
                            @if($leave->leave_type === 'auto')
                                <span class="badge" style="background: #d1fae5; color: #065f46;">Auto</span>
                            @else
                                <span class="badge" style="background: #dbeafe; color: #1e40af;">Requested</span>
                            @endif
                        </td>
                        <td>
                            @if($leave->status === 'approved')
                                <span class="badge badge-success"><i class="fas fa-check me-1"></i>Approved</span>
                            @elseif($leave->status === 'rejected')
                                <span class="badge badge-danger"><i class="fas fa-times me-1"></i>Rejected</span>
                            @else
                                <span class="badge badge-pending"><i class="fas fa-clock me-1"></i>Pending</span>
                            @endif
                        </td>
                        <td>
                            {{ $leave->created_at->format('d M Y') }}
                            <br><small class="text-muted">{{ $leave->created_at->diffForHumans() }}</small>
                        </td>
                        <td>
                            @if($leave->status === 'pending')
                            <div class="btn-group">
                                <form action="{{ route('admin.leaves.approve', $leave->id) }}" method="POST" class="d-inline">
                                    @csrf
                                    <button type="submit" class="btn btn-sm btn-outline-success" title="Approve">
                                        <i class="fas fa-check"></i>
                                    </button>
                                </form>
                                <form action="{{ route('admin.leaves.reject', $leave->id) }}" method="POST" class="d-inline">
                                    @csrf
                                    <button type="submit" class="btn btn-sm btn-outline-danger" title="Reject">
                                        <i class="fas fa-times"></i>
                                    </button>
                                </form>
                            </div>
                            @else
                                <span class="text-muted">-</span>
                            @endif
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
        
        <div class="d-flex justify-content-center mt-4">
            {{ $leaves->appends(request()->query())->links() }}
        </div>
        @else
        <div class="text-center py-5">
            <i class="fas fa-calendar-times fa-3x text-muted mb-3"></i>
            <p class="text-muted">No leave requests found</p>
        </div>
        @endif
    </div>
</div>
@endsection
