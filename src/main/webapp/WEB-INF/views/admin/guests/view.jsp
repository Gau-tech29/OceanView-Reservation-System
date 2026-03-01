<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guest Details - Ocean View Hotel</title>
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
            color: rgba(255,255,255,0.8); text-decoration: none;
            transition: all 0.3s; border-radius: 10px;
        }
        .sidebar-menu a:hover, .sidebar-menu a.active {
            background: rgba(255,255,255,0.15); color: white; transform: translateX(5px);
        }
        .sidebar-menu a i { width: 30px; font-size: 1.2rem; }

        .main-content { margin-left: var(--sidebar-width); padding: 20px 30px; }
        .top-nav {
            background: white; border-radius: 15px; padding: 15px 25px;
            margin-bottom: 25px; box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            display: flex; justify-content: space-between; align-items: center;
        }
        .page-title h2 { font-size: 1.5rem; font-weight: 600; color: #212529; margin: 0; }
        .user-avatar {
            width: 40px; height: 40px; background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%);
            border-radius: 50%; display: flex; align-items: center; justify-content: center;
            color: white; font-weight: 600;
        }

        .detail-card {
            background: white; border-radius: 15px; padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        .guest-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 25px; padding-bottom: 20px; border-bottom: 2px solid #f0f0f0;
        }
        .guest-number {
            font-size: 1.5rem; font-weight: 700; color: var(--primary-color);
        }
        .guest-number small {
            font-size: 0.9rem; color: #6c757d; font-weight: normal;
        }
        .vip-badge {
            background: #ffc107; color: #212529; padding: 8px 20px;
            border-radius: 30px; font-weight: 600;
        }
        .info-section { margin-bottom: 30px; }
        .info-section h5 {
            font-size: 1.1rem; font-weight: 600; color: #212529;
            margin-bottom: 15px; padding-bottom: 10px; border-bottom: 2px solid #f0f0f0;
        }
        .info-grid {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px;
        }
        .info-item {
            background: #f8f9fa; border-radius: 10px; padding: 15px;
        }
        .info-item .label {
            font-size: 0.85rem; color: #6c757d; margin-bottom: 5px;
        }
        .info-item .value {
            font-size: 1.1rem; font-weight: 600; color: #212529;
        }
        .action-buttons {
            display: flex; gap: 10px; margin-top: 25px; padding-top: 20px;
            border-top: 2px solid #f0f0f0;
        }
        .btn-action { padding: 10px 20px; border-radius: 10px; font-weight: 500; transition: all 0.3s; }
        .btn-action:hover { transform: translateY(-2px); }
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
        <li><a href="${pageContext.request.contextPath}/admin/reservations"><i class="fas fa-calendar-alt"></i><span>Reservations</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/guests" class="active"><i class="fas fa-users"></i><span>Guests</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/manage-rooms"><i class="fas fa-door-open"></i><span>Rooms</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/reports"><i class="fas fa-chart-bar"></i><span>Reports</span></a></li>
        <li><a href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
    </ul>
</div>

<!-- Main Content -->
<div class="main-content">
    <!-- Top Navigation -->
    <div class="top-nav">
        <div class="page-title">
            <h2>Guest Details</h2>
        </div>
        <div class="user-avatar">
            <%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %>
        </div>
    </div>

    <!-- Detail Card -->
    <div class="detail-card">
        <!-- Header -->
        <div class="guest-header">
            <div>
                <div class="guest-number">
                    ${guest.guestNumber}
                    <small>Member since: <fmt:formatDate value="${guest.createdAt}" pattern="dd MMM yyyy"/></small>
                </div>
            </div>
            <c:if test="${guest.isVip}">
                <span class="vip-badge"><i class="fas fa-crown me-2"></i>VIP Guest</span>
            </c:if>
        </div>

        <!-- Personal Information -->
        <div class="info-section">
            <h5><i class="fas fa-user me-2"></i>Personal Information</h5>
            <div class="info-grid">
                <div class="info-item">
                    <div class="label">Full Name</div>
                    <div class="value">${guest.fullName}</div>
                </div>
                <div class="info-item">
                    <div class="label">Email</div>
                    <div class="value">${guest.email}</div>
                </div>
                <div class="info-item">
                    <div class="label">Phone</div>
                    <div class="value">${guest.phone}</div>
                </div>
            </div>
        </div>

        <!-- Address Information -->
        <div class="info-section">
            <h5><i class="fas fa-map-marker-alt me-2"></i>Address</h5>
            <div class="info-grid">
                <div class="info-item">
                    <div class="label">Address</div>
                    <div class="value">${guest.address}</div>
                </div>
                <div class="info-item">
                    <div class="label">City</div>
                    <div class="value">${guest.city}</div>
                </div>
                <div class="info-item">
                    <div class="label">Country</div>
                    <div class="value">${guest.country}</div>
                </div>
                <div class="info-item">
                    <div class="label">Postal Code</div>
                    <div class="value">${guest.postalCode}</div>
                </div>
            </div>
        </div>

        <!-- Identification -->
        <div class="info-section">
            <h5><i class="fas fa-id-card me-2"></i>Identification</h5>
            <div class="info-grid">
                <div class="info-item">
                    <div class="label">ID Type</div>
                    <div class="value">${guest.idCardType}</div>
                </div>
                <div class="info-item">
                    <div class="label">ID Number</div>
                    <div class="value">${guest.idCardNumber}</div>
                </div>
            </div>
        </div>

        <!-- Loyalty Information -->
        <div class="info-section">
            <h5><i class="fas fa-star me-2"></i>Loyalty Information</h5>
            <div class="info-grid">
                <div class="info-item">
                    <div class="label">Loyalty Points</div>
                    <div class="value">${guest.loyaltyPoints}</div>
                </div>
                <div class="info-item">
                    <div class="label">Total Stays</div>
                    <div class="value">${guest.totalStays}</div>
                </div>
                <div class="info-item">
                    <div class="label">Last Stay</div>
                    <div class="value"><fmt:formatDate value="${guest.lastStay}" pattern="dd MMM yyyy"/></div>
                </div>
            </div>
        </div>

        <!-- Notes -->
        <c:if test="${not empty guest.notes}">
            <div class="info-section">
                <h5><i class="fas fa-comment me-2"></i>Notes</h5>
                <div class="p-3 bg-light rounded">
                        ${guest.notes}
                </div>
            </div>
        </c:if>

        <!-- Reservation History -->
        <div class="info-section">
            <h5><i class="fas fa-history me-2"></i>Reservation History</h5>
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                    <tr>
                        <th>Reservation #</th>
                        <th>Room</th>
                        <th>Check-in</th>
                        <th>Check-out</th>
                        <th>Total</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="res" items="${reservations}">
                        <tr>
                            <td><strong>${res.reservationNumber}</strong></td>
                            <td>${res.roomNumber}</td>
                            <td><fmt:formatDate value="${res.checkInDate}" pattern="dd MMM yyyy"/></td>
                            <td><fmt:formatDate value="${res.checkOutDate}" pattern="dd MMM yyyy"/></td>
                            <td>$${res.totalAmount}</td>
                            <td>
                                    <span class="badge bg-${res.reservationStatus == 'CONFIRMED' ? 'success' :
                                        (res.reservationStatus == 'CHECKED_IN' ? 'info' :
                                        (res.reservationStatus == 'CANCELLED' ? 'danger' : 'secondary'))}">
                                            ${res.reservationStatus}
                                    </span>
                            </td>
                            <td>
                                <a href="${pageContext.request.contextPath}/admin/reservations/view?id=${res.id}"
                                   class="btn btn-sm btn-outline-primary">
                                    <i class="fas fa-eye"></i>
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty reservations}">
                        <tr>
                            <td colspan="7" class="text-center py-3 text-muted">
                                No reservation history found.
                            </td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="action-buttons">
            <a href="${pageContext.request.contextPath}/admin/guests/edit?id=${guest.id}"
               class="btn btn-primary btn-action">
                <i class="fas fa-edit me-2"></i>Edit Guest
            </a>
            <a href="${pageContext.request.contextPath}/admin/reservations/new?guestId=${guest.id}"
               class="btn btn-success btn-action">
                <i class="fas fa-plus-circle me-2"></i>New Reservation
            </a>
            <a href="${pageContext.request.contextPath}/admin/guests/delete?id=${guest.id}"
               class="btn btn-danger btn-action"
               onclick="return confirm('Are you sure you want to delete this guest?')">
                <i class="fas fa-trash me-2"></i>Delete Guest
            </a>
            <a href="${pageContext.request.contextPath}/admin/guests"
               class="btn btn-secondary btn-action ms-auto">
                <i class="fas fa-arrow-left me-2"></i>Back to List
            </a>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>