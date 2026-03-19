@extends('layouts.admin')

@section('title', 'System Settings')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">System / Settings</div>
        <h1 class="page-title">Platform & Commission Settings</h1>
    </div>
    <div class="header-btns">
        <button type="submit" form="settings-form" class="btn btn-primary">
            <i class="fas fa-save"></i> Save All Changes
        </button>
    </div>
</div>

<form id="settings-form" action="{{ route('admin.settings.update') }}" method="POST">
    @csrf
    <div class="dashboard-grid">
        <div class="card">
            <h2 style="font-size: 18px; font-weight: 700; margin-bottom: 24px;">Commission Configuration</h2>
            
            <div style="grid">
                <div style="display: flex; flex-direction: column; gap: 8px;">
                    <label style="font-size: 14px; font-weight: 600; color: var(--text-main);">Teacher Platform Fee (%)</label>
                    <input type="number" name="teacher_platform_fee" value="{{ $settings['teacher_platform_fee'] ?? '15' }}" style="padding: 12px; border: 1px solid #e2e8f0; border-radius: 8px; outline: none;">
                    <span style="font-size: 12px; color: var(--text-muted);">Percentage of tuition fee taken as platform service charge.</span>
                </div>

                <div style="display: flex; flex-direction: column; gap: 8px; margin-top: 20px;">
                    <label style="font-size: 14px; font-weight: 600; color: var(--text-main);">Agent Commission (%)</label>
                    <input type="number" name="agent_commission" value="{{ $settings['agent_commission'] ?? '5' }}" style="padding: 12px; border: 1px solid #e2e8f0; border-radius: 8px; outline: none;">
                    <span style="font-size: 12px; color: var(--text-muted);">Commission given to the referring agent from the platform fee.</span>
                </div>

                <div style="display: flex; flex-direction: column; gap: 8px; margin-top: 20px;">
                    <label style="font-size: 14px; font-weight: 600; color: var(--text-main);">Lead Price (₹)</label>
                    <input type="number" name="lead_price" value="{{ $settings['lead_price'] ?? '50' }}" style="padding: 12px; border: 1px solid #e2e8f0; border-radius: 8px; outline: none;">
                    <span style="font-size: 12px; color: var(--text-muted);">Fixed cost for a teacher to unlock a high-priority lead.</span>
                </div>
            </div>
        </div>

        <div style="display: flex; flex-direction: column; gap: 24px;">
            <div class="card">
                <h2 style="font-size: 18px; font-weight: 700; margin-bottom: 24px;">App Versions</h2>
                <div style="display: grid; gap: 16px;">
                    <div>
                        <label style="font-size: 12px; font-weight: 600;">Android Version</label>
                        <input type="text" value="1.0.5" style="width: 100%; padding: 10px; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 4px;">
                    </div>
                    <div>
                        <label style="font-size: 12px; font-weight: 600;">iOS Version</label>
                        <input type="text" value="1.0.2" style="width: 100%; padding: 10px; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 4px;">
                    </div>
                    <div style="display: flex; align-items: center; gap: 10px; margin-top: 8px;">
                        <input type="checkbox" id="force-update" checked>
                        <label for="force-update" style="font-size: 13px;">Force Update Required</label>
                    </div>
                </div>
            </div>

            <div class="card" style="background: #fff1f2; border: 1px solid #fecdd3;">
                <h2 style="font-size: 18px; font-weight: 700; margin-bottom: 12px; color: #9f1239;">Maintenance Mode</h2>
                <p style="font-size: 13px; color: #9f1239; margin-bottom: 16px;">Activating this will prevent all users from accessing the platform apps and web portal.</p>
                <button type="button" class="btn" style="background: #be123c; color: white; width: 100%; justify-content: center;">
                    Activate Now
                </button>
            </div>
        </div>
    </div>
</form>
@endsection
