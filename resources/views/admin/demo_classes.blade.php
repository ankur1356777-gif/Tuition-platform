@extends('layouts.admin')

@section('title', 'Demo Classes')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">Operations / Demo Classes</div>
        <h1 class="page-title">Demo Class Management</h1>
    </div>
</div>

<div class="card">
    <div class="table-responsive">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Lead Info</th>
                    <th>Teacher</th>
                    <th>Student</th>
                    <th>Scheduled At</th>
                    <th>Status</th>
                    <th>Feedback</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($demoClasses as $demo)
                <tr>
                    <td>
                        <span style="font-size: 12px; color: var(--text-muted);">ID: #{{ $demo->lead->id ?? 'N/A' }}</span>
                        <div style="font-weight: 500;">{{ $demo->lead->tuitionRequest->subjects[0] ?? 'Subject' }}</div>
                    </td>
                    <td>
                        <div style="font-weight: 600;">{{ $demo->lead->teacher->user->name ?? 'N/A' }}</div>
                        <div style="font-size: 11px; color: var(--text-muted);">{{ $demo->lead->teacher->user->phone ?? '' }}</div>
                    </td>
                    <td>
                        <div style="font-weight: 600;">{{ $demo->lead->tuitionRequest->student->user->name ?? 'N/A' }}</div>
                    </td>
                    <td>{{ $demo->scheduled_at ? $demo->scheduled_at->format('d M, h:i A') : 'Not Scheduled' }}</td>
                    <td>
                        <span class="badge badge-{{ $demo->status == 'completed' ? 'success' : ($demo->status == 'scheduled' ? 'warning' : 'danger') }}">
                            {{ ucfirst($demo->status) }}
                        </span>
                    </td>
                    <td>
                        {{ Str::limit($demo->feedback ?? 'No feedback', 30) }}
                    </td>
                    <td>
                         <div style="display: flex; gap: 8px;">
                            <a href="#" class="btn" style="background: rgba(79, 70, 229, 0.1); color: #4f46e5; padding: 6px 12px; font-size: 12px;">
                                <i class="fas fa-eye"></i>
                            </a>
                        </div>
                    </td>
                </tr>
                @empty
                 <tr>
                    <td colspan="7" style="text-align: center; padding: 20px; color: var(--text-muted);">No demo classes found.</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
    
    <div style="margin-top: 24px;">
        {{ $demoClasses->links() }}
    </div>
</div>
@endsection
