@extends('layouts.admin')

@section('title', 'Parent Management')

@section('content')
@if(session('success'))
<div class="alert alert-success alert-dismissible fade show" role="alert">
    <i class="fas fa-check-circle me-2"></i>{{ session('success') }}
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
@endif
@if(session('error'))
<div class="alert alert-danger alert-dismissible fade show" role="alert">
    <i class="fas fa-exclamation-circle me-2"></i>{{ session('error') }}
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
@endif
<div class="page-header">
    <div>
        <div class="breadcrumb">User Management / Parents</div>
        <h1 class="page-title">Parent Management</h1>
    </div>
</div>

<!-- Stats -->
<div class="row mb-4">
    <div class="col-md-3">
        <div class="card text-center" style="border-left: 4px solid var(--primary);">
            <div class="h4 mb-0">{{ $stats['total_parents'] }}</div>
            <div class="text-muted">Total Parents</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card text-center" style="border-left: 4px solid var(--success);">
            <div class="h4 mb-0">{{ $stats['linked_parents'] }}</div>
            <div class="text-muted">With Linked Children</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card text-center" style="border-left: 4px solid var(--warning);">
            <div class="h4 mb-0">{{ $stats['unlinked_parents'] }}</div>
            <div class="text-muted">No Children Linked</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card text-center" style="border-left: 4px solid var(--info);">
            <div class="h4 mb-0">{{ $stats['total_links'] }}</div>
            <div class="text-muted">Total Links</div>
        </div>
    </div>
</div>

<!-- Parents Table -->
<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">Registered Parents</h5>
        <form method="GET" class="d-flex gap-2">
            <input type="text" name="search" value="{{ request('search') }}" placeholder="Search name or phone..." class="form-control" style="width: 250px;">
            <button type="submit" class="btn btn-sm btn-primary"><i class="fas fa-search"></i></button>
        </form>
    </div>
    <div class="card-body">
        @if($parents->count() > 0)
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Parent</th>
                        <th>Phone</th>
                        <th>Registered</th>
                        <th>Children</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($parents as $parent)
                    <tr>
                        <td>
                            <div class="user-table-info">
                                <div class="user-avatar" style="background: rgba(139, 92, 246, 0.1); color: #8b5cf6;">{{ substr($parent->name, 0, 1) }}</div>
                                <div>
                                    <div style="font-weight: 600;">{{ $parent->name }}</div>
                                    <div style="font-size: 11px; color: var(--text-muted);">{{ $parent->email ?? 'No email' }}</div>
                                </div>
                            </div>
                        </td>
                        <td>{{ $parent->phone }}</td>
                        <td>
                            {{ $parent->created_at->format('d M Y') }}
                            <br><small class="text-muted">{{ $parent->created_at->diffForHumans() }}</small>
                        </td>
                        <td>
                            @php
                                $children = \App\Models\ParentChild::with(['student.user'])
                                    ->where('parent_id', $parent->id)
                                    ->get();
                            @endphp
                            @if($children->count() > 0)
                                @foreach($children as $link)
                                    <div class="mb-1">
                                        <span class="badge" style="background: rgba(16, 185, 129, 0.1); color: #10b981; font-size: 12px; padding: 5px 10px;">
                                            <i class="fas fa-user-graduate me-1"></i>
                                            {{ $link->student->user->name ?? 'N/A' }}
                                            <span class="text-muted" style="font-size: 10px;">
                                                ({{ $link->student->user->phone ?? '' }})
                                            </span>
                                        </span>
                                    </div>
                                @endforeach
                            @else
                                <span class="badge" style="background: rgba(239, 68, 68, 0.1); color: #ef4444;">
                                    <i class="fas fa-unlink me-1"></i> No children linked
                                </span>
                            @endif
                        </td>
                        <td>
                            @if($parent->status === 'approved')
                                <span class="badge badge-success"><i class="fas fa-check me-1"></i>Active</span>
                            @elseif($parent->status === 'pending')
                                <span class="badge badge-pending"><i class="fas fa-clock me-1"></i>Pending</span>
                            @elseif($parent->status === 'rejected')
                                <span class="badge badge-danger"><i class="fas fa-times me-1"></i>Rejected</span>
                            @else
                                <span class="badge badge-danger">{{ ucfirst($parent->status) }}</span>
                            @endif
                        </td>
                        <td>
                            <div class="d-flex gap-2">
                                <a href="{{ route('admin.parents.show', $parent->id) }}" class="btn btn-sm" style="background: rgba(79, 70, 229, 0.1); color: #4f46e5; padding: 6px 12px; font-size: 12px;" title="View Details">
                                    <i class="fas fa-eye"></i>
                                </a>
                                @if($parent->status === 'pending')
                                    <form method="POST" action="{{ route('admin.parents.approve', $parent->id) }}" style="display:inline;">
                                        @csrf
                                        <button type="submit" class="btn btn-sm btn-success" title="Approve" onclick="return confirm('Approve this parent account?')">
                                            <i class="fas fa-check"></i>
                                        </button>
                                    </form>
                                    <form method="POST" action="{{ route('admin.parents.reject', $parent->id) }}" style="display:inline;">
                                        @csrf
                                        <button type="submit" class="btn btn-sm btn-danger" title="Reject" onclick="return confirm('Reject this parent account?')">
                                            <i class="fas fa-times"></i>
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

        <div class="d-flex justify-content-center mt-4">
            {{ $parents->appends(request()->query())->links() }}
        </div>
        @else
        <div class="text-center py-5">
            <i class="fas fa-user-friends fa-3x text-muted mb-3"></i>
            <p class="text-muted">No parents found</p>
        </div>
        @endif
    </div>
</div>
@endsection
