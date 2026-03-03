<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.dto.ReservationDTO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - Ocean View Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #0d6efd;
            --primary-dark: #0b5ed7;
            --secondary-color: #6c757d;
            --success-color: #198754;
            --danger-color: #dc3545;
            --sidebar-width: 280px;
            --dark-color: #212529;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Poppins', sans-serif; background: #f4f6f9; overflow-x: hidden; }

        .sidebar {
            position: fixed; top: 0; left: 0; height: 100vh; width: var(--sidebar-width);
            background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%);
            color: white; padding: 20px 0; z-index: 1000; box-shadow: 3px 0 15px rgba(0,0,0,0.15);
        }
        .sidebar-brand { padding: 0 20px 20px; border-bottom: 1px solid rgba(255,255,255,0.2); margin-bottom: 20px; }
        .sidebar-brand h3 { font-size: 1.5rem; font-weight: 600; margin: 0; }
        .sidebar-brand p { font-size: 0.85rem; opacity: 0.8; margin: 5px 0 0; }
        .sidebar-menu { list-style: none; padding: 0 15px; }
        .sidebar-menu a {
            display: flex; align-items: center; padding: 12px 20px;
            color: rgba(255,255,255,0.8); text-decoration: none;
            transition: all 0.3s; border-radius: 10px;
        }
        .sidebar-menu a:hover, .sidebar-menu a.active { background: rgba(255,255,255,0.15); color: white; }
        .sidebar-menu a i { width: 30px; font-size: 1.2rem; }

        .main-content { margin-left: var(--sidebar-width); padding: 20px 30px; }
        .top-nav {
            background: white; border-radius: 15px; padding: 15px 25px;
            margin-bottom: 25px; box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            display: flex; justify-content: space-between; align-items: center;
        }
        .page-title h2 {
            font-size: 1.4rem; font-weight: 600; color: var(--dark-color);
            display: flex; align-items: center; gap: 10px;
        }
        .page-title .badge-today {
            background: var(--primary-color); color: white;
            padding: 5px 12px; border-radius: 20px; font-size: 0.8rem;
            font-weight: 500; margin-left: 10px;
        }
        .user-avatar {
            width: 40px; height: 40px;
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
            border-radius: 10px; display: flex; align-items: center;
            justify-content: center; color: white; font-weight: 600;
        }

        .stats-summary {
            display: grid; grid-template-columns: repeat(3, 1fr);
            gap: 20px; margin-bottom: 25px;
        }
        .stat-mini-card {
            background: white; border-radius: 12px; padding: 15px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            display: flex; align-items: center; gap: 12px;
            border-left: 4px solid var(--primary-color);
        }
        .stat-mini-card.primary { border-left-color: var(--primary-color); }
        .stat-mini-card.success { border-left-color: var(--success-color); }
        .stat-mini-card.warning { border-left-color: #ffc107; }
        .stat-mini-icon {
            width: 40px; height: 40px; border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            color: white; font-size: 1.1rem;
        }
        .stat-mini-info h4 { font-size: 1.3rem; font-weight: 700; margin: 0; line-height: 1.2; }
        .stat-mini-info p { margin: 0; font-size: 0.75rem; color: var(--secondary-color); }

        .filter-section {
            background: white; border-radius: 12px; padding: 15px 20px;
            margin-bottom: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }

        .table-card {
            background: white; border-radius: 15px; padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        .badge-status { padding: 5px 12px; border-radius: 20px; font-size: 0.8rem; font-weight: 500; }
        .badge-confirmed { background: #d4edda; color: #155724; }
        .badge-checked-in { background: #cce5ff; color: #004085; }
        .badge-checked-out { background: #e2e3e5; color: #383d41; }
        .badge-cancelled { background: #f8d7da; color: #721c24; }
        .badge-pending { background: #fff3cd; color: #856404; }

        .btn-action-sm {
            padding: 5px 10px; border-radius: 8px; font-size: 0.75rem;
            margin: 0 2px; transition: all 0.2s;
        }
        .btn-action-sm:hover { transform: translateY(-2px); }

        .empty-state {
            text-align: center; padding: 40px 20px;
            background: #f8f9fa; border-radius: 10px;
        }
        .empty-state i { font-size: 3rem; color: #dee2e6; margin-bottom: 15px; }
        .empty-state p { color: #6c757d; margin-bottom: 5px; }
        .empty-state small { color: #adb5bd; }

        @media (max-width: 768px) {
            .sidebar { transform: translateX(-100%); }
            .main-content { margin-left: 0; padding: 15px; }
            .stats-summary { grid-template-columns: 1fr; }
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

    // Get attributes from request
    Boolean isAdminAttr = (Boolean) request.getAttribute("isAdmin");
    Boolean isCheckInsAttr = (Boolean) request.getAttribute("isCheckIns");

    boolean isAdmin = isAdminAttr != null ? isAdminAttr : false;
    boolean isCheckIns = isCheckInsAttr != null ? isCheckInsAttr : true;

    String basePath = isAdmin ? "/admin" : "/staff";
    LocalDate today = LocalDate.now();
    DateTimeFormatter displayFormat = DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy");
    String formattedDate = today.format(displayFormat);

    // Get reservations list
    List<ReservationDTO> reservations = (List<ReservationDTO>) request.getAttribute("reservations");
    if (reservations == null) {
        reservations = new java.util.ArrayList<>();
    }

    // Calculate stats
    long completedCount = 0;
    long pendingCount = 0;

    if (isCheckIns) {
        completedCount = reservations.stream()
                .filter(r -> "CHECKED_IN".equals(r.getReservationStatus()))
                .count();
        pendingCount = reservations.stream()
                .filter(r -> "CONFIRMED".equals(r.getReservationStatus()))
                .count();
    } else {
        completedCount = reservations.stream()
                .filter(r -> "CHECKED_OUT".equals(r.getReservationStatus()))
                .count();
        pendingCount = reservations.stream()
                .filter(r -> "CHECKED_IN".equals(r.getReservationStatus()))
                .count();
    }

    // Date formatter for display - we'll just show the date since time isn't available in LocalDate
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("MMM dd, yyyy");
%>

<div class="sidebar">
    <div class="sidebar-brand">
        <h3><i class="fas fa-hotel me-2"></i>Ocean View</h3>
        <p>Hotel Reservation System</p>
    </div>
    <ul class="sidebar-menu">
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/dashboard">
            <i class="fas fa-chart-pie"></i><span>Dashboard</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations">
            <i class="fas fa-calendar-alt"></i><span>All Reservations</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations/new">
            <i class="fas fa-plus-circle"></i><span>New Reservation</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/guests">
            <i class="fas fa-users"></i><span>Guests</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/rooms">
            <i class="fas fa-door-open"></i><span>Rooms</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/bills">
            <i class="fas fa-receipt"></i><span>Bills</span></a></li>
        <li><a href="${pageContext.request.contextPath}/logout">
            <i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
    </ul>
</div>

<div class="main-content">
    <div class="top-nav">
        <div class="page-title">
            <h2>
                <i class="fas fa-<%= isCheckIns ? "sign-in-alt" : "sign-out-alt" %> me-2 text-<%= isCheckIns ? "success" : "warning" %>"></i>
                <%= isCheckIns ? "Today's Check-ins" : "Today's Check-outs" %>
                <span class="badge-today"><%= formattedDate %></span>
            </h2>
        </div>
        <div class="d-flex align-items-center gap-3">
            <div class="user-avatar">
                <%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %>
            </div>
            <div>
                <div style="font-weight:600;font-size:.9rem;"><%= user.getFullName() %></div>
                <div style="font-size:.75rem;color:#6c757d;"><%= user.getRole() %></div>
            </div>
        </div>
    </div>

    <% if (session.getAttribute("success") != null) { %>
    <div class="alert alert-success alert-dismissible fade show">
        <i class="fas fa-check-circle me-2"></i><%= session.getAttribute("success") %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% session.removeAttribute("success"); %>
    <% } %>
    <% if (session.getAttribute("error") != null) { %>
    <div class="alert alert-danger alert-dismissible fade show">
        <i class="fas fa-exclamation-circle me-2"></i><%= session.getAttribute("error") %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% session.removeAttribute("error"); %>
    <% } %>

    <!-- Mini Stats -->
    <div class="stats-summary">
        <div class="stat-mini-card primary">
            <div class="stat-mini-icon" style="background: linear-gradient(135deg,#0d6efd,#0b5ed7);">
                <i class="fas fa-<%= isCheckIns ? "sign-in-alt" : "sign-out-alt" %>"></i>
            </div>
            <div class="stat-mini-info">
                <h4><%= reservations.size() %></h4>
                <p>Total for Today</p>
            </div>
        </div>
        <div class="stat-mini-card success">
            <div class="stat-mini-icon" style="background: linear-gradient(135deg,#198754,#146c43);">
                <i class="fas fa-check-circle"></i>
            </div>
            <div class="stat-mini-info">
                <h4><%= completedCount %></h4>
                <p>Completed</p>
            </div>
        </div>
        <div class="stat-mini-card warning">
            <div class="stat-mini-icon" style="background: linear-gradient(135deg,#ffc107,#e0a800);">
                <i class="fas fa-hourglass-half"></i>
            </div>
            <div class="stat-mini-info">
                <h4><%= pendingCount %></h4>
                <p>Pending</p>
            </div>
        </div>
    </div>

    <!-- Filter Section -->
    <div class="filter-section">
        <form method="get" class="row g-3 align-items-center">
            <div class="col-md-4">
                <select name="status" class="form-select form-select-sm">
                    <option value="">All Status</option>
                    <option value="CONFIRMED" <%= "CONFIRMED".equals(request.getParameter("status")) ? "selected" : "" %>>Confirmed</option>
                    <option value="CHECKED_IN" <%= "CHECKED_IN".equals(request.getParameter("status")) ? "selected" : "" %>>Checked In</option>
                    <option value="CHECKED_OUT" <%= "CHECKED_OUT".equals(request.getParameter("status")) ? "selected" : "" %>>Checked Out</option>
                </select>
            </div>
            <div class="col-md-4">
                <input type="text" name="guestName" class="form-control form-control-sm"
                       placeholder="Search guest name..." value="<%= request.getParameter("guestName") != null ? request.getParameter("guestName") : "" %>">
            </div>
            <div class="col-md-4">
                <button type="submit" class="btn btn-primary btn-sm">
                    <i class="fas fa-filter me-1"></i>Apply Filters
                </button>
                <a href="${pageContext.request.contextPath}<%= basePath %>/today-<%= isCheckIns ? "checkins" : "checkouts" %>"
                   class="btn btn-outline-secondary btn-sm ms-2">
                    <i class="fas fa-redo-alt me-1"></i>Reset
                </a>
            </div>
        </form>
    </div>

    <!-- Reservations List -->
    <div class="table-card">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <span class="fw-semibold">
                <i class="fas fa-list me-2"></i>
                <%= isCheckIns ? "Guests Arriving Today" : "Guests Departing Today" %>
            </span>
            <a href="${pageContext.request.contextPath}<%= basePath %>/dashboard" class="btn btn-sm btn-outline-secondary">
                <i class="fas fa-arrow-left me-1"></i>Back to Dashboard
            </a>
        </div>

        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                <tr>
                    <th>Reservation #</th>
                    <th>Guest Name</th>
                    <th>Room(s)</th>
                    <th>Date</th>
                    <th>Status</th>
                    <th>Payment</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <%
                    if (reservations == null || reservations.isEmpty()) {
                %>
                <tr>
                    <td colspan="7">
                        <div class="empty-state">
                            <i class="fas fa-<%= isCheckIns ? "calendar-check" : "calendar-times" %>"></i>
                            <p>No <%= isCheckIns ? "check-ins" : "check-outs" %> scheduled for today</p>
                            <small>All set for the day!</small>
                        </div>
                    </td>
                </tr>
                <%
                } else {
                    for (ReservationDTO r : reservations) {
                        String status = r.getReservationStatus();
                        String badgeClass = "badge-pending";
                        if ("CONFIRMED".equals(status)) badgeClass = "badge-confirmed";
                        else if ("CHECKED_IN".equals(status)) badgeClass = "badge-checked-in";
                        else if ("CHECKED_OUT".equals(status)) badgeClass = "badge-checked-out";
                        else if ("CANCELLED".equals(status)) badgeClass = "badge-cancelled";

                        String paymentStatus = r.getPaymentStatus();
                        boolean isPaid = "PAID".equals(paymentStatus);

                        // Format date based on whether it's check-in or check-out
                        String dateDisplay = isCheckIns ?
                                (r.getCheckInDate() != null ? r.getCheckInDate().format(dateFormatter) : "N/A") :
                                (r.getCheckOutDate() != null ? r.getCheckOutDate().format(dateFormatter) : "N/A");
                %>
                <tr>
                    <td><strong><%= r.getReservationNumber() %></strong></td>
                    <td>
                        <div class="fw-semibold"><%= r.getGuestName() != null ? r.getGuestName() : "-" %></div>
                        <small class="text-muted"><%= r.getGuestPhone() != null ? r.getGuestPhone() : "" %></small>
                    </td>
                    <td>
                        <span class="badge bg-primary bg-opacity-10 text-primary p-2">
                            <i class="fas fa-door-open me-1"></i><%= r.getRoomNumbersSummary() %>
                        </span>
                    </td>
                    <td><%= dateDisplay %></td>
                    <td>
                        <span class="badge-status <%= badgeClass %>">
                            <%= status != null ? status.replace("_", " ") : "PENDING" %>
                        </span>
                    </td>
                    <td>
                        <% if (isPaid) { %>
                        <span class="badge bg-success bg-opacity-10 text-success p-2">
                            <i class="fas fa-check-circle me-1"></i>Paid
                        </span>
                        <% } else { %>
                        <span class="badge bg-warning bg-opacity-10 text-warning p-2">
                            <i class="fas fa-clock me-1"></i><%= paymentStatus != null ? paymentStatus : "PENDING" %>
                        </span>
                        <% } %>
                    </td>
                    <td>
                        <div class="btn-group btn-group-sm">
                            <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/view?id=<%= r.getId() %>"
                               class="btn btn-outline-primary btn-action-sm" title="View Details">
                                <i class="fas fa-eye"></i>
                            </a>

                            <% if (isCheckIns && "CONFIRMED".equals(status)) { %>
                            <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/checkin?id=<%= r.getId() %>"
                               class="btn btn-outline-success btn-action-sm" title="Check In"
                               onclick="return confirm('Check in this guest?')">
                                <i class="fas fa-sign-in-alt"></i>
                            </a>
                            <% } %>

                            <% if (!isCheckIns && "CHECKED_IN".equals(status)) { %>
                            <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/checkout?id=<%= r.getId() %>"
                               class="btn btn-outline-warning btn-action-sm" title="Check Out & Process Payment"
                               onclick="return confirm('Proceed to checkout and payment for this guest?')">
                                <i class="fas fa-sign-out-alt"></i>
                            </a>
                            <% } %>

                            <% if ("CHECKED_IN".equals(status) || "CHECKED_OUT".equals(status)) { %>
                            <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/print-bill?id=<%= r.getId() %>"
                               class="btn btn-outline-info btn-action-sm" title="Print Bill" target="_blank">
                                <i class="fas fa-print"></i>
                            </a>
                            <% } %>
                        </div>
                    </td>
                </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Auto-refresh every 2 minutes to show updated status
    setTimeout(function() {
        location.reload();
    }, 120000);
</script>
</body>
</html>