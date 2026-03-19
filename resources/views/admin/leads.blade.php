@extends('layouts.admin')

@section('title', 'Lead Monitoring')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">Operations / Leads</div>
        <h1 class="page-title">Lead Monitoring Dashboard</h1>
    </div>
</div>

<div class="card">
    <div class="table-responsive">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Lead ID</th>
                    <th>Teacher</th>
                    <th>Student</th>
                    <th>Subject & Class</th>
                    <th>Match Score</th>
                    <th>Distance</th>
                    <th>Status</th>
                    <th>Time</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach($leads as $lead)
                <tr>
                    <td>#{{ $lead->id }}</td>
                    <td>
                        <div style="font-weight: 600;">{{ $lead->teacher->user->name }}</div>
                        <div style="font-size: 11px; color: var(--text-muted);">{{ $lead->teacher->user->phone }}</div>
                    </td>
                    <td>
                        <div style="font-weight: 600;">{{ $lead->tuitionRequest->student->user->name }}</div>
                        <div style="font-size: 11px; color: var(--text-muted);">{{ $lead->tuitionRequest->student->user->phone }}</div>
                    </td>
                    <td>
                        <div style="font-weight: 500;">{{ is_array($lead->tuitionRequest->subjects) ? implode(', ', $lead->tuitionRequest->subjects) : $lead->tuitionRequest->subjects }}</div>
                        <div style="font-size: 11px; color: var(--text-muted);">Grade {{ $lead->tuitionRequest->class }}</div>
                    </td>
                    <td>
                        <div style="display: flex; align-items: center; gap: 6px;">
                            <div style="width: 40px; height: 6px; background: #f1f5f9; border-radius: 3px; overflow: hidden;">
                                <div style="width: {{ $lead->match_score }}%; height: 100%; background: var(--primary);"></div>
                            </div>
                            <span style="font-size: 12px; font-weight: 600;">{{ $lead->match_score }}%</span>
                        </div>
                    </td>
                    <td>{{ $lead->distance_km }} km</td>
                    <td>
                        <span class="badge badge-{{ $lead->status == 'accepted' ? 'success' : ($lead->status == 'sent' ? 'pending' : 'danger') }}">
                            {{ ucfirst($lead->status) }}
                        </span>
                    </td>
                    <td style="font-size: 12px; color: var(--text-muted);">
                        {{ $lead->created_at->diffForHumans() }}
                    </td>
                    <td>
                        <div style="display: flex; gap: 8px; flex-direction: column;">
                            <form action="{{ route('admin.leads.toggle_contact', $lead->id) }}" method="POST">
                                @csrf
                                <button type="submit" class="btn" style="width: 100%; background: {{ $lead->is_contact_shared ? 'rgba(16, 185, 129, 0.1)' : 'rgba(79, 70, 229, 0.1)' }}; color: {{ $lead->is_contact_shared ? '#10b981' : '#4f46e5' }}; padding: 6px 12px; font-size: 11px; border: none; cursor: pointer; border-radius: 4px;">
                                    <i class="fas {{ $lead->is_contact_shared ? 'fa-eye' : 'fa-eye-slash' }}"></i>
                                    {{ $lead->is_contact_shared ? 'Hide Contact' : 'Share Contact' }}
                                </button>
                            </form>
                            
                            @if($lead->status == 'accepted')
                            <form action="{{ route('admin.leads.convert', $lead->id) }}" method="POST">
                                @csrf
                                <button type="submit" class="btn" style="width: 100%; background: #10b981; color: white; padding: 6px 12px; font-size: 11px; border: none; cursor: pointer; border-radius: 4px;" onclick="return confirm('Convert this lead to an active paid tuition?')">
                                    <i class="fas fa-check-circle"></i> Confirm Tuition
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
        {{ $leads->links() }}
    </div>
</div>
@endsection
