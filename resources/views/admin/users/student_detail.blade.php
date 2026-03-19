@extends('layouts.admin')

@section('title', 'Student Details')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">User Management / Students / Details</div>
        <h1 class="page-title">{{ $student->name }}</h1>
    </div>
    <div class="header-btns">
        <a href="{{ route('admin.students') }}" class="btn" style="background: #e5e7eb; color: #374151;">
            <i class="fas fa-arrow-left"></i> Back to List
        </a>
    </div>
</div>

<div style="display: grid; grid-template-columns: 1fr 2fr; gap: 24px;">
    <!-- Profile Card -->
    <div>
        <div class="card" style="text-align: center; padding: 32px 24px;">
            <div class="user-avatar" style="width: 80px; height: 80px; font-size: 32px; margin: 0 auto 16px auto; background: rgba(16, 185, 129, 0.1); color: #10b981;">{{ substr($student->name, 0, 1) }}</div>
            <h2 style="margin: 0; font-size: 20px;">{{ $student->name }}</h2>
            <p style="color: var(--text-muted); margin: 4px 0 16px 0;">Student ID: #STD{{ $student->id }}</p>
            <span class="badge badge-success" style="padding: 6px 16px;">Active</span>
            
            <div style="margin-top: 32px; text-align: left; border-top: 1px solid #f3f4f6; padding-top: 24px;">
                <div style="margin-bottom: 16px;">
                    <div style="font-size: 12px; color: var(--text-muted); margin-bottom: 4px;">Grade / Class</div>
                    <div style="font-weight: 500;">Class {{ $student->student->class ?? 'N/A' }}</div>
                </div>
                <div style="margin-bottom: 16px;">
                    <div style="font-size: 12px; color: var(--text-muted); margin-bottom: 4px;">Phone Number</div>
                    <div style="font-weight: 500;">{{ $student->phone }}</div>
                </div>
                <div style="margin-bottom: 16px;">
                    <div style="font-size: 12px; color: var(--text-muted); margin-bottom: 4px;">Email Address</div>
                    <div style="font-weight: 500;">{{ $student->email ?? 'N/A' }}</div>
                </div>
                <div style="margin-bottom: 16px;">
                    <div style="font-size: 12px; color: var(--text-muted); margin-bottom: 4px;">Address</div>
                    <div style="font-weight: 500; font-size: 14px;">{{ $student->student->address ?? 'N/A' }}</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Info -->
    <div>
        <div class="card">
            <h3 style="font-size: 18px; margin-bottom: 20px;">Current Active Tuitions</h3>
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Teacher</th>
                            <th>Subject</th>
                            <th>Monthly Fee</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($activeTuitions as $tuition)
                        <tr>
                            <td>{{ $tuition->teacher->user->name }}</td>
                            <td>{{ $tuition->lead->tuitionRequest->subjects[0] ?? 'N/A' }}</td>
                            <td>₹{{ $tuition->monthly_fee }}</td>
                            <td><span class="badge badge-success">{{ ucfirst($tuition->status) }}</span></td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="4" style="text-align: center; color: var(--text-muted); padding: 20px;">No active tuitions.</td>
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
                            <th>Teacher</th>
                            <th>Date & Time</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($attendance as $record)
                        <tr>
                            <td>{{ $record->teacher->user->name ?? 'N/A' }}</td>
                            <td>{{ $record->marked_at ? date('d M Y, h:i A', strtotime($record->marked_at)) : 'N/A' }}</td>
                            <td>
                                <span class="badge badge-{{ $record->status == 'present' ? 'success' : 'danger' }}">
                                    {{ ucfirst($record->status) }}
                                </span>
                            </td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="3" style="text-align: center; color: var(--text-muted); padding: 20px;">No attendance records found.</td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

        <div class="card" style="margin-top: 24px;">
            <h3 style="font-size: 18px; margin-bottom: 20px;">Recent Tuition Requests</h3>
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Subject</th>
                            <th>Class</th>
                            <th>Status</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($student->tuitionRequests->take(5) as $request)
                        <tr>
                            <td>{{ is_array($request->subjects) ? $request->subjects[0] : json_decode($request->subjects)[0] }}</td>
                            <td>{{ $request->class }}</td>
                            <td>
                                <span class="badge badge-{{ $request->status == 'new' ? 'primary' : 'success' }}">
                                    {{ ucfirst($request->status) }}
                                </span>
                            </td>
                            <td>{{ $request->created_at->format('d M Y') }}</td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="4" style="text-align: center; color: var(--text-muted); padding: 20px;">No requests found.</td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

        <div class="card" style="margin-top: 24px;">
            <h3 style="font-size: 18px; margin-bottom: 20px;">Payment History</h3>
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Ref ID</th>
                            <th>Amount</th>
                            <th>Type</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($student->transactions->take(5) as $trx)
                        <tr>
                            <td>#{{ substr($trx->transaction_id ?? $trx->id, -8) }}</td>
                            <td style="color: {{ $trx->type == 'debit' ? '#ef4444' : '#10b981' }}">
                                {{ $trx->type == 'debit' ? '-' : '+' }}₹{{ $trx->amount }}
                            </td>
                            <td>{{ ucfirst($trx->type) }}</td>
                            <td>{{ $trx->created_at->format('d M Y') }}</td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="4" style="text-align: center; color: var(--text-muted); padding: 20px;">No transactions found.</td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection
