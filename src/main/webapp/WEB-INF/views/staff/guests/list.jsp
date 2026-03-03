<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.dto.GuestDTO" %>
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

        /* Sidebar */
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

        /* Main Content */
        .main-content {
            margin-left: var(--sidebar-width);
            padding: 20px 30px;
        }

        /* Top Navigation */
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

        /* Alerts */
        .alert-custom {
            border-radius: 12px;
            padding: 15px 20px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            border: none;
        }
        .alert-success-custom {
            background: #d4edda;
            color: #155724;
            border-left: 4px solid #28a745;
        }
        .alert-error-custom {
            background: #f8d7da;
            color: #721c24;
            border-left: 4px solid #dc3545;
        }

        /* Search Section */
        .search-section {
            background: white;
            border-radius: 16px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        }
        .search-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--dark-color);
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .search-title i {
            color: var(--primary-color);
            font-size: 1.2rem;
        }
        .search-input-group {
            display: flex;
            gap: 10px;
        }
        .search-input-group input {
            flex: 1;
            padding: 12px 15px;
            border: 2px solid #e9ecef;
            border-radius: 12px;
            font-size: 0.95rem;
            transition: all 0.3s;
        }
        .search-input-group input:focus {
            border-color: var(--primary-color);
            outline: none;
            box-shadow: 0 0 0 3px rgba(13,110,253,0.1);
        }
        .search-input-group button {
            padding: 12px 25px;
            background: var(--primary-color);
            color: white;
            border: none;
            border-radius: 12px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
        }
        .search-input-group button:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(13,110,253,0.3);
        }

        /* Stats Cards */
        .stats-row {
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
            display: flex;
            align-items: center;
            gap: 15px;
            transition: all 0.3s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(13,110,253,0.15);
        }
        .stat-icon {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .stat-icon i {
            font-size: 24px;
            color: white;
        }
        .stat-info h3 {
            font-size: 1.8rem;
            font-weight: 700;
            color: var(--dark-color);
            margin: 0;
            line-height: 1.2;
        }
        .stat-info p {
            color: var(--secondary-color);
            margin: 5px 0 0;
            font-size: 0.85rem;
        }

        /* Action Bar */
        .action-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .action-bar-left {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        .view-toggle {
            display: flex;
            gap: 5px;
            background: white;
            padding: 5px;
            border-radius: 10px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }
        .view-toggle button {
            padding: 8px 12px;
            border: none;
            background: none;
            border-radius: 8px;
            cursor: pointer;
            color: var(--secondary-color);
            transition: all 0.3s;
        }
        .view-toggle button.active {
            background: var(--primary-color);
            color: white;
        }
        .btn-add {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 12px;
            font-weight: 500;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s;
        }
        .btn-add:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(13,110,253,0.3);
            color: white;
        }

        /* Guest Grid */
        .guest-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 25px;
        }
        .guest-card {
            background: white;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            transition: all 0.3s;
            position: relative;
            border: 1px solid rgba(13,110,253,0.1);
        }
        .guest-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(13,110,253,0.15);
            border-color: var(--primary-color);
        }
        .guest-card.vip {
            border-left: 4px solid #ffc107;
            background: linear-gradient(to right, white, #fff9e6);
        }
        .guest-avatar {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 15px;
        }
        .guest-name {
            font-size: 1.2rem;
            font-weight: 600;
            color: var(--dark-color);
            margin-bottom: 5px;
        }
        .guest-number {
            font-size: 0.8rem;
            color: var(--primary-color);
            background: var(--primary-light);
            display: inline-block;
            padding: 3px 10px;
            border-radius: 20px;
            margin-bottom: 10px;
        }
        .guest-detail {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 8px;
            color: var(--secondary-color);
            font-size: 0.9rem;
        }
        .guest-detail i {
            width: 20px;
            color: var(--primary-color);
        }
        .guest-actions {
            display: flex;
            gap: 10px;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #e9ecef;
        }
        .guest-actions a {
            flex: 1;
            padding: 8px;
            border-radius: 8px;
            text-decoration: none;
            text-align: center;
            font-size: 0.85rem;
            transition: all 0.3s;
        }
        .btn-view {
            background: var(--primary-light);
            color: var(--primary-color);
        }
        .btn-view:hover {
            background: var(--primary-color);
            color: white;
        }
        .btn-edit {
            background: #e9ecef;
            color: var(--secondary-color);
        }
        .btn-edit:hover {
            background: var(--secondary-color);
            color: white;
        }

        /* Guest Table (List View) */
        .guest-table {
            background: white;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            margin-bottom: 25px;
            display: none;
        }
        .guest-table.show {
            display: block;
        }
        .guest-table table {
            width: 100%;
            border-collapse: collapse;
        }
        .guest-table th {
            background: #f8f9fa;
            padding: 15px;
            text-align: left;
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--secondary-color);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .guest-table td {
            padding: 15px;
            border-bottom: 1px solid #e9ecef;
        }
        .guest-table tr:hover {
            background: #f8f9fa;
        }
        .guest-table .vip-badge {
            background: #ffc107;
            color: #856404;
            padding: 3px 8px;
            border-radius: 20px;
            font-size: 0.7rem;
            font-weight: 600;
        }

        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            gap: 5px;
            margin-top: 25px;
        }
        .page-link {
            padding: 8px 15px;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            color: var(--primary-color);
            text-decoration: none;
            transition: all 0.3s;
        }
        .page-link:hover,
        .page-link.active {
            background: var(--primary-color);
            color: white;
            border-color: var(--primary-color);
        }

        @media (max-width: 1200px) {
            .stats-row {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-100%);
            }
            .main-content {
                margin-left: 0;
                padding: 15px;
            }
            .stats-row {
                grid-template-columns: 1fr;
            }
            .action-bar {
                flex-direction: column;
                gap: 15px;
            }
            .guest-grid {
                grid-template-columns: 1fr;
            }
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
    String basePath = "/staff";
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
            <p><i class="fas fa-users me-1"></i>Manage guest profiles and view stay history</p>
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

    <!-- Messages -->
    <% if (session.getAttribute("success") != null) { %>
    <div class="alert-custom alert-success-custom">
        <i class="fas fa-check-circle"></i>
        <%= session.getAttribute("success") %>
        <% session.removeAttribute("success"); %>
    </div>
    <% } %>
    <% if (session.getAttribute("error") != null) { %>
    <div class="alert-custom alert-error-custom">
        <i class="fas fa-exclamation-circle"></i>
        <%= session.getAttribute("error") %>
        <% session.removeAttribute("error"); %>
    </div>
    <% } %>

    <!-- Search Section -->
    <div class="search-section">
        <div class="search-title">
            <i class="fas fa-search"></i>
            <span>Find Guests</span>
        </div>
        <form action="${pageContext.request.contextPath}<%= basePath %>/guests" method="get" class="search-input-group">
            <input type="text" name="search" placeholder="Search by name, email, phone, or guest number..."
                   value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
            <button type="submit">
                <i class="fas fa-search me-2"></i>Search
            </button>
        </form>
        <% if (request.getParameter("search") != null && !request.getParameter("search").isEmpty()) { %>
        <div style="margin-top: 10px; color: var(--secondary-color);">
            <i class="fas fa-info-circle me-1"></i>
            Found <strong><%= request.getAttribute("totalCount") %></strong> guest(s) matching "<%= request.getParameter("search") %>"
            <a href="${pageContext.request.contextPath}<%= basePath %>/guests" class="ms-2" style="color: var(--primary-color);">Clear search</a>
        </div>
        <% } %>
    </div>

    <!-- Stats Row -->
    <div class="stats-row">
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-users"></i></div>
            <div class="stat-info">
                <h3><%= request.getAttribute("totalCount") %></h3>
                <p>Total Guests</p>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: linear-gradient(135deg,#198754,#146c43);"><i class="fas fa-crown"></i></div>
            <div class="stat-info">
                <h3>
                    <%
                        int vipCount = 0;
                        List<GuestDTO> guests = (List<GuestDTO>) request.getAttribute("guests");
                        if (guests != null) {
                            vipCount = (int) guests.stream().filter(g -> g.getIsVip() != null && g.getIsVip()).count();
                        }
                    %>
                    <%= vipCount %>
                </h3>
                <p>VIP Guests</p>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: linear-gradient(135deg,#ffc107,#e0a800);"><i class="fas fa-star"></i></div>
            <div class="stat-info">
                <h3>
                    <%
                        int loyaltySum = 0;
                        if (guests != null) {
                            loyaltySum = guests.stream().mapToInt(g -> g.getLoyaltyPoints() != null ? g.getLoyaltyPoints() : 0).sum();
                        }
                    %>
                    <%= loyaltySum %>
                </h3>
                <p>Loyalty Points</p>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: linear-gradient(135deg,#0dcaf0,#0aa2c0);"><i class="fas fa-calendar-check"></i></div>
            <div class="stat-info">
                <h3><%= new java.text.SimpleDateFormat("yyyy").format(new java.util.Date()) %></h3>
                <p>Year</p>
            </div>
        </div>
    </div>

    <!-- Action Bar -->
    <div class="action-bar">
        <div class="action-bar-left">
            <div class="view-toggle">
                <button class="active" onclick="toggleView('grid')" id="gridViewBtn">
                    <i class="fas fa-th-large"></i>
                </button>
                <button onclick="toggleView('list')" id="listViewBtn">
                    <i class="fas fa-list"></i>
                </button>
            </div>
            <span style="color: var(--secondary-color);">
                Showing <%= guests != null ? guests.size() : 0 %> guests
            </span>
        </div>
        <a href="${pageContext.request.contextPath}<%= basePath %>/guests/new" class="btn-add">
            <i class="fas fa-user-plus"></i> Add New Guest
        </a>
    </div>

    <!-- Guest Grid View -->
    <div class="guest-grid" id="gridView">
        <% if (guests == null || guests.isEmpty()) { %>
        <div style="grid-column: 1/-1; text-align: center; padding: 60px 20px; background: white; border-radius: 16px;">
            <i class="fas fa-users fa-4x" style="color: #dee2e6; margin-bottom: 20px;"></i>
            <h4 style="color: #6c757d;">No guests found</h4>
            <p style="color: #adb5bd; margin-bottom: 20px;">
                <% if (request.getParameter("search") != null) { %>
                Try a different search term or <a href="${pageContext.request.contextPath}<%= basePath %>/guests">view all guests</a>
                <% } else { %>
                Start by adding your first guest
                <% } %>
            </p>
            <% if (request.getParameter("search") == null) { %>
            <a href="${pageContext.request.contextPath}<%= basePath %>/guests/new" class="btn-add" style="display: inline-flex;">
                <i class="fas fa-user-plus"></i> Add New Guest
            </a>
            <% } %>
        </div>
        <% } else {
            for (GuestDTO guest : guests) {
                String initials = "";
                if (guest.getFirstName() != null && guest.getLastName() != null) {
                    initials = String.valueOf(guest.getFirstName().charAt(0)) +
                            String.valueOf(guest.getLastName().charAt(0));
                } else {
                    initials = guest.getFullName().substring(0, Math.min(2, guest.getFullName().length())).toUpperCase();
                }
                boolean isVip = guest.getIsVip() != null && guest.getIsVip();
        %>
        <div class="guest-card <%= isVip ? "vip" : "" %>">
            <div class="guest-avatar"><%= initials %></div>
            <div class="guest-name">
                <%= guest.getFullName() %>
                <% if (isVip) { %>
                <i class="fas fa-crown" style="color: #ffc107; font-size: 1rem; margin-left: 5px;"></i>
                <% } %>
            </div>
            <div class="guest-number">#<%= guest.getGuestNumber() %></div>

            <div class="guest-detail">
                <i class="fas fa-envelope"></i>
                <span><%= guest.getEmail() != null && !guest.getEmail().isEmpty() ? guest.getEmail() : "No email" %></span>
            </div>
            <div class="guest-detail">
                <i class="fas fa-phone"></i>
                <span><%= guest.getPhone() != null && !guest.getPhone().isEmpty() ? guest.getPhone() : "No phone" %></span>
            </div>
            <% if (guest.getCity() != null && !guest.getCity().isEmpty()) { %>
            <div class="guest-detail">
                <i class="fas fa-map-marker-alt"></i>
                <span><%= guest.getCity() %><%= guest.getCountry() != null ? ", " + guest.getCountry() : "" %></span>
            </div>
            <% } %>
            <% if (guest.getLoyaltyPoints() != null && guest.getLoyaltyPoints() > 0) { %>
            <div class="guest-detail">
                <i class="fas fa-star"></i>
                <span><%= guest.getLoyaltyPoints() %> points</span>
            </div>
            <% } %>

            <div class="guest-actions">
                <a href="${pageContext.request.contextPath}<%= basePath %>/guests/view?id=<%= guest.getId() %>" class="btn-view">
                    <i class="fas fa-eye me-1"></i>View
                </a>
                <a href="${pageContext.request.contextPath}<%= basePath %>/guests/edit?id=<%= guest.getId() %>" class="btn-edit">
                    <i class="fas fa-edit me-1"></i>Edit
                </a>
            </div>
        </div>
        <% } } %>
    </div>

    <!-- Guest Table View -->
    <div class="guest-table" id="listView">
        <table>
            <thead>
            <tr>
                <th>Guest #</th>
                <th>Name</th>
                <th>Email</th>
                <th>Phone</th>
                <th>Location</th>
                <th>Status</th>
                <th>Points</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <% if (guests != null && !guests.isEmpty()) {
                for (GuestDTO guest : guests) {
                    boolean isVip = guest.getIsVip() != null && guest.getIsVip();
            %>
            <tr>
                <td><strong><%= guest.getGuestNumber() %></strong></td>
                <td>
                    <%= guest.getFullName() %>
                    <% if (isVip) { %>
                    <span class="vip-badge">VIP</span>
                    <% } %>
                </td>
                <td><%= guest.getEmail() != null ? guest.getEmail() : "-" %></td>
                <td><%= guest.getPhone() != null ? guest.getPhone() : "-" %></td>
                <td>
                    <% if (guest.getCity() != null) { %>
                    <%= guest.getCity() %><%= guest.getCountry() != null ? ", " + guest.getCountry() : "" %>
                    <% } else { %>
                    -
                    <% } %>
                </td>
                <td>
                    <% if (isVip) { %>
                    <span class="badge bg-warning text-dark">VIP</span>
                    <% } else { %>
                    <span class="badge bg-secondary">Regular</span>
                    <% } %>
                </td>
                <td><%= guest.getLoyaltyPoints() != null ? guest.getLoyaltyPoints() : 0 %></td>
                <td>
                    <a href="${pageContext.request.contextPath}<%= basePath %>/guests/view?id=<%= guest.getId() %>"
                       class="btn btn-sm btn-outline-primary" title="View">
                        <i class="fas fa-eye"></i>
                    </a>
                    <a href="${pageContext.request.contextPath}<%= basePath %>/guests/edit?id=<%= guest.getId() %>"
                       class="btn btn-sm btn-outline-secondary" title="Edit">
                        <i class="fas fa-edit"></i>
                    </a>
                </td>
            </tr>
            <% } } %>
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <% if (request.getAttribute("totalPages") != null) {
        int currentPage = (Integer) request.getAttribute("currentPage");
        int totalPages = (Integer) request.getAttribute("totalPages");
        if (totalPages > 1) {
    %>
    <div class="pagination">
        <% for (int i = 1; i <= totalPages; i++) { %>
        <a href="${pageContext.request.contextPath}<%= basePath %>/guests?page=<%= i %>"
           class="page-link <%= i == currentPage ? "active" : "" %>">
            <%= i %>
        </a>
        <% } %>
    </div>
    <% } } %>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function toggleView(view) {
        const gridView = document.getElementById('gridView');
        const listView = document.getElementById('listView');
        const gridBtn = document.getElementById('gridViewBtn');
        const listBtn = document.getElementById('listViewBtn');

        if (view === 'grid') {
            gridView.style.display = 'grid';
            listView.classList.remove('show');
            gridBtn.classList.add('active');
            listBtn.classList.remove('active');
        } else {
            gridView.style.display = 'none';
            listView.classList.add('show');
            listBtn.classList.add('active');
            gridBtn.classList.remove('active');
        }

        // Save preference
        localStorage.setItem('guestViewPreference', view);
    }

    // Load saved preference
    document.addEventListener('DOMContentLoaded', function() {
        const savedView = localStorage.getItem('guestViewPreference') || 'grid';
        toggleView(savedView);
    });
</script>
</body>
</html>