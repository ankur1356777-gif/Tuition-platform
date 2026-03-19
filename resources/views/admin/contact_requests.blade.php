@extends('layouts.admin')

@section('title', 'Contact Requests')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">Education Management / Contact Requests</div>
        <h1 class="page-title">Contact Sharing Requests</h1>
    </div>
</div>

<div class="alert" style="background: #dbeafe; color: #1e40af;">
    <i class="fas fa-info-circle"></i>
    Teachers must request approval before viewing student contact details. Review and approve/reject requests below.
</div>

<div class="card">
    <h5 style="font-weight: 600; margin-bottom: 20px;"><i class="fas fa-clock text-warning"></i> Pending Contact Requests</h5>
    
    <div class="table-responsive">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Teacher</th>
                    <th>Student</th>
                    <th>Subject / Class</th>
                    <th>Area</th>
                    <th>Requested At</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($requests as $lead)
                <tr>
                    <td>
                        <div class="user-table-info">
                            <div class="user-avatar">{{ substr($lead->teacher->user->name ?? 'T', 0, 1) }}</div>
                            <div>
                                <div style="font-weight: 600;">{{ $lead->teacher->user->name ?? 'N/A' }}</div>
                                <div style="font-size: 11px; color: var(--text-muted);">{{ $lead->teacher->user->phone ?? '' }}</div>
                            </div>
                        </div>
                    </td>
                    <td>
                        <div style="font-weight: 600;">{{ $lead->tuitionRequest->student->user->name ?? 'N/A' }}</div>
                        <div style="font-size: 11px; color: var(--text-muted);">
                            <i class="fas fa-phone"></i> {{ $lead->tuitionRequest->student->user->phone ?? 'Hidden' }}
                        </div>
                    </td>
                    <td>
                        <span class="badge bg-primary">{{ $lead->tuitionRequest->subject ?? 'N/A' }}</span>
                        <span class="badge bg-secondary">Class {{ $lead->tuitionRequest->class ?? 'N/A' }}</span>
                    </td>
                    <td>{{ $lead->tuitionRequest->area->name ?? 'N/A' }}</td>
                    <td>{{ $lead->contact_requested_at ? \Carbon\Carbon::parse($lead->contact_requested_at)->format('d M Y H:i') : 'N/A' }}</td>
                    <td>
                        <div style="display: flex; gap: 8px;">
                            <form action="{{ route('admin.leads.approve_contact', $lead->id) }}" method="POST">
                                @csrf
                                <button type="submit" class="btn btn-sm" style="background: rgba(16, 185, 129, 0.1); color: #10b981;">
                                    <i class="fas fa-check"></i> Approve
                                </button>
                            </form>
                            <form action="{{ route('admin.leads.reject_contact', $lead->id) }}" method="POST">
                                @csrf
                                <button type="submit" class="btn btn-sm" style="background: rgba(239, 68, 68, 0.1); color: #ef4444;">
                                    <i class="fas fa-times"></i> Reject
                                </button>
                            </form>
                            <form action="{{ route('admin.leads.schedule_demo', $lead->id) }}" method="POST" onsubmit="return promptSchedule(this)">
                                @csrf
                                <input type="hidden" name="scheduled_at" id="scheduledAt{{ $lead->id }}">
                                <button type="submit" class="btn btn-sm btn-primary">
                                    <i class="fas fa-calendar"></i> Schedule Demo
                                </button>
                            </form>
                        </div>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="6" class="text-center text-muted py-4">No pending contact requests</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>

<div class="card">
    <h5 style="font-weight: 600; margin-bottom: 20px;"><i class="fas fa-check-circle text-success"></i> Recently Approved</h5>
    
    <div class="table-responsive">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Teacher</th>
                    <th>Student</th>
                    <th>Subject</th>
                    <th>Shared At</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                @forelse($approvedRequests ?? [] as $lead)
                <tr>
                    <td>{{ $lead->teacher->user->name ?? 'N/A' }}</td>
                    <td>{{ $lead->tuitionRequest->student->user->name ?? 'N/A' }}</td>
                    <td><span class="badge bg-primary">{{ $lead->tuitionRequest->subject ?? 'N/A' }}</span></td>
                    <td>{{ $lead->contact_shared_at ? \Carbon\Carbon::parse($lead->contact_shared_at)->format('d M Y H:i') : 'N/A' }}</td>
                    <td><span class="badge badge-success">Contact Shared</span></td>
                </tr>
                @empty
                <tr>
                    <td colspan="5" class="text-center text-muted py-4">No recently approved requests</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection

@section('scripts')
<script>
function promptSchedule(form) {
    const date = prompt('Enter demo date and time (YYYY-MM-DD HH:MM):');
    if (date) {
        const input = form.querySelector('input[name="scheduled_at"]');
        input.value = date;
        return true;
    }
    return false;
}
</script>
@endsection
