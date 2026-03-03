<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    User staff = (User) request.getAttribute("staff");
    if (staff == null) {
        response.sendRedirect(request.getContextPath() + "/admin/manage-staff");
        return;
    }

    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Staff - Ocean View Hotel</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Font Awesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
        :root {
            --primary-color: #0d6efd;
            --sidebar-width: 280px;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: #f4f6f9;
        }

        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            width: var(--sidebar-width);
            background: linear-gradient(180deg, #0a58ca 0%, #0d6efd 100%);
            color: white;
            z-index: 1000;
        }

        .sidebar-brand {
            padding: 25px 25px;
            border-bottom: 2px solid rgba(255,255,255,0.15);
        }

        .sidebar-brand h3 {
            font-size: 1.8rem;
            font-weight: 700;
        }

        .sidebar-menu {
            list-style: none;
            padding: 0 15px;
            margin-top: 20px;
        }

        .sidebar-menu a {
            display: flex;
            align-items: center;
            padding: 12px 20px;
            color: rgba(255,255,255,0.85);
            text-decoration: none;
            border-radius: 12px;
            margin-bottom: 8px;
        }

        .sidebar-menu a:hover,
        .sidebar-menu a.active {
            background: rgba(255,255,255,0.15);
            color: white;
        }

        .sidebar-menu a i {
            width: 30px;
        }

        .main-content {
            margin-left: var(--sidebar-width);
            padding: 25px 35px;
        }

        .top-nav {
            background: white;
            border-radius: 20px;
            padding: 15px 30px;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(13, 110, 253, 0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .page-title h2 {
            font-size: 1.8rem;
            font-weight: 600;
            color: var(--primary-color);
            margin: 0;
        }

        .profile-card {
            background: white;
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(13, 110, 253, 0.1);
        }

        .profile-header {
            display: flex;
            align-items: center;
            gap: 30px;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #e9ecef;
        }

        .profile-avatar {
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, #0d6efd, #0a58ca);
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2.5rem;
            font-weight: 600;
            box-shadow: 0 10px 20px rgba(13, 110, 253, 0.3);
        }

        .profile-title h3 {
            font-size: 2rem;
            font-weight: 600;
            margin-bottom: 5px;
        }

        .profile-title p {
            color: #6c757d;
            margin: 0;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }

        .info-item {
            padding: 15px;
            background: #f8f9fa;
            border-radius: 12px;
        }

        .info-label {
            font-size: 0.85rem;
            color: #6c757d;
            margin-bottom: 5px;
        }

        .info-value {
            font-size: 1.1rem;
            font-weight: 500;
            color: #212529;
        }

        .badge-status {
            padding: 5px 12px;
            border-radius: 50px;
            font-size: 0.85rem;
            font-weight: 500;
            display: inline-block;
        }

        .badge-active {
            background: #d4edda;
            color: #155724;
        }

        .badge-inactive {
            background: #f8d7da;
            color: #721c24;
        }

        .badge-admin {
            background: #cce5ff;
            color: #004085;
        }

        .badge-staff {
            background: #e2e3e5;
            color: #383d41;
        }

        .btn-action {
            padding: 10px 25px;
            border-radius: 12px;
            font-weight: 500;
        }

        @media (max-width: 992px) {
            .sidebar {
                transform: translateX(-100%);
            }
            .main-content {
                margin-left: 0;
            }
        }
    </style>
</head>
<body>

<!-- Sidebar -->
<div class="sidebar">
    <div class="sidebar-brand">
        <h3>Ocean View</h3>
        <p>Hotel Reservation System</p>
    </div>
    <ul class="sidebar-menu">
        <li><a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fas fa-chart-pie"></i><span>Dashboard</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/manage-staff" class="active"><i class="fas fa-users-cog"></i><span>Manage Staff</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/manage-rooms"><i class="fas fa-door-open"></i><span>Manage Rooms</span></a></li>
        <li><a href="#"><i class="fas fa-calendar-alt"></i><span>All Reservations</span></a></li>
        <li><a href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
    </ul>
</div>

<!-- Main Content -->
<div class="main-content">
    <!-- Top Navigation -->
    <div class="top-nav">
        <div class="page-title">
            <h2>Staff Profile</h2>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/admin/manage-staff" class="btn btn-outline-secondary">
                <i class="fas fa-arrow-left me-2"></i>Back to List
            </a>
        </div>
    </div>

    <!-- Profile Card -->
    <div class="profile-card">
        <div class="profile-header">
            <div class="profile-avatar">
                <%= staff.getFirstName().charAt(0) %><%= staff.getLastName().charAt(0) %>
            </div>
            <div class="profile-title">
                <h3><%= staff.getFullName() %></h3>
                <p>
                    <span class="badge-status <%= staff.isAdmin() ? "badge-admin" : "badge-staff" %> me-2">
                        <%= staff.getRole() %>
                    </span>
                    <span class="badge-status <%= staff.isActive() ? "badge-active" : "badge-inactive" %>">
                        <%= staff.isActive() ? "Active" : "Inactive" %>
                    </span>
                </p>
            </div>
        </div>

        <div class="info-grid">
            <div class="info-item">
                <div class="info-label"><i class="fas fa-user me-2"></i>Username</div>
                <div class="info-value"><%= staff.getUsername() %></div>
            </div>

            <div class="info-item">
                <div class="info-label"><i class="fas fa-envelope me-2"></i>Email</div>
                <div class="info-value"><%= staff.getEmail() %></div>
            </div>

            <div class="info-item">
                <div class="info-label"><i class="fas fa-phone me-2"></i>Phone</div>
                <div class="info-value"><%= staff.getPhone() != null ? staff.getPhone() : "Not provided" %></div>
            </div>

            <div class="info-item">
                <div class="info-label"><i class="fas fa-calendar me-2"></i>Created At</div>
                <div class="info-value"><%= staff.getCreatedAt() != null ? staff.getCreatedAt().format(dateFormatter) : "N/A" %></div>
            </div>

            <div class="info-item">
                <div class="info-label"><i class="fas fa-clock me-2"></i>Last Login</div>
                <div class="info-value"><%= staff.getLastLogin() != null ? staff.getLastLogin().format(dateFormatter) : "Never" %></div>
            </div>

            <div class="info-item">
                <div class="info-label"><i class="fas fa-id-card me-2"></i>User ID</div>
                <div class="info-value">#<%= staff.getId() %></div>
            </div>
        </div>

        <%-- Replace the existing action buttons div at the bottom of the profile-card with: --%>
        <div class="mt-4 d-flex flex-wrap gap-2 justify-content-end">
            <a href="${pageContext.request.contextPath}/admin/manage-staff?action=edit&id=<%= staff.getId() %>"
               class="btn btn-primary" style="border-radius:12px; padding:10px 24px;">
                <i class="fas fa-edit me-2"></i>Edit Profile
            </a>
            <a href="${pageContext.request.contextPath}/admin/manage-staff?action=resetpw&id=<%= staff.getId() %>"
               class="btn" style="background:#7c3aed; color:white; border-radius:12px; padding:10px 24px; font-weight:500; box-shadow:0 4px 12px rgba(124,58,237,.3);">
                <i class="fas fa-key me-2"></i>Reset Password
            </a>
            <% if (staff.isActive()) { %>
            <a href="${pageContext.request.contextPath}/admin/manage-staff?action=toggle&id=<%= staff.getId() %>&toggle=deactivate"
               class="btn btn-warning" style="border-radius:12px; padding:10px 24px;"
               onclick="return confirm('Deactivate this staff member?')">
                <i class="fas fa-ban me-2"></i>Deactivate
            </a>
            <% } else { %>
            <a href="${pageContext.request.contextPath}/admin/manage-staff?action=toggle&id=<%= staff.getId() %>&toggle=activate"
               class="btn btn-success" style="border-radius:12px; padding:10px 24px;"
               onclick="return confirm('Activate this staff member?')">
                <i class="fas fa-check-circle me-2"></i>Activate
            </a>
            <% } %>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>