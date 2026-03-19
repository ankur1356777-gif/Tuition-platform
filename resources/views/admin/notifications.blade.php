@extends('layouts.admin')

@section('title', 'Notifications')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">System / Notifications</div>
        <h1 class="page-title">Broadcast Notifications</h1>
    </div>
</div>

<div style="display: grid; grid-template-columns: 1fr 2fr; gap: 24px;">
    <!-- Send Notification Form -->
    <div class="card">
        <h2 style="font-size: 18px; font-weight: 700; margin-bottom: 24px;">Send New Broadcast</h2>
        
        <form action="{{ route('admin.notifications.send') }}" method="POST">
            @csrf
            <div style="margin-bottom: 20px;">
                <label style="display: block; font-size: 14px; font-weight: 500; margin-bottom: 8px;">Target Audience</label>
                <select name="role" style="width: 100%; padding: 12px; border: 1px solid #e2e8f0; border-radius: 8px; outline: none; transition: border-color 0.2s;">
                    <option value="">All Users</option>
                    <option value="teacher">Teachers Only</option>
                    <option value="student">Students Only</option>
                    <option value="agent">Agents Only</option>
                </select>
            </div>

            <div style="margin-bottom: 20px;">
                <label style="display: block; font-size: 14px; font-weight: 500; margin-bottom: 8px;">Notification Title</label>
                <input type="text" name="title" required placeholder="e.g. Schedule Update" style="width: 100%; padding: 12px; border: 1px solid #e2e8f0; border-radius: 8px; outline: none;">
            </div>

            <div style="margin-bottom: 24px;">
                <label style="display: block; font-size: 14px; font-weight: 500; margin-bottom: 8px;">Message Content</label>
                <textarea name="body" required rows="4" placeholder="Type your message here..." style="width: 100%; padding: 12px; border: 1px solid #e2e8f0; border-radius: 8px; outline: none; resize: vertical;"></textarea>
            </div>

            <button type="submit" class="btn btn-primary" style="width: 100%; justify-content: center;">
                <i class="fas fa-paper-plane"></i> Send Notification
            </button>
        </form>
    </div>

    <!-- Recent Notifications List -->
    <div class="card">
        <h2 style="font-size: 18px; font-weight: 700; margin-bottom: 24px;">Recent Broadcasts</h2>
        
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Recipient</th>
                        <th>Title & Message</th>
                        <th>Sent At</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($notifications as $notif)
                    <tr>
                        <td style="white-space: nowrap;">
                            @if($notif->user_id)
                                {{ $notif->user->name }}
                            @else
                                <span class="badge badge-info" style="background: #e0f2fe; color: #0369a1;">Broadcast</span>
                            @endif
                        </td>
                        <td>
                            <div style="font-weight: 600; font-size: 13px;">{{ $notif->title }}</div>
                            <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">{{ Str::limit($notif->body, 50) }}</div>
                        </td>
                        <td style="font-size: 12px; color: var(--text-muted);">
                            {{ $notif->created_at->diffForHumans() }}
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="3" style="text-align: center; padding: 40px; color: var(--text-muted);">No notification history.</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div style="margin-top: 24px;">
            {{ $notifications->links() }}
        </div>
    </div>
</div>
@endsection
