<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.dto.DashboardStatsDTO" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    DashboardStatsDTO stats = (DashboardStatsDTO) request.getAttribute("stats");
    LocalDate today = LocalDate.now();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy");
    String currentDate = today.format(formatter);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Ocean View Hotel</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Font Awesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        :root {
            --primary-color: #0d6efd;
            --primary-dark: #0b5ed7;
            --primary-light: #e6f2ff;
            --secondary-color: #6c757d;
            --success-color: #198754;
            --info-color: #0dcaf0;
            --warning-color: #ffc107;
            --danger-color: #dc3545;
            --light-bg: #f8f9fa;
            --dark-color: #212529;
            --sidebar-width: 280px;
            --header-height: 70px;
            --card-shadow: 0 10px 30px rgba(13, 110, 253, 0.1);
            --transition: all 0.3s ease;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #e9ecef 100%);
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* Premium Sidebar */
        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            width: var(--sidebar-width);
            background: linear-gradient(180deg, #0a58ca 0%, #0d6efd 100%);
            color: white;
            transition: var(--transition);
            z-index: 1000;
            box-shadow: 5px 0 25px rgba(13, 110, 253, 0.3);
        }

        .sidebar-brand {
            padding: 25px 25px;
            border-bottom: 2px solid rgba(255,255,255,0.15);
            margin-bottom: 20px;
            position: relative;
            overflow: hidden;
        }

        .sidebar-brand::after {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            animation: rotate 20s linear infinite;
        }

        @keyframes rotate {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }

        .sidebar-brand h3 {
            font-size: 1.8rem;
            font-weight: 700;
            margin: 0;
            letter-spacing: 1px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
        }

        .sidebar-brand p {
            font-size: 0.9rem;
            opacity: 0.9;
            margin: 5px 0 0;
            letter-spacing: 0.5px;
        }

        .sidebar-menu {
            list-style: none;
            padding: 0 15px;
            margin: 0;
        }

        .sidebar-menu li {
            margin-bottom: 8px;
        }

        .sidebar-menu a {
            display: flex;
            align-items: center;
            padding: 14px 20px;
            color: rgba(255,255,255,0.85);
            text-decoration: none;
            transition: var(--transition);
            border-radius: 12px;
            font-weight: 500;
            letter-spacing: 0.3px;
        }

        .sidebar-menu a:hover,
        .sidebar-menu a.active {
            background: rgba(255,255,255,0.15);
            color: white;
            transform: translateX(5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }

        .sidebar-menu a i {
            width: 30px;
            font-size: 1.3rem;
        }

        .sidebar-menu a span {
            font-size: 1rem;
        }

        /* Main Content */
        .main-content {
            margin-left: var(--sidebar-width);
            padding: 25px 35px;
            transition: var(--transition);
        }

        /* Top Navigation */
        .top-nav {
            background: white;
            border-radius: 20px;
            padding: 15px 30px;
            margin-bottom: 30px;
            box-shadow: var(--card-shadow);
            display: flex;
            justify-content: space-between;
            align-items: center;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(13, 110, 253, 0.1);
        }

        .page-title h2 {
            font-size: 1.8rem;
            font-weight: 600;
            color: var(--dark-color);
            margin: 0;
            background: linear-gradient(135deg, #0d6efd, #0a58ca);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .page-title p {
            color: var(--secondary-color);
            margin: 5px 0 0;
            font-size: 0.95rem;
        }

        .page-title p i {
            color: var(--primary-color);
        }

        .user-menu {
            display: flex;
            align-items: center;
            gap: 25px;
        }

        .notifications {
            position: relative;
            cursor: pointer;
            width: 45px;
            height: 45px;
            background: var(--primary-light);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: var(--transition);
        }

        .notifications:hover {
            background: var(--primary-color);
            transform: translateY(-3px);
        }

        .notifications:hover i {
            color: white;
        }

        .notifications i {
            font-size: 1.3rem;
            color: var(--primary-color);
            transition: var(--transition);
        }

        .badge {
            position: absolute;
            top: -5px;
            right: -5px;
            background: var(--danger-color);
            color: white;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            font-size: 0.7rem;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            border: 2px solid white;
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 15px;
            cursor: pointer;
            padding: 8px 15px;
            border-radius: 15px;
            transition: var(--transition);
            background: var(--primary-light);
        }

        .user-profile:hover {
            background: var(--primary-color);
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(13, 110, 253, 0.2);
        }

        .user-profile:hover .user-info .name,
        .user-profile:hover .user-info .role,
        .user-profile:hover i {
            color: white;
        }

        .user-avatar {
            width: 45px;
            height: 45px;
            background: linear-gradient(135deg, #0d6efd, #0a58ca);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 1.2rem;
            box-shadow: 0 5px 15px rgba(13, 110, 253, 0.3);
        }

        .user-info .name {
            font-weight: 600;
            color: var(--dark-color);
            line-height: 1.2;
            transition: var(--transition);
        }

        .user-info .role {
            font-size: 0.8rem;
            color: var(--secondary-color);
            transition: var(--transition);
        }

        /* Welcome Banner */
        .welcome-banner {
            background: linear-gradient(135deg, #0d6efd 0%, #0a58ca 100%);
            color: white;
            border: none;
            border-radius: 25px;
            padding: 30px 40px;
            margin-bottom: 40px;
            box-shadow: 0 20px 40px rgba(13, 110, 253, 0.3);
            position: relative;
            overflow: hidden;
        }

        .welcome-banner::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.2) 0%, transparent 70%);
            animation: rotate 30s linear infinite;
        }

        .welcome-banner h4 {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
        }

        .welcome-banner p {
            font-size: 1.1rem;
            opacity: 0.95;
            margin: 0;
        }

        .welcome-banner .badge-date {
            background: rgba(255,255,255,0.2);
            padding: 8px 20px;
            border-radius: 50px;
            font-size: 1rem;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255,255,255,0.3);
        }

        /* Stats Cards Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }

        .stat-card {
            background: white;
            border-radius: 20px;
            padding: 25px;
            box-shadow: var(--card-shadow);
            display: flex;
            align-items: center;
            justify-content: space-between;
            transition: var(--transition);
            border: 1px solid rgba(13, 110, 253, 0.1);
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 5px;
            height: 100%;
            background: linear-gradient(180deg, var(--primary-color), var(--primary-dark));
            transition: var(--transition);
        }

        .stat-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(13, 110, 253, 0.2);
        }

        .stat-card:hover::before {
            width: 100%;
            opacity: 0.1;
        }

        .stat-info h3 {
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--dark-color);
            margin-bottom: 5px;
            line-height: 1;
        }

        .stat-info p {
            color: var(--secondary-color);
            margin: 0;
            font-size: 0.95rem;
            font-weight: 500;
        }

        .stat-icon {
            width: 70px;
            height: 70px;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            border-radius: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 10px 20px rgba(13, 110, 253, 0.3);
        }

        .stat-icon i {
            font-size: 35px;
            color: white;
        }

        /* Section Styles */
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }

        .section-header h3 {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--dark-color);
            margin: 0;
            position: relative;
            padding-left: 15px;
        }

        .section-header h3::before {
            content: '';
            position: absolute;
            left: 0;
            top: 50%;
            transform: translateY(-50%);
            width: 5px;
            height: 25px;
            background: linear-gradient(180deg, var(--primary-color), var(--primary-dark));
            border-radius: 5px;
        }

        .view-all {
            color: var(--primary-color);
            text-decoration: none;
            font-size: 0.95rem;
            font-weight: 500;
            padding: 8px 15px;
            border-radius: 10px;
            background: var(--primary-light);
            transition: var(--transition);
        }

        .view-all:hover {
            background: var(--primary-color);
            color: white;
            transform: translateX(5px);
        }

        .view-all i {
            transition: var(--transition);
        }

        .view-all:hover i {
            transform: translateX(5px);
        }

        /* Quick Actions Grid */
        .actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }

        .action-card {
            background: white;
            border-radius: 20px;
            padding: 30px;
            box-shadow: var(--card-shadow);
            transition: var(--transition);
            text-decoration: none;
            color: inherit;
            display: block;
            border: 1px solid rgba(13, 110, 253, 0.1);
            position: relative;
            overflow: hidden;
        }

        .action-card::after {
            content: '';
            position: absolute;
            bottom: 0;
            right: 0;
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, transparent 50%, rgba(13, 110, 253, 0.05) 50%);
            border-radius: 50%;
            transition: var(--transition);
        }

        .action-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(13, 110, 253, 0.2);
        }

        .action-card:hover::after {
            transform: scale(1.5);
        }

        .card-icon {
            width: 70px;
            height: 70px;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            border-radius: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 25px;
            box-shadow: 0 10px 20px rgba(13, 110, 253, 0.3);
        }

        .card-icon i {
            font-size: 35px;
            color: white;
        }

        .action-card h4 {
            font-size: 1.3rem;
            font-weight: 600;
            color: var(--dark-color);
            margin-bottom: 12px;
        }

        .action-card p {
            color: var(--secondary-color);
            font-size: 0.95rem;
            margin-bottom: 20px;
            line-height: 1.6;
        }

        .card-link {
            color: var(--primary-color);
            font-size: 0.95rem;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: var(--transition);
        }

        .card-link i {
            transition: var(--transition);
        }

        .action-card:hover .card-link i {
            transform: translateX(8px);
        }

        /* Recent Activity Table */
        .recent-activity {
            background: white;
            border-radius: 20px;
            padding: 25px;
            box-shadow: var(--card-shadow);
            margin-bottom: 40px;
            border: 1px solid rgba(13, 110, 253, 0.1);
        }

        .table {
            margin: 0;
        }

        .table th {
            border-top: none;
            color: var(--secondary-color);
            font-weight: 600;
            font-size: 0.9rem;
            padding: 15px 10px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .table td {
            padding: 15px 10px;
            vertical-align: middle;
            color: var(--dark-color);
            font-weight: 500;
            border-bottom: 1px solid #e9ecef;
        }

        .badge-status {
            padding: 6px 12px;
            border-radius: 50px;
            font-size: 0.8rem;
            font-weight: 500;
            display: inline-block;
        }

        .badge-confirmed {
            background: #d4edda;
            color: #155724;
        }

        .badge-pending {
            background: #fff3cd;
            color: #856404;
        }

        .badge-checked-in {
            background: #cce5ff;
            color: #004085;
        }

        .badge-checked-out {
            background: #e2e3e5;
            color: #383d41;
        }

        .badge-cancelled {
            background: #f8d7da;
            color: #721c24;
        }

        .btn-action {
            padding: 6px 12px;
            border-radius: 8px;
            font-size: 0.85rem;
            margin: 0 3px;
            transition: var(--transition);
        }

        .btn-action:hover {
            transform: translateY(-2px);
        }

        /* Chart Container */
        .chart-container {
            background: white;
            border-radius: 20px;
            padding: 25px;
            box-shadow: var(--card-shadow);
            margin-bottom: 40px;
            border: 1px solid rgba(13, 110, 253, 0.1);
        }

        /* Responsive */
        @media (max-width: 992px) {
            .sidebar {
                transform: translateX(-100%);
            }

            .main-content {
                margin-left: 0;
                padding: 20px;
            }

            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 768px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }

            .actions-grid {
                grid-template-columns: 1fr;
            }

            .welcome-banner h4 {
                font-size: 1.5rem;
            }
        }

        /* Loading Spinner */
        .spinner {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(255, 255, 255, 0.9);
            z-index: 9999;
            justify-content: center;
            align-items: center;
            backdrop-filter: blur(5px);
        }

        .spinner.active {
            display: flex;
        }

        .spinner::after {
            content: '';
            width: 50px;
            height: 50px;
            border: 5px solid var(--primary-light);
            border-top: 5px solid var(--primary-color);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>

<div class="spinner" id="spinner"></div>

<!-- Sidebar -->
<div class="sidebar">
    <div class="sidebar-brand">
        <h3>Ocean View</h3>
        <p>Hotel Reservation System</p>
    </div>

    <ul class="sidebar-menu">
        <li>
            <a href="#" class="active">
                <i class="fas fa-chart-pie"></i>
                <span>Dashboard</span>
            </a>
        </li>
        <li><a href="${pageContext.request.contextPath}/admin/manage-staff"><i class="fas fa-users-cog"></i><span>Manage Staff</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/manage-rooms"><i class="fas fa-door-open"></i><span>Manage Rooms</span></a></li>
        <li>
            <a href="#">
                <i class="fas fa-calendar-alt"></i>
                <span>All Reservations</span>
            </a>
        </li>
        <li>
            <a href="#">
                <i class="fas fa-users"></i>
                <span>Guests</span>
            </a>
        </li>
        <li>
            <a href="#">
                <i class="fas fa-file-invoice-dollar"></i>
                <span>Bills & Payments</span>
            </a>
        </li>
        <li>
            <a href="#">
                <i class="fas fa-tools"></i>
                <span>Maintenance</span>
            </a>
        </li>
        <li>
            <a href="#">
                <i class="fas fa-chart-bar"></i>
                <span>Reports</span>
            </a>
        </li>
        <li>
            <a href="#">
                <i class="fas fa-cog"></i>
                <span>Settings</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/logout">
                <i class="fas fa-sign-out-alt"></i>
                <span>Logout</span>
            </a>
        </li>
    </ul>
</div>

<!-- Main Content -->
<div class="main-content">
    <!-- Top Navigation -->
    <div class="top-nav">
        <div class="page-title">
            <h2>Admin Dashboard</h2>
            <p><i class="fas fa-calendar-alt me-2"></i><%= currentDate %></p>
        </div>

        <div class="user-menu">
            <div class="notifications">
                <i class="fas fa-bell"></i>
                <span class="badge">3</span>
            </div>

            <div class="user-profile" onclick="toggleUserMenu()">
                <div class="user-avatar">
                    <%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %>
                </div>
                <div class="user-info d-none d-md-block">
                    <div class="name"><%= user.getFullName() %></div>
                    <div class="role"><%= user.getRole() %></div>
                </div>
                <i class="fas fa-chevron-down" style="color: var(--secondary-color); font-size: 0.8rem;"></i>
            </div>
        </div>
    </div>

    <!-- Welcome Banner -->
    <div class="welcome-banner">
        <div class="row align-items-center">
            <div class="col-md-8">
                <h4>Welcome back, <%= user.getFirstName() %>! 👋</h4>
                <p>You have full system access. Here's what's happening today.</p>
            </div>
            <div class="col-md-4 text-md-end">
                <span class="badge-date">
                    <i class="fas fa-sun me-2"></i>Good Day
                </span>
            </div>
        </div>
    </div>

    <!-- Stats Cards -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-info">
                <h3><%= stats != null ? stats.getTotalReservations() : 0 %></h3>
                <p>Total Reservations</p>
            </div>
            <div class="stat-icon">
                <i class="fas fa-calendar-check"></i>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-info">
                <h3><%= stats != null ? stats.getActiveReservations() : 0 %></h3>
                <p>Active Reservations</p>
            </div>
            <div class="stat-icon">
                <i class="fas fa-clock"></i>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-info">
                <h3><%= stats != null ? stats.getAvailableRooms() : 0 %>/<%= stats != null ? stats.getTotalRooms() : 0 %></h3>
                <p>Available Rooms</p>
            </div>
            <div class="stat-icon">
                <i class="fas fa-door-open"></i>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-info">
                <h3><%= stats != null ? stats.getTotalGuests() : 0 %></h3>
                <p>Total Guests</p>
            </div>
            <div class="stat-icon">
                <i class="fas fa-users"></i>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-info">
                <h3><%= stats != null ? stats.getTodayCheckIns() : 0 %></h3>
                <p>Check-ins Today</p>
            </div>
            <div class="stat-icon">
                <i class="fas fa-sign-in-alt"></i>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-info">
                <h3><%= stats != null ? stats.getTodayCheckOuts() : 0 %></h3>
                <p>Check-outs Today</p>
            </div>
            <div class="stat-icon">
                <i class="fas fa-sign-out-alt"></i>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-info">
                <h3>$<%= stats != null ? String.format("%,.2f", stats.getMonthlyRevenue()) : "0.00" %></h3>
                <p>Monthly Revenue</p>
            </div>
            <div class="stat-icon">
                <i class="fas fa-dollar-sign"></i>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-info">
                <h3><%= stats != null ? String.format("%.1f", stats.getOccupancyRate()) : 0 %>%</h3>
                <p>Occupancy Rate</p>
            </div>
            <div class="stat-icon">
                <i class="fas fa-chart-line"></i>
            </div>
        </div>
    </div>

    <!-- Quick Actions -->
    <div class="section-header">
        <h3>Quick Actions</h3>
        <a href="#" class="view-all">View All <i class="fas fa-arrow-right ms-1"></i></a>
    </div>

    <div class="actions-grid">
        <a href="#" class="action-card">
            <div class="card-icon">
                <i class="fas fa-plus-circle"></i>
            </div>
            <h4>New Reservation</h4>
            <p>Create a new booking for guests with room selection and special requests.</p>
            <span class="card-link">Create Now <i class="fas fa-arrow-right"></i></span>
        </a>

        <a href="#" class="action-card">
            <div class="card-icon">
                <i class="fas fa-user-plus"></i>
            </div>
            <h4>Add Staff Member</h4>
            <p>Create new staff accounts and assign appropriate roles and permissions.</p>
            <span class="card-link">Add Staff <i class="fas fa-arrow-right"></i></span>
        </a>

        <a href="#" class="action-card">
            <div class="card-icon">
                <i class="fas fa-door-open"></i>
            </div>
            <h4>Add New Room</h4>
            <p>Configure new rooms with type, view, pricing, and amenities.</p>
            <span class="card-link">Add Room <i class="fas fa-arrow-right"></i></span>
        </a>

        <a href="#" class="action-card">
            <div class="card-icon">
                <i class="fas fa-file-invoice"></i>
            </div>
            <h4>Generate Report</h4>
            <p>Create detailed reports on revenue, occupancy, and performance.</p>
            <span class="card-link">Generate <i class="fas fa-arrow-right"></i></span>
        </a>
    </div>

    <!-- Recent Reservations -->
    <div class="recent-activity">
        <div class="section-header">
            <h3>Recent Reservations</h3>
            <a href="#" class="view-all">View All <i class="fas fa-arrow-right ms-1"></i></a>
        </div>

        <div class="table-responsive">
            <table class="table">
                <thead>
                <tr>
                    <th>Reservation #</th>
                    <th>Guest Name</th>
                    <th>Room</th>
                    <th>Check-in</th>
                    <th>Check-out</th>
                    <th>Status</th>
                    <th>Payment</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <tr>
                    <td><strong>#RES001</strong></td>
                    <td>John Smith</td>
                    <td>Deluxe Suite - 501</td>
                    <td>2024-02-25</td>
                    <td>2024-02-28</td>
                    <td><span class="badge-status badge-confirmed">Confirmed</span></td>
                    <td><span class="badge-status badge-confirmed">Paid</span></td>
                    <td>
                        <button class="btn btn-sm btn-outline-primary btn-action" title="View"><i class="fas fa-eye"></i></button>
                        <button class="btn btn-sm btn-outline-success btn-action" title="Edit"><i class="fas fa-edit"></i></button>
                        <button class="btn btn-sm btn-outline-danger btn-action" title="Delete"><i class="fas fa-trash"></i></button>
                    </td>
                </tr>
                <tr>
                    <td><strong>#RES002</strong></td>
                    <td>Emma Wilson</td>
                    <td>Ocean View - 302</td>
                    <td>2024-02-26</td>
                    <td>2024-03-01</td>
                    <td><span class="badge-status badge-pending">Pending</span></td>
                    <td><span class="badge-status badge-pending">Pending</span></td>
                    <td>
                        <button class="btn btn-sm btn-outline-primary btn-action" title="View"><i class="fas fa-eye"></i></button>
                        <button class="btn btn-sm btn-outline-success btn-action" title="Edit"><i class="fas fa-edit"></i></button>
                        <button class="btn btn-sm btn-outline-danger btn-action" title="Delete"><i class="fas fa-trash"></i></button>
                    </td>
                </tr>
                <tr>
                    <td><strong>#RES003</strong></td>
                    <td>Michael Brown</td>
                    <td>Standard - 201</td>
                    <td>2024-02-24</td>
                    <td>2024-02-27</td>
                    <td><span class="badge-status badge-checked-in">Checked In</span></td>
                    <td><span class="badge-status badge-confirmed">Paid</span></td>
                    <td>
                        <button class="btn btn-sm btn-outline-primary btn-action" title="View"><i class="fas fa-eye"></i></button>
                        <button class="btn btn-sm btn-outline-success btn-action" title="Edit"><i class="fas fa-edit"></i></button>
                        <button class="btn btn-sm btn-outline-danger btn-action" title="Delete"><i class="fas fa-trash"></i></button>
                    </td>
                </tr>
                <tr>
                    <td><strong>#RES004</strong></td>
                    <td>Sarah Davis</td>
                    <td>Family Room - 401</td>
                    <td>2024-02-23</td>
                    <td>2024-02-26</td>
                    <td><span class="badge-status badge-checked-out">Checked Out</span></td>
                    <td><span class="badge-status badge-confirmed">Paid</span></td>
                    <td>
                        <button class="btn btn-sm btn-outline-primary btn-action" title="View"><i class="fas fa-eye"></i></button>
                        <button class="btn btn-sm btn-outline-success btn-action" title="Edit"><i class="fas fa-edit"></i></button>
                        <button class="btn btn-sm btn-outline-danger btn-action" title="Delete"><i class="fas fa-trash"></i></button>
                    </td>
                </tr>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Charts Row -->
    <div class="row">
        <div class="col-lg-8">
            <div class="chart-container">
                <div class="section-header">
                    <h3>Revenue Overview</h3>
                </div>
                <canvas id="revenueChart" height="300"></canvas>
            </div>
        </div>

        <div class="col-lg-4">
            <div class="chart-container">
                <div class="section-header">
                    <h3>Room Status</h3>
                </div>
                <canvas id="roomStatusChart" height="300"></canvas>
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // Toggle user menu
    function toggleUserMenu() {
        // Implement dropdown menu
        console.log('User menu clicked');
    }

    // Initialize charts
    document.addEventListener('DOMContentLoaded', function() {
        // Revenue Chart
        const ctx1 = document.getElementById('revenueChart').getContext('2d');
        new Chart(ctx1, {
            type: 'line',
            data: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                datasets: [{
                    label: 'Revenue ($)',
                    data: [45000, 52000, 48000, 58000, 62000, 68000, 72000, 75000, 71000, 69000, 73000, 78000],
                    borderColor: '#0d6efd',
                    backgroundColor: 'rgba(13, 110, 253, 0.1)',
                    tension: 0.4,
                    fill: true,
                    borderWidth: 3,
                    pointBackgroundColor: '#0d6efd',
                    pointBorderColor: 'white',
                    pointBorderWidth: 2,
                    pointRadius: 5,
                    pointHoverRadius: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        backgroundColor: '#0d6efd',
                        titleColor: 'white',
                        bodyColor: 'white',
                        borderColor: '#0d6efd',
                        borderWidth: 1
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {
                            color: 'rgba(13, 110, 253, 0.1)'
                        },
                        ticks: {
                            callback: function(value) {
                                return '$' + value.toLocaleString();
                            }
                        }
                    },
                    x: {
                        grid: {
                            display: false
                        }
                    }
                }
            }
        });

        // Room Status Chart
        const ctx2 = document.getElementById('roomStatusChart').getContext('2d');
        new Chart(ctx2, {
            type: 'doughnut',
            data: {
                labels: ['Available', 'Occupied', 'Maintenance', 'Reserved'],
                datasets: [{
                    data: [45, 35, 10, 10],
                    backgroundColor: [
                        '#198754',
                        '#0d6efd',
                        '#ffc107',
                        '#6c757d'
                    ],
                    borderWidth: 0,
                    hoverOffset: 10
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            padding: 20,
                            usePointStyle: true,
                            pointStyle: 'circle'
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return context.label + ': ' + context.raw + '%';
                            }
                        }
                    }
                },
                cutout: '70%'
            }
        });
    });

    // Auto-refresh data every 60 seconds
    setInterval(function() {
        console.log('Refreshing dashboard data...');
        // Implement AJAX refresh here
    }, 60000);
</script>
</body>
</html>