@extends('layouts.admin')

@section('title', 'Attendance Logs')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">Operations / Attendance</div>
        <h1 class="page-title">Attendance Monitoring</h1>
    </div>
</div>

<div class="card">
    <div class="table-responsive">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Date & Time</th>
                    <th>Teacher</th>
                    <th>Student</th>
                    <th>Status</th>
                    <th>Location</th>
                    <th>Verification</th>
                </tr>
            </thead>
            <tbody>
                @forelse($attendance as $log)
                <tr>
                    <td>{{ $log->marked_at->format('M d, Y h:i A') }}</td>
                    <td>
                        <div style="font-weight: 600;">{{ $log->teacher->user->name }}</div>
                        <div style="font-size: 11px; color: var(--text-muted);">{{ $log->teacher->user->phone }}</div>
                    </td>
                    <td>{{ $log->paidTuition->student->user->name }}</td>
                    <td>
                        <span class="badge badge-{{ $log->status == 'present' ? 'success' : 'danger' }}">
                            {{ ucfirst($log->status) }}
                        </span>
                    </td>
                    <td>
                        <a href="https://www.google.com/maps?q={{ $log->latitude }},{{ $log->longitude }}" target="_blank" style="color: var(--primary); font-size: 12px;">
                            <i class="fas fa-location-dot"></i> View Map
                        </a>
                    </td>
                    <td>
                        @if($log->is_verified)
                            <span style="color: var(--success);"><i class="fas fa-check-circle"></i> Verified</span>
                        @else
                            <span style="color: var(--warning);"><i class="fas fa-clock"></i> Pending</span>
                        @endif
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="6" style="text-align: center; padding: 40px; color: var(--text-muted);">No attendance records found.</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
    <div style="margin-top: 24px;">
        {{ $attendance->links() }}
    </div>
</div>
@endsection
