@extends('layouts.admin')

@section('title', 'Teaching Plans')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">Education Management / Teaching Plans</div>
        <h1 class="page-title">Teaching Plans</h1>
    </div>
</div>

<div class="card">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div class="d-flex gap-2">
            <select class="form-select" id="statusFilter" style="width: 200px;">
                <option value="">All Status</option>
                <option value="planned">Planned</option>
                <option value="in_progress">In Progress</option>
                <option value="completed">Completed</option>
                <option value="incomplete">Incomplete</option>
            </select>
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Teacher</th>
                    <th>Student</th>
                    <th>Week</th>
                    <th>Planned Topics</th>
                    <th>Completed</th>
                    <th>Status</th>
                    <th>Incomplete Reason</th>
                </tr>
            </thead>
            <tbody>
                @forelse($plans as $plan)
                <tr>
                    <td>{{ $plan->teacher->user->name ?? 'N/A' }}</td>
                    <td>{{ $plan->paidTuition->student->user->name ?? 'N/A' }}</td>
                    <td>
                        <div style="font-weight: 600;">{{ \Carbon\Carbon::parse($plan->week_start)->format('d M') }}</div>
                        <div style="font-size: 11px; color: var(--text-muted);">to {{ \Carbon\Carbon::parse($plan->week_start)->addDays(6)->format('d M Y') }}</div>
                    </td>
                    <td>
                        @php
                            $topics = json_decode($plan->planned_topics, true) ?? [];
                        @endphp
                        <span class="badge bg-primary">{{ count($topics) }} topics</span>
                    </td>
                    <td>
                        @php
                            $completed = json_decode($plan->completed_topics, true) ?? [];
                        @endphp
                        <span class="badge bg-success">{{ count($completed) }} done</span>
                    </td>
                    <td>
                        @if($plan->status == 'completed')
                            <span class="badge badge-success">Completed</span>
                        @elseif($plan->status == 'incomplete')
                            <span class="badge badge-danger">Incomplete</span>
                        @elseif($plan->status == 'in_progress')
                            <span class="badge" style="background: #dbeafe; color: #1e40af;">In Progress</span>
                        @else
                            <span class="badge badge-pending">Planned</span>
                        @endif
                    </td>
                    <td>
                        @if($plan->status == 'incomplete' && $plan->incomplete_reason)
                            <div style="max-width: 200px; font-size: 12px; color: #991b1b;">
                                <i class="fas fa-exclamation-circle"></i>
                                {{ Str::limit($plan->incomplete_reason, 100) }}
                            </div>
                        @else
                            <span class="text-muted">-</span>
                        @endif
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="7" class="text-center text-muted py-4">No teaching plans found</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
    
    <div style="margin-top: 24px;">
        {{ $plans->links() }}
    </div>
</div>
@endsection
