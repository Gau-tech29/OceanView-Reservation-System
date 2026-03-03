<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String successMsg = (String) request.getAttribute("successMsg");
    String errorMsg   = (String) request.getAttribute("errorMsg");
    String activeTab  = (String) request.getAttribute("activeTab");
    if (activeTab == null) activeTab = "profile";

    String createdAt = currentUser.getCreatedAt() != null
            ? currentUser.getCreatedAt().format(DateTimeFormatter.ofPattern("MMMM d, yyyy"))
            : "N/A";
    String lastLogin = currentUser.getLastLogin() != null
            ? currentUser.getLastLogin().format(DateTimeFormatter.ofPattern("MMM d, yyyy · HH:mm"))
            : "This session";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Settings - Ocean View Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary:       #0d6efd;
            --primary-dark:  #0a58ca;
            --primary-light: #e8f0fe;
            --success:       #10b981;
            --danger:        #ef4444;
            --warning:       #f59e0b;
            --muted:         #6c757d;
            --dark:          #212529;
            --border:        #e9ecef;
            --bg:            #f4f6f9;
            --sidebar-width: 280px;
            --card-radius:   18px;
        }
        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Poppins',sans-serif; background:var(--bg); overflow-x:hidden; }

        /* ── Sidebar ── */
        .sidebar {
            position:fixed; top:0; left:0; height:100vh;
            width:var(--sidebar-width);
            background:linear-gradient(180deg,#0a58ca 0%,#0d6efd 100%);
            color:white; z-index:1000;
            box-shadow:5px 0 25px rgba(13,110,253,.3);
            overflow-y:auto;
        }
        .sidebar-brand { padding:26px 25px 22px; border-bottom:1px solid rgba(255,255,255,.18); margin-bottom:8px; }
        .sidebar-brand h3 { font-size:1.55rem; font-weight:700; margin:0; }
        .sidebar-brand p  { font-size:.82rem; opacity:.85; margin:5px 0 0; }
        .sidebar-menu { list-style:none; padding:0 14px; margin:0; }
        .sidebar-menu li { margin-bottom:5px; }
        .sidebar-menu a {
            display:flex; align-items:center; gap:2px; padding:12px 18px;
            color:rgba(255,255,255,.85); text-decoration:none;
            border-radius:12px; transition:all .25s; font-size:.9rem; font-weight:500;
        }
        .sidebar-menu a i   { width:32px; font-size:1.05rem; }
        .sidebar-menu a:hover,
        .sidebar-menu a.active { background:rgba(255,255,255,.17); color:white; transform:translateX(4px); }
        .sidebar-divider { height:1px; background:rgba(255,255,255,.12); margin:12px 14px; }

        /* ── Layout ── */
        .main-content { margin-left:var(--sidebar-width); padding:26px 34px; min-height:100vh; }

        /* ── Top Nav ── */
        .top-nav {
            background:white; border-radius:var(--card-radius); padding:16px 28px;
            margin-bottom:28px; box-shadow:0 4px 20px rgba(13,110,253,.08);
            display:flex; justify-content:space-between; align-items:center;
        }
        .page-title h2 { font-size:1.5rem; font-weight:700; color:var(--dark); margin:0; }
        .page-title p  { color:var(--muted); margin:3px 0 0; font-size:.82rem; }
        .user-chip {
            display:flex; align-items:center; gap:12px;
            background:#f8faff; border-radius:14px; padding:8px 16px 8px 10px;
            border:1.5px solid var(--primary-light);
        }
        .user-avatar-sm {
            width:38px; height:38px; border-radius:10px;
            background:linear-gradient(135deg,#0d6efd,#0a58ca);
            display:flex; align-items:center; justify-content:center;
            color:white; font-weight:700; font-size:.95rem; flex-shrink:0;
        }
        .user-chip .u-name { font-weight:600; font-size:.88rem; color:var(--dark); }
        .user-chip .u-role { font-size:.72rem; color:var(--muted); }

        /* ── Toast ── */
        .toast-wrap { margin-bottom:20px; }
        .toast-msg {
            border-radius:14px; padding:14px 20px;
            display:flex; align-items:center; gap:12px;
            font-size:.875rem; font-weight:500; animation:slideIn .3s ease;
        }
        @keyframes slideIn { from{opacity:0;transform:translateY(-8px)} to{opacity:1;transform:none} }
        .toast-success { background:#d1fae5; color:#065f46; border:1.5px solid #a7f3d0; }
        .toast-error   { background:#fee2e2; color:#991b1b; border:1.5px solid #fca5a5; }
        .toast-msg .t-icon {
            width:36px; height:36px; border-radius:10px;
            display:flex; align-items:center; justify-content:center; flex-shrink:0;
        }
        .toast-success .t-icon { background:#10b981; color:white; }
        .toast-error   .t-icon { background:#ef4444; color:white; }
        .toast-close { margin-left:auto; background:none; border:none; font-size:1.1rem; cursor:pointer; opacity:.6; color:inherit; }
        .toast-close:hover { opacity:1; }

        /* ── Profile Hero ── */
        .profile-hero {
            background:linear-gradient(135deg,#0d6efd 0%,#0a58ca 100%);
            border-radius:var(--card-radius); padding:28px 32px;
            margin-bottom:24px; color:white;
            box-shadow:0 10px 30px rgba(13,110,253,.25);
            display:flex; align-items:center; gap:24px;
            position:relative; overflow:hidden;
        }
        .profile-hero::before {
            content:''; position:absolute; top:-40px; right:-40px;
            width:200px; height:200px; border-radius:50%;
            background:rgba(255,255,255,.07); pointer-events:none;
        }
        .profile-hero::after {
            content:''; position:absolute; bottom:-60px; right:80px;
            width:160px; height:160px; border-radius:50%;
            background:rgba(255,255,255,.05); pointer-events:none;
        }
        .hero-avatar {
            width:80px; height:80px; border-radius:20px;
            background:rgba(255,255,255,.2); backdrop-filter:blur(6px);
            border:3px solid rgba(255,255,255,.3);
            display:flex; align-items:center; justify-content:center;
            font-size:2rem; font-weight:700; flex-shrink:0; position:relative; z-index:1;
        }
        .hero-info { position:relative; z-index:1; }
        .hero-info h3 { font-size:1.5rem; font-weight:700; margin:0 0 4px; }
        .hero-info p  { margin:0; opacity:.85; font-size:.875rem; }
        .hero-badges  { display:flex; gap:8px; margin-top:10px; flex-wrap:wrap; }
        .hero-badge {
            background:rgba(255,255,255,.18); border-radius:20px;
            padding:4px 13px; font-size:.74rem; font-weight:600;
            display:inline-flex; align-items:center; gap:5px;
        }
        .hero-meta { margin-left:auto; text-align:right; position:relative; z-index:1; opacity:.85; font-size:.8rem; }
        .hero-meta div { margin-bottom:6px; }
        .hero-meta i { margin-right:5px; }

        /* ── Settings Layout ── */
        .settings-layout { display:grid; grid-template-columns:240px 1fr; gap:24px; align-items:start; }

        /* ── Tab Nav ── */
        .tab-nav {
            background:white; border-radius:var(--card-radius); overflow:hidden;
            box-shadow:0 2px 12px rgba(0,0,0,.06); position:sticky; top:20px;
        }
        .tab-nav-header { padding:18px 20px 14px; border-bottom:1px solid var(--border); }
        .tab-nav-header h6 { font-size:.75rem; font-weight:700; color:var(--muted); text-transform:uppercase; letter-spacing:.7px; margin:0; }
        .tab-btn {
            display:flex; align-items:center; gap:12px; width:100%;
            padding:13px 20px; background:none; border:none; text-align:left;
            color:var(--muted); font-size:.875rem; font-weight:500;
            cursor:pointer; transition:all .2s; border-left:3px solid transparent;
            font-family:'Poppins',sans-serif;
        }
        .tab-btn .tab-icon {
            width:34px; height:34px; border-radius:9px;
            display:flex; align-items:center; justify-content:center; flex-shrink:0;
            background:#f4f6f9; color:var(--muted); font-size:.9rem; transition:all .2s;
        }
        .tab-btn:hover { background:#f8faff; color:var(--dark); }
        .tab-btn:hover .tab-icon { background:var(--primary-light); color:var(--primary); }
        .tab-btn.active { background:#f0f6ff; color:var(--primary); border-left-color:var(--primary); }
        .tab-btn.active .tab-icon { background:var(--primary); color:white; }
        .tab-btn .tab-label { flex:1; }
        .tab-btn .tab-arrow { font-size:.7rem; opacity:.5; }
        .tab-btn.active .tab-arrow { opacity:1; color:var(--primary); }

        /* ── Panel ── */
        .settings-panel { display:none; }
        .settings-panel.active { display:block; }
        .panel-card {
            background:white; border-radius:var(--card-radius); padding:30px;
            box-shadow:0 2px 12px rgba(0,0,0,.06); margin-bottom:20px;
        }
        .panel-card:last-child { margin-bottom:0; }
        .panel-title {
            font-size:1.05rem; font-weight:700; color:var(--dark);
            margin-bottom:6px; display:flex; align-items:center; gap:9px;
        }
        .panel-title .pt-icon {
            width:36px; height:36px; border-radius:10px;
            background:linear-gradient(135deg,#0d6efd,#0a58ca);
            display:flex; align-items:center; justify-content:center;
            color:white; font-size:.9rem; flex-shrink:0;
        }
        .panel-title.purple .pt-icon { background:linear-gradient(135deg,#7c3aed,#6d28d9); }
        .panel-title.green  .pt-icon { background:linear-gradient(135deg,#10b981,#059669); }
        .panel-title.orange .pt-icon { background:linear-gradient(135deg,#f59e0b,#d97706); }
        .panel-title.teal   .pt-icon { background:linear-gradient(135deg,#0891b2,#0e7490); }
        .panel-subtitle { font-size:.82rem; color:var(--muted); margin-bottom:22px; padding-left:45px; }
        .panel-divider  { height:1px; background:var(--border); margin:22px 0; }

        /* ── Form ── */
        .form-group { margin-bottom:18px; }
        .form-row   { display:grid; grid-template-columns:1fr 1fr; gap:18px; }
        .field-label {
            font-size:.78rem; font-weight:700; color:var(--muted);
            text-transform:uppercase; letter-spacing:.5px; margin-bottom:7px;
            display:flex; align-items:center; gap:6px;
        }
        .field-label .req { color:var(--danger); }
        .field-wrap { position:relative; }
        .field-input {
            width:100%; border:2px solid var(--border); border-radius:12px;
            padding:11px 15px; font-size:.9rem; font-family:'Poppins',sans-serif;
            color:var(--dark); background:white; transition:all .25s; outline:none;
        }
        .field-input:focus { border-color:var(--primary); box-shadow:0 0 0 4px rgba(13,110,253,.1); }
        .field-input.readonly-field { background:#f8f9fa; color:var(--muted); cursor:not-allowed; }
        .field-input.pw-input { padding-right:48px; }
        .pw-toggle {
            position:absolute; right:14px; top:50%; transform:translateY(-50%);
            background:none; border:none; color:var(--muted); cursor:pointer;
            font-size:.9rem; padding:4px; transition:color .2s;
        }
        .pw-toggle:hover { color:var(--primary); }
        .field-hint { font-size:.76rem; color:var(--muted); margin-top:5px; }
        .field-hint i { color:var(--primary); margin-right:3px; }

        /* ── Strength ── */
        .strength-wrap { margin-top:8px; }
        .strength-track { height:5px; background:#e9ecef; border-radius:10px; overflow:hidden; }
        .strength-fill  { height:100%; width:0; border-radius:10px; transition:all .35s; }
        .strength-text  { font-size:.74rem; font-weight:600; margin-top:5px; }
        .rules-checklist { list-style:none; padding:0; margin:10px 0 0; display:grid; grid-template-columns:1fr 1fr; gap:4px; }
        .rules-checklist li { font-size:.76rem; color:var(--muted); display:flex; align-items:center; gap:5px; transition:color .2s; }
        .rules-checklist li i { width:13px; transition:color .2s; }
        .rules-checklist li.ok   { color:#065f46; }
        .rules-checklist li.ok i { color:var(--success); }

        /* ── Buttons ── */
        .btn-primary-custom {
            background:linear-gradient(135deg,#0d6efd,#0a58ca); color:white; border:none;
            padding:12px 30px; border-radius:12px; font-weight:600; font-size:.875rem;
            cursor:pointer; transition:all .2s; font-family:'Poppins',sans-serif;
            box-shadow:0 4px 15px rgba(13,110,253,.3); display:inline-flex; align-items:center; gap:8px;
        }
        .btn-primary-custom:hover  { transform:translateY(-2px); box-shadow:0 6px 20px rgba(13,110,253,.4); }
        .btn-purple-custom {
            background:linear-gradient(135deg,#7c3aed,#6d28d9); color:white; border:none;
            padding:12px 30px; border-radius:12px; font-weight:600; font-size:.875rem;
            cursor:pointer; transition:all .2s; font-family:'Poppins',sans-serif;
            box-shadow:0 4px 15px rgba(124,58,237,.3); display:inline-flex; align-items:center; gap:8px;
        }
        .btn-purple-custom:hover { transform:translateY(-2px); box-shadow:0 6px 20px rgba(124,58,237,.4); }
        .btn-ghost {
            background:white; border:2px solid var(--border); color:var(--muted);
            padding:11px 24px; border-radius:12px; font-weight:500; font-size:.875rem;
            cursor:pointer; transition:all .2s; font-family:'Poppins',sans-serif;
            display:inline-flex; align-items:center; gap:7px;
        }
        .btn-ghost:hover { background:#f8f9fa; border-color:#cdd0d5; color:var(--dark); }
        .form-actions { display:flex; align-items:center; gap:12px; justify-content:flex-end; margin-top:24px; }

        /* ── Info Grid ── */
        .info-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:14px; }
        .info-tile {
            background:#f8faff; border-radius:14px; padding:16px 18px;
            border:1.5px solid #e8f0fe;
        }
        .info-tile .it-label { font-size:.72rem; font-weight:700; color:var(--muted); text-transform:uppercase; letter-spacing:.5px; margin-bottom:6px; display:flex; align-items:center; gap:5px; }
        .info-tile .it-label i { color:var(--primary); }
        .info-tile .it-value  { font-size:.95rem; font-weight:600; color:var(--dark); }
        .info-tile .it-sub    { font-size:.75rem; color:var(--muted); margin-top:2px; }

        /* ── Security Tiles ── */
        .sec-grid { display:grid; grid-template-columns:1fr 1fr; gap:14px; margin-bottom:22px; }
        .sec-tile { border-radius:14px; padding:16px 18px; display:flex; align-items:center; gap:14px; }
        .sec-tile.good { background:#d1fae5; border:1.5px solid #a7f3d0; }
        .sec-tile.warn { background:#fef3c7; border:1.5px solid #fde68a; }
        .sec-tile .sec-icon { width:40px; height:40px; border-radius:10px; display:flex; align-items:center; justify-content:center; flex-shrink:0; font-size:1.1rem; }
        .sec-tile.good .sec-icon { background:#10b981; color:white; }
        .sec-tile.warn .sec-icon { background:#f59e0b; color:white; }
        .sec-tile .sec-label { font-size:.78rem; font-weight:600; margin:0 0 2px; }
        .sec-tile.good .sec-label { color:#065f46; }
        .sec-tile.warn .sec-label { color:#92400e; }
        .sec-tile .sec-desc { font-size:.73rem; color:var(--muted); margin:0; }

        /* ── Sys Rows ── */
        .sys-row {
            display:flex; align-items:center; justify-content:space-between;
            padding:13px 0; border-bottom:1px solid var(--border); font-size:.875rem;
        }
        .sys-row:last-child { border-bottom:none; }
        .sys-row .sys-key { color:var(--muted); font-weight:500; display:flex; align-items:center; gap:8px; }
        .sys-row .sys-key i { color:var(--primary); width:16px; }
        .sys-row .sys-val { font-weight:600; color:var(--dark); }
        .sys-badge { background:var(--primary-light); color:var(--primary); border-radius:20px; padding:3px 12px; font-size:.75rem; font-weight:600; }
        .sys-badge.green  { background:#d1fae5; color:#065f46; }
        .sys-badge.orange { background:#fef3c7; color:#92400e; }

        /* ── Session Card ── */
        .session-header {
            display:flex; align-items:center; gap:16px;
            background:linear-gradient(135deg,#0891b2,#0e7490);
            border-radius:14px; padding:20px 22px; margin-bottom:22px; color:white;
        }
        .session-icon {
            width:52px; height:52px; border-radius:14px;
            background:rgba(255,255,255,.2);
            display:flex; align-items:center; justify-content:center;
            font-size:1.4rem; flex-shrink:0;
        }
        .session-header h5 { font-size:1.05rem; font-weight:700; margin:0 0 3px; }
        .session-header p  { font-size:.8rem; opacity:.85; margin:0; }
        .session-status { margin-left:auto; }
        .pulse-badge {
            display:inline-flex; align-items:center; gap:7px;
            background:rgba(255,255,255,.2); border-radius:20px;
            padding:6px 14px; font-size:.78rem; font-weight:600;
        }
        .pulse-dot {
            width:8px; height:8px; border-radius:50%; background:#4ade80;
            animation:pulse 1.5s infinite;
        }
        @keyframes pulse {
            0%,100% { opacity:1; transform:scale(1); }
            50%      { opacity:.5; transform:scale(.8); }
        }
        .btn-logout-session {
            background:white; border:none; color:#0e7490;
            padding:10px 22px; border-radius:10px; font-weight:600; font-size:.82rem;
            cursor:pointer; transition:all .2s; font-family:'Poppins',sans-serif;
            display:inline-flex; align-items:center; gap:7px; text-decoration:none;
            box-shadow:0 2px 8px rgba(0,0,0,.12);
        }
        .btn-logout-session:hover { background:#f0fdff; color:#0e7490; transform:translateY(-1px); }

        /* ── Responsive ── */
        @media(max-width:1100px) { .settings-layout{grid-template-columns:200px 1fr;} }
        @media(max-width:900px) {
            .sidebar{transform:translateX(-100%);}
            .main-content{margin-left:0; padding:16px;}
            .settings-layout{grid-template-columns:1fr;}
            .tab-nav{position:static;}
            .form-row{grid-template-columns:1fr;}
            .info-grid{grid-template-columns:1fr 1fr;}
            .sec-grid{grid-template-columns:1fr;}
            .hero-meta{display:none;}
            .rules-checklist{grid-template-columns:1fr;}
        }
        @media(max-width:600px) { .info-grid{grid-template-columns:1fr;} }
    </style>
</head>
<body>

<!-- ═══ SIDEBAR ═══ -->
<div class="sidebar">
    <div class="sidebar-brand">
        <h3><i class="fas fa-hotel me-2"></i>Ocean View</h3>
        <p>Hotel Reservation System</p>
    </div>
    <ul class="sidebar-menu">
        <li><a href="${pageContext.request.contextPath}/admin/dashboard">
            <i class="fas fa-chart-pie"></i><span>Dashboard</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/manage-staff">
            <i class="fas fa-users-cog"></i><span>Manage Staff</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/manage-rooms">
            <i class="fas fa-door-open"></i><span>Manage Rooms</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/reservations">
            <i class="fas fa-calendar-alt"></i><span>All Reservations</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/guests">
            <i class="fas fa-users"></i><span>Guests</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/payments">
            <i class="fas fa-credit-card"></i><span>Payments & Bills</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/reports">
            <i class="fas fa-chart-bar"></i><span>Reports</span></a></li>
        <div class="sidebar-divider"></div>
        <li><a href="${pageContext.request.contextPath}/admin/settings" class="active">
            <i class="fas fa-cog"></i><span>Settings</span></a></li>
        <li><a href="${pageContext.request.contextPath}/logout">
            <i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
    </ul>
</div>

<!-- ═══ MAIN ═══ -->
<div class="main-content">

    <!-- Top Nav -->
    <div class="top-nav">
        <div class="page-title">
            <h2><i class="fas fa-cog me-2" style="color:var(--primary);"></i>Settings</h2>
            <p>Manage your account, security and system preferences</p>
        </div>
        <div class="user-chip">
            <div class="user-avatar-sm">
                <%= currentUser.getFirstName().charAt(0) %><%= currentUser.getLastName().charAt(0) %>
            </div>
            <div>
                <div class="u-name"><%= currentUser.getFullName() %></div>
                <div class="u-role"><%= currentUser.getRole() %></div>
            </div>
        </div>
    </div>

    <!-- Flash Messages -->
    <% if (successMsg != null) { %>
    <div class="toast-wrap" id="toastWrap">
        <div class="toast-msg toast-success">
            <div class="t-icon"><i class="fas fa-check"></i></div>
            <span><%= successMsg %></span>
            <button class="toast-close" onclick="document.getElementById('toastWrap').remove()">
                <i class="fas fa-times"></i>
            </button>
        </div>
    </div>
    <% } %>
    <% if (errorMsg != null) { %>
    <div class="toast-wrap" id="toastWrap">
        <div class="toast-msg toast-error">
            <div class="t-icon"><i class="fas fa-exclamation"></i></div>
            <span><%= errorMsg %></span>
            <button class="toast-close" onclick="document.getElementById('toastWrap').remove()">
                <i class="fas fa-times"></i>
            </button>
        </div>
    </div>
    <% } %>

    <!-- Profile Hero -->
    <div class="profile-hero">
        <div class="hero-avatar">
            <%= currentUser.getFirstName().charAt(0) %><%= currentUser.getLastName().charAt(0) %>
        </div>
        <div class="hero-info">
            <h3><%= currentUser.getFullName() %></h3>
            <p>
                <i class="fas fa-at me-1"></i><%= currentUser.getUsername() %>
                &nbsp;·&nbsp;
                <i class="fas fa-envelope me-1"></i><%= currentUser.getEmail() %>
            </p>
            <div class="hero-badges">
                <span class="hero-badge"><i class="fas fa-shield-alt"></i> Administrator</span>
                <span class="hero-badge"><i class="fas fa-check-circle"></i> Active Account</span>
                <% if (currentUser.getPhone() != null && !currentUser.getPhone().isEmpty()) { %>
                <span class="hero-badge"><i class="fas fa-phone"></i> <%= currentUser.getPhone() %></span>
                <% } %>
            </div>
        </div>
        <div class="hero-meta">
            <div><i class="fas fa-calendar-plus"></i> Member since <%= createdAt %></div>
            <div><i class="fas fa-clock"></i> Last login: <%= lastLogin %></div>
            <div><i class="fas fa-id-badge"></i> User ID: #<%= currentUser.getId() %></div>
        </div>
    </div>

    <!-- Settings Layout -->
    <div class="settings-layout">

        <!-- ── Left Tab Nav ── -->
        <nav class="tab-nav">
            <div class="tab-nav-header"><h6>Settings Menu</h6></div>

            <button class="tab-btn <%= "profile".equals(activeTab)  ? "active" : "" %>"
                    onclick="switchTab('profile')">
                <span class="tab-icon"><i class="fas fa-user"></i></span>
                <span class="tab-label">Profile</span>
                <i class="fas fa-chevron-right tab-arrow"></i>
            </button>

            <button class="tab-btn <%= "security".equals(activeTab) ? "active" : "" %>"
                    onclick="switchTab('security')">
                <span class="tab-icon"><i class="fas fa-lock"></i></span>
                <span class="tab-label">Security</span>
                <i class="fas fa-chevron-right tab-arrow"></i>
            </button>

            <button class="tab-btn <%= "account".equals(activeTab)  ? "active" : "" %>"
                    onclick="switchTab('account')">
                <span class="tab-icon"><i class="fas fa-id-card"></i></span>
                <span class="tab-label">Account Info</span>
                <i class="fas fa-chevron-right tab-arrow"></i>
            </button>

            <button class="tab-btn <%= "system".equals(activeTab)   ? "active" : "" %>"
                    onclick="switchTab('system')">
                <span class="tab-icon"><i class="fas fa-server"></i></span>
                <span class="tab-label">System Info</span>
                <i class="fas fa-chevron-right tab-arrow"></i>
            </button>

            <button class="tab-btn <%= "session".equals(activeTab)  ? "active" : "" %>"
                    onclick="switchTab('session')">
                <span class="tab-icon"><i class="fas fa-satellite-dish"></i></span>
                <span class="tab-label">Current Session</span>
                <i class="fas fa-chevron-right tab-arrow"></i>
            </button>
        </nav>

        <!-- ── Right Panels ── -->
        <div class="panels-wrap">

            <!-- ══ PROFILE ══ -->
            <div class="settings-panel <%= "profile".equals(activeTab) ? "active" : "" %>" id="panel-profile">
                <div class="panel-card">
                    <div class="panel-title">
                        <div class="pt-icon"><i class="fas fa-user-edit"></i></div>
                        Edit Profile Information
                    </div>
                    <div class="panel-subtitle">Update your display name, email address and contact details.</div>

                    <form action="${pageContext.request.contextPath}/admin/settings"
                          method="POST" id="profileForm">
                        <input type="hidden" name="action" value="updateProfile">

                        <div class="form-row">
                            <div class="form-group">
                                <div class="field-label">First Name <span class="req">*</span></div>
                                <input type="text" class="field-input" name="firstName"
                                       value="<%= currentUser.getFirstName() %>"
                                       placeholder="First name" required maxlength="50">
                            </div>
                            <div class="form-group">
                                <div class="field-label">Last Name <span class="req">*</span></div>
                                <input type="text" class="field-input" name="lastName"
                                       value="<%= currentUser.getLastName() %>"
                                       placeholder="Last name" required maxlength="50">
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="field-label">Email Address <span class="req">*</span></div>
                            <input type="email" class="field-input" name="email"
                                   value="<%= currentUser.getEmail() %>"
                                   placeholder="admin@oceanview.com" required>
                            <div class="field-hint"><i class="fas fa-info-circle"></i> Used for system notifications and login identification.</div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <div class="field-label">Phone Number</div>
                                <input type="tel" class="field-input" name="phone"
                                       value="<%= currentUser.getPhone() != null ? currentUser.getPhone() : "" %>"
                                       placeholder="+94 77 123 4567">
                                <div class="field-hint"><i class="fas fa-info-circle"></i> Optional. International format preferred.</div>
                            </div>
                            <div class="form-group">
                                <div class="field-label">Username</div>
                                <input type="text" class="field-input readonly-field"
                                       value="<%= currentUser.getUsername() %>" readonly>
                                <div class="field-hint"><i class="fas fa-lock"></i> Username cannot be changed after account creation.</div>
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <div class="field-label">Role</div>
                                <input type="text" class="field-input readonly-field"
                                       value="<%= currentUser.getRole() %>" readonly>
                            </div>
                            <div class="form-group">
                                <div class="field-label">Account Status</div>
                                <input type="text" class="field-input readonly-field"
                                       value="<%= currentUser.isActive() ? "Active" : "Inactive" %>" readonly
                                       style="color:<%= currentUser.isActive() ? "#065f46" : "#991b1b" %>; font-weight:600;">
                            </div>
                        </div>

                        <div class="form-actions">
                            <button type="reset" class="btn-ghost"><i class="fas fa-undo"></i> Reset</button>
                            <button type="submit" class="btn-primary-custom"><i class="fas fa-save"></i> Save Profile</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- ══ SECURITY ══ -->
            <div class="settings-panel <%= "security".equals(activeTab) ? "active" : "" %>" id="panel-security">

                <div class="panel-card">
                    <div class="panel-title purple">
                        <div class="pt-icon"><i class="fas fa-shield-alt"></i></div>
                        Security Overview
                    </div>
                    <div class="panel-subtitle">Your account security status at a glance.</div>
                    <div class="sec-grid">
                        <div class="sec-tile good">
                            <div class="sec-icon"><i class="fas fa-check"></i></div>
                            <div>
                                <p class="sec-label">Password Protected</p>
                                <p class="sec-desc">Your account has a strong password set</p>
                            </div>
                        </div>
                        <div class="sec-tile good">
                            <div class="sec-icon"><i class="fas fa-user-shield"></i></div>
                            <div>
                                <p class="sec-label">Admin Privileges</p>
                                <p class="sec-desc">Full system access granted</p>
                            </div>
                        </div>
                        <div class="sec-tile good">
                            <div class="sec-icon"><i class="fas fa-clock"></i></div>
                            <div>
                                <p class="sec-label">Last Login Tracked</p>
                                <p class="sec-desc"><%= lastLogin %></p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="panel-card">
                    <div class="panel-title purple">
                        <div class="pt-icon"><i class="fas fa-key"></i></div>
                        Change Password
                    </div>
                    <div class="panel-subtitle">Update your password regularly to keep your account secure.</div>

                    <form action="${pageContext.request.contextPath}/admin/settings"
                          method="POST" id="passwordForm">
                        <input type="hidden" name="action" value="changePassword">

                        <div class="form-group">
                            <div class="field-label">Current Password <span class="req">*</span></div>
                            <div class="field-wrap">
                                <input type="password" class="field-input pw-input"
                                       name="currentPassword" id="currentPw"
                                       placeholder="Enter your current password"
                                       required autocomplete="current-password">
                                <button type="button" class="pw-toggle" onclick="togglePw('currentPw','eyeCur')">
                                    <i class="fas fa-eye" id="eyeCur"></i>
                                </button>
                            </div>
                        </div>

                        <div class="panel-divider"></div>

                        <div class="form-row">
                            <div class="form-group">
                                <div class="field-label">New Password <span class="req">*</span></div>
                                <div class="field-wrap">
                                    <input type="password" class="field-input pw-input"
                                           name="newPassword" id="newPw"
                                           placeholder="Enter new password"
                                           required autocomplete="new-password"
                                           oninput="onNewPwInput(this.value)">
                                    <button type="button" class="pw-toggle" onclick="togglePw('newPw','eyeNew')">
                                        <i class="fas fa-eye" id="eyeNew"></i>
                                    </button>
                                </div>
                                <div class="strength-wrap">
                                    <div class="strength-track"><div class="strength-fill" id="strFill"></div></div>
                                    <div class="strength-text" id="strText" style="color:var(--muted);">Enter a password</div>
                                    <ul class="rules-checklist">
                                        <li id="rLen"><i class="fas fa-circle"></i> 8+ characters</li>
                                        <li id="rUpper"><i class="fas fa-circle"></i> Uppercase letter</li>
                                        <li id="rLower"><i class="fas fa-circle"></i> Lowercase letter</li>
                                        <li id="rNum"><i class="fas fa-circle"></i> Number</li>
                                    </ul>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="field-label">Confirm New Password <span class="req">*</span></div>
                                <div class="field-wrap">
                                    <input type="password" class="field-input pw-input"
                                           name="confirmPassword" id="confirmPw"
                                           placeholder="Re-enter new password"
                                           required autocomplete="new-password"
                                           oninput="onConfirmInput()">
                                    <button type="button" class="pw-toggle" onclick="togglePw('confirmPw','eyeConf')">
                                        <i class="fas fa-eye" id="eyeConf"></i>
                                    </button>
                                </div>
                                <div class="field-hint" id="matchHint" style="display:none;"></div>
                                <div class="field-hint" style="margin-top:10px;">
                                    <i class="fas fa-info-circle"></i>
                                    Min 8 chars · uppercase · lowercase · number
                                </div>
                            </div>
                        </div>

                        <div class="form-actions">
                            <button type="reset" class="btn-ghost" onclick="resetStrength()">
                                <i class="fas fa-undo"></i> Clear
                            </button>
                            <button type="submit" class="btn-purple-custom">
                                <i class="fas fa-key"></i> Change Password
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- ══ ACCOUNT INFO ══ -->
            <div class="settings-panel <%= "account".equals(activeTab) ? "active" : "" %>" id="panel-account">
                <div class="panel-card">
                    <div class="panel-title green">
                        <div class="pt-icon"><i class="fas fa-id-card"></i></div>
                        Account Overview
                    </div>
                    <div class="panel-subtitle">A complete summary of your account details and activity.</div>

                    <div class="info-grid" style="margin-bottom:22px;">
                        <div class="info-tile">
                            <div class="it-label"><i class="fas fa-hashtag"></i> User ID</div>
                            <div class="it-value">#<%= currentUser.getId() %></div>
                            <div class="it-sub">System identifier</div>
                        </div>
                        <div class="info-tile">
                            <div class="it-label"><i class="fas fa-user"></i> Username</div>
                            <div class="it-value"><%= currentUser.getUsername() %></div>
                            <div class="it-sub">Login credential</div>
                        </div>
                        <div class="info-tile">
                            <div class="it-label"><i class="fas fa-shield-alt"></i> Role</div>
                            <div class="it-value"><%= currentUser.getRole() %></div>
                            <div class="it-sub">Access level</div>
                        </div>
                        <div class="info-tile">
                            <div class="it-label"><i class="fas fa-envelope"></i> Email</div>
                            <div class="it-value" style="font-size:.85rem; word-break:break-all;"><%= currentUser.getEmail() %></div>
                            <div class="it-sub">Contact & login</div>
                        </div>
                        <div class="info-tile">
                            <div class="it-label"><i class="fas fa-phone"></i> Phone</div>
                            <div class="it-value">
                                <%= (currentUser.getPhone() != null && !currentUser.getPhone().isEmpty())
                                        ? currentUser.getPhone() : "Not set" %>
                            </div>
                            <div class="it-sub">Contact number</div>
                        </div>
                        <div class="info-tile">
                            <div class="it-label"><i class="fas fa-toggle-on"></i> Status</div>
                            <div class="it-value"
                                 style="color:<%= currentUser.isActive() ? "#065f46" : "#991b1b" %>;">
                                <i class="fas fa-circle"
                                   style="font-size:.5rem; vertical-align:middle; margin-right:4px;"></i>
                                <%= currentUser.isActive() ? "Active" : "Inactive" %>
                            </div>
                            <div class="it-sub">Account state</div>
                        </div>
                    </div>

                    <div class="panel-divider"></div>
                    <div style="font-size:.78rem; font-weight:700; color:var(--muted); text-transform:uppercase; letter-spacing:.5px; margin-bottom:14px;">
                        <i class="fas fa-history me-1" style="color:var(--primary);"></i> Login History
                    </div>
                    <div class="sys-row">
                        <div class="sys-key"><i class="fas fa-calendar-plus"></i> Account Created</div>
                        <div class="sys-val"><%= createdAt %></div>
                    </div>
                    <div class="sys-row">
                        <div class="sys-key"><i class="fas fa-sign-in-alt"></i> Last Login</div>
                        <div class="sys-val"><%= lastLogin %></div>
                    </div>
                    <div class="sys-row">
                        <div class="sys-key"><i class="fas fa-globe"></i> Current Session</div>
                        <div class="sys-val"><span class="sys-badge green">Active</span></div>
                    </div>
                </div>
            </div>

            <!-- ══ SYSTEM INFO ══ -->
            <div class="settings-panel <%= "system".equals(activeTab) ? "active" : "" %>" id="panel-system">
                <div class="panel-card">
                    <div class="panel-title orange">
                        <div class="pt-icon"><i class="fas fa-server"></i></div>
                        System Information
                    </div>
                    <div class="panel-subtitle">Technical details about this installation of Ocean View Hotel System.</div>

                    <%
                        String contextPath = request.getContextPath();
                        String serverInfo  = application.getServerInfo();
                        String javaVersion = System.getProperty("java.version");
                        java.time.LocalDateTime nowDt = java.time.LocalDateTime.now();
                        String serverTime = nowDt.format(
                                java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                    %>

                    <!-- Application -->
                    <div style="font-size:.78rem; font-weight:700; color:var(--muted); text-transform:uppercase; letter-spacing:.5px; margin-bottom:12px;">
                        <i class="fas fa-code me-1" style="color:var(--primary);"></i> Application
                    </div>
                    <div class="sys-row">
                        <div class="sys-key"><i class="fas fa-hotel"></i> System Name</div>
                        <div class="sys-val">Ocean View Hotel Reservation System</div>
                    </div>
                    <div class="sys-row">
                        <div class="sys-key"><i class="fas fa-tag"></i> Version</div>
                        <div class="sys-val"><span class="sys-badge">v1.0.0</span></div>
                    </div>
                    <div class="sys-row">
                        <div class="sys-key"><i class="fas fa-link"></i> Context Path</div>
                        <div class="sys-val">
                            <code style="background:#f4f6f9; padding:2px 8px; border-radius:6px; font-size:.82rem;">
                                <%= contextPath.isEmpty() ? "/" : contextPath %>
                            </code>
                        </div>
                    </div>
                    <div class="sys-row">
                        <div class="sys-key"><i class="fas fa-globe"></i> Servlet Container</div>
                        <div class="sys-val"><%= serverInfo %></div>
                    </div>
                    <div class="sys-row">
                        <div class="sys-key"><i class="fas fa-coffee"></i> Java Version</div>
                        <div class="sys-val"><span class="sys-badge"><%= javaVersion %></span></div>
                    </div>
                    <div class="sys-row">
                        <div class="sys-key"><i class="fas fa-clock"></i> Server Time</div>
                        <div class="sys-val"><%= serverTime %></div>
                    </div>
                </div>
            </div>

            <!-- ══ CURRENT SESSION ══ -->
            <div class="settings-panel <%= "session".equals(activeTab) ? "active" : "" %>" id="panel-session">
                <div class="panel-card">
                    <div class="panel-title teal">
                        <div class="pt-icon"><i class="fas fa-satellite-dish"></i></div>
                        Current Session
                    </div>
                    <div class="panel-subtitle">Details about your active login session.</div>

                    <%
                        javax.servlet.http.HttpSession sess = request.getSession(false);
                        long sessionAge  = sess != null
                                ? (System.currentTimeMillis() - sess.getCreationTime()) / 60000 : 0;
                        long sessionAgeH = sessionAge / 60;
                        long sessionAgeM = sessionAge % 60;
                        int  maxInactive = sess != null ? sess.getMaxInactiveInterval() / 60 : 30;
                        java.time.LocalDateTime loginTime = currentUser.getLastLogin() != null
                                ? currentUser.getLastLogin() : java.time.LocalDateTime.now();
                        String loginTimeStr = loginTime.format(
                                java.time.format.DateTimeFormatter.ofPattern("MMMM d, yyyy · HH:mm:ss"));
                    %>

                    <!-- Session header strip -->
                    <div class="session-header">
                        <div class="session-icon"><i class="fas fa-user-circle"></i></div>
                        <div>
                            <h5><%= currentUser.getFullName() %></h5>
                            <p>Logged in as &nbsp;<strong><%= currentUser.getRole() %></strong>
                                &nbsp;·&nbsp; @<%= currentUser.getUsername() %></p>
                        </div>
                        <div class="session-status">
                            <span class="pulse-badge">
                                <span class="pulse-dot"></span> Active
                            </span>
                        </div>
                    </div>

                    <!-- Session details -->
                    <div class="sys-row">
                        <div class="sys-key"><i class="fas fa-sign-in-alt"></i> Logged In At</div>
                        <div class="sys-val"><%= loginTimeStr %></div>
                    </div>
                    <div class="sys-row">
                        <div class="sys-key"><i class="fas fa-hourglass-start"></i> Session Duration</div>
                        <div class="sys-val">
                            <% if (sessionAgeH > 0) { %>
                            <%= sessionAgeH %> hr <%= sessionAgeM %> min
                            <% } else { %>
                            <%= sessionAgeM %> minute<%= sessionAgeM != 1 ? "s" : "" %>
                            <% } %>
                        </div>
                    </div>
                    <div class="sys-row">
                        <div class="sys-key"><i class="fas fa-hourglass-end"></i> Idle Timeout</div>
                        <div class="sys-val"><%= maxInactive %> minutes of inactivity</div>
                    </div>
                    <div class="sys-row">
                        <div class="sys-key"><i class="fas fa-shield-alt"></i> Access Level</div>
                        <div class="sys-val"><span class="sys-badge"><%= currentUser.getRole() %></span></div>
                    </div>
                    <div class="sys-row">
                        <div class="sys-key"><i class="fas fa-circle"></i> Session Status</div>
                        <div class="sys-val"><span class="sys-badge green">Active &amp; Secure</span></div>
                    </div>

                    <!-- Logout button -->
                    <div style="margin-top:22px; padding-top:18px; border-top:1px solid var(--border); display:flex; justify-content:flex-end;">
                        <a href="${pageContext.request.contextPath}/logout"
                           class="btn-logout-session"
                           onclick="return confirm('Are you sure you want to log out?')">
                            <i class="fas fa-sign-out-alt"></i> End Session &amp; Logout
                        </a>
                    </div>
                </div>
            </div>

        </div><!-- /.panels-wrap -->
    </div><!-- /.settings-layout -->
</div><!-- /.main-content -->

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // ── Tab Switching ────────────────────────────────────────────────────────────
    function switchTab(name) {
        document.querySelectorAll('.tab-btn').forEach(function(b){ b.classList.remove('active'); });
        document.querySelectorAll('.settings-panel').forEach(function(p){ p.classList.remove('active'); });
        var btn = document.querySelector('[onclick="switchTab(\'' + name + '\')"]');
        if (btn) btn.classList.add('active');
        var panel = document.getElementById('panel-' + name);
        if (panel) panel.classList.add('active');
        localStorage.setItem('settingsTab', name);
    }

    // Server-set activeTab always wins; only fall back to localStorage on plain GET
    (function() {
        var server = '<%= activeTab %>';
        if (server && server !== 'profile') return; // server already opened the right tab
        var saved = localStorage.getItem('settingsTab');
        if (saved && document.getElementById('panel-' + saved)) switchTab(saved);
    })();

    // ── Password Toggle ──────────────────────────────────────────────────────────
    function togglePw(inputId, iconId) {
        var inp = document.getElementById(inputId);
        var ico = document.getElementById(iconId);
        inp.type = (inp.type === 'password') ? 'text' : 'password';
        ico.className = (inp.type === 'text') ? 'fas fa-eye-slash' : 'fas fa-eye';
    }

    // ── Password Strength ────────────────────────────────────────────────────────
    var strengthLevels = [
        { color:'#ef4444', label:'Very Weak',   pct:20  },
        { color:'#f97316', label:'Weak',        pct:40  },
        { color:'#eab308', label:'Fair',        pct:60  },
        { color:'#22c55e', label:'Strong',      pct:80  },
        { color:'#10b981', label:'Very Strong', pct:100 }
    ];

    function setRule(id, ok) {
        var el = document.getElementById(id);
        if (!el) return;
        el.className = ok ? 'ok' : '';
        el.querySelector('i').className = ok ? 'fas fa-check-circle' : 'fas fa-circle';
    }

    function onNewPwInput(pw) {
        var len   = pw.length >= 8;
        var upper = /[A-Z]/.test(pw);
        var lower = /[a-z]/.test(pw);
        var num   = /[0-9]/.test(pw);
        var spec  = /[^A-Za-z0-9]/.test(pw);
        setRule('rLen', len); setRule('rUpper', upper); setRule('rLower', lower); setRule('rNum', num);

        var fill = document.getElementById('strFill');
        var text = document.getElementById('strText');
        if (!pw) {
            fill.style.width = '0'; fill.style.background = '';
            text.textContent = 'Enter a password'; text.style.color = '#6c757d';
            return;
        }
        var score = [len, upper, lower, num, spec].filter(Boolean).length;
        var lvl   = strengthLevels[Math.min(score - 1, 4)];
        fill.style.width      = lvl.pct + '%';
        fill.style.background = lvl.color;
        text.textContent      = lvl.label;
        text.style.color      = lvl.color;
        onConfirmInput();
    }

    function onConfirmInput() {
        var pw   = document.getElementById('newPw').value;
        var cpw  = document.getElementById('confirmPw').value;
        var hint = document.getElementById('matchHint');
        if (!cpw) { hint.style.display = 'none'; return; }
        hint.style.display = '';
        hint.innerHTML = (pw === cpw)
            ? '<i class="fas fa-check-circle" style="color:#10b981;"></i> <span style="color:#065f46;">Passwords match</span>'
            : '<i class="fas fa-times-circle" style="color:#ef4444;"></i> <span style="color:#991b1b;">Passwords do not match</span>';
    }

    function resetStrength() {
        var fill = document.getElementById('strFill');
        var text = document.getElementById('strText');
        if (fill) { fill.style.width = '0'; fill.style.background = ''; }
        if (text) { text.textContent = 'Enter a password'; text.style.color = '#6c757d'; }
        ['rLen','rUpper','rLower','rNum'].forEach(function(id) {
            var el = document.getElementById(id);
            if (el) { el.className = ''; el.querySelector('i').className = 'fas fa-circle'; }
        });
        var hint = document.getElementById('matchHint');
        if (hint) hint.style.display = 'none';
    }

    // ── Form Validation ──────────────────────────────────────────────────────────
    document.getElementById('passwordForm').addEventListener('submit', function(e) {
        var cur = document.getElementById('currentPw').value;
        var np  = document.getElementById('newPw').value;
        var cp  = document.getElementById('confirmPw').value;
        if (!cur || !np || !cp)  { alert('All password fields are required.'); e.preventDefault(); return; }
        if (np !== cp)           { alert('New password and confirm password do not match.'); e.preventDefault(); return; }
        if (np.length < 8)       { alert('New password must be at least 8 characters.'); e.preventDefault(); return; }
        if (!/[A-Z]/.test(np) || !/[a-z]/.test(np) || !/[0-9]/.test(np)) {
            alert('Password must have uppercase, lowercase and a number.'); e.preventDefault(); return;
        }
        if (cur === np) { alert('New password must be different from your current password.'); e.preventDefault(); }
    });

    document.getElementById('profileForm').addEventListener('submit', function(e) {
        var fn    = this.querySelector('[name="firstName"]').value.trim();
        var ln    = this.querySelector('[name="lastName"]').value.trim();
        var email = this.querySelector('[name="email"]').value.trim();
        if (!fn || !ln) { alert('First name and last name are required.'); e.preventDefault(); return; }
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) { alert('Invalid email address.'); e.preventDefault(); }
    });

    // ── Auto-dismiss toast ───────────────────────────────────────────────────────
    setTimeout(function() {
        var t = document.getElementById('toastWrap');
        if (t) {
            t.style.transition = 'opacity .5s';
            t.style.opacity = '0';
            setTimeout(function(){ if (t) t.remove(); }, 500);
        }
    }, 5000);
</script>
</body>
</html>