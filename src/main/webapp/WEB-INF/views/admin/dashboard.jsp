<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard - Ocean View Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body { font-family: 'Poppins', sans-serif; background: #f4f6f9; }
        .sidebar {
            position: fixed; top: 0; left: 0; height: 100vh; width: 250px;
            background: linear-gradient(135deg, #dc3545, #c0392b);
            color: white; padding: 20px 0; z-index: 1000;
        }
        .sidebar-brand { padding: 0 20px 20px; border-bottom: 1px solid rgba(255,255,255,0.2); margin-bottom: 20px; }
        .sidebar-menu { list-style: none; padding: 0; margin: 0; }
        .sidebar-menu a {
            display: flex; align-items: center; padding: 12px 20px;
            color: rgba(255,255,255,0.8); text-decoration: none;
            transition: all 0.3s; border-left: 3px solid transparent;
        }
        .sidebar-menu a:hover, .sidebar-menu a.active {
            background: rgba(255,255,255,0.1); color: white; border-left-color: white;
        }
        .sidebar-menu a i { width: 30px; }
        .main-content { margin-left: 250px; padding: 30px; }
        .top-nav {
            background: white; border-radius: 15px; padding: 15px 25px;
            margin-bottom: 25px; box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            display: flex; justify-content: space-between; align-items: center;
        }
        .stat-card {
            background: white; border-radius: 15px; padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            display: flex; align-items: center; justify-content: space-between;
        }
        .stat-icon {
            width: 60px; height: 60px; border-radius: 12px;
            background: linear-gradient(135deg, #dc3545, #c0392b);
            display: flex; align-items: center; justify-content: center;
        }
        .stat-icon i { font-size: 28px; color: white; }
        .stat-info h3 { font-size: 2rem; font-weight: 700; margin-bottom: 5px; }
        .stat-info p { color: #6c757d; margin: 0; }
    </style>
</head>
<body>
<div class="sidebar">
    <div class="sidebar-brand">
        <h3 style="font-size:1.4rem; font-weight:600; margin:0;">Ocean View</h3>
        <p style="font-size:0.8rem; opacity:0.8; margin:5px 0 0;">Admin Panel</p>
    </div>
    <ul class="sidebar-menu">
        <li><a href="#" class="active"><i class="fas fa-dashboard"></i><span>Dashboard</span></a></li>
        <li><a href="#"><i class="fas fa-users"></i><span>Manage Staff</span></a></li>
        <li><a href="#"><i class="fas fa-list-alt"></i><span>All Reservations</span></a></li>
        <li><a href="#"><i class="fas fa-door-open"></i><span>Rooms</span></a></li>
        <li><a href="#"><i class="fas fa-chart-bar"></i><span>Reports</span></a></li>
        <li><a href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
    </ul>
</div>

<div class="main-content">
    <div class="top-nav">
        <div>
            <h2 style="font-size:1.5rem; font-weight:600; margin:0;">Admin Dashboard</h2>
            <p style="color:#6c757d; margin:5px 0 0; font-size:0.9rem;">Welcome, <%= user.getFullName() %></p>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-danger btn-sm">
            <i class="fas fa-sign-out-alt me-1"></i>Logout
        </a>
    </div>

    <div class="alert" style="background:linear-gradient(135deg,#dc3545,#c0392b);color:white;border:none;border-radius:15px;padding:20px 30px;margin-bottom:30px;">
        <h4 style="font-weight:600;margin-bottom:8px;">Welcome back, <%= user.getFirstName() %>! 👋</h4>
        <p style="margin:0;opacity:0.9;">You are logged in as Administrator. Full system access granted.</p>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-info"><h3>42</h3><p>Total Reservations</p></div>
                <div class="stat-icon"><i class="fas fa-calendar-check"></i></div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-info"><h3>8</h3><p>Staff Members</p></div>
                <div class="stat-icon"><i class="fas fa-users"></i></div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-info"><h3>20</h3><p>Total Rooms</p></div>
                <div class="stat-icon"><i class="fas fa-door-open"></i></div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-info"><h3>85%</h3><p>Occupancy Rate</p></div>
                <div class="stat-icon"><i class="fas fa-chart-pie"></i></div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>