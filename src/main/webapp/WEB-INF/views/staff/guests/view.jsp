<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.dto.GuestDTO" %>
<%@ page import="com.oceanview.dto.ReservationDTO" %>
<%@ page import="java.util.List" %>
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
            --primary-light: #e8f0fe;
            --secondary-color: #6c757d;
            --success-color: #198754;
            --warning-color: #ffc107;
            --danger-color: #dc3545;
            --dark-color: #212529;
            --sidebar-width: 280px;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Poppins', sans-serif;
            background: #f4f7fc;
            overflow-x: hidden;
        }

        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            width: var(--sidebar-width);
            background: linear-gradient(180deg, #0b5ed7 0%, #0d6efd 100%);
            color: white;
            z-index: 1000;
            box-shadow: 3px 0 20px rgba(0,0,0,0.1);
            overflow-y: auto;
        }
        .sidebar-brand {
            padding: 25px 20px 20px;
            border-bottom: 1px solid rgba(255,255,255,0.2);
            margin-bottom: 15px;
        }
        .sidebar-brand h3 {
            font-size: 1.4rem;
            font-weight: 700;
            margin: 0;
        }
        .sidebar-brand p {
            font-size: 0.8rem;
            opacity: 0.8;
            margin: 4px 0 0;
        }
        .sidebar-menu {
            list-style: none;
            padding: 5px 15px;
            margin: 0;
        }
        .sidebar-menu li {
            margin-bottom: 4px;
        }
        .sidebar-menu a {
            display: flex;
            align-items: center;
            padding: 12px 15px;
            color: rgba(255,255,255,0.85);
            text-decoration: none;
            transition: all 0.3s;
            border-radius: 10px;
        }
        .sidebar-menu a:hover,
        .sidebar-menu a.active {
            background: rgba(255,255,255,0.15);
            color: white;
            transform: translateX(5px);
        }
        .sidebar-menu a i {
            width: 30px;
            font-size: 1.1rem;
        }

        .main-content {
            margin-left: var(--sidebar-width);
            padding: 20px 30px;
        }

        .top-nav {
            background: white;
            border-radius: 16px;
            padding: 15px 25px;
            margin-bottom: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .page-title h2 {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--dark-color);
            margin: 0;
        }
        .page-title p {
            color: var(--secondary-color);
            margin: 3px 0 0;
            font-size: 0.85rem;
        }
        .user-menu {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .user-avatar {
            width: 45px;
            height: 45px;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 1rem;
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: var(--secondary-color);
            text-decoration: none;
            margin-bottom: 20px;
            padding: 8px 15px;
            background: white;
            border-radius: 10px;
            transition: all 0.3s;
        }
        .back-link:hover {
            background: var(--primary-light);
            color: var(--primary-color);
            transform: translateX(-5px);
        }

        .profile-header {
            background: white;
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            display: flex;
            align-items: center;
            gap: 30px;
            position: relative;
        }
        .profile-avatar {
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2.5rem;
            font-weight: 600;
            box-shadow: 0 10px 20px rgba(13,110,253,0.2);
        }
        .profile-info h1 {
            font-size: 2rem;
            font-weight: 700;
            color: var(--dark-color);
            margin-bottom: 10px;
        }
        .profile-badges {
            display: flex;
            gap: 10px;
            margin-bottom: 10px;
        }
        .badge-vip {
            background: #ffc107;
            color: #856404;
            padding: 5px 15px;
            border-radius: 30px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        .badge-guest-number {
            background: var(--primary-light);
            color: var(--primary-color);
            padding: 5px 15px;
            border-radius: 30px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        .profile-meta {
            display: flex;
            gap: 30px;
            margin-top: 10px;
        }
        .profile-meta-item {
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--secondary-color);
        }
        .profile-actions {
            position: absolute;
            top: 30px;
            right: 30px;
            display: flex;
            gap: 10px;
        }
        .btn-edit {
            background: var(--primary-color);
            color: white;
            padding: 10px 20px;
            border-radius: 10px;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s;
        }
        .btn-edit:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(13,110,253,0.3);
            color: white;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 25px;
        }
        .stat-card {
            background: white;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            text-align: center;
            transition: all 0.3s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(13,110,253,0.15);
        }
        .stat-value {
            font-size: 2rem;
            font-weight: 700;
            color: var(--primary-color);
            margin-bottom: 5px;
        }
        .stat-label {
            color: var(--secondary-color);
            font-size: 0.85rem;
        }

        .details-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 25px;
            margin-bottom: 25px;
        }
        .detail-card {
            background: white;
            border-radius: 16px;
            padding: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        }
        .detail-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--dark-color);
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid var(--primary-light);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .detail-title i {
            color: var(--primary-color);
        }
        .detail-row {
            display: flex;
            margin-bottom: 15px;
        }
        .detail-label {
            width: 120px;
            color: var(--secondary-color);
            font-size: 0.9rem;
        }
        .detail-value {
            flex: 1;
            color: var(--dark-color);
            font-weight: 500;
        }

        .reservations-table {
            background: white;
            border-radius: 16px;
            padding: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            margin-bottom: 25px;
        }
        .reservations-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--dark-color);
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .reservations-title i {
            color: var(--primary-color);
        }
        .reservations-table table {
            width: 100%;
            border-collapse: collapse;
        }
        .reservations-table th {
            background: #f8f9fa;
            padding: 15px;
            text-align: left;
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--secondary-color);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .reservations-table td {
            padding: 15px;
            border-bottom: 1px solid #e9ecef;
        }
        .reservations-table tr:hover {
            background: #f8f9fa;
        }
        .badge-status {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
        }
        .badge-confirmed { background: #d4edda; color: #155724; }
        .badge-checked-in { background: #cce5ff; color: #004085; }
        .badge-checked-out { background: #e2e3e5; color: #383d41; }
        .badge-cancelled { background: #f8d7da; color: #721c24; }
        .badge-pending { background: #fff3cd; color: #856404; }

        @media (max-width: 1200px) {
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
        }
        @media (max-width: 768px) {
            .sidebar { transform: translateX(-100%); }
            .main-content { margin-left: 0; padding: 15px; }
            .profile-header { flex-direction: column; text-align: center; }
            .profile-actions { position: static; margin-top: 20px; }
            .details-grid { grid-template-columns: 1fr; }
            .stats-grid { grid-template-columns: 1fr; }
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
    String basePath = user.isAdmin() ? "/admin" : "/staff";
    GuestDTO guest = (GuestDTO) request.getAttribute("guest");
%>

<!-- Sidebar -->
<div class="sidebar">
    <div class="sidebar-brand">
        <h3><i class="fas fa-hotel me-2"></i>Ocean View</h3>
        <p>Hotel Reservation System</p>
    </div>
    <ul class="sidebar-menu">
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/dashboard">
            <i class="fas fa-tachometer-alt"></i><span>Dashboard</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations">
            <i class="fas fa-calendar-alt"></i><span>Reservations</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations/new">
            <i class="fas fa-plus-circle"></i><span>New Reservation</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/guests" class="active">
            <i class="fas fa-users"></i><span>Guests</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/rooms">
            <i class="fas fa-door-open"></i><span>Rooms</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/bills">
            <i class="fas fa-receipt"></i><span>Bills</span></a></li>
        <li><a href="${pageContext.request.contextPath}/logout">
            <i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
    </ul>
</div>

<!-- Main Content -->
<div class="main-content">
    <div class="top-nav">
        <div class="page-title">
            <h2><%= request.getAttribute("pageTitle") %></h2>
            <p><i class="fas fa-user me-1"></i>Guest profile and stay history</p>
        </div>
        <div class="user-menu">
            <div class="user-avatar">
                <%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %>
            </div>
            <div>
                <div style="font-weight:600;"><%= user.getFullName() %></div>
                <div style="font-size:0.8rem;color:#6c757d;"><%= user.getRole() %></div>
            </div>
        </div>
    </div>

    <a href="${pageContext.request.contextPath}<%= basePath %>/guests" class="back-link">
        <i class="fas fa-arrow-left"></i> Back to Guests
    </a>

    <!-- Profile Header -->
    <div class="profile-header">
        <div class="profile-avatar">
            <%= guest.getFirstName() != null && guest.getLastName() != null ?
                    String.valueOf(guest.getFirstName().charAt(0)) + String.valueOf(guest.getLastName().charAt(0)) :
                    guest.getFullName().substring(0, Math.min(2, guest.getFullName().length())).toUpperCase() %>
        </div>
        <div class="profile-info">
            <h1><%= guest.getFullName() %></h1>
            <div class="profile-badges">
                <span class="badge-guest-number"><i class="fas fa-hashtag"></i> <%= guest.getGuestNumber() %></span>
                <% if (guest.getIsVip() != null && guest.getIsVip()) { %>
                <span class="badge-vip"><i class="fas fa-crown"></i> VIP Guest</span>
                <% } %>
            </div>
            <div class="profile-meta">
                <span class="profile-meta-item"><i class="fas fa-calendar-alt"></i> Member since: <%= guest.getCreatedAt() != null ? new java.text.SimpleDateFormat("MMM yyyy").format(java.sql.Timestamp.valueOf(guest.getCreatedAt())) : "N/A" %></span>
                <span class="profile-meta-item"><i class="fas fa-star"></i> Loyalty Points: <%= guest.getLoyaltyPoints() != null ? guest.getLoyaltyPoints() : 0 %></span>
            </div>
        </div>
        <div class="profile-actions">
            <a href="${pageContext.request.contextPath}<%= basePath %>/guests/edit?id=<%= guest.getId() %>" class="btn-edit">
                <i class="fas fa-edit"></i> Edit Profile
            </a>
            <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/new?guestId=<%= guest.getId() %>" class="btn-edit" style="background: var(--success-color);">
                <i class="fas fa-plus-circle"></i> New Reservation
            </a>
        </div>
    </div>

    <!-- Stats -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-value"><%= request.getAttribute("totalStays") %></div>
            <div class="stat-label">Total Stays</div>
        </div>
        <div class="stat-card">
            <div class="stat-value"><%= request.getAttribute("completedStays") %></div>
            <div class="stat-label">Completed Stays</div>
        </div>
        <div class="stat-card">
            <div class="stat-value"><%= request.getAttribute("cancelledStays") %></div>
            <div class="stat-label">Cancelled</div>
        </div>
        <div class="stat-card">
            <div class="stat-value">$<%= String.format("%,.0f", (Double) request.getAttribute("totalSpent")) %></div>
            <div class="stat-label">Total Spent</div>
        </div>
    </div>

    <!-- Details Grid -->
    <div class="details-grid">
        <div class="detail-card">
            <div class="detail-title">
                <i class="fas fa-address-card"></i> Contact Information
            </div>
            <div class="detail-row">
                <div class="detail-label">Email:</div>
                <div class="detail-value">
                    <% if (guest.getEmail() != null && !guest.getEmail().isEmpty()) { %>
                    <a href="mailto:<%= guest.getEmail() %>"><%= guest.getEmail() %></a>
                    <% } else { %>Not provided<% } %>
                </div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Phone:</div>
                <div class="detail-value">
                    <% if (guest.getPhone() != null && !guest.getPhone().isEmpty()) { %>
                    <a href="tel:<%= guest.getPhone() %>"><%= guest.getPhone() %></a>
                    <% } else { %>Not provided<% } %>
                </div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Address:</div>
                <div class="detail-value">
                    <% if (guest.getAddress() != null && !guest.getAddress().isEmpty()) { %>
                    <%= guest.getAddress() %><br>
                    <%= guest.getCity() != null ? guest.getCity() + ", " : "" %>
                    <%= guest.getCountry() != null ? guest.getCountry() : "" %>
                    <%= guest.getPostalCode() != null ? " - " + guest.getPostalCode() : "" %>
                    <% } else { %>Not provided<% } %>
                </div>
            </div>
        </div>

        <div class="detail-card">
            <div class="detail-title">
                <i class="fas fa-id-card"></i> Identification
            </div>
            <div class="detail-row">
                <div class="detail-label">ID Type:</div>
                <div class="detail-value">
                    <% if (guest.getIdCardType() != null && !guest.getIdCardType().isEmpty()) { %>
                    <%= guest.getIdCardType().replace("_", " ") %>
                    <% } else { %>Not specified<% } %>
                </div>
            </div>
            <div class="detail-row">
                <div class="detail-label">ID Number:</div>
                <div class="detail-value">
                    <% if (guest.getIdCardNumber() != null && !guest.getIdCardNumber().isEmpty()) { %>
                    <%= guest.getIdCardNumber() %>
                    <% } else { %>Not provided<% } %>
                </div>
            </div>
        </div>

        <% if (guest.getNotes() != null && !guest.getNotes().isEmpty()) { %>
        <div class="detail-card" style="grid-column: span 2;">
            <div class="detail-title">
                <i class="fas fa-sticky-note"></i> Notes
            </div>
            <div class="detail-value">
                <%= guest.getNotes() %>
            </div>
        </div>
        <% } %>
    </div>

    <!-- Reservation History -->
    <div class="reservations-table">
        <div class="reservations-title">
            <i class="fas fa-history"></i> Stay History
        </div>
        <table>
            <thead>
            <tr>
                <th>Reservation #</th>
                <th>Check-in</th>
                <th>Check-out</th>
                <th>Rooms</th>
                <th>Guests</th>
                <th>Status</th>
                <th>Total</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <%
                List<ReservationDTO> reservations = (List<ReservationDTO>) request.getAttribute("reservations");
                if (reservations == null || reservations.isEmpty()) {
            %>
            <tr>
                <td colspan="8" style="text-align: center; padding: 40px; color: #6c757d;">
                    <i class="fas fa-calendar-times fa-3x mb-3" style="opacity: 0.3;"></i>
                    <h5>No reservation history found</h5>
                    <p>This guest hasn't made any reservations yet.</p>
                    <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/new?guestId=<%= guest.getId() %>"
                       class="btn btn-primary mt-2">
                        <i class="fas fa-plus-circle"></i> Create Reservation
                    </a>
                </td>
            </tr>
            <% } else {
                for (ReservationDTO r : reservations) {
                    String status = r.getReservationStatus();
                    String badgeClass = "badge-pending";
                    if ("CONFIRMED".equals(status)) badgeClass = "badge-confirmed";
                    else if ("CHECKED_IN".equals(status)) badgeClass = "badge-checked-in";
                    else if ("CHECKED_OUT".equals(status)) badgeClass = "badge-checked-out";
                    else if ("CANCELLED".equals(status)) badgeClass = "badge-cancelled";
            %>
            <tr>
                <td><strong><%= r.getReservationNumber() %></strong></td>
                <td><%= r.getFormattedCheckInDate() %></td>
                <td><%= r.getFormattedCheckOutDate() %></td>
                <td>
                    <%= r.getRoomNumbersSummary() %>
                    <small class="text-muted d-block"><%= r.getRoomTypesSummary() %></small>
                </td>
                <td><%= r.getAdults() %> Adults, <%= r.getChildren() %> Children</td>
                <td><span class="badge-status <%= badgeClass %>"><%= status != null ? status.replace("_"," ") : "PENDING" %></span></td>
                <td>$<%= r.getTotalAmount() != null ? String.format("%,.2f", r.getTotalAmount()) : "0.00" %></td>
                <td>
                    <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/view?id=<%= r.getId() %>"
                       class="btn btn-sm btn-outline-primary" title="View">
                        <i class="fas fa-eye"></i>
                    </a>
                </td>
            </tr>
            <% } } %>
            </tbody>
        </table>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>