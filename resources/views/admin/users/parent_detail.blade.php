@extends('layouts.admin')

@section('title', 'Parent Details')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">User Management / Parents / Details</div>
        <h1 class="page-title">{{ $parent->name }}</h1>
    </div>
    <div class="header-btns">
        <a href="{{ route('admin.parents') }}" class="btn" style="background: #e5e7eb; color: #374151;">
            <i class="fas fa-arrow-left"></i> Back to List
        </a>
    </div>
</div>

<div style="display: grid; grid-template-columns: 1fr 2fr; gap: 24px;">
    <!-- Profile Card -->
    <div>
        <div class="card" style="text-align: center; padding: 32px 24px;">
            <div class="user-avatar" style="width: 80px; height: 80px; font-size: 32px; margin: 0 auto 16px auto; background: rgba(139, 92, 246, 0.1); color: #8b5cf6;">{{ substr($parent->name, 0, 1) }}</div>
            <h2 style="margin: 0; font-size: 20px;">{{ $parent->name }}</h2>
            <p style="color: var(--text-muted); margin: 4px 0 16px 0;">Parent ID: #PRT{{ $parent->id }}</p>
            <span class="badge badge-{{ $parent->status == 'approved' ? 'success' : ($parent->status == 'pending' ? 'warning' : 'danger') }}" style="padding: 6px 16px;">
                {{ ucfirst($parent->status) }}
            </span>

            <div style="margin-top: 32px; text-align: left; border-top: 1px solid #f3f4f6; padding-top: 24px;">
                <div style="margin-bottom: 16px;">
                    <div style="font-size: 12px; color: var(--text-muted); margin-bottom: 4px;">Phone Number</div>
                    <div style="font-weight: 500;">{{ $parent->phone }}</div>
                </div>
                <div style="margin-bottom: 16px;">
                    <div style="font-size: 12px; color: var(--text-muted); margin-bottom: 4px;">Email Address</div>
                    <div style="font-weight: 500;">{{ $parent->email ?? 'N/A' }}</div>
                </div>
                <div style="margin-bottom: 16px;">
                    <div style="font-size: 12px; color: var(--text-muted); margin-bottom: 4px;">Joined On</div>
                    <div style="font-weight: 500;">{{ $parent->created_at->format('d M, Y') }}</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Info -->
    <div>
        <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; margin-bottom: 24px;">
            <div class="card" style="padding: 20px; border-left: 4px solid #8b5cf6;">
                <div style="font-size: 12px; color: var(--text-muted);">Status</div>
                <div style="font-size: 24px; font-weight: 700;">{{ ucfirst($parent->status) }}</div>
            </div>
            <div class="card" style="padding: 20px; border-left: 4px solid #10b981;">
                <div style="font-size: 12px; color: var(--text-muted);">Linked Children</div>
                <div style="font-size: 24px; font-weight: 700;">{{ count($children) }}</div>
            </div>
        </div>

        <div class="card">
            <h3 style="font-size: 18px; margin-bottom: 20px;">Linked Children</h3>
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Student Name</th>
                            <th>Phone</th>
                            <th>Class</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($children as $link)
                        <tr>
                            <td>
                                <div class="user-table-info">
                                    <div class="user-avatar" style="background: rgba(16, 185, 129, 0.1); color: #10b981; width: 32px; height: 32px; font-size: 14px;">{{ substr($link->student->user->name ?? 'N', 0, 1) }}</div>
                                    <div>
                                        <div style="font-weight: 600;">{{ $link->student->user->name ?? 'N/A' }}</div>
                                        <div style="font-size: 11px; color: var(--text-muted);">{{ $link->student->user->email ?? '' }}</div>
                                    </div>
                                </div>
                            </td>
                            <td>{{ $link->student->user->phone ?? 'N/A' }}</td>
                            <td>Class {{ $link->student->class ?? 'N/A' }}</td>
                            <td>
                                <a href="{{ route('admin.students.show', $link->student->user->id ?? 0) }}" class="btn" style="background: rgba(79, 70, 229, 0.1); color: #4f46e5; padding: 6px 12px; font-size: 12px;">
                                    <i class="fas fa-eye"></i> View Student
                                </a>
                            </td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="4" style="text-align: center; color: var(--text-muted); padding: 20px;">No children linked yet.</td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection
