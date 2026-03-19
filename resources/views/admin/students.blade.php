@extends('layouts.admin')

@section('title', 'Manage Students')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">User Management / Students</div>
        <h1 class="page-title">Student & Parent Management</h1>
    </div>
    <div class="header-btns">
        <a href="{{ route('admin.users.create', ['role' => 'student']) }}" class="btn btn-primary">
            <i class="fas fa-plus"></i> Manual Registration
        </a>
    </div>
</div>

<div class="card">
    <div class="table-responsive">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Student Name</th>
                    <th>Phone</th>
                    <th>Grade/Class</th>
                    <th>Address</th>
                    <th>Joined</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach($students as $studentUser)
                <tr>
                    <td>
                        <div class="user-table-info">
                            <div class="user-avatar" style="background: rgba(16, 185, 129, 0.1); color: #10b981;">{{ substr($studentUser->name, 0, 1) }}</div>
                            <div>
                                <div style="font-weight: 600;">{{ $studentUser->name }}</div>
                                <div style="font-size: 11px; color: var(--text-muted);">{{ $studentUser->email }}</div>
                            </div>
                        </div>
                    </td>
                    <td>{{ $studentUser->phone }}</td>
                    <td>Class {{ $studentUser->student->class ?? 'N/A' }}</td>
                    <td>{{ Str::limit($studentUser->student->address ?? 'N/A', 30) }}</td>
                    <td>{{ $studentUser->created_at->format('d M Y') }}</td>
                    <td>
                        <div style="display: flex; gap: 8px;">
                            <a href="{{ route('admin.students.show', $studentUser->id) }}" class="btn" style="background: rgba(79, 70, 229, 0.1); color: #4f46e5; padding: 6px 12px; font-size: 12px;">
                                <i class="fas fa-eye"></i>
                            </a>
                            <a href="#" class="btn" style="background: rgba(239, 68, 68, 0.1); color: #ef4444; padding: 6px 12px; font-size: 12px;">
                                <i class="fas fa-ban"></i>
                            </a>
                        </div>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
    
    <div style="margin-top: 24px;">
        {{ $students->links() }}
    </div>
</div>
@endsection
