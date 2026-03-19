@extends('layouts.admin')

@section('title', 'Teacher Details')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">User Management / Teachers / Details</div>
        <h1 class="page-title">{{ $teacher->name }}</h1>
    </div>
    <div class="header-btns">
        <a href="{{ route('admin.teachers') }}" class="btn" style="background: #e5e7eb; color: #374151;">
            <i class="fas fa-arrow-left"></i> Back to List
        </a>
    </div>
</div>

<div style="display: grid; grid-template-columns: 1fr 2fr; gap: 24px;">
    <!-- Profile Card -->
    <div>
        <div class="card" style="text-align: center; padding: 32px 24px;">
            <div class="user-avatar" style="width: 80px; height: 80px; font-size: 32px; margin: 0 auto 16px auto;">{{ substr($teacher->name, 0, 1) }}</div>
            <h2 style="margin: 0; font-size: 20px;">{{ $teacher->name }}</h2>
            <p style="color: var(--text-muted); margin: 4px 0 16px 0;">Teacher ID: #TCH{{ $teacher->id }}</p>
            <span class="badge badge-{{ $teacher->status == 'approved' ? 'success' : 'warning' }}" style="padding: 6px 16px;">
                {{ ucfirst($teacher->status) }}
            </span>
            
            <div style="margin-top: 32px; text-align: left; border-top: 1px solid #f3f4f6; padding-top: 24px;">
                <div style="margin-bottom: 16px;">
                    <div style="font-size: 12px; color: var(--text-muted); margin-bottom: 4px;">Phone Number</div>
                    <div style="font-weight: 500;">{{ $teacher->phone }}</div>
                </div>
                <div style="margin-bottom: 16px;">
                    <div style="font-size: 12px; color: var(--text-muted); margin-bottom: 4px;">Email Address</div>
                    <div style="font-weight: 500;">{{ $teacher->email ?? 'N/A' }}</div>
                </div>
                <div style="margin-bottom: 16px;">
                    <div style="font-size: 12px; color: var(--text-muted); margin-bottom: 4px;">Joined On</div>
                    <div style="font-weight: 500;">{{ $teacher->created_at->format('d M, Y') }}</div>
                </div>
            </div>
        </div>

        <div class="card" style="margin-top: 24px;">
            <h3 style="font-size: 16px; margin-bottom: 16px;">Qualifications</h3>
            @php $quals = is_array(optional($teacher->teacher)->qualifications) ? $teacher->teacher->qualifications : json_decode(optional($teacher->teacher)->qualifications ?? '[]', true); @endphp
            @if(is_array($quals) && count($quals) > 0)
                <ul style="padding-left: 20px; color: var(--text-muted);">
                    @foreach($quals as $q)
                        <li style="margin-bottom: 8px;">{{ $q }}</li>
                    @endforeach
                </ul>
            @else
                <p style="color: var(--text-muted); font-size: 14px;">No qualifications listed.</p>
            @endif
        </div>

        <div class="card" style="margin-top: 24px;">
            <h3 style="font-size: 16px; margin-bottom: 16px;">Uploaded Documents</h3>
            @php $docs = is_array(optional($teacher->teacher)->documents) ? $teacher->teacher->documents : json_decode(optional($teacher->teacher)->documents ?? '[]', true); @endphp
            @if(is_array($docs) && count($docs) > 0)
                <div style="display: flex; flex-direction: column; gap: 12px;">
                    @foreach($docs as $label => $url)
                        <div style="padding: 12px; background: #f8fafc; border-radius: 8px; border: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
                            <span style="font-size: 13px; font-weight: 500;">{{ ucfirst(str_replace('_', ' ', $label)) }}</span>
                            <a href="{{ asset('storage/' . $url) }}" target="_blank" class="btn" style="padding: 4px 12px; font-size: 12px; background: var(--primary); color: white;">
                                <i class="fas fa-external-link-alt"></i> View
                            </a>
                        </div>
                    @endforeach
                </div>
            @else
                <p style="color: var(--text-muted); font-size: 14px;">No documents uploaded yet.</p>
            @endif
        </div>
    </div>

    <!-- Main Info -->
    <div>
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 24px;">
            <div class="card" style="padding: 20px; border-left: 4px solid var(--primary-color);">
                <div style="font-size: 12px; color: var(--text-muted);">Experience</div>
                <div style="font-size: 24px; font-weight: 700;">{{ $teacher->teacher->experience_years ?? 0 }} Years</div>
            </div>
            <div class="card" style="padding: 20px; border-left: 4px solid #10b981;">
                <div style="font-size: 12px; color: var(--text-muted);">Wallet Balance</div>
                <div style="font-size: 24px; font-weight: 700;">₹{{ $teacher->wallet ? $teacher->wallet->balance : 0 }}</div>
            </div>
            <div class="card" style="padding: 20px; border-left: 4px solid #f59e0b;">
                <div style="font-size: 12px; color: var(--text-muted);">Active Classes</div>
                <div style="font-size: 24px; font-weight: 700;">{{ count($activeTuitions) }}</div>
            </div>
        </div>

        <div class="card">
            <h3 style="font-size: 18px; margin-bottom: 20px;">Active Tuitions</h3>
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Student</th>
                            <th>Subject</th>
                            <th>Fee</th>
                            <th>Started Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($activeTuitions as $tuition)
                        <tr>
                            <td>{{ ($tuition->student && $tuition->student->user) ? $tuition->student->user->name : 'N/A' }}</td>
                            <td>{{ ($tuition->lead && $tuition->lead->tuitionRequest && $tuition->lead->tuitionRequest->subjects) ? $tuition->lead->tuitionRequest->subjects[0] : 'N/A' }}</td>
                            <td>₹{{ $tuition->monthly_fee }}</td>
                            <td>{{ $tuition->started_at ? date('d M Y', strtotime($tuition->started_at)) : 'N/A' }}</td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="4" style="text-align: center; color: var(--text-muted);">No active tuitions found.</td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

        <div class="card" style="margin-top: 24px;">
            <h3 style="font-size: 18px; margin-bottom: 20px;">Recent Attendance</h3>
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Student</th>
                            <th>Date & Time</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($attendance as $record)
                        <tr>
                            <td>{{ ($record->paidTuition && $record->paidTuition->student && $record->paidTuition->student->user) ? $record->paidTuition->student->user->name : 'N/A' }}</td>
                            <td>{{ $record->marked_at ? date('d M Y, h:i A', strtotime($record->marked_at)) : 'N/A' }}</td>
                            <td>
                                <span class="badge badge-{{ $record->status == 'present' ? 'success' : 'danger' }}">
                                    {{ ucfirst($record->status) }}
                                </span>
                            </td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="3" style="text-align: center; color: var(--text-muted);">No attendance records found.</td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

        <div class="card" style="margin-top: 24px;">
            <h3 style="font-size: 18px; margin-bottom: 20px;">Recent Payout Requests</h3>
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Amount</th>
                            <th>Status</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($teacher->payoutRequests->take(5) as $payout)
                        <tr>
                            <td>₹{{ $payout->amount }}</td>
                            <td>
                                <span class="badge badge-{{ $payout->status == 'paid' ? 'success' : 'warning' }}">
                                    {{ ucfirst($payout->status) }}
                                </span>
                            </td>
                            <td>{{ $payout->created_at->format('d M Y') }}</td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="3" style="text-align: center; color: var(--text-muted);">No payout records found.</td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection
