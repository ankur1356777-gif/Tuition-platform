<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Admin Dashboard') | Tuition Platform</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary: #4f46e5;
            --primary-dark: #4338ca;
            --primary-light: #eef2ff;
            --secondary: #64748b;
            --success: #10b981;
            --danger: #ef4444;
            --warning: #f59e0b;
            --background: #f8fafc;
            --surface: #ffffff;
            --text-main: #0f172a;
            --text-muted: #64748b;
            --sidebar-width: 260px;
            --header-height: 70px;
            --shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--background);
            color: var(--text-main);
            overflow-x: hidden;
        }

        h1, h2, h3, .brand {
            font-family: 'Outfit', sans-serif;
        }

        /* Layout */
        .admin-container {
            display: flex;
            min-height: 100vh;
        }

        /* Sidebar */
        .sidebar {
            width: var(--sidebar-width);
            background: #1e293b;
            color: white;
            position: fixed;
            height: 100vh;
            z-index: 1000;
            transition: all 0.3s ease;
            overflow-y: auto;
            scrollbar-width: thin;
            scrollbar-color: rgba(255,255,255,0.1) transparent;
        }

        .sidebar::-webkit-scrollbar {
            width: 4px;
        }

        .sidebar::-webkit-scrollbar-thumb {
            background: rgba(255,255,255,0.1);
            border-radius: 10px;
        }

        .brand {
            height: var(--header-height);
            display: flex;
            align-items: center;
            padding: 0 24px;
            font-size: 20px;
            font-weight: 700;
            background: rgba(0,0,0,0.1);
        }

        .brand i {
            color: var(--primary);
            margin-right: 10px;
        }

        .nav-menu {
            padding: 24px 0;
            list-style: none;
        }

        .nav-item {
            padding: 2px 16px;
        }

        .nav-link {
            display: flex;
            align-items: center;
            padding: 12px 16px;
            color: #94a3b8;
            text-decoration: none;
            border-radius: 8px;
            transition: all 0.2s;
            font-size: 14px;
            font-weight: 500;
        }

        .nav-link i {
            width: 20px;
            margin-right: 12px;
            font-size: 18px;
        }

        .nav-link:hover {
            color: white;
            background: rgba(255,255,255,0.05);
        }

        .nav-link.active {
            color: white;
            background: var(--primary);
        }

        .nav-category {
            padding: 16px 24px 8px;
            font-size: 11px;
            text-transform: uppercase;
            color: #64748b;
            letter-spacing: 1px;
        }

        /* Main Content */
        .main-content {
            flex: 1;
            margin-left: var(--sidebar-width);
            display: flex;
            flex-direction: column;
            min-width: 0;
        }

        /* Header */
        header {
            height: var(--header-height);
            background: var(--surface);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 32px;
            box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);
            position: sticky;
            top: 0;
            z-index: 999;
        }

        .search-bar {
            background: #f1f5f9;
            padding: 8px 16px;
            border-radius: 20px;
            display: flex;
            align-items: center;
            width: 300px;
        }

        .search-bar input {
            background: none;
            border: none;
            outline: none;
            margin-left: 8px;
            width: 100%;
            font-size: 14px;
        }

        .header-actions {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .notification-btn {
            color: var(--text-muted);
            font-size: 18px;
            cursor: pointer;
            position: relative;
        }

        .notification-badge {
            position: absolute;
            top: -5px;
            right: -5px;
            background: var(--danger);
            color: white;
            font-size: 10px;
            width: 16px;
            height: 16px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 12px;
            cursor: pointer;
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: var(--primary-light);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary);
            font-weight: 600;
        }

        /* Content Area */
        .page-content {
            padding: 32px;
        }

        .page-header {
            margin-bottom: 32px;
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
        }

        .page-title {
            font-size: 24px;
            font-weight: 700;
            color: var(--text-main);
        }

        .breadcrumb {
            font-size: 13px;
            color: var(--text-muted);
            margin-bottom: 8px;
        }


        /* Common Components */
        .card {
            background: var(--surface);
            border-radius: 16px;
            padding: 24px;
            box-shadow: var(--shadow);
            margin-bottom: 24px;
            border: none;
        }

        .card-body {
            padding: 0;
        }

        .card-header {
            background: transparent;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 16px;
            margin-bottom: 20px;
        }

        /* Tables */
        .table-responsive {
            border-radius: 12px;
            overflow: hidden;
        }

        .table {
            margin-bottom: 0;
            font-size: 14px;
        }

        .table thead th {
            background: #f8fafc;
            color: var(--text-main);
            font-weight: 600;
            border-bottom: 2px solid #e2e8f0;
            padding: 16px;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 0.5px;
        }

        .table tbody td {
            padding: 16px;
            vertical-align: middle;
            border-bottom: 1px solid #f1f5f9;
        }

        .table tbody tr:hover {
            background: #f8fafc;
        }

        .table tbody tr:last-child td {
            border-bottom: none;
        }

        /* Forms */
        .form-label {
            font-weight: 600;
            color: var(--text-main);
            margin-bottom: 8px;
            font-size: 14px;
        }

        .form-control, .form-select {
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            padding: 10px 16px;
            font-size: 14px;
            transition: all 0.2s;
        }

        .form-control:focus, .form-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
        }

        .form-check-input {
            width: 20px;
            height: 20px;
            border: 2px solid #e2e8f0;
            cursor: pointer;
        }

        .form-check-input:checked {
            background-color: var(--primary);
            border-color: var(--primary);
        }

        /* Buttons */
        .btn {
            padding: 10px 20px;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            border: none;
            transition: all 0.2s;
            font-size: 14px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }

        .btn-primary {
            background: var(--primary);
            color: white;
        }

        .btn-primary:hover {
            background: var(--primary-dark);
            transform: translateY(-1px);
            color: white;
        }

        .btn-secondary {
            background: #64748b;
            color: white;
        }

        .btn-secondary:hover {
            background: #475569;
            color: white;
        }

        .btn-outline-primary {
            background: transparent;
            color: var(--primary);
            border: 2px solid var(--primary);
        }

        .btn-outline-primary:hover {
            background: var(--primary);
            color: white;
        }

        .btn-outline-secondary {
            background: transparent;
            color: #64748b;
            border: 2px solid #64748b;
        }

        .btn-outline-secondary:hover {
            background: #64748b;
            color: white;
        }

        .btn-outline-danger {
            background: transparent;
            color: var(--danger);
            border: 2px solid var(--danger);
        }

        .btn-outline-danger:hover {
            background: var(--danger);
            color: white;
        }

        .btn-sm {
            padding: 6px 12px;
            font-size: 13px;
        }

        .btn-group {
            display: inline-flex;
            gap: 4px;
        }

        /* Badges */
        .badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .bg-primary {
            background-color: var(--primary) !important;
        }

        .bg-success {
            background-color: var(--success) !important;
        }

        .bg-secondary {
            background-color: #94a3b8 !important;
        }

        .bg-info {
            background-color: #0ea5e9 !important;
        }

        .badge-pending { background: #fef3c7; color: #92400e; }
        .badge-success { background: #d1fae5; color: #065f46; }
        .badge-danger { background: #fee2e2; color: #991b1b; }

        /* Alerts */
        .alert {
            border-radius: 12px;
            border: none;
            padding: 16px 20px;
            margin-bottom: 24px;
        }

        .alert-success {
            background: #d1fae5;
            color: #065f46;
        }

        .alert-dismissible .btn-close {
            padding: 12px;
        }

        /* Utilities */
        .text-muted {
            color: var(--text-muted) !important;
        }

        .text-truncate {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .d-flex {
            display: flex !important;
        }

        .justify-content-between {
            justify-content: space-between !important;
        }

        .align-items-center {
            align-items: center !important;
        }

        .gap-2 {
            gap: 8px !important;
        }

        .mb-0 {
            margin-bottom: 0 !important;
        }

        .mb-3 {
            margin-bottom: 16px !important;
        }

        .mb-4 {
            margin-bottom: 24px !important;
        }

        .py-4 {
            padding-top: 24px !important;
            padding-bottom: 24px !important;
        }

        @media (max-width: 1024px) {
            .sidebar {
                transform: translateX(-100%);
            }
            .main-content {
                margin-left: 0;
            }
        }

    </style>
    @yield('styles')
</head>
<body>
    <div class="admin-container">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="brand">
                <i class="fas fa-graduation-cap"></i>
                Tuition Admin
            </div>
            
            <ul class="nav-menu">
                <li class="nav-item">
                    <a href="{{ route('admin.dashboard') }}" class="nav-link {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">
                        <i class="fas fa-grid-2"></i> Dashboard
                    </a>
                </li>

                <div class="nav-category">User Management</div>
                <li class="nav-item">
                    <a href="{{ route('admin.users.create', ['role' => 'teacher']) }}" class="nav-link {{ request()->is('admin/users/create') && request('role') == 'teacher' ? 'active' : '' }}">
                        <i class="fas fa-user-plus"></i> Register Teacher
                    </a>
                </li>
                <li class="nav-item">
                    <a href="{{ route('admin.teachers') }}" class="nav-link {{ request()->routeIs('admin.teachers') ? 'active' : '' }}">
                        <i class="fas fa-chalkboard-teacher"></i> Teachers List
                    </a>
                </li>
                <li class="nav-item">
                    <a href="{{ route('admin.students') }}" class="nav-link {{ request()->routeIs('admin.students') ? 'active' : '' }}">
                        <i class="fas fa-user-graduate"></i> Students
                    </a>
                </li>
                <li class="nav-item">
                    <a href="{{ route('admin.parents') }}" class="nav-link {{ request()->routeIs('admin.parents') ? 'active' : '' }}">
                        <i class="fas fa-users"></i> Parents
                    </a>
                </li>
                <li class="nav-item">
                    <a href="{{ route('admin.agents') }}" class="nav-link {{ request()->routeIs('admin.agents') ? 'active' : '' }}">
                        <i class="fas fa-user-friends"></i> Agents
                    </a>
                </li>

                <div class="nav-category">Operations</div>
                <li class="nav-item">
                    <a href="{{ route('admin.leads') }}" class="nav-link {{ request()->routeIs('admin.leads') ? 'active' : '' }}">
                        <i class="fas fa-bullseye"></i> Lead Monitoring
                    </a>
                </li>
                <li class="nav-item">
                    <a href="{{ route('admin.attendance') }}" class="nav-link {{ request()->routeIs('admin.attendance') ? 'active' : '' }}">
                        <i class="fas fa-calendar-check"></i> Attendance Monitoring
                    </a>
                </li>
                <li class="nav-item">
                    <a href="{{ route('admin.demo') }}" class="nav-link {{ request()->routeIs('admin.demo') ? 'active' : '' }}">
                        <i class="fas fa-video"></i> Demo Classes
                    </a>
                </li>
                <li class="nav-item">
                    <a href="{{ route('admin.leaves') }}" class="nav-link {{ request()->routeIs('admin.leaves') ? 'active' : '' }}">
                        <i class="fas fa-calendar-minus"></i> Teacher Leaves
                    </a>
                </li>

                <div class="nav-category">Education Management</div>
                <li class="nav-item">
                    <a href="{{ route('admin.homework') }}" class="nav-link {{ request()->routeIs('admin.homework') ? 'active' : '' }}">
                        <i class="fas fa-book-open"></i> Homework
                    </a>
                </li>
                <li class="nav-item">
                    <a href="{{ route('admin.teaching_plans') }}" class="nav-link {{ request()->routeIs('admin.teaching_plans') ? 'active' : '' }}">
                        <i class="fas fa-clipboard-list"></i> Teaching Plans
                    </a>
                </li>
                <li class="nav-item">
                    <a href="{{ route('admin.batches') }}" class="nav-link {{ request()->routeIs('admin.batches') ? 'active' : '' }}">
                        <i class="fas fa-layer-group"></i> Student Batches
                    </a>
                </li>
                <li class="nav-item">
                    <a href="{{ route('admin.rewards') }}" class="nav-link {{ request()->routeIs('admin.rewards') ? 'active' : '' }}">
                        <i class="fas fa-gift"></i> Teacher Rewards
                    </a>
                </li>
                <li class="nav-item">
                    <a href="{{ route('admin.teacher_feedback') }}" class="nav-link {{ request()->routeIs('admin.teacher_feedback') ? 'active' : '' }}">
                        <i class="fas fa-comment-dots"></i> Teacher Feedback
                    </a>
                </li>
                <li class="nav-item">
                    <a href="{{ route('admin.contact_requests') }}" class="nav-link {{ request()->routeIs('admin.contact_requests') ? 'active' : '' }}">
                        <i class="fas fa-phone-alt"></i> Contact Requests
                    </a>
                </li>

                <div class="nav-category">Finance</div>
                <li class="nav-item">
                    <a href="{{ route('admin.payments') }}" class="nav-link {{ request()->routeIs('admin.payments') ? 'active' : '' }}">
                        <i class="fas fa-wallet"></i> Payout Requests
                    </a>
                </li>
                <li class="nav-item">
                    <a href="{{ route('admin.transactions') }}" class="nav-link {{ request()->routeIs('admin.transactions') ? 'active' : '' }}">
                        <i class="fas fa-exchange-alt"></i> Transactions
                    </a>
                </li>

                <div class="nav-category">System</div>
                <li class="nav-item">
                    <a href="{{ route('admin.banners.index') }}" class="nav-link {{ request()->routeIs('admin.banners.*') ? 'active' : '' }}">
                        <i class="fas fa-images"></i> Banners
                    </a>
                </li>
                <li class="nav-item">
                    <a href="{{ route('admin.notifications') }}" class="nav-link {{ request()->routeIs('admin.notifications') ? 'active' : '' }}">
                        <i class="fas fa-bell"></i> Broadcast Messages
                    </a>
                </li>
                <li class="nav-item">
                    <a href="{{ route('admin.settings') }}" class="nav-link {{ request()->routeIs('admin.settings') ? 'active' : '' }}">
                        <i class="fas fa-percent"></i> Commission Settings
                    </a>
                </li>
                <li class="nav-item">
                    <a href="{{ route('admin.system_settings') }}" class="nav-link {{ request()->routeIs('admin.system_settings') ? 'active' : '' }}">
                        <i class="fas fa-sliders-h"></i> Global Configuration
                    </a>
                </li>
                <li class="nav-item">
                    <form action="{{ route('logout') }}" method="POST" id="logout-form" style="display: none;">
                        @csrf
                    </form>
                    <a href="#" class="nav-link" onclick="event.preventDefault(); document.getElementById('logout-form').submit();">
                        <i class="fas fa-sign-out-alt"></i> Logout
                    </a>
                </li>
            </ul>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <header>
                <div class="search-bar">
                    <i class="fas fa-search"></i>
                    <input type="text" placeholder="Search anything...">
                </div>

                <div class="header-actions">
                    <div class="notification-btn">
                        <i class="far fa-bell"></i>
                        <span class="notification-badge">3</span>
                    </div>
                    <div class="user-profile">
                        <div class="user-avatar">A</div>
                        <div class="user-info">
                            <div style="font-weight: 600; font-size: 14px;">Admin</div>
                            <div style="font-size: 11px; color: var(--text-muted)">Super Admin</div>
                        </div>
                    </div>
                </div>
            </header>

            <main class="page-content">
                @yield('content')
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    @yield('scripts')
</body>
</html>
