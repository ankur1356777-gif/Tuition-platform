@extends('layouts.admin')

@section('title', 'Dashboard')

@section('styles')
<style>
    .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
        gap: 24px;
        margin-bottom: 32px;
    }

    .stat-card {
        padding: 24px;
        border-radius: 16px;
        background: var(--surface);
        box-shadow: var(--shadow);
        display: flex;
        justify-content: space-between;
        align-items: center;
        transition: transform 0.2s;
    }

    .stat-card:hover {
        transform: translateY(-5px);
    }

    .stat-info h3 {
        font-size: 14px;
        color: var(--text-muted);
        margin-bottom: 8px;
        font-weight: 500;
    }

    .stat-info .value {
        font-size: 28px;
        font-weight: 700;
        color: var(--text-main);
    }

    .stat-icon {
        width: 56px;
        height: 56px;
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 24px;
    }

    .icon-teachers { background: rgba(79, 70, 229, 0.1); color: #4f46e5; }
    .icon-students { background: rgba(16, 185, 129, 0.1); color: #10b981; }
    .icon-revenue { background: rgba(245, 158, 11, 0.1); color: #f59e0b; }
    .icon-payouts { background: rgba(239, 68, 68, 0.1); color: #ef4444; }

    .dashboard-grid {
        display: grid;
        grid-template-columns: 2fr 1fr;
        gap: 24px;
    }

    .table-responsive {
        width: 100%;
        overflow-x: auto;
    }

    table {
        width: 100%;
        border-collapse: collapse;
    }

    th {
        text-align: left;
        padding: 12px 16px;
        font-size: 12px;
        color: var(--text-muted);
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border-bottom: 2px solid #f1f5f9;
        font-weight: 600;
    }

    td {
        padding: 16px;
        border-bottom: 1px solid #f1f5f9;
        font-size: 14px;
    }

    .user-table-info {
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .user-table-info img {
        width: 32px;
        height: 32px;
        border-radius: 50%;
    }

    .activity-list {
        list-style: none;
    }

    .activity-item {
        display: flex;
        gap: 16px;
        padding: 16px 0;
        border-bottom: 1px solid #f1f5f9;
    }

    .activity-item:last-child {
        border-bottom: none;
    }

    .activity-point {
        width: 12px;
        height: 12px;
        border-radius: 50%;
        margin-top: 4px;
        flex-shrink: 0;
    }

    .activity-content p {
        font-size: 13px;
        margin-bottom: 4px;
    }

    .activity-content span {
        font-size: 11px;
        color: var(--text-muted);
    }
</style>
@endsection

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">Overview / Dashboard</div>
        <h1 class="page-title">Platform Dashboard</h1>
    </div>
    <div class="header-btns" style="display: flex; gap: 12px;">
        <a href="{{ route('admin.users.create', ['role' => 'teacher']) }}" class="btn btn-primary" style="background: #10b981;">
            <i class="fas fa-plus"></i> Add New Teacher
        </a>
        <a href="{{ route('admin.notifications') }}" class="btn btn-primary">
            <i class="fas fa-paper-plane"></i> Broadcast Message
        </a>
    </div>
</div>

<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-info">
            <h3>Total Teachers</h3>
            <div class="value">{{ $stats['total_teachers'] }}</div>
        </div>
        <div class="stat-icon icon-teachers">
            <i class="fas fa-chalkboard-teacher"></i>
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-info">
            <h3>Total Students</h3>
            <div class="value">{{ $stats['total_students'] }}</div>
        </div>
        <div class="stat-icon icon-students">
            <i class="fas fa-user-graduate"></i>
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-info">
            <h3>Total Revenue</h3>
            <div class="value">₹{{ number_format($stats['total_revenue'], 2) }}</div>
        </div>
        <div class="stat-icon icon-revenue">
            <i class="fas fa-money-bill-wave"></i>
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-info">
            <h3>Pending Payouts</h3>
            <div class="value">{{ $stats['pending_payouts'] }}</div>
        </div>
        <div class="stat-icon icon-payouts">
            <i class="fas fa-hand-holding-usd"></i>
        </div>
    </div>
</div>

<div class="dashboard-grid">
    <div class="card">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
            <h2 style="font-size: 18px; font-weight: 700;">Recent Leads & Assignments</h2>
            <a href="{{ route('admin.leads') }}" style="font-size: 13px; color: var(--primary); text-decoration: none; font-weight: 600;">View All</a>
        </div>
        
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Teacher</th>
                        <th>Student</th>
                        <th>Subject</th>
                        <th>Distance</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($stats['recent_leads'] as $lead)
                    <tr>
                        <td>
                            <div class="user-table-info">
                                <div class="user-avatar" style="width: 28px; height: 28px; font-size: 10px;">{{ substr($lead->teacher->user->name, 0, 1) }}</div>
                                {{ $lead->teacher->user->name }}
                            </div>
                        </td>
                        <td>{{ $lead->tuitionRequest->student->user->name }}</td>
                        <td>{{ is_array($lead->tuitionRequest->subjects) ? implode(', ', $lead->tuitionRequest->subjects) : $lead->tuitionRequest->subjects }}</td>
                        <td>{{ $lead->distance_km }} km</td>
                        <td>
                            <span class="badge badge-{{ $lead->status == 'accepted' ? 'success' : ($lead->status == 'sent' ? 'pending' : 'danger') }}">
                                {{ ucfirst($lead->status) }}
                            </span>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="5" style="text-align: center; color: var(--text-muted); padding: 32px;">No recent leads found.</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <div class="card">
        <h2 style="font-size: 18px; font-weight: 700; margin-bottom: 24px;">Platform Activity</h2>
        <ul class="activity-list">
            @php
                $activities = [
                    ['bg' => 'var(--primary)', 'text' => 'New teacher registered', 'user' => 'Rajesh Kumar', 'time' => '10 mins ago'],
                    ['bg' => 'var(--success)', 'text' => 'Demo class completed', 'user' => 'Maths - Grade 10', 'time' => '1 hour ago'],
                    ['bg' => 'var(--warning)', 'text' => 'New tuition request', 'user' => 'Suresh Raina', 'time' => '2 hours ago'],
                    ['bg' => 'var(--danger)', 'text' => 'Payout request failed', 'user' => 'Teacher ID #44', 'time' => '5 hours ago'],
                ];
            @endphp

            @foreach($activities as $activity)
            <li class="activity-item">
                <div class="activity-point" style="background: {{ $activity['bg'] }}"></div>
                <div class="activity-content">
                    <p><strong>{{ $activity['user'] }}</strong> {{ $activity['text'] }}</p>
                    <span>{{ $activity['time'] }}</span>
                </div>
            </li>
            @endforeach
        </ul>
    </div>
</div>
@endsection
