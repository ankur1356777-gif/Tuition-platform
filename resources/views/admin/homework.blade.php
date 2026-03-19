@extends('layouts.admin')

@section('title', 'Homework Management')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">Education Management / Homework</div>
        <h1 class="page-title">Homework Management</h1>
    </div>
</div>

<div class="card">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <select class="form-select" id="statusFilter" style="width: 200px;" onchange="filterByStatus()">
                <option value="">All Status</option>
                <option value="pending">Pending</option>
                <option value="submitted">Submitted</option>
                <option value="reviewed">Reviewed</option>
            </select>
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Title</th>
                    <th>Teacher</th>
                    <th>Student</th>
                    <th>Subject</th>
                    <th>Due Date</th>
                    <th>Status</th>
                    <th>Submissions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($homework as $hw)
                <tr>
                    <td>
                        <div style="font-weight: 600;">{{ $hw->title }}</div>
                        <div style="font-size: 12px; color: var(--text-muted);">{{ Str::limit($hw->description, 50) }}</div>
                    </td>
                    <td>{{ $hw->teacher->user->name ?? 'N/A' }}</td>
                    <td>{{ $hw->paidTuition->student->user->name ?? 'N/A' }}</td>
                    <td>{{ $hw->subject }}</td>
                    <td>
                        <span class="{{ \Carbon\Carbon::parse($hw->due_date)->isPast() ? 'text-danger' : '' }}">
                            {{ \Carbon\Carbon::parse($hw->due_date)->format('d M Y') }}
                        </span>
                    </td>
                    <td>
                        @if($hw->status == 'pending')
                            <span class="badge badge-pending">Pending</span>
                        @elseif($hw->status == 'submitted')
                            <span class="badge" style="background: #dbeafe; color: #1e40af;">Submitted</span>
                        @else
                            <span class="badge badge-success">Reviewed</span>
                        @endif
                    </td>
                    <td>
                        <span class="badge bg-secondary">{{ $hw->submissions->count() }}</span>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="7" class="text-center text-muted py-4">No homework found</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
    
    <div style="margin-top: 24px;">
        {{ $homework->links() }}
    </div>
</div>
@endsection
