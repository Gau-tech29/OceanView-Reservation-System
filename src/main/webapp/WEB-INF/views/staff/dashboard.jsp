<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.dto.ReservationDTO" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Dashboard - Ocean View Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root {
            --primary-color: #0d6efd;
            --primary-dark: #0b5ed7;
            --secondary-color: #6c757d;
            --success-color: #198754;
            --danger-color: #dc3545;
            --sidebar-width: 260px;
            --dark-color: #212529;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Poppins', sans-serif; background: #f4f6f9; overflow-x: hidden; }

        .sidebar {
            position: fixed; top: 0; left: 0; height: 100vh;
            width: var(--sidebar-width);
            background: linear-gradient(180deg, #0b5ed7 0%, #0d6efd 100%);
            color: white; z-index: 1000;
            box-shadow: 3px 0 15px rgba(0,0,0,0.15);
            overflow-y: auto;
        }
        .sidebar-brand { padding: 25px 20px 20px; border-bottom: 1px solid rgba(255,255,255,0.2); margin-bottom: 10px; }
        .sidebar-brand h3 { font-size: 1.4rem; font-weight: 700; margin: 0; }
        .sidebar-brand p { font-size: 0.8rem; opacity: 0.8; margin: 4px 0 0; }
        .sidebar-menu { list-style: none; padding: 5px 10px; margin: 0; }
        .sidebar-menu li { margin-bottom: 4px; }
        .sidebar-menu a {
            display: flex; align-items: center; padding: 11px 15px;
            color: rgba(255,255,255,0.85); text-decoration: none;
            transition: all 0.2s; border-radius: 10px;
        }
        .sidebar-menu a:hover, .sidebar-menu a.active { background: rgba(255,255,255,0.15); color: white; }
        .sidebar-menu a i { width: 28px; font-size: 1.1rem; }
        .sidebar-menu a span { font-size: 0.9rem; font-weight: 500; }

        .main-content { margin-left: var(--sidebar-width); padding: 20px 28px; }
        .top-nav {
            background: white; border-radius: 15px; padding: 14px 22px;
            margin-bottom: 22px; box-shadow: 0 2px 10px rgba(0,0,0,0.06);
            display: flex; justify-content: space-between; align-items: center;
        }
        .page-title h2 { font-size: 1.4rem; font-weight: 600; color: var(--dark-color); margin: 0; }
        .page-title p { color: var(--secondary-color); margin: 3px 0 0; font-size: 0.85rem; }
        .user-menu { display: flex; align-items: center; gap: 18px; }
        .user-avatar {
            width: 40px; height: 40px;
            background: linear-gradient(135deg, #0d6efd, #0b5ed7);
            border-radius: 10px; display: flex; align-items: center;
            justify-content: center; color: white; font-weight: 700; font-size: 1rem;
        }
        .user-name { font-weight: 600; color: var(--dark-color); font-size: 0.9rem; }
        .user-role { font-size: 0.75rem; color: var(--secondary-color); }

        .welcome-banner {
            background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%);
            color: white; border-radius: 18px; padding: 22px 30px;
            margin-bottom: 25px; box-shadow: 0 10px 30px rgba(13,110,253,0.25);
        }
        .welcome-banner h4 { font-size: 1.4rem; font-weight: 600; margin-bottom: 6px; }
        .welcome-banner p { opacity: 0.9; margin: 0; font-size: 0.95rem; }

        .alert-success-custom {
            background: #d4edda; color: #155724; border: 1px solid #c3e6cb;
            border-radius: 10px; padding: 12px 18px; margin-bottom: 20px;
            display: flex; align-items: center; gap: 10px;
        }
        .alert-error-custom {
            background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb;
            border-radius: 10px; padding: 12px 18px; margin-bottom: 20px;
            display: flex; align-items: center; gap: 10px;
        }

        .stats-grid {
            display: grid; grid-template-columns: repeat(4, 1fr);
            gap: 20px; margin-bottom: 25px;
        }
        .stat-card {
            background: white; border-radius: 14px; padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.06);
            display: flex; align-items: center; justify-content: space-between;
            transition: transform 0.2s, box-shadow 0.2s;
            border-left: 4px solid var(--primary-color);
        }
        .stat-card:hover { transform: translateY(-4px); box-shadow: 0 8px 20px rgba(0,0,0,0.1); }
        .stat-info h3 { font-size: 1.8rem; font-weight: 700; color: var(--dark-color); margin-bottom: 4px; }
        .stat-info p { color: var(--secondary-color); margin: 0; font-size: 0.85rem; }
        .stat-icon {
            width: 55px; height: 55px;
            background: linear-gradient(135deg, #0d6efd, #0b5ed7);
            border-radius: 12px; display: flex; align-items: center; justify-content: center;
        }
        .stat-icon i { font-size: 26px; color: white; }

        .section-title {
            font-size: 1.1rem; font-weight: 600; color: var(--dark-color);
            margin-bottom: 15px; padding-left: 10px;
            border-left: 3px solid var(--primary-color);
        }
        .quick-actions {
            display: grid; grid-template-columns: repeat(3, 1fr);
            gap: 16px; margin-bottom: 25px;
        }
        .action-btn {
            background: white; border-radius: 14px; padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.06);
            text-decoration: none; color: inherit; display: block;
            transition: all 0.2s; border: 2px solid transparent;
        }
        .action-btn:hover {
            transform: translateY(-4px); border-color: var(--primary-color);
            box-shadow: 0 8px 20px rgba(13,110,253,0.15); color: inherit;
        }
        .action-btn .action-icon {
            width: 48px; height: 48px;
            background: linear-gradient(135deg, #0d6efd, #0b5ed7);
            border-radius: 10px; display: flex; align-items: center;
            justify-content: center; margin-bottom: 12px;
        }
        .action-btn .action-icon i { font-size: 22px; color: white; }
        .action-btn h5 { font-size: 0.95rem; font-weight: 600; margin-bottom: 4px; color: var(--dark-color); }
        .action-btn p { font-size: 0.8rem; color: var(--secondary-color); margin: 0; }

        .table-card {
            background: white; border-radius: 14px; padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.06); margin-bottom: 25px;
        }
        .table-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
        .table th {
            font-size: 0.8rem; font-weight: 600; color: var(--secondary-color);
            text-transform: uppercase; letter-spacing: 0.5px; padding: 12px 10px;
        }
        .table td { padding: 12px 10px; vertical-align: middle; font-size: 0.9rem; }
        .badge-status { padding: 5px 12px; border-radius: 20px; font-size: 0.78rem; font-weight: 500; }
        .badge-confirmed { background: #d4edda; color: #155724; }
        .badge-checked-in { background: #cce5ff; color: #004085; }
        .badge-checked-out { background: #e2e3e5; color: #383d41; }
        .badge-cancelled { background: #f8d7da; color: #721c24; }
        .badge-pending { background: #fff3cd; color: #856404; }

        @media (max-width: 1200px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } }
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
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    // Read stats set by StaffDashboardServlet
    int activeReservations = request.getAttribute("activeReservations") != null
            ? (int) request.getAttribute("activeReservations") : 0;
    int availableRooms = request.getAttribute("availableRooms") != null
            ? (int) request.getAttribute("availableRooms") : 0;
    long totalGuests = request.getAttribute("totalGuests") != null
            ? (long) request.getAttribute("totalGuests") : 0L;
    int todayCheckins = request.getAttribute("todayCheckins") != null
            ? (int) request.getAttribute("todayCheckins") : 0;

    @SuppressWarnings("unchecked")
    List<ReservationDTO> recentReservations = (List<ReservationDTO>) request.getAttribute("recentReservations");

    java.time.LocalDate today = java.time.LocalDate.now();
    java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy");
    String currentDate = today.format(formatter);

    String successMsg = (String) session.getAttribute("success");
    String errorMsg = (String) session.getAttribute("error");
    if (successMsg != null) session.removeAttribute("success");
    if (errorMsg != null) session.removeAttribute("error");
%>

<!-- Sidebar -->
<div class="sidebar">
    <div class="sidebar-brand">
        <h3><i class="fas fa-hotel me-2"></i>Ocean View</h3>
        <p>Hotel Reservation System</p>
    </div>
    <ul class="sidebar-menu">
        <li><a href="<%= request.getContextPath() %>/staff/dashboard" class="active">
            <i class="fas fa-tachometer-alt"></i><span>Dashboard</span></a></li>
        <li><a href="<%= request.getContextPath() %>/staff/reservations/new">
            <i class="fas fa-plus-circle"></i><span>New Reservation</span></a></li>
        <li><a href="<%= request.getContextPath() %>/staff/reservations">
            <i class="fas fa-list-alt"></i><span>All Reservations</span></a></li>
        <li><a href="<%= request.getContextPath() %>/staff/reservations/search">
            <i class="fas fa-search"></i><span>Search Reservation</span></a></li>
        <li><a href="<%= request.getContextPath() %>/staff/guests">
            <i class="fas fa-users"></i><span>Guests</span></a></li>
        <li><a href="<%= request.getContextPath() %>/staff/rooms">
            <i class="fas fa-door-open"></i><span>Rooms</span></a></li>
        <li><a href="<%= request.getContextPath() %>/staff/bills">
            <i class="fas fa-receipt"></i><span>Bills</span></a></li>
        <li><a href="<%= request.getContextPath() %>/logout">
            <i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
    </ul>
</div>

<div class="main-content">

    <div class="top-nav">
        <div class="page-title">
            <h2>Staff Dashboard</h2>
            <p><i class="fas fa-calendar-alt me-1"></i><%= currentDate %></p>
        </div>
        <div class="user-menu">
            <div class="user-avatar">
                <%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %>
            </div>
            <div>
                <div class="user-name"><%= user.getFullName() %></div>
                <div class="user-role"><%= user.getRole() %></div>
            </div>
        </div>
    </div>

    <% if (successMsg != null) { %>
    <div class="alert-success-custom">
        <i class="fas fa-check-circle"></i> <%= successMsg %>
    </div>
    <% } %>
    <% if (errorMsg != null) { %>
    <div class="alert-error-custom">
        <i class="fas fa-exclamation-circle"></i> <%= errorMsg %>
    </div>
    <% } %>

    <div class="welcome-banner">
        <div class="row align-items-center">
            <div class="col-md-9">
                <h4>Welcome back, <%= user.getFirstName() %>! 👋</h4>
                <p>You have <strong><%= todayCheckins %></strong> check-in(s) scheduled for today. Manage reservations from the actions below.</p>
            </div>
            <div class="col-md-3 text-end d-none d-md-block">
                <i class="fas fa-concierge-bell" style="font-size: 3rem; opacity: 0.3;"></i>
            </div>
        </div>
    </div>

    <!-- Stats - now properly reading from request attributes set by servlet -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-info">
                <h3><%= activeReservations %></h3>
                <p>Active Reservations</p>
            </div>
            <div class="stat-icon"><i class="fas fa-calendar-check"></i></div>
        </div>
        <div class="stat-card" style="border-left-color: #198754;">
            <div class="stat-info">
                <h3><%= availableRooms %></h3>
                <p>Available Rooms</p>
            </div>
            <div class="stat-icon" style="background: linear-gradient(135deg,#198754,#146c43);">
                <i class="fas fa-door-open"></i>
            </div>
        </div>
        <div class="stat-card" style="border-left-color: #fd7e14;">
            <div class="stat-info">
                <h3><%= totalGuests %></h3>
                <p>Total Guests</p>
            </div>
            <div class="stat-icon" style="background: linear-gradient(135deg,#fd7e14,#e96c02);">
                <i class="fas fa-users"></i>
            </div>
        </div>
        <div class="stat-card" style="border-left-color: #0dcaf0;">
            <div class="stat-info">
                <h3><%= todayCheckins %></h3>
                <p>Check-ins Today</p>
            </div>
            <div class="stat-icon" style="background: linear-gradient(135deg,#0dcaf0,#0aa2c0);">
                <i class="fas fa-sign-in-alt"></i>
            </div>
        </div>
    </div>

    <div class="section-title">Quick Actions</div>
    <div class="quick-actions">
        <a href="<%= request.getContextPath() %>/staff/reservations/new" class="action-btn">
            <div class="action-icon"><i class="fas fa-plus-circle"></i></div>
            <h5>New Reservation</h5>
            <p>Create a booking for a guest</p>
        </a>
        <a href="<%= request.getContextPath() %>/staff/reservations/search" class="action-btn">
            <div class="action-icon"><i class="fas fa-search"></i></div>
            <h5>Find Reservation</h5>
            <p>Search by number, guest, or date</p>
        </a>
        <a href="<%= request.getContextPath() %>/staff/reservations" class="action-btn">
            <div class="action-icon"><i class="fas fa-list-alt"></i></div>
            <h5>All Reservations</h5>
            <p>View and manage all bookings</p>
        </a>
        <a href="<%= request.getContextPath() %>/staff/guests" class="action-btn">
            <div class="action-icon"><i class="fas fa-user-plus"></i></div>
            <h5>Manage Guests</h5>
            <p>Add or search guest profiles</p>
        </a>
        <a href="<%= request.getContextPath() %>/staff/rooms" class="action-btn">
            <div class="action-icon"><i class="fas fa-door-open"></i></div>
            <h5>Room Status</h5>
            <p>View available and occupied rooms</p>
        </a>
        <a href="<%= request.getContextPath() %>/staff/bills" class="action-btn">
            <div class="action-icon"><i class="fas fa-receipt"></i></div>
            <h5>Bills & Payments</h5>
            <p>Generate bills and record payments</p>
        </a>
    </div>

    <!-- Recent Reservations Table -->
    <div class="table-card">
        <div class="table-header">
            <span class="section-title mb-0">Recent Reservations</span>
            <a href="<%= request.getContextPath() %>/staff/reservations"
               class="btn btn-sm btn-outline-primary">
                View All <i class="fas fa-arrow-right ms-1"></i>
            </a>
        </div>
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                <tr>
                    <th>Reservation #</th>
                    <th>Guest Name</th>
                    <th>Room</th>
                    <th>Check-in</th>
                    <th>Check-out</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <% if (recentReservations == null || recentReservations.isEmpty()) { %>
                <tr>
                    <td colspan="7" class="text-center py-4 text-muted">
                        <i class="fas fa-calendar-times fa-2x mb-2 d-block"></i>
                        No reservations found.
                        <a href="<%= request.getContextPath() %>/staff/reservations/new">Create one now</a>
                    </td>
                </tr>
                <% } else { for (ReservationDTO r : recentReservations) { %>
                <tr>
                    <td><strong><%= r.getReservationNumber() %></strong></td>
                    <td><%= r.getGuestName() != null ? r.getGuestName() : "-" %></td>
                    <td>
                        <%= r.getRoomNumber() != null ? r.getRoomNumber() : "-" %>
                        <% if (r.getRoomType() != null) { %>
                        <small class="text-muted">(<%= r.getRoomType() %>)</small>
                        <% } %>
                    </td>
                    <td><%= r.getCheckInDate() %></td>
                    <td><%= r.getCheckOutDate() %></td>
                    <td>
                        <%
                            String status = r.getReservationStatus();
                            String badgeClass = "badge-pending";
                            String statusLabel = status != null ? status.replace("_", " ") : "PENDING";
                            if ("CONFIRMED".equals(status)) badgeClass = "badge-confirmed";
                            else if ("CHECKED_IN".equals(status)) badgeClass = "badge-checked-in";
                            else if ("CHECKED_OUT".equals(status)) badgeClass = "badge-checked-out";
                            else if ("CANCELLED".equals(status)) badgeClass = "badge-cancelled";
                        %>
                        <span class="badge-status <%= badgeClass %>"><%= statusLabel %></span>
                    </td>
                    <td>
                        <a href="<%= request.getContextPath() %>/staff/reservations/view?id=<%= r.getId() %>"
                           class="btn btn-sm btn-outline-primary" title="View">
                            <i class="fas fa-eye"></i>
                        </a>
                        <a href="<%= request.getContextPath() %>/staff/reservations/edit?id=<%= r.getId() %>"
                           class="btn btn-sm btn-outline-secondary" title="Edit">
                            <i class="fas fa-edit"></i>
                        </a>
                        <% if ("CONFIRMED".equals(status)) { %>
                        <a href="<%= request.getContextPath() %>/staff/reservations/checkin?id=<%= r.getId() %>"
                           class="btn btn-sm btn-outline-success" title="Check In"
                           onclick="return confirm('Check in this guest?')">
                            <i class="fas fa-sign-in-alt"></i>
                        </a>
                        <% } else if ("CHECKED_IN".equals(status)) { %>
                        <a href="<%= request.getContextPath() %>/staff/reservations/checkout?id=<%= r.getId() %>"
                           class="btn btn-sm btn-outline-warning" title="Check Out"
                           onclick="return confirm('Check out this guest?')">
                            <i class="fas fa-sign-out-alt"></i>
                        </a>
                        <% } %>
                        <a href="<%= request.getContextPath() %>/staff/reservations/delete?id=<%= r.getId() %>"
                           class="btn btn-sm btn-outline-danger" title="Delete"
                           onclick="return confirm('Delete this reservation?')">
                            <i class="fas fa-trash"></i>
                        </a>
                    </td>
                </tr>
                <% } } %>
                </tbody>
            </table>
        </div>
    </div>

    <div class="row">
        <div class="col-md-8">
            <div class="table-card">
                <div class="section-title">Weekly Occupancy</div>
                <canvas id="occupancyChart" height="120"></canvas>
            </div>
        </div>
        <div class="col-md-4">
            <div class="table-card">
                <div class="section-title">Room Type Distribution</div>
                <canvas id="roomTypeChart" height="200"></canvas>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        new Chart(document.getElementById('occupancyChart').getContext('2d'), {
            type: 'line',
            data: {
                labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                datasets: [{
                    label: 'Occupancy %',
                    data: [65, 70, 75, 80, 85, 90, 88],
                    borderColor: '#0d6efd',
                    backgroundColor: 'rgba(13,110,253,0.08)',
                    tension: 0.4, fill: true, borderWidth: 2,
                    pointBackgroundColor: '#0d6efd', pointRadius: 4
                }]
            },
            options: {
                responsive: true,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true, max: 100 } }
            }
        });

        new Chart(document.getElementById('roomTypeChart').getContext('2d'), {
            type: 'doughnut',
            data: {
                labels: ['Standard', 'Deluxe', 'Suite', 'Ocean View', 'Family'],
                datasets: [{
                    data: [30, 25, 15, 20, 10],
                    backgroundColor: ['#0d6efd', '#198754', '#ffc107', '#0dcaf0', '#6c757d'],
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                plugins: { legend: { position: 'bottom' } },
                cutout: '60%'
            }
        });
    });
</script>
</body>
</html>
