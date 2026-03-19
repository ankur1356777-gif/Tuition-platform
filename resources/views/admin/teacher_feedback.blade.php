@extends('layouts.admin')

@section('title', 'Teacher Feedback')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">Education Management / Teacher Feedback</div>
        <h1 class="page-title">Teacher Feedback (Hidden from Public)</h1>
    </div>
</div>

<div class="alert" style="background: #fef3c7; color: #92400e;">
    <i class="fas fa-info-circle"></i>
    <strong>Note:</strong> This feedback is hidden from students and teachers. Only the star rating is publicly visible.
</div>

<div class="card">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <select class="form-select" id="teacherFilter" style="width: 250px;">
                <option value="">All Teachers</option>
                @foreach($teachers ?? [] as $teacher)
                    <option value="{{ $teacher->id }}">{{ $teacher->user->name ?? 'N/A' }}</option>
                @endforeach
            </select>
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Teacher</th>
                    <th>Student</th>
                    <th>Rating</th>
                    <th>Feedback (Hidden)</th>
                    <th>Date</th>
                </tr>
            </thead>
            <tbody>
                @forelse($feedback as $item)
                <tr>
                    <td>
                        <div class="user-table-info">
                            <div class="user-avatar">{{ substr($item->teacher->user->name ?? 'T', 0, 1) }}</div>
                            <div>
                                <div style="font-weight: 600;">{{ $item->teacher->user->name ?? 'N/A' }}</div>
                                <div style="font-size: 11px; color: var(--text-muted);">
                                    Avg Rating: 
                                    <span class="text-warning">
                                        @for($i = 1; $i <= 5; $i++)
                                            @if($i <= round($item->teacher->rating ?? 0))
                                                <i class="fas fa-star"></i>
                                            @else
                                                <i class="far fa-star"></i>
                                            @endif
                                        @endfor
                                    </span>
                                    ({{ $item->teacher->rating ?? 0 }})
                                </div>
                            </div>
                        </div>
                    </td>
                    <td>{{ $item->student->user->name ?? 'N/A' }}</td>
                    <td>
                        <span class="text-warning">
                            @for($i = 1; $i <= 5; $i++)
                                @if($i <= $item->rating)
                                    <i class="fas fa-star"></i>
                                @else
                                    <i class="far fa-star"></i>
                                @endif
                            @endfor
                        </span>
                    </td>
                    <td>
                        <div style="max-width: 300px; background: #fef2f2; padding: 10px; border-radius: 8px; border-left: 3px solid #ef4444;">
                            <i class="fas fa-lock text-muted" style="font-size: 10px;"></i>
                            <span style="font-size: 13px;">{{ $item->feedback }}</span>
                        </div>
                    </td>
                    <td>{{ $item->created_at->format('d M Y') }}</td>
                </tr>
                @empty
                <tr>
                    <td colspan="5" class="text-center text-muted py-4">No feedback found</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
    
    <div style="margin-top: 24px;">
        {{ $feedback->links() }}
    </div>
</div>
@endsection
