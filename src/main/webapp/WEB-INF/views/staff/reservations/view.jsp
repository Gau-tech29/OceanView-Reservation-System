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
  <title>Reservation Details</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
  <style>
    body { font-family: 'Poppins', sans-serif; background: #f4f6f9; padding: 20px; }
    .detail-card {
      max-width: 900px; margin: 0 auto;
      background: white; border-radius: 15px; box-shadow: 0 4px 20px rgba(0,0,0,0.08);
      padding: 30px;
    }
    .status-badge {
      padding: 8px 20px; border-radius: 30px; font-weight: 600;
    }
    .status-confirmed { background: #d4edda; color: #155724; }
    .status-checked_in { background: #cce5ff; color: #004085; }
    .status-checked_out { background: #e2e3e5; color: #383d41; }
    .status-cancelled { background: #f8d7da; color: #721c24; }
  </style>
</head>
<body>
<div class="detail-card">
  <div class="mb-3">
    <a href="${pageContext.request.contextPath}/staff/reservations" class="btn btn-outline-secondary">
      <i class="fas fa-arrow-left"></i> Back
    </a>
  </div>

  <% if(session.getAttribute("success") != null) { %>
  <div class="alert alert-success">
    <%= session.getAttribute("success") %>
  </div>
  <% session.removeAttribute("success"); %>
  <% } %>

  <c:if test="${not empty reservation}">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h2>Reservation #${reservation.reservationNumber}</h2>
      <span class="status-badge status-${reservation.reservationStatus.toLowerCase()}">
          ${reservation.reservationStatus}
      </span>
    </div>

    <div class="row">
      <div class="col-md-6 mb-4">
        <h5><i class="fas fa-user"></i> Guest Information</h5>
        <div class="bg-light p-3 rounded">
          <p class="mb-1"><strong>Name:</strong> ${reservation.guestName}</p>
          <p class="mb-1"><strong>Email:</strong> ${reservation.guestEmail}</p>
          <p class="mb-1"><strong>Phone:</strong> ${reservation.guestPhone}</p>
        </div>
      </div>

      <div class="col-md-6 mb-4">
        <h5><i class="fas fa-door-open"></i> Room Information</h5>
        <div class="bg-light p-3 rounded">
          <p class="mb-1"><strong>Room:</strong> ${reservation.roomNumber}</p>
          <p class="mb-1"><strong>Type:</strong> ${reservation.roomType}</p>
          <p class="mb-1"><strong>Rate:</strong> $${reservation.roomPrice}/night</p>
        </div>
      </div>
    </div>

    <div class="row mb-4">
      <div class="col-md-6">
        <h5><i class="fas fa-calendar"></i> Stay Details</h5>
        <div class="bg-light p-3 rounded">
          <p class="mb-1"><strong>Check-in:</strong> ${reservation.checkInDate}</p>
          <p class="mb-1"><strong>Check-out:</strong> ${reservation.checkOutDate}</p>
          <p class="mb-1"><strong>Nights:</strong> ${reservation.totalNights}</p>
          <p class="mb-1"><strong>Guests:</strong> ${reservation.adults} Adults, ${reservation.children} Children</p>
        </div>
      </div>

      <div class="col-md-6">
        <h5><i class="fas fa-dollar-sign"></i> Payment Details</h5>
        <div class="bg-light p-3 rounded">
          <p class="mb-1"><strong>Subtotal:</strong> $${reservation.subtotal}</p>
          <p class="mb-1"><strong>Tax (12%):</strong> $${reservation.taxAmount}</p>
          <p class="mb-1"><strong>Discount:</strong> $${reservation.discountAmount}</p>
          <p class="mb-0 fw-bold"><strong>Total:</strong> $${reservation.totalAmount}</p>
          <p class="mb-0 mt-2"><strong>Payment Status:</strong>
            <span class="badge bg-${reservation.paymentStatus == 'PAID' ? 'success' : 'warning'}">
                ${reservation.paymentStatus}
            </span>
          </p>
        </div>
      </div>
    </div>

    <c:if test="${not empty reservation.specialRequests}">
      <div class="mb-4">
        <h5><i class="fas fa-comment"></i> Special Requests</h5>
        <div class="bg-light p-3 rounded">
            ${reservation.specialRequests}
        </div>
      </div>
    </c:if>

    <div class="d-flex gap-2">
      <c:if test="${reservation.reservationStatus == 'CONFIRMED'}">
        <a href="${pageContext.request.contextPath}/staff/reservations/checkin?id=${reservation.id}"
           class="btn btn-success" onclick="return confirm('Check in this guest?')">
          <i class="fas fa-sign-in-alt"></i> Check In
        </a>
      </c:if>
      <c:if test="${reservation.reservationStatus == 'CHECKED_IN'}">
        <a href="${pageContext.request.contextPath}/staff/reservations/checkout?id=${reservation.id}"
           class="btn btn-warning" onclick="return confirm('Check out this guest?')">
          <i class="fas fa-sign-out-alt"></i> Check Out
        </a>
      </c:if>
      <a href="${pageContext.request.contextPath}/staff/reservations/edit?id=${reservation.id}"
         class="btn btn-primary">
        <i class="fas fa-edit"></i> Edit
      </a>
    </div>
  </c:if>
</div>
</body>
</html>