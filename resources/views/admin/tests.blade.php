@extends('layouts.admin')

@section('title', 'Test Monitoring')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">Academic / Tests</div>
        <h1 class="page-title">Test Monitoring</h1>
    </div>
</div>

<div class="card">
    <div class="table-responsive">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Test Title</th>
                    <th>Teacher</th>
                    <th>Student</th>
                    <th>Subject</th>
                    <th>Total Marks</th>
                    <th>Created At</th>
                </tr>
            </thead>
            <tbody>
                @foreach($tests as $test)
                <tr>
                    <td>{{ $test->title }}</td>
                    <td>
                        <div style="font-weight: 600;">{{ $test->teacher->user->name }}</div>
                    </td>
                    <td>
                        <div style="font-weight: 600;">{{ $test->paidTuition->student->user->name ?? 'N/A' }}</div>
                    </td>
                    <td>{{ $test->subject }}</td>
                    <td>{{ $test->total_marks }}</td>
                    <td style="font-size: 12px; color: var(--text-muted);">
                        {{ $test->created_at->format('d M Y, h:i A') }}
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
    
    <div style="margin-top: 24px;">
        {{ $tests->links() }}
    </div>
</div>
@endsection
