@extends('layouts.admin')

@section('title', 'Student Batches')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">Education Management / Student Batches</div>
        <h1 class="page-title">Student Batch Management</h1>
    </div>
</div>

<div class="row mb-4">
    <div class="col-md-4">
        <div class="card" style="background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%); color: white;">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <div style="font-size: 14px; opacity: 0.9;">Gold Batch</div>
                    <div style="font-size: 32px; font-weight: 700;">{{ $stats['gold'] ?? 0 }}</div>
                </div>
                <i class="fas fa-trophy" style="font-size: 40px; opacity: 0.3;"></i>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card" style="background: linear-gradient(135deg, #94a3b8 0%, #64748b 100%); color: white;">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <div style="font-size: 14px; opacity: 0.9;">Silver Batch</div>
                    <div style="font-size: 32px; font-weight: 700;">{{ $stats['silver'] ?? 0 }}</div>
                </div>
                <i class="fas fa-medal" style="font-size: 40px; opacity: 0.3;"></i>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card" style="background: linear-gradient(135deg, #d97706 0%, #b45309 100%); color: white;">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <div style="font-size: 14px; opacity: 0.9;">Bronze Batch</div>
                    <div style="font-size: 32px; font-weight: 700;">{{ $stats['bronze'] ?? 0 }}</div>
                </div>
                <i class="fas fa-award" style="font-size: 40px; opacity: 0.3;"></i>
            </div>
        </div>
    </div>
</div>

<div class="card">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <select class="form-select" id="batchFilter" style="width: 200px;" onchange="window.location.href='?batch='+this.value">
                <option value="">All Batches</option>
                <option value="gold" {{ request('batch') == 'gold' ? 'selected' : '' }}>Gold</option>
                <option value="silver" {{ request('batch') == 'silver' ? 'selected' : '' }}>Silver</option>
                <option value="bronze" {{ request('batch') == 'bronze' ? 'selected' : '' }}>Bronze</option>
            </select>
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Student</th>
                    <th>Phone</th>
                    <th>Current Batch</th>
                    <th>Consecutive 80%+</th>
                    <th>Progress to Upgrade</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($students as $student)
                <tr>
                    <td>
                        <div class="user-table-info">
                            <div class="user-avatar">{{ substr($student->user->name ?? 'S', 0, 1) }}</div>
                            <div>
                                <div style="font-weight: 600;">{{ $student->user->name ?? 'N/A' }}</div>
                                <div style="font-size: 11px; color: var(--text-muted);">{{ $student->user->email ?? '' }}</div>
                            </div>
                        </div>
                    </td>
                    <td>{{ $student->user->phone ?? 'N/A' }}</td>
                    <td>
                        @if($student->batch == 'gold')
                            <span class="badge" style="background: #fef3c7; color: #92400e;">🏆 Gold</span>
                        @elseif($student->batch == 'silver')
                            <span class="badge" style="background: #f1f5f9; color: #475569;">🥈 Silver</span>
                        @else
                            <span class="badge" style="background: #fef3c7; color: #b45309;">🥉 Bronze</span>
                        @endif
                    </td>
                    <td>
                        <span class="badge bg-primary">{{ $student->consecutive_high_scores ?? 0 }}</span>
                    </td>
                    <td>
                        @if($student->batch != 'gold')
                            <div class="progress" style="height: 10px; width: 150px;">
                                <div class="progress-bar bg-success" style="width: {{ (($student->consecutive_high_scores ?? 0) / 3) * 100 }}%"></div>
                            </div>
                            <div style="font-size: 11px; color: var(--text-muted);">{{ $student->consecutive_high_scores ?? 0 }}/3 for next upgrade</div>
                        @else
                            <span class="text-success"><i class="fas fa-check-circle"></i> Max batch reached</span>
                        @endif
                    </td>
                    <td>
                        <div class="btn-group">
                            <button class="btn btn-sm btn-outline-primary" onclick="updateBatch({{ $student->id }}, 'gold')">Gold</button>
                            <button class="btn btn-sm btn-outline-secondary" onclick="updateBatch({{ $student->id }}, 'silver')">Silver</button>
                            <button class="btn btn-sm btn-outline-danger" onclick="updateBatch({{ $student->id }}, 'bronze')">Bronze</button>
                        </div>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="6" class="text-center text-muted py-4">No students found</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
    
    <div style="margin-top: 24px;">
        {{ $students->links() }}
    </div>
</div>

<form id="batchForm" method="POST" style="display: none;">
    @csrf
    <input type="hidden" name="batch" id="batchInput">
</form>
@endsection

@section('scripts')
<script>
function updateBatch(studentId, batch) {
    if (confirm('Are you sure you want to update this student to ' + batch.toUpperCase() + ' batch?')) {
        document.getElementById('batchInput').value = batch;
        document.getElementById('batchForm').action = '/admin/students/' + studentId + '/batch';
        document.getElementById('batchForm').submit();
    }
}
</script>
@endsection
