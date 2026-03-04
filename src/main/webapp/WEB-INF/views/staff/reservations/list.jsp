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
  <title>Reservations - Ocean View Hotel</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <style>
    :root { --primary-color: #0d6efd; --sidebar-width: 280px; }
    body { font-family: 'Poppins', sans-serif; background: #f4f6f9; }
    .sidebar {
      position: fixed; top: 0; left: 0; height: 100vh; width: var(--sidebar-width);
      background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%);
      color: white; padding: 20px 0;
    }
    .sidebar-brand { padding: 0 20px 20px; border-bottom: 1px solid rgba(255,255,255,0.2); }
    .sidebar-brand h3 { font-size: 1.5rem; font-weight: 600; }
    .sidebar-menu { list-style: none; padding: 0 15px; }
    .sidebar-menu a {
      display: flex; align-items: center; padding: 12px 20px;
      color: rgba(255,255,255,0.8); text-decoration: none;
      border-radius: 10px;
    }
    .sidebar-menu a:hover, .sidebar-menu a.active {
      background: rgba(255,255,255,0.15); color: white;
    }
    .main-content { margin-left: var(--sidebar-width); padding: 20px 30px; }
    .top-nav {
      background: white; border-radius: 15px; padding: 15px 25px;
      margin-bottom: 25px; display: flex; justify-content: space-between;
    }
    .content-card {
      background: white; border-radius: 15px; padding: 25px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    }
    .badge-status { padding: 5px 10px; border-radius: 20px; font-size: 0.8rem; }
    .badge-confirmed { background: #d4edda; color: #155724; }
    .badge-checked-in { background: #cce5ff; color: #004085; }
    .badge-checked-out { background: #e2e3e5; color: #383d41; }
    .badge-cancelled { background: #f8d7da; color: #721c24; }
  </style>
</head>
<body>
<div class="sidebar">
  <div class="sidebar-brand">
    <h3>Ocean View</h3>
    <p>Staff Portal</p>
  </div>
  <ul class="sidebar-menu">
    <li><a href="${pageContext.request.contextPath}/staff/dashboard"><i class="fas fa-chart-pie"></i>Dashboard</a></li>
    <li><a href="${pageContext.request.contextPath}/staff/reservations" class="active"><i class="fas fa-calendar-alt"></i>Reservations</a></li>
    <li><a href="${pageContext.request.contextPath}/staff/reservations/new"><i class="fas fa-plus-circle"></i>New Reservation</a></li>
    <li><a href="${pageContext.request.contextPath}/staff/reservations/search"><i class="fas fa-search"></i>Search</a></li>
    <li><a href="${pageContext.request.contextPath}/staff/guests"><i class="fas fa-users"></i>Guests</a></li>
    <li><a href="${pageContext.request.contextPath}/staff/rooms"><i class="fas fa-door-open"></i>Rooms</a></li>
    <li><a href="${pageContext.request.contextPath}/help"><i class="fas fa-question-circle"></i>Help & Guidelines</a></li>
    <li><a href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i>Logout</a></li>
  </ul>
</div>

<div class="main-content">
  <div class="top-nav">
    <h2>Reservations</h2>
    <div class="user-avatar bg-primary text-white p-2 rounded-circle">
      <%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %>
    </div>
  </div>

  <% if(session.getAttribute("success") != null) { %>
  <div class="alert alert-success alert-dismissible fade show">
    <%= session.getAttribute("success") %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
  <% session.removeAttribute("success"); %>
  <% } %>

  <% if(session.getAttribute("error") != null) { %>
  <div class="alert alert-danger alert-dismissible fade show">
    <%= session.getAttribute("error") %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
  <% session.removeAttribute("error"); %>
  <% } %>

  <div class="content-card">
    <div class="d-flex justify-content-between mb-3">
      <h3>All Reservations</h3>
      <a href="${pageContext.request.contextPath}/staff/reservations/new" class="btn btn-primary">
        <i class="fas fa-plus-circle"></i> New Reservation
      </a>
    </div>

    <div class="table-responsive">
      <table class="table table-hover">
        <thead>
        <tr>
          <th>Reservation #</th>
          <th>Guest</th>
          <th>Room</th>
          <th>Check-in</th>
          <th>Check-out</th>
          <th>Total</th>
          <th>Status</th>
          <th>Actions</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="res" items="${reservations}">
          <tr>
            <td><strong>${res.reservationNumber}</strong></td>
            <td>${res.guestName}</td>
            <td>${res.roomNumber}</td>
            <td>${res.checkInDate}</td>
            <td>${res.checkOutDate}</td>
            <!-- CHANGED: $ -> Rs. -->
            <td>Rs. ${res.totalAmount}</td>
            <td>
                <span class="badge-status badge-${res.reservationStatus.toLowerCase()}">
                    ${res.reservationStatus}
                </span>
            </td>
            <td>
              <a href="${pageContext.request.contextPath}/staff/reservations/view?id=${res.id}"
                 class="btn btn-sm btn-outline-primary">
                <i class="fas fa-eye"></i>
              </a>
              <a href="${pageContext.request.contextPath}/staff/reservations/edit?id=${res.id}"
                 class="btn btn-sm btn-outline-success">
                <i class="fas fa-edit"></i>
              </a>
              <c:if test="${res.reservationStatus == 'CONFIRMED'}">
                <a href="${pageContext.request.contextPath}/staff/reservations/checkin?id=${res.id}"
                   class="btn btn-sm btn-outline-info"
                   onclick="return confirm('Check in this guest?')">
                  <i class="fas fa-sign-in-alt"></i>
                </a>
              </c:if>
            </td>
          </tr>
        </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
</div>
</body>
</html>
