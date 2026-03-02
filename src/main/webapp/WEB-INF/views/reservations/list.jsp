<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
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
            --sidebar-width: 280px;
        }
        body { font-family: 'Poppins', sans-serif; background: #f4f6f9; overflow-x: hidden; }
        .sidebar {
            position: fixed; top: 0; left: 0; height: 100vh; width: var(--sidebar-width);
            background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%);
            color: white; padding: 20px 0; z-index: 1000;
        }
        .sidebar-brand { padding: 0 20px 20px; border-bottom: 1px solid rgba(255,255,255,0.2); margin-bottom: 20px; }
        .sidebar-brand h3 { font-size: 1.5rem; font-weight: 600; margin: 0; }
        .sidebar-menu { list-style: none; padding: 0 15px; }
        .sidebar-menu a {
            display: flex; align-items: center; padding: 12px 20px;
            color: rgba(255,255,255,0.8); text-decoration: none; border-radius: 10px;
        }
        .sidebar-menu a:hover, .sidebar-menu a.active { background: rgba(255,255,255,0.15); color: white; }
        .sidebar-menu a i { width: 30px; font-size: 1.2rem; }
        .main-content { margin-left: var(--sidebar-width); padding: 20px 30px; }
        .top-nav {
            background: white; border-radius: 15px; padding: 15px 25px;
            margin-bottom: 25px; box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            display: flex; justify-content: space-between; align-items: center;
        }
        .page-title h2 { font-size: 1.5rem; font-weight: 600; color: #212529; margin: 0; }
        .user-avatar {
            width: 40px; height: 40px; background: linear-gradient(135deg, #0d6efd, #0b5ed7);
            border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white;
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
        .badge-paid { background: #d4edda; color: #155724; }
        @media (max-width: 768px) { .sidebar { transform: translateX(-100%); } .main-content { margin-left: 0; } }
    </style>
</head>
<body>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    boolean isAdmin = user.isAdmin();
    String basePath = isAdmin ? "/admin" : "/staff";

    List<ReservationDTO> reservations = (List<ReservationDTO>) request.getAttribute("reservations");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Long totalCount = (Long) request.getAttribute("totalCount");

    currentPage = currentPage != null ? currentPage : 1;
    totalPages = totalPages != null ? totalPages : 1;
    totalCount = totalCount != null ? totalCount : 0;
%>

<div class="sidebar">
    <div class="sidebar-brand">
        <h3><i class="fas fa-hotel me-2"></i>Ocean View</h3>
    </div>
    <ul class="sidebar-menu">
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/dashboard"><i class="fas fa-chart-pie"></i>Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations" class="active"><i class="fas fa-calendar-alt"></i>Reservations</a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations/new"><i class="fas fa-plus-circle"></i>New Reservation</a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/guests"><i class="fas fa-users"></i>Guests</a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/rooms"><i class="fas fa-door-open"></i>Rooms</a></li>
        <li><a href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i>Logout</a></li>
    </ul>
</div>

<div class="main-content">
    <div class="top-nav">
        <div class="page-title"><h2>${pageTitle}</h2></div>
        <div class="d-flex align-items-center gap-3">
            <div class="user-avatar"><%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %></div>
            <div><div style="font-weight:600;"><%= user.getFullName() %></div><div style="font-size:.75rem;"><%= user.getRole() %></div></div>
        </div>
    </div>

    <% if (session.getAttribute("success") != null) { %>
    <div class="alert alert-success alert-dismissible fade show"><i class="fas fa-check-circle me-2"></i><%= session.getAttribute("success") %><button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
    <% session.removeAttribute("success"); %>
    <% } %>
    <% if (session.getAttribute("error") != null) { %>
    <div class="alert alert-danger alert-dismissible fade show"><i class="fas fa-exclamation-circle me-2"></i><%= session.getAttribute("error") %><button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
    <% session.removeAttribute("error"); %>
    <% } %>

    <div class="table-card">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <span>Total Reservations: <strong><%= totalCount %></strong></span>
            <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/new" class="btn btn-primary"><i class="fas fa-plus me-2"></i>New Reservation</a>
        </div>
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                <tr>
                    <th>Reservation #</th>
                    <th>Guest</th>
                    <th>Rooms</th>
                    <th>Check-in</th>
                    <th>Check-out</th>
                    <th>Status</th>
                    <th>Payment</th>
                    <th>Total</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <% if (reservations == null || reservations.isEmpty()) { %>
                <tr><td colspan="9" class="text-center py-4 text-muted">No reservations found.</td></tr>
                <% } else { for (ReservationDTO r : reservations) {
                    String status = r.getReservationStatus();
                    String badgeClass = "badge-pending";
                    if ("CONFIRMED".equals(status)) badgeClass = "badge-confirmed";
                    else if ("CHECKED_IN".equals(status)) badgeClass = "badge-checked-in";
                    else if ("CHECKED_OUT".equals(status)) badgeClass = "badge-checked-out";
                    else if ("CANCELLED".equals(status)) badgeClass = "badge-cancelled";

                    String pStatus = r.getPaymentStatus();
                    String pBadge = "PAID".equals(pStatus) ? "badge-paid" : "badge-pending";
                %>
                <tr>
                    <td><strong><%= r.getReservationNumber() %></strong></td>
                    <td><%= r.getGuestName() != null ? r.getGuestName() : "-" %></td>
                    <td><%= r.getRoomNumbersSummary() %></td>
                    <td><%= r.getFormattedCheckInDate() %></td>
                    <td><%= r.getFormattedCheckOutDate() %></td>
                    <td><span class="badge-status <%= badgeClass %>"><%= status != null ? status.replace("_"," ") : "PENDING" %></span></td>
                    <td><span class="badge-status <%= pBadge %>"><%= pStatus != null ? pStatus : "PENDING" %></span></td>
                    <td>$<fmt:formatNumber value="<%= r.getTotalAmount() %>" pattern="#,##0.00"/></td>
                    <td>
                        <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/view?id=<%= r.getId() %>" class="btn btn-sm btn-outline-primary"><i class="fas fa-eye"></i></a>
                        <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/edit?id=<%= r.getId() %>" class="btn btn-sm btn-outline-secondary"><i class="fas fa-edit"></i></a>
                    </td>
                </tr>
                <% } } %>
                </tbody>
            </table>
        </div>

        <% if (totalPages > 1) { %>
        <nav class="mt-3">
            <ul class="pagination justify-content-center">
                <li class="page-item <%= currentPage == 1 ? "disabled" : "" %>">
                    <a class="page-link" href="?page=<%= currentPage-1 %>">Previous</a>
                </li>
                <% for(int i=1; i<=totalPages; i++) { %>
                <li class="page-item <%= currentPage == i ? "active" : "" %>">
                    <a class="page-link" href="?page=<%= i %>"><%= i %></a>
                </li>
                <% } %>
                <li class="page-item <%= currentPage == totalPages ? "disabled" : "" %>">
                    <a class="page-link" href="?page=<%= currentPage+1 %>">Next</a>
                </li>
            </ul>
        </nav>
        <% } %>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>