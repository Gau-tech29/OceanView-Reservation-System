<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.dto.ReservationDTO" %>
<%@ page import="com.oceanview.dto.DashboardStatsDTO" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Ocean View Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root {
            --primary-color: #0d6efd; --primary-dark: #0b5ed7;
            --secondary-color: #6c757d; --dark-color: #212529;
            --sidebar-width: 270px; --card-shadow: 0 4px 20px rgba(13,110,253,0.1);
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Poppins', sans-serif; background: #f0f4f8; overflow-x: hidden; }

        .sidebar {
            position: fixed; top: 0; left: 0; height: 100vh; width: var(--sidebar-width);
            background: linear-gradient(180deg, #0a3d8f 0%, #0d6efd 100%);
            color: white; z-index: 1000; box-shadow: 5px 0 20px rgba(0,0,0,0.2); overflow-y: auto;
        }
        .sidebar-brand { padding: 25px 22px 20px; border-bottom: 1px solid rgba(255,255,255,0.15); margin-bottom: 10px; }
        .sidebar-brand h3 { font-size: 1.5rem; font-weight: 700; margin: 0; }
        .sidebar-brand p { font-size: 0.8rem; opacity: 0.8; margin: 4px 0 0; }
        .sidebar-label { font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; opacity: 0.5; padding: 15px 22px 5px; }
        .sidebar-menu { list-style: none; padding: 5px 12px; margin: 0; }
        .sidebar-menu li { margin-bottom: 4px; }
        .sidebar-menu a {
            display: flex; align-items: center; padding: 11px 15px;
            color: rgba(255,255,255,0.85); text-decoration: none;
            transition: all 0.2s; border-radius: 10px; font-weight: 500;
        }
        .sidebar-menu a:hover, .sidebar-menu a.active { background: rgba(255,255,255,0.18); color: white; }
        .sidebar-menu a i { width: 28px; font-size: 1.05rem; }
        .sidebar-menu a span { font-size: 0.88rem; }

        .main-content { margin-left: var(--sidebar-width); padding: 22px 30px; }
        .top-nav {
            background: white; border-radius: 16px; padding: 14px 24px;
            margin-bottom: 22px; box-shadow: var(--card-shadow);
            display: flex; justify-content: space-between; align-items: center;
        }
        .page-title h2 {
            font-size: 1.5rem; font-weight: 700; margin: 0;
            background: linear-gradient(135deg, #0d6efd, #0a3d8f);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        }
        .page-title p { color: var(--secondary-color); margin: 3px 0 0; font-size: 0.85rem; }
        .user-menu { display: flex; align-items: center; gap: 15px; }
        .user-avatar {
            width: 42px; height: 42px;
            background: linear-gradient(135deg, #0d6efd, #0a3d8f);
            border-radius: 10px; display: flex; align-items: center;
            justify-content: center; color: white; font-weight: 700; font-size: 1rem;
        }
        .user-name { font-weight: 600; color: var(--dark-color); font-size: 0.9rem; }
        .user-role { font-size: 0.75rem; color: var(--secondary-color); }

        .alert-success-custom { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; border-radius: 10px; padding: 12px 18px; margin-bottom: 20px; }
        .alert-error-custom { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; border-radius: 10px; padding: 12px 18px; margin-bottom: 20px; }

        .welcome-banner {
            background: linear-gradient(135deg, #0a3d8f 0%, #0d6efd 100%);
            color: white; border-radius: 20px; padding: 25px 35px;
            margin-bottom: 25px; box-shadow: 0 15px 35px rgba(13,110,253,0.3);
        }
        .welcome-banner h4 { font-size: 1.5rem; font-weight: 700; margin-bottom: 6px; }
        .welcome-banner p { opacity: 0.9; margin: 0; font-size: 0.95rem; }

        .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 18px; margin-bottom: 25px; }
        .stat-card {
            background: white; border-radius: 15px; padding: 20px;
            box-shadow: var(--card-shadow);
            display: flex; align-items: center; justify-content: space-between;
            transition: all 0.25s; border-left: 4px solid var(--primary-color);
        }
        .stat-card:hover { transform: translateY(-5px); box-shadow: 0 15px 35px rgba(13,110,253,0.18); }
        .stat-info h3 { font-size: 1.8rem; font-weight: 700; color: var(--dark-color); margin-bottom: 4px; line-height: 1; }
        .stat-info p { color: var(--secondary-color); margin: 0; font-size: 0.82rem; font-weight: 500; }
        .stat-icon {
            width: 55px; height: 55px;
            background: linear-gradient(135deg, #0d6efd, #0a3d8f);
            border-radius: 12px; display: flex; align-items: center; justify-content: center;
            box-shadow: 0 8px 15px rgba(13,110,253,0.3);
        }
        .stat-icon i { font-size: 24px; color: white; }

        .section-title { font-size: 1.05rem; font-weight: 600; color: var(--dark-color); margin-bottom: 15px; padding-left: 12px; border-left: 3px solid var(--primary-color); }

        .quick-actions { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 25px; }
        .action-btn {
            background: white; border-radius: 15px; padding: 20px;
            box-shadow: var(--card-shadow); text-decoration: none; color: inherit;
            display: block; transition: all 0.2s; border: 2px solid transparent;
        }
        .action-btn:hover { transform: translateY(-5px); border-color: var(--primary-color); box-shadow: 0 12px 25px rgba(13,110,253,0.18); color: inherit; }
        .action-btn .action-icon {
            width: 50px; height: 50px;
            background: linear-gradient(135deg, #0d6efd, #0a3d8f);
            border-radius: 12px; display: flex; align-items: center; justify-content: center; margin-bottom: 14px;
        }
        .action-btn .action-icon i { font-size: 22px; color: white; }
        .action-btn h5 { font-size: 0.9rem; font-weight: 600; margin-bottom: 4px; color: var(--dark-color); }
        .action-btn p { font-size: 0.78rem; color: var(--secondary-color); margin: 0; }

        .table-card { background: white; border-radius: 15px; padding: 22px; box-shadow: var(--card-shadow); margin-bottom: 25px; }
        .table-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
        .table th { font-size: 0.78rem; font-weight: 700; color: var(--secondary-color); text-transform: uppercase; letter-spacing: 0.5px; padding: 12px 10px; border-bottom: 2px solid #f0f4f8; }
        .table td { padding: 13px 10px; vertical-align: middle; font-size: 0.88rem; border-bottom: 1px solid #f8f9fa; }
        .badge-status { padding: 5px 12px; border-radius: 20px; font-size: 0.76rem; font-weight: 600; }
        .badge-confirmed { background: #d4edda; color: #155724; }
        .badge-checked-in { background: #cce5ff; color: #004085; }
        .badge-checked-out { background: #e2e3e5; color: #383d41; }
        .badge-cancelled { background: #f8d7da; color: #721c24; }
        .badge-pending { background: #fff3cd; color: #856404; }
        .badge-paid { background: #d4edda; color: #155724; }

        .chart-card { background: white; border-radius: 15px; padding: 22px; box-shadow: var(--card-shadow); }

        @media (max-width: 1400px) { .quick-actions { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 1100px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 768px) {
            .sidebar { transform: translateX(-100%); }
            .main-content { margin-left: 0; padding: 15px; }
            .stats-grid { grid-template-columns: 1fr; }
            .quick-actions { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    if (!user.isAdmin()) { response.sendRedirect(request.getContextPath() + "/staff/dashboard"); return; }

    // Define basePath for admin
    String basePath = "/admin";

    DashboardStatsDTO stats = (DashboardStatsDTO) request.getAttribute("stats");

    int totalReservations = 0, activeReservations = 0, availableRooms = 0, totalRooms = 0;
    long totalGuests = 0;
    int todayCheckIns = 0, todayCheckOuts = 0;
    double monthlyRevenue = 0.0, occupancyRate = 0.0;

    if (stats != null) {
        totalReservations = stats.getTotalReservations();
        activeReservations = stats.getActiveReservations();
        availableRooms = stats.getAvailableRooms();
        totalRooms = stats.getTotalRooms();
        totalGuests = stats.getTotalGuests();
        todayCheckIns = stats.getTodayCheckIns();
        todayCheckOuts = stats.getTodayCheckOuts();
        monthlyRevenue = stats.getMonthlyRevenue();
        occupancyRate = stats.getOccupancyRate();
    }

    @SuppressWarnings("unchecked")
    List<ReservationDTO> recentReservations = (List<ReservationDTO>) request.getAttribute("recentReservations");

    java.time.LocalDate today = java.time.LocalDate.now();
    java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy");
    String currentDate = today.format(fmt);

    String successMsg = (String) session.getAttribute("success");
    String errorMsg   = (String) session.getAttribute("error");
    if (successMsg != null) session.removeAttribute("success");
    if (errorMsg   != null) session.removeAttribute("error");
%>

<!-- Sidebar -->
<div class="sidebar">
    <div class="sidebar-brand">
        <h3><i class="fas fa-hotel me-2"></i>Ocean View</h3>
        <p>Admin Control Panel</p>
    </div>
    <div class="sidebar-label">Main Menu</div>
    <ul class="sidebar-menu">
        <li><a href="<%= request.getContextPath() %>/admin/dashboard" class="active">
            <i class="fas fa-chart-pie"></i><span>Dashboard</span></a></li>
        <li><a href="<%= request.getContextPath() %>/admin/reservations">
            <i class="fas fa-calendar-alt"></i><span>All Reservations</span></a></li>
        <li><a href="<%= request.getContextPath() %>/admin/reservations/new">
            <i class="fas fa-plus-circle"></i><span>New Reservation</span></a></li>
        <li><a href="<%= request.getContextPath() %>/admin/guests">
            <i class="fas fa-users"></i><span>Guests</span></a></li>
        <li><a href="<%= request.getContextPath() %><%= basePath %>/payments">
            <i class="fas fa-credit-card"></i><span>Payments & Bills</span></a>
        </li>
    </ul>
    <div class="sidebar-label">Administration</div>
    <ul class="sidebar-menu">
        <li><a href="<%= request.getContextPath() %>/admin/manage-staff">
            <i class="fas fa-users-cog"></i><span>Manage Staff</span></a></li>
        <li><a href="<%= request.getContextPath() %>/admin/manage-rooms">
            <i class="fas fa-door-open"></i><span>Manage Rooms</span></a></li>
        <li><a href="<%= request.getContextPath() %>/admin/reports">
            <i class="fas fa-chart-bar"></i><span>Reports</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/settings">
            <i class="fas fa-cog"></i><span>Settings</span></a></li>
        <li><a href="<%= request.getContextPath() %>/help">
            <i class="fas fa-question-circle"></i><span>Help & Guidelines</span></a></li>
        <li><a href="<%= request.getContextPath() %>/logout">
            <i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
    </ul>
</div>

<!-- Main Content -->
<div class="main-content">
    <div class="top-nav">
        <div class="page-title">
            <h2>Admin Dashboard</h2>
            <p><i class="fas fa-calendar-alt me-1"></i><%= currentDate %></p>
        </div>
        <div class="user-menu">
            <div class="user-avatar">
                <%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %>
            </div>
            <div>
                <div class="user-name"><%= user.getFullName() %></div>
                <div class="user-role"><%= user.getRole() %> (Admin)</div>
            </div>
        </div>
    </div>

    <% if (successMsg != null) { %>
    <div class="alert-success-custom"><i class="fas fa-check-circle me-2"></i><%= successMsg %></div>
    <% } %>
    <% if (errorMsg != null) { %>
    <div class="alert-error-custom"><i class="fas fa-exclamation-circle me-2"></i><%= errorMsg %></div>
    <% } %>

    <div class="welcome-banner">
        <div class="row align-items-center">
            <div class="col-md-9">
                <h4>Welcome back, <%= user.getFirstName() %>! 👋</h4>
                <p>Full system access enabled. <strong><%= todayCheckIns %></strong> check-in(s) and
                    <strong><%= todayCheckOuts %></strong> check-out(s) scheduled today.</p>
            </div>
            <div class="col-md-3 text-end d-none d-md-block">
                <i class="fas fa-shield-alt" style="font-size:3rem; opacity:0.25;"></i>
            </div>
        </div>
    </div>

    <!-- Stats with Clickable Cards -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-info"><h3><%= totalReservations %></h3><p>Total Reservations</p></div>
            <div class="stat-icon"><i class="fas fa-calendar-check"></i></div>
        </div>
        <div class="stat-card" style="border-left-color:#198754;">
            <div class="stat-info"><h3><%= availableRooms %>/<%= totalRooms %></h3><p>Available / Total Rooms</p></div>
            <div class="stat-icon" style="background:linear-gradient(135deg,#198754,#146c43);"><i class="fas fa-door-open"></i></div>
        </div>
        <div class="stat-card" style="border-left-color:#fd7e14;">
            <div class="stat-info"><h3><%= totalGuests %></h3><p>Total Guests</p></div>
            <div class="stat-icon" style="background:linear-gradient(135deg,#fd7e14,#e96c02);"><i class="fas fa-users"></i></div>
        </div>

        <!-- Clickable Today's Check-ins Card -->
        <a href="<%= request.getContextPath() %>/admin/today-checkins" class="stat-card text-decoration-none" style="border-left-color:#0dcaf0; cursor:pointer; display:block;">
            <div class="stat-info"><h3><%= todayCheckIns %></h3><p>Check-ins Today</p><small style="font-size:0.7rem;">Click to view</small></div>
            <div class="stat-icon" style="background:linear-gradient(135deg,#0dcaf0,#0aa2c0);"><i class="fas fa-sign-in-alt"></i></div>
        </a>

        <!-- Clickable Today's Check-outs Card -->
        <a href="<%= request.getContextPath() %>/admin/today-checkouts" class="stat-card text-decoration-none" style="border-left-color:#6f42c1; cursor:pointer; display:block;">
            <div class="stat-info"><h3><%= todayCheckOuts %></h3><p>Check-outs Today</p><small style="font-size:0.7rem;">Click to view</small></div>
            <div class="stat-icon" style="background:linear-gradient(135deg,#6f42c1,#59359a);"><i class="fas fa-sign-out-alt"></i></div>
        </a>

        <div class="stat-card" style="border-left-color:#20c997;">
            <div class="stat-info"><h3>Rs.<%= String.format("%,.0f", monthlyRevenue) %></h3><p>Monthly Revenue</p></div>
            <div class="stat-icon" style="background:linear-gradient(135deg,#20c997,#17a589);"><i class="fas fa-dollar-sign"></i></div>
        </div>
        <div class="stat-card" style="border-left-color:#ffc107;">
            <div class="stat-info"><h3><%= String.format("%.1f", occupancyRate) %>%</h3><p>Occupancy Rate</p></div>
            <div class="stat-icon" style="background:linear-gradient(135deg,#ffc107,#e0a800);"><i class="fas fa-chart-line"></i></div>
        </div>
        <div class="stat-card" style="border-left-color:#dc3545;">
            <div class="stat-info"><h3><%= activeReservations %></h3><p>Active Reservations</p></div>
            <div class="stat-icon" style="background:linear-gradient(135deg,#dc3545,#b02a37);"><i class="fas fa-clock"></i></div>
        </div>
    </div>

    <div class="section-title">Quick Actions</div>
    <div class="quick-actions">
        <a href="<%= request.getContextPath() %>/admin/reservations/new" class="action-btn">
            <div class="action-icon"><i class="fas fa-plus-circle"></i></div><h5>New Reservation</h5><p>Create a booking for a guest</p>
        </a>
        <a href="<%= request.getContextPath() %>/admin/reservations" class="action-btn">
            <div class="action-icon"><i class="fas fa-list-alt"></i></div><h5>All Reservations</h5><p>View and manage all bookings</p>
        </a>
        <a href="<%= request.getContextPath() %>/admin/manage-staff" class="action-btn">
            <div class="action-icon"><i class="fas fa-user-plus"></i></div><h5>Manage Staff</h5><p>Add and manage staff accounts</p>
        </a>
        <a href="<%= request.getContextPath() %>/admin/manage-rooms" class="action-btn">
            <div class="action-icon"><i class="fas fa-door-open"></i></div><h5>Manage Rooms</h5><p>Add and configure rooms</p>
        </a>
        <a href="<%= request.getContextPath() %>/admin/guests" class="action-btn">
            <div class="action-icon"><i class="fas fa-users"></i></div><h5>Guests</h5><p>View and manage guest profiles</p>
        </a>
        <a href="<%= request.getContextPath() %><%= basePath %>/payments" class="action-btn">
            <div class="action-icon"><i class="fas fa-credit-card"></i></div>
            <h5>Payments & Bills</h5>
            <p>View all payments, process refunds, manage bills</p>
        </a>
        <a href="<%= request.getContextPath() %>/admin/reports" class="action-btn">
            <div class="action-icon"><i class="fas fa-chart-bar"></i></div><h5>Reports</h5><p>Revenue, occupancy & analytics</p>
        </a>
        <a href="<%= request.getContextPath() %>/admin/reservations/search" class="action-btn">
            <div class="action-icon"><i class="fas fa-search"></i></div><h5>Search</h5><p>Find any reservation or guest</p>
        </a>
    </div>

    <!-- Recent Reservations -->
    <div class="table-card">
        <div class="table-header">
            <span class="section-title mb-0">Recent Reservations</span>
            <a href="<%= request.getContextPath() %>/admin/reservations" class="btn btn-sm btn-primary">
                View All <i class="fas fa-arrow-right ms-1"></i>
            </a>
        </div>
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                <tr>
                    <th>Reservation #</th>
                    <th>Guest Name</th>
                    <th>Rooms</th>
                    <th>Check-in</th>
                    <th>Check-out</th>
                    <th>Status</th>
                    <th>Payment</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <% if (recentReservations == null || recentReservations.isEmpty()) { %>
                <tr>
                    <td colspan="8" class="text-center py-5 text-muted">
                        <i class="fas fa-calendar-times fa-3x mb-3 d-block" style="opacity:0.3;"></i>
                        No reservations found.
                        <a href="<%= request.getContextPath() %>/admin/reservations/new">Create the first one</a>
                    </td>
                </tr>
                <% } else { for (ReservationDTO r : recentReservations) {
                    String status = r.getReservationStatus();
                    String badgeClass = "badge-pending";
                    if ("CONFIRMED".equals(status)) badgeClass = "badge-confirmed";
                    else if ("CHECKED_IN".equals(status)) badgeClass = "badge-checked-in";
                    else if ("CHECKED_OUT".equals(status)) badgeClass = "badge-checked-out";
                    else if ("CANCELLED".equals(status)) badgeClass = "badge-cancelled";
                    String pStatus = r.getPaymentStatus();
                    String pBadge  = "PAID".equals(pStatus) ? "badge-paid" : "badge-pending";
                %>
                <tr>
                    <td><strong><%= r.getReservationNumber() %></strong></td>
                    <td><%= r.getGuestName() != null ? r.getGuestName() : "-" %></td>
                    <td>
                        <%= r.getRoomNumbersSummary() %>
                        <% if (r.getRoomTypesSummary() != null && !r.getRoomTypesSummary().equals("N/A")) { %>
                        <small class="text-muted d-block"><%= r.getRoomTypesSummary() %></small>
                        <% } %>
                    </td>
                    <td><%= r.getFormattedCheckInDate() %></td>
                    <td><%= r.getFormattedCheckOutDate() %></td>
                    <td><span class="badge-status <%= badgeClass %>"><%= status != null ? status.replace("_"," ") : "PENDING" %></span></td>
                    <td><span class="badge-status <%= pBadge %>"><%= pStatus != null ? pStatus : "PENDING" %></span></td>
                    <td>
                        <a href="<%= request.getContextPath() %>/admin/reservations/view?id=<%= r.getId() %>"
                           class="btn btn-sm btn-outline-primary" title="View"><i class="fas fa-eye"></i></a>
                        <a href="<%= request.getContextPath() %>/admin/reservations/edit?id=<%= r.getId() %>"
                           class="btn btn-sm btn-outline-secondary" title="Edit"><i class="fas fa-edit"></i></a>
                        <% if ("CONFIRMED".equals(status)) { %>
                        <a href="<%= request.getContextPath() %>/admin/reservations/checkin?id=<%= r.getId() %>"
                           class="btn btn-sm btn-outline-success" title="Check In"
                           onclick="return confirm('Confirm check-in?')"><i class="fas fa-sign-in-alt"></i></a>
                        <% } else if ("CHECKED_IN".equals(status)) { %>
                        <a href="<%= request.getContextPath() %>/admin/reservations/checkout?id=<%= r.getId() %>"
                           class="btn btn-sm btn-outline-warning" title="Check Out"
                           onclick="return confirm('Confirm check-out?')"><i class="fas fa-sign-out-alt"></i></a>
                        <% } %>
                        <a href="<%= request.getContextPath() %>/admin/reservations/delete?id=<%= r.getId() %>"
                           class="btn btn-sm btn-outline-danger" title="Delete"
                           onclick="return confirm('Permanently delete this reservation?')"><i class="fas fa-trash"></i></a>
                    </td>
                </tr>
                <% } } %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Charts -->
    <div class="row g-4 mb-4">
        <div class="col-lg-8">
            <div class="chart-card">
                <div class="section-title">Revenue Overview (Last 6 Months)</div>
                <canvas id="revenueChart" height="120"></canvas>
            </div>
        </div>
        <div class="col-lg-4">
            <div class="chart-card">
                <div class="section-title">Room Status</div>
                <canvas id="roomStatusChart" height="220"></canvas>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        new Chart(document.getElementById('revenueChart').getContext('2d'), {
            type: 'line',
            data: {
                labels: ['3mo ago', '2mo ago', 'Last month', 'This month'],
                datasets: [{
                    label: 'Revenue (Rs.)',
                    data: [0, 0, 0, <%= monthlyRevenue %>],
                    borderColor: '#0d6efd', backgroundColor: 'rgba(13,110,253,0.08)',
                    tension: 0.4, fill: true, borderWidth: 2,
                    pointBackgroundColor: '#0d6efd', pointRadius: 5
                }]
            },
            options: {
                responsive: true,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true, ticks: { callback: v => 'Rs.' + v.toLocaleString() } } }
            }
        });

        new Chart(document.getElementById('roomStatusChart').getContext('2d'), {
            type: 'doughnut',
            data: {
                labels: ['Available', 'Occupied', 'Maintenance', 'Reserved'],
                datasets: [{
                    data: [<%= availableRooms %>, <%= totalRooms - availableRooms %>, 0, 0],
                    backgroundColor: ['#198754', '#0d6efd', '#dc3545', '#ffc107'],
                    borderWidth: 0, hoverOffset: 8
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'bottom', labels: { padding: 15 } },
                    tooltip: { callbacks: { label: c => c.label + ': ' + c.raw + ' rooms' } }
                },
                cutout: '65%'
            }
        });
    });
</script>
</body>
</html>