@extends('layouts.admin')

@section('title', 'Manage Teachers')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">User Management / Teachers</div>
        <h1 class="page-title">Teacher Management</h1>
    </div>
    <div class="header-btns">
        <a href="{{ route('admin.users.create', ['role' => 'teacher']) }}" class="btn btn-primary">
            <i class="fas fa-user-plus"></i> Add New Teacher
        </a>
    </div>
</div>

<div class="card">
    <div class="table-responsive">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Teacher Name</th>
                    <th>Phone</th>
                    <th>Status</th>
                    <th>Experience</th>
                    <th>Joined Date</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach($teachers as $teacherUser)
                <tr>
                    <td>
                        <div class="user-table-info">
                            <div class="user-avatar">{{ substr($teacherUser->name, 0, 1) }}</div>
                            <div>
                                <div style="font-weight: 600;">{{ $teacherUser->name }}</div>
                                <div style="font-size: 11px; color: var(--text-muted);">{{ $teacherUser->email }}</div>
                            </div>
                        </div>
                    </td>
                    <td>{{ $teacherUser->phone }}</td>
                    <td>
                        <span class="badge badge-{{ $teacherUser->status == 'approved' ? 'success' : ($teacherUser->status == 'pending' ? 'warning' : 'danger') }}">
                            {{ ucfirst($teacherUser->status) }}
                        </span>
                    </td>
                    <td>{{ $teacherUser->teacher->experience_years ?? 0 }} Years</td>
                    <td>{{ $teacherUser->created_at->format('d M Y') }}</td>
                    <td>
                        <div style="display: flex; gap: 8px;">
                            @if($teacherUser->status == 'pending')
                            <form action="{{ route('admin.teachers.verify', $teacherUser->id) }}" method="POST">
                                @csrf
                                <input type="hidden" name="status" value="approved">
                                <button type="submit" class="btn" style="background: rgba(16, 185, 129, 0.1); color: #10b981; padding: 6px 12px; font-size: 12px;">
                                    Approve
                                </button>
                            </form>
                            @endif
                            <a href="{{ route('admin.teachers.show', $teacherUser->id) }}" class="btn" style="background: rgba(79, 70, 229, 0.1); color: #4f46e5; padding: 6px 12px; font-size: 12px;">
                                <i class="fas fa-eye"></i>
                            </a>
                        </div>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
    
    <div style="margin-top: 24px;">
        {{ $teachers->links() }}
    </div>
</div>
@endsection
