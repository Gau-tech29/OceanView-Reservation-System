<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%
  User user = (User) session.getAttribute("user");
  if (user == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
  boolean isAdmin = user.isAdmin();
  String basePath = isAdmin ? "/admin" : "/staff";
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reservation Details - Ocean View Hotel</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <style>
    :root { --primary-color: #0d6efd; --primary-dark: #0b5ed7; --sidebar-width: 280px; }
    body { font-family: 'Poppins', sans-serif; background: #f4f6f9; overflow-x: hidden; }

    .sidebar {
      position: fixed; top: 0; left: 0; height: 100vh; width: var(--sidebar-width);
      background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%);
      color: white; padding: 20px 0; z-index: 1000;
    }
    .sidebar-brand { padding: 0 20px 20px; border-bottom: 1px solid rgba(255,255,255,0.2); margin-bottom: 20px; }
    .sidebar-brand h3 { font-size: 1.5rem; font-weight: 600; margin: 0; }
    .sidebar-brand p  { font-size: 0.85rem; opacity: 0.8; margin: 5px 0 0; }
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
    .page-title h2 { font-size: 1.5rem; font-weight: 600; color: #212529; margin: 0; }
    .user-avatar {
      width: 40px; height: 40px;
      background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%);
      border-radius: 50%; display: flex; align-items: center;
      justify-content: center; color: white; font-weight: 600;
    }

    .detail-card {
      background: white; border-radius: 15px; padding: 30px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    }
    .reservation-header {
      display: flex; justify-content: space-between; align-items: center;
      margin-bottom: 25px; padding-bottom: 20px; border-bottom: 2px solid #f0f0f0;
    }
    .reservation-number { font-size: 1.5rem; font-weight: 700; color: var(--primary-color); }
    .reservation-number small { font-size: 0.9rem; color: #6c757d; font-weight: normal; }
    .status-badge { padding: 8px 20px; border-radius: 30px; font-weight: 600; font-size: 0.9rem; }
    .status-confirmed   { background: #d4edda; color: #155724; }
    .status-checked-in  { background: #cce5ff; color: #004085; }
    .status-checked-out { background: #e2e3e5; color: #383d41; }
    .status-cancelled   { background: #f8d7da; color: #721c24; }
    .status-pending     { background: #fff3cd; color: #856404; }
    .payment-paid       { background: #d4edda; color: #155724; }
    .payment-pending    { background: #fff3cd; color: #856404; }

    .info-section { margin-bottom: 30px; }
    .info-section h5 {
      font-size: 1.1rem; font-weight: 600; color: #212529;
      margin-bottom: 15px; padding-bottom: 10px; border-bottom: 2px solid #f0f0f0;
    }
    .info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 15px; }
    .info-item { background: #f8f9fa; border-radius: 10px; padding: 15px; }
    .info-item .label { font-size: 0.82rem; color: #6c757d; margin-bottom: 5px; }
    .info-item .value { font-size: 1rem; font-weight: 600; color: #212529; }

    .price-breakdown { background: #f8f9fa; border-radius: 10px; padding: 20px; }
    .price-row { display: flex; justify-content: space-between; padding: 7px 0; font-size: 0.9rem; }
    .price-row.total {
      border-top: 2px solid #dee2e6; margin-top: 10px; padding-top: 15px;
      font-weight: 700; font-size: 1.1rem; color: var(--primary-color);
    }

    .action-buttons {
      display: flex; flex-wrap: wrap; gap: 10px;
      margin-top: 25px; padding-top: 20px; border-top: 2px solid #f0f0f0;
    }
    .btn-action { padding: 10px 20px; border-radius: 10px; font-weight: 500; transition: all 0.3s; }
    .btn-action:hover { transform: translateY(-2px); }
    /* Inline delete form should look like a button */
    .delete-form { display: inline; margin: 0; padding: 0; }

    .alert { border-radius: 10px; margin-bottom: 20px; }

    @media (max-width: 768px) {
      .sidebar { transform: translateX(-100%); }
      .main-content { margin-left: 0; padding: 15px; }
      .reservation-header { flex-direction: column; gap: 15px; }
    }
  </style>
</head>
<body>

<!-- Sidebar -->
<div class="sidebar">
  <div class="sidebar-brand">
    <h3><i class="fas fa-hotel me-2"></i>Ocean View</h3>
    <p>Hotel Reservation System</p>
  </div>
  <ul class="sidebar-menu">
    <li><a href="${pageContext.request.contextPath}<%= basePath %>/dashboard">
      <i class="fas fa-chart-pie"></i><span>Dashboard</span></a></li>
    <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations" class="active">
      <i class="fas fa-calendar-alt"></i><span>Reservations</span></a></li>
    <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations/new">
      <i class="fas fa-plus-circle"></i><span>New Reservation</span></a></li>
    <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations/search">
      <i class="fas fa-search"></i><span>Search</span></a></li>
    <% if (isAdmin) { %>
    <li><a href="${pageContext.request.contextPath}/admin/guests">
      <i class="fas fa-users"></i><span>Guests</span></a></li>
    <li><a href="${pageContext.request.contextPath}/admin/manage-rooms">
      <i class="fas fa-door-open"></i><span>Rooms</span></a></li>
    <li><a href="${pageContext.request.contextPath}/admin/bills">
      <i class="fas fa-receipt"></i><span>Bills</span></a></li>
    <% } else { %>
    <li><a href="${pageContext.request.contextPath}/staff/guests">
      <i class="fas fa-users"></i><span>Guests</span></a></li>
    <li><a href="${pageContext.request.contextPath}/staff/rooms">
      <i class="fas fa-door-open"></i><span>Rooms</span></a></li>
    <li><a href="${pageContext.request.contextPath}/staff/bills">
      <i class="fas fa-receipt"></i><span>Bills</span></a></li>
    <% } %>
    <li><a href="${pageContext.request.contextPath}/logout">
      <i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
  </ul>
</div>

<!-- Main Content -->
<div class="main-content">
  <div class="top-nav">
    <div class="page-title"><h2>Reservation Details</h2></div>
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

  <!-- Session Messages -->
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

  <c:choose>
    <c:when test="${empty reservation}">
      <div class="alert alert-danger">
        <i class="fas fa-exclamation-triangle me-2"></i>
        Reservation not found.
        <a href="${pageContext.request.contextPath}<%= basePath %>/reservations">Back to list</a>
      </div>
    </c:when>
    <c:otherwise>
      <div class="detail-card">

        <!-- ── Header ── -->
        <div class="reservation-header">
          <div>
            <div class="reservation-number">
                ${reservation.reservationNumber}
              <small class="d-block mt-1">Created: ${reservation.formattedCreatedAt}</small>
            </div>
          </div>
          <div class="d-flex gap-2 flex-wrap">
            <c:choose>
              <c:when test="${reservation.reservationStatus == 'CONFIRMED'}">
                <span class="status-badge status-confirmed"><i class="fas fa-check-circle me-1"></i>Confirmed</span>
              </c:when>
              <c:when test="${reservation.reservationStatus == 'CHECKED_IN'}">
                <span class="status-badge status-checked-in"><i class="fas fa-sign-in-alt me-1"></i>Checked In</span>
              </c:when>
              <c:when test="${reservation.reservationStatus == 'CHECKED_OUT'}">
                <span class="status-badge status-checked-out"><i class="fas fa-sign-out-alt me-1"></i>Checked Out</span>
              </c:when>
              <c:when test="${reservation.reservationStatus == 'CANCELLED'}">
                <span class="status-badge status-cancelled"><i class="fas fa-times-circle me-1"></i>Cancelled</span>
              </c:when>
              <c:otherwise>
                <span class="status-badge status-pending"><i class="fas fa-clock me-1"></i>Pending</span>
              </c:otherwise>
            </c:choose>
            <c:choose>
              <c:when test="${reservation.paymentStatus == 'PAID'}">
                <span class="status-badge payment-paid"><i class="fas fa-dollar-sign me-1"></i>Paid</span>
              </c:when>
              <c:otherwise>
                <span class="status-badge payment-pending">
                  <i class="fas fa-hourglass-half me-1"></i>
                  <c:out value="${reservation.paymentStatus}"/>
                </span>
              </c:otherwise>
            </c:choose>
          </div>
        </div>

        <!-- ── Guest Information ── -->
        <div class="info-section">
          <h5><i class="fas fa-user me-2"></i>Guest Information</h5>
          <div class="info-grid">
            <div class="info-item">
              <div class="label">Full Name</div>
              <div class="value"><c:out value="${reservation.guestName}"/></div>
            </div>
            <div class="info-item">
              <div class="label">Email</div>
              <div class="value">
                <c:choose>
                  <c:when test="${not empty reservation.guestEmail}"><c:out value="${reservation.guestEmail}"/></c:when>
                  <c:otherwise>—</c:otherwise>
                </c:choose>
              </div>
            </div>
            <div class="info-item">
              <div class="label">Phone</div>
              <div class="value">
                <c:choose>
                  <c:when test="${not empty reservation.guestPhone}"><c:out value="${reservation.guestPhone}"/></c:when>
                  <c:otherwise>—</c:otherwise>
                </c:choose>
              </div>
            </div>
            <c:if test="${not empty reservation.guestNumber}">
              <div class="info-item">
                <div class="label">Guest #</div>
                <div class="value"><c:out value="${reservation.guestNumber}"/></div>
              </div>
            </c:if>
          </div>
        </div>

        <!-- ── Room Information ── -->
        <div class="info-section">
          <h5><i class="fas fa-door-open me-2"></i>Room Information</h5>
          <c:choose>
            <c:when test="${not empty reservation.rooms}">
              <div class="table-responsive">
                <table class="table table-bordered table-hover align-middle">
                  <thead class="table-light">
                  <tr>
                    <th>#</th>
                    <th>Room Number</th>
                    <th>Room Type</th>
                    <th>View</th>
                    <th>Floor</th>
                    <th>Capacity</th>
                    <th>Price/Night</th>
                  </tr>
                  </thead>
                  <tbody>
                  <c:forEach var="room" items="${reservation.rooms}" varStatus="loop">
                    <tr>
                      <td><span class="badge bg-primary">${loop.index + 1}</span></td>
                      <td><strong><c:out value="${room.roomNumber}"/></strong></td>
                      <td>
                          <span class="badge"
                                style="background:
                                <c:choose>
                                <c:when test="${room.roomType == 'DELUXE'}">#f3e5f5;color:#7b1fa2</c:when>
                                <c:when test="${room.roomType == 'SUITE'}">#fff8e1;color:#f57f17</c:when>
                                <c:when test="${room.roomType == 'EXECUTIVE'}">#e8f5e9;color:#2e7d32</c:when>
                                <c:when test="${room.roomType == 'FAMILY'}">#fce4ec;color:#c62828</c:when>
                                <c:when test="${room.roomType == 'PRESIDENTIAL'}">#fdf3e7;color:#e65100</c:when>
                                <c:otherwise>#e3f2fd;color:#1565c0</c:otherwise>
                                        </c:choose>">
                            <c:out value="${room.roomType}"/>
                          </span>
                      </td>
                      <td><c:out value="${not empty room.roomView ? room.roomView : '—'}"/></td>
                      <td><c:out value="${not empty room.floorNumber ? room.floorNumber : '—'}"/></td>
                      <td><c:out value="${not empty room.capacity ? room.capacity : '—'}"/></td>
                      <td>
                        <c:choose>
                          <c:when test="${not empty room.roomPrice}">
                            $<fmt:formatNumber value="${room.roomPrice}" pattern="#,##0.00"/>
                          </c:when>
                          <c:otherwise>—</c:otherwise>
                        </c:choose>
                      </td>
                    </tr>
                  </c:forEach>
                  </tbody>
                </table>
              </div>
            </c:when>
            <c:otherwise>
              <div class="alert alert-warning">
                <i class="fas fa-info-circle me-2"></i>No room details available.
              </div>
            </c:otherwise>
          </c:choose>
          <div class="info-grid mt-3">
            <div class="info-item">
              <div class="label">Total Rooms</div>
              <div class="value">${reservation.numberOfRooms}</div>
            </div>
          </div>
        </div>

        <!-- ── Stay Details ── -->
        <div class="info-section">
          <h5><i class="fas fa-calendar-alt me-2"></i>Stay Details</h5>
          <div class="info-grid">
            <div class="info-item">
              <div class="label">Check-in</div>
              <div class="value">${reservation.formattedCheckInDate}</div>
            </div>
            <div class="info-item">
              <div class="label">Check-out</div>
              <div class="value">${reservation.formattedCheckOutDate}</div>
            </div>
            <div class="info-item">
              <div class="label">Nights</div>
              <div class="value">${reservation.totalNights}</div>
            </div>
            <div class="info-item">
              <div class="label">Guests</div>
              <div class="value">${reservation.adults} Adults, ${reservation.children} Children</div>
            </div>
            <c:if test="${not empty reservation.source}">
              <div class="info-item">
                <div class="label">Source</div>
                <div class="value"><c:out value="${reservation.source}"/></div>
              </div>
            </c:if>
          </div>
        </div>

        <!-- ── Price Breakdown ── -->
        <div class="info-section">
          <h5><i class="fas fa-dollar-sign me-2"></i>Price Breakdown</h5>
          <div class="price-breakdown">

              <%-- Per-room breakdown if multiple rooms --%>
            <c:if test="${reservation.numberOfRooms > 1}">
              <c:forEach var="room" items="${reservation.rooms}" varStatus="loop">
                <c:if test="${not empty room.roomPrice}">
                  <div class="price-row">
                    <span>Room ${loop.index + 1} — <c:out value="${room.roomNumber}"/> (<c:out value="${room.roomType}"/>)
                      × ${reservation.totalNights} night(s)</span>
                    <span class="fw-bold">
                      $<fmt:formatNumber value="${room.roomPrice * reservation.totalNights}" pattern="#,##0.00"/>
                    </span>
                  </div>
                </c:if>
              </c:forEach>
              <hr style="margin:8px 0;border-color:#dee2e6;">
            </c:if>

              <%-- Subtotal row --%>
            <c:choose>
              <c:when test="${not empty reservation.subtotal}">
                <div class="price-row">
                  <span>
                    <c:choose>
                      <c:when test="${reservation.numberOfRooms > 1}">Total Room Charges (${reservation.totalNights} nights)</c:when>
                      <c:otherwise>Room Charges (${reservation.totalNights} nights
                        <c:if test="${not empty reservation.roomPrice}">
                          @ $<fmt:formatNumber value="${reservation.roomPrice}" pattern="#,##0.00"/>/night
                        </c:if>)
                      </c:otherwise>
                    </c:choose>
                  </span>
                  <span class="fw-bold">$<fmt:formatNumber value="${reservation.subtotal}" pattern="#,##0.00"/></span>
                </div>
              </c:when>
              <c:otherwise>
                <div class="price-row">
                  <span>Room Charges</span>
                  <span class="fw-bold">—</span>
                </div>
              </c:otherwise>
            </c:choose>

              <%-- Tax --%>
            <c:choose>
              <c:when test="${not empty reservation.taxAmount}">
                <div class="price-row">
                  <span>Tax (12%)</span>
                  <span class="fw-bold">$<fmt:formatNumber value="${reservation.taxAmount}" pattern="#,##0.00"/></span>
                </div>
              </c:when>
              <c:otherwise>
                <div class="price-row"><span>Tax (12%)</span><span class="fw-bold">—</span></div>
              </c:otherwise>
            </c:choose>

              <%-- Discount --%>
            <c:if test="${not empty reservation.discountAmount and reservation.discountAmount > 0}">
              <div class="price-row">
                <span>Discount</span>
                <span class="fw-bold text-success">-$<fmt:formatNumber value="${reservation.discountAmount}" pattern="#,##0.00"/></span>
              </div>
            </c:if>

              <%-- Total --%>
            <div class="price-row total">
              <span>Total Amount</span>
              <span>
                <c:choose>
                  <c:when test="${not empty reservation.totalAmount}">
                    $<fmt:formatNumber value="${reservation.totalAmount}" pattern="#,##0.00"/>
                  </c:when>
                  <c:otherwise>—</c:otherwise>
                </c:choose>
              </span>
            </div>
          </div>
        </div>

        <!-- ── Special Requests ── -->
        <c:if test="${not empty reservation.specialRequests}">
          <div class="info-section">
            <h5><i class="fas fa-comment me-2"></i>Special Requests</h5>
            <div class="p-3 bg-light rounded"><c:out value="${reservation.specialRequests}"/></div>
          </div>
        </c:if>

        <!-- ── Staff ── -->
        <c:if test="${not empty reservation.staffName}">
          <div class="info-section">
            <h5><i class="fas fa-user-tie me-2"></i>Created By</h5>
            <div class="info-item" style="max-width:300px;">
              <div class="label">Staff Name</div>
              <div class="value"><c:out value="${reservation.staffName}"/></div>
            </div>
          </div>
        </c:if>

        <!-- ── Actions ── -->
        <div class="action-buttons">

            <%-- Check In --%>
          <c:if test="${reservation.reservationStatus == 'CONFIRMED'}">
            <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/checkin?id=${reservation.id}"
               class="btn btn-success btn-action"
               onclick="return confirm('Confirm check-in for this guest?')">
              <i class="fas fa-sign-in-alt me-2"></i>Check In
            </a>
          </c:if>

            <%-- Check Out --%>
          <c:if test="${reservation.reservationStatus == 'CHECKED_IN'}">
            <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/checkout?id=${reservation.id}"
               class="btn btn-warning btn-action"
               onclick="return confirm('Confirm check-out for this guest?')">
              <i class="fas fa-sign-out-alt me-2"></i>Check Out
            </a>
          </c:if>

            <%-- Cancel --%>
          <c:if test="${reservation.reservationStatus != 'CHECKED_OUT' and reservation.reservationStatus != 'CANCELLED'}">
            <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/cancel?id=${reservation.id}"
               class="btn btn-danger btn-action"
               onclick="return confirm('Are you sure you want to cancel this reservation?')">
              <i class="fas fa-times-circle me-2"></i>Cancel
            </a>
          </c:if>

            <%-- Edit --%>
          <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/edit?id=${reservation.id}"
             class="btn btn-primary btn-action">
            <i class="fas fa-edit me-2"></i>Edit
          </a>

            <%-- Print Bill --%>
          <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/print-bill?id=${reservation.id}"
             class="btn btn-info btn-action text-white" target="_blank">
            <i class="fas fa-print me-2"></i>Print Bill
          </a>

            <%--
              DELETE: must be a POST form — the controller's doPost handles /delete.
              A plain GET link would hit doGet which has no /delete case → 404.
            --%>
          <form method="POST"
                action="${pageContext.request.contextPath}<%= basePath %>/reservations/delete"
                class="delete-form"
                onsubmit="return confirm('Permanently delete this reservation? This cannot be undone.');">
            <input type="hidden" name="id" value="${reservation.id}">
            <button type="submit" class="btn btn-outline-danger btn-action">
              <i class="fas fa-trash me-2"></i>Delete
            </button>
          </form>

            <%-- Back to List --%>
          <a href="${pageContext.request.contextPath}<%= basePath %>/reservations"
             class="btn btn-secondary btn-action ms-auto">
            <i class="fas fa-arrow-left me-2"></i>Back to List
          </a>

        </div>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
