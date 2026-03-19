@extends('layouts.admin')

@section('title', 'Teacher Rewards')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">Education Management / Teacher Rewards</div>
        <h1 class="page-title">Teacher Rewards</h1>
    </div>
</div>

<div class="row mb-4">
    <div class="col-md-6">
        <div class="card" style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white;">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <div style="font-size: 14px; opacity: 0.9;">Pending Rewards</div>
                    <div style="font-size: 32px; font-weight: 700;">{{ count($pendingRewards ?? []) }}</div>
                </div>
                <i class="fas fa-gift" style="font-size: 40px; opacity: 0.3;"></i>
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <div class="card" style="background: linear-gradient(135deg, #4f46e5 0%, #4338ca 100%); color: white;">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <div style="font-size: 14px; opacity: 0.9;">Total Rewarded This Month</div>
                    <div style="font-size: 32px; font-weight: 700;">₹{{ number_format($totalRewardedThisMonth ?? 0) }}</div>
                </div>
                <i class="fas fa-rupee-sign" style="font-size: 40px; opacity: 0.3;"></i>
            </div>
        </div>
    </div>
</div>

<div class="card">
    <h5 style="font-weight: 600; margin-bottom: 20px;"><i class="fas fa-clock text-warning"></i> Pending Rewards (80%+ Test Results)</h5>
    
    <div class="table-responsive">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Student</th>
                    <th>Teacher</th>
                    <th>Test</th>
                    <th>Score</th>
                    <th>Date</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($pendingRewards as $result)
                <tr>
                    <td>{{ $result->student->user->name ?? 'N/A' }}</td>
                    <td>{{ $result->test->teacher->user->name ?? 'N/A' }}</td>
                    <td>{{ $result->test->title ?? 'Weekly Test' }}</td>
                    <td>
                        <span class="badge bg-success">{{ $result->percentage }}%</span>
                        <div style="font-size: 11px; color: var(--text-muted);">{{ $result->obtained_marks }}/{{ $result->total_marks }}</div>
                    </td>
                    <td>{{ $result->created_at->format('d M Y') }}</td>
                    <td>
                        <button class="btn btn-sm btn-primary" onclick="rewardTeacher({{ $result->test->teacher_id }}, {{ $result->id }})">
                            <i class="fas fa-gift"></i> Reward ₹50
                        </button>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="6" class="text-center text-muted py-4">No pending rewards</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>

<div class="card">
    <h5 style="font-weight: 600; margin-bottom: 20px;"><i class="fas fa-history text-primary"></i> Recent Reward Transactions</h5>
    
    <div class="table-responsive">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Teacher</th>
                    <th>Amount</th>
                    <th>Reason</th>
                    <th>Date</th>
                </tr>
            </thead>
            <tbody>
                @forelse($recentRewards ?? [] as $transaction)
                <tr>
                    <td>{{ $transaction->user->name ?? 'N/A' }}</td>
                    <td><span class="text-success">+₹{{ number_format($transaction->amount) }}</span></td>
                    <td>{{ $transaction->description }}</td>
                    <td>{{ $transaction->created_at->format('d M Y H:i') }}</td>
                </tr>
                @empty
                <tr>
                    <td colspan="4" class="text-center text-muted py-4">No recent rewards</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>

<!-- Reward Modal -->
<div class="modal fade" id="rewardModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form id="rewardForm" method="POST">
                @csrf
                <div class="modal-header">
                    <h5 class="modal-title">Reward Teacher</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Amount (₹)</label>
                        <input type="number" name="amount" class="form-control" value="50" min="1" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Reason</label>
                        <input type="text" name="reason" class="form-control" value="Student scored 80%+ on weekly test" required>
                    </div>
                    <input type="hidden" name="test_result_id" id="testResultId">
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Send Reward</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script>
function rewardTeacher(teacherId, resultId) {
    document.getElementById('rewardForm').action = '/admin/teachers/' + teacherId + '/reward';
    document.getElementById('testResultId').value = resultId;
    new bootstrap.Modal(document.getElementById('rewardModal')).show();
}
</script>
@endsection
