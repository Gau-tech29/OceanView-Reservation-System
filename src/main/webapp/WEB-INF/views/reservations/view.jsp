<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.dto.ReservationDTO" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%
  User user = (User) session.getAttribute("user");
  if (user == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
  }
  boolean isAdmin = user.isAdmin();
  String basePath = isAdmin ? "/admin" : "/staff";
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reservation Details - Ocean View Hotel</title>

  <!-- Bootstrap 5 CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- Font Awesome 6 -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

  <style>
    :root {
      --primary-color: #0d6efd;
      --primary-dark: #0b5ed7;
      --sidebar-width: 280px;
    }

    body {
      font-family: 'Poppins', sans-serif;
      background: #f4f6f9;
      overflow-x: hidden;
    }

    .sidebar {
      position: fixed;
      top: 0;
      left: 0;
      height: 100vh;
      width: var(--sidebar-width);
      background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%);
      color: white;
      padding: 20px 0;
      transition: all 0.3s;
      z-index: 1000;
    }

    .sidebar-brand {
      padding: 0 20px 20px;
      border-bottom: 1px solid rgba(255,255,255,0.2);
      margin-bottom: 20px;
    }

    .sidebar-menu {
      list-style: none;
      padding: 0 15px;
    }

    .sidebar-menu a {
      display: flex;
      align-items: center;
      padding: 12px 20px;
      color: rgba(255,255,255,0.8);
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
      font-size: 1.2rem;
    }

    .main-content {
      margin-left: var(--sidebar-width);
      padding: 20px 30px;
    }

    .top-nav {
      background: white;
      border-radius: 15px;
      padding: 15px 25px;
      margin-bottom: 25px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.05);
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .page-title h2 {
      font-size: 1.5rem;
      font-weight: 600;
      color: #212529;
      margin: 0;
    }

    .user-avatar {
      width: 40px;
      height: 40px;
      background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-weight: 600;
    }

    /* Detail Card */
    .detail-card {
      background: white;
      border-radius: 15px;
      padding: 30px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    }

    .reservation-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 25px;
      padding-bottom: 20px;
      border-bottom: 2px solid #f0f0f0;
    }

    .reservation-number {
      font-size: 1.5rem;
      font-weight: 700;
      color: var(--primary-color);
    }

    .reservation-number small {
      font-size: 0.9rem;
      color: #6c757d;
      font-weight: normal;
    }

    .status-badge {
      padding: 8px 20px;
      border-radius: 30px;
      font-weight: 600;
      font-size: 0.9rem;
    }

    .status-confirmed {
      background: #d4edda;
      color: #155724;
    }

    .status-checked-in {
      background: #cce5ff;
      color: #004085;
    }

    .status-checked-out {
      background: #e2e3e5;
      color: #383d41;
    }

    .status-cancelled {
      background: #f8d7da;
      color: #721c24;
    }

    .payment-paid {
      background: #d4edda;
      color: #155724;
    }

    .payment-pending {
      background: #fff3cd;
      color: #856404;
    }

    .info-section {
      margin-bottom: 30px;
    }

    .info-section h5 {
      font-size: 1.1rem;
      font-weight: 600;
      color: #212529;
      margin-bottom: 15px;
      padding-bottom: 10px;
      border-bottom: 2px solid #f0f0f0;
    }

    .info-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 20px;
    }

    .info-item {
      background: #f8f9fa;
      border-radius: 10px;
      padding: 15px;
    }

    .info-item .label {
      font-size: 0.85rem;
      color: #6c757d;
      margin-bottom: 5px;
    }

    .info-item .value {
      font-size: 1.1rem;
      font-weight: 600;
      color: #212529;
    }

    .price-breakdown {
      background: #f8f9fa;
      border-radius: 10px;
      padding: 20px;
    }

    .price-row {
      display: flex;
      justify-content: space-between;
      padding: 8px 0;
    }

    .price-row.total {
      border-top: 2px solid #dee2e6;
      margin-top: 10px;
      padding-top: 15px;
      font-weight: 700;
      font-size: 1.2rem;
      color: var(--primary-color);
    }

    .action-buttons {
      display: flex;
      gap: 10px;
      margin-top: 25px;
      padding-top: 20px;
      border-top: 2px solid #f0f0f0;
    }

    .btn-action {
      padding: 10px 20px;
      border-radius: 10px;
      font-weight: 500;
      transition: all 0.3s;
    }

    .btn-action:hover {
      transform: translateY(-2px);
    }

    .btn-primary {
      background: var(--primary-color);
      border: none;
    }

    .btn-success {
      background: #198754;
      border: none;
    }

    .btn-warning {
      background: #ffc107;
      border: none;
      color: #212529;
    }

    .btn-danger {
      background: #dc3545;
      border: none;
    }

    .btn-info {
      background: #0dcaf0;
      border: none;
      color: #212529;
    }

    @media (max-width: 768px) {
      .sidebar {
        transform: translateX(-100%);
      }
      .main-content {
        margin-left: 0;
        padding: 20px;
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
    <li>
      <a href="${pageContext.request.contextPath}<%= basePath %>/dashboard">
        <i class="fas fa-chart-pie"></i>
        <span>Dashboard</span>
      </a>
    </li>
    <li>
      <a href="${pageContext.request.contextPath}<%= basePath %>/reservations" class="active">
        <i class="fas fa-calendar-alt"></i>
        <span>Reservations</span>
      </a>
    </li>
    <li>
      <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/new">
        <i class="fas fa-plus-circle"></i>
        <span>New Reservation</span>
      </a>
    </li>
    <li>
      <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/search">
        <i class="fas fa-search"></i>
        <span>Search</span>
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
      <h2>Reservation Details</h2>
    </div>

    <div class="user-avatar">
      <%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %>
    </div>
  </div>

  <!-- Detail Card -->
  <div class="detail-card">
    <!-- Header -->
    <div class="reservation-header">
      <div>
        <div class="reservation-number">
          ${reservation.reservationNumber}
          <small>Created: <fmt:formatDate value="${reservation.createdAt}" pattern="dd MMM yyyy HH:mm"/></small>
        </div>
      </div>
      <div>
        <c:choose>
          <c:when test="${reservation.reservationStatus == 'CONFIRMED'}">
            <span class="status-badge status-confirmed">Confirmed</span>
          </c:when>
          <c:when test="${reservation.reservationStatus == 'CHECKED_IN'}">
            <span class="status-badge status-checked-in">Checked In</span>
          </c:when>
          <c:when test="${reservation.reservationStatus == 'CHECKED_OUT'}">
            <span class="status-badge status-checked-out">Checked Out</span>
          </c:when>
          <c:when test="${reservation.reservationStatus == 'CANCELLED'}">
            <span class="status-badge status-cancelled">Cancelled</span>
          </c:when>
        </c:choose>

        <c:choose>
          <c:when test="${reservation.paymentStatus == 'PAID'}">
            <span class="status-badge payment-paid ms-2">Paid</span>
          </c:when>
          <c:when test="${reservation.paymentStatus == 'PENDING'}">
            <span class="status-badge payment-pending ms-2">Pending</span>
          </c:when>
          <c:when test="${reservation.paymentStatus == 'PARTIAL'}">
            <span class="status-badge payment-pending ms-2">Partial</span>
          </c:when>
        </c:choose>
      </div>
    </div>

    <!-- Guest Information -->
    <div class="info-section">
      <h5><i class="fas fa-user me-2"></i>Guest Information</h5>
      <div class="info-grid">
        <div class="info-item">
          <div class="label">Full Name</div>
          <div class="value">${reservation.guestName}</div>
        </div>
        <div class="info-item">
          <div class="label">Email</div>
          <div class="value">${reservation.guestEmail}</div>
        </div>
        <div class="info-item">
          <div class="label">Phone</div>
          <div class="value">${reservation.guestPhone}</div>
        </div>
      </div>
    </div>

    <!-- Room Information -->
    <div class="info-section">
      <h5><i class="fas fa-door-open me-2"></i>Room Information</h5>
      <div class="info-grid">
        <div class="info-item">
          <div class="label">Room Number</div>
          <div class="value">${reservation.roomNumber}</div>
        </div>
        <div class="info-item">
          <div class="label">Room Type</div>
          <div class="value">${reservation.roomType}</div>
        </div>
        <div class="info-item">
          <div class="label">Room View</div>
          <div class="value">${reservation.roomView}</div>
        </div>
      </div>
    </div>

    <!-- Stay Details -->
    <div class="info-section">
      <h5><i class="fas fa-calendar-alt me-2"></i>Stay Details</h5>
      <div class="info-grid">
        <div class="info-item">
          <div class="label">Check-in Date</div>
          <div class="value"><fmt:formatDate value="${reservation.checkInDate}" pattern="dd MMMM yyyy"/></div>
        </div>
        <div class="info-item">
          <div class="label">Check-out Date</div>
          <div class="value"><fmt:formatDate value="${reservation.checkOutDate}" pattern="dd MMMM yyyy"/></div>
        </div>
        <div class="info-item">
          <div class="label">Nights</div>
          <div class="value">${reservation.totalNights}</div>
        </div>
        <div class="info-item">
          <div class="label">Guests</div>
          <div class="value">${reservation.adults} Adults, ${reservation.children} Children</div>
        </div>
        <div class="info-item">
          <div class="label">Source</div>
          <div class="value">${reservation.source}</div>
        </div>
      </div>
    </div>

    <!-- Price Breakdown -->
    <div class="info-section">
      <h5><i class="fas fa-dollar-sign me-2"></i>Price Breakdown</h5>
      <div class="price-breakdown">
        <div class="price-row">
          <span>Room Price (${reservation.totalNights} nights @ $${reservation.roomPrice}/night)</span>
          <span class="fw-bold">$${reservation.subtotal}</span>
        </div>
        <div class="price-row">
          <span>Tax (12%)</span>
          <span class="fw-bold">$${reservation.taxAmount}</span>
        </div>
        <c:if test="${reservation.discountAmount > 0}">
          <div class="price-row">
            <span>Discount</span>
            <span class="fw-bold text-success">-$${reservation.discountAmount}</span>
          </div>
        </c:if>
        <div class="price-row total">
          <span>Total Amount</span>
          <span>$${reservation.totalAmount}</span>
        </div>
      </div>
    </div>

    <!-- Special Requests -->
    <c:if test="${not empty reservation.specialRequests}">
      <div class="info-section">
        <h5><i class="fas fa-comment me-2"></i>Special Requests</h5>
        <div class="p-3 bg-light rounded">
            ${reservation.specialRequests}
        </div>
      </div>
    </c:if>

    <!-- Staff Information -->
    <div class="info-section">
      <h5><i class="fas fa-user-tie me-2"></i>Created By</h5>
      <div class="info-item" style="max-width: 300px;">
        <div class="label">Staff Name</div>
        <div class="value">${reservation.staffName}</div>
      </div>
    </div>

    <!-- Action Buttons -->
    <div class="action-buttons">
      <c:if test="${reservation.reservationStatus == 'CONFIRMED'}">
        <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/checkin?id=${reservation.id}"
           class="btn btn-success btn-action">
          <i class="fas fa-sign-in-alt me-2"></i>Check In
        </a>
      </c:if>

      <c:if test="${reservation.reservationStatus == 'CHECKED_IN'}">
        <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/checkout?id=${reservation.id}"
           class="btn btn-warning btn-action">
          <i class="fas fa-sign-out-alt me-2"></i>Check Out
        </a>
      </c:if>

      <c:if test="${reservation.reservationStatus != 'CHECKED_OUT' && reservation.reservationStatus != 'CANCELLED'}">
        <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/cancel?id=${reservation.id}"
           class="btn btn-danger btn-action"
           onclick="return confirm('Are you sure you want to cancel this reservation?')">
          <i class="fas fa-times-circle me-2"></i>Cancel
        </a>
      </c:if>

      <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/edit?id=${reservation.id}"
         class="btn btn-primary btn-action">
        <i class="fas fa-edit me-2"></i>Edit
      </a>

      <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/print-bill?id=${reservation.id}"
         class="btn btn-info btn-action" target="_blank">
        <i class="fas fa-print me-2"></i>Print Bill
      </a>

      <a href="${pageContext.request.contextPath}<%= basePath %>/reservations"
         class="btn btn-secondary btn-action ms-auto">
        <i class="fas fa-arrow-left me-2"></i>Back to List
      </a>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>