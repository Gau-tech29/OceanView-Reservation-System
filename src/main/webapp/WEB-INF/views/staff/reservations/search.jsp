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
  <title>Search Reservations</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
  <style>
    body { font-family: 'Poppins', sans-serif; background: #f4f6f9; padding: 20px; }
    .search-card {
      max-width: 1000px; margin: 0 auto;
      background: white; border-radius: 15px; box-shadow: 0 4px 20px rgba(0,0,0,0.08);
      padding: 30px;
    }
  </style>
</head>
<body>
<div class="search-card">
  <div class="mb-3">
    <a href="${pageContext.request.contextPath}/staff/reservations" class="btn btn-outline-secondary">
      <i class="fas fa-arrow-left"></i> Back
    </a>
  </div>

  <h3 class="mb-4">Search Reservations</h3>

  <form method="post" action="${pageContext.request.contextPath}/staff/reservations/search" class="mb-4">
    <div class="row">
      <div class="col-md-4 mb-3">
        <select name="searchType" class="form-control">
          <option value="reservationNumber">Reservation Number</option>
          <option value="guestName">Guest Name</option>
          <option value="roomNumber">Room Number</option>
          <option value="guestEmail">Email</option>
          <option value="guestPhone">Phone</option>
        </select>
      </div>
      <div class="col-md-6 mb-3">
        <input type="text" name="searchValue" class="form-control" placeholder="Enter search term...">
      </div>
      <div class="col-md-2 mb-3">
        <button type="submit" class="btn btn-primary w-100">
          <i class="fas fa-search"></i> Search
        </button>
      </div>
    </div>

    <div class="row">
      <div class="col-md-3 mb-3">
        <input type="date" name="checkInDate" class="form-control" placeholder="Check-in">
      </div>
      <div class="col-md-3 mb-3">
        <input type="date" name="checkOutDate" class="form-control" placeholder="Check-out">
      </div>
      <div class="col-md-3 mb-3">
        <select name="status" class="form-control">
          <option value="">All Status</option>
          <option value="CONFIRMED">Confirmed</option>
          <option value="CHECKED_IN">Checked In</option>
          <option value="CHECKED_OUT">Checked Out</option>
          <option value="CANCELLED">Cancelled</option>
        </select>
      </div>
      <div class="col-md-3 mb-3">
        <select name="paymentStatus" class="form-control">
          <option value="">All Payments</option>
          <option value="PAID">Paid</option>
          <option value="PENDING">Pending</option>
        </select>
      </div>
    </div>
  </form>

  <c:if test="${not empty results}">
    <h5>Results (${results.size()} found)</h5>
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
          <th>Action</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="res" items="${results}">
          <tr>
            <td>${res.reservationNumber}</td>
            <td>${res.guestName}</td>
            <td>${res.roomNumber}</td>
            <td>${res.checkInDate}</td>
            <td>${res.checkOutDate}</td>
            <td>$${res.totalAmount}</td>
            <td>${res.reservationStatus}</td>
            <td>
              <a href="${pageContext.request.contextPath}/staff/reservations/view?id=${res.id}"
                 class="btn btn-sm btn-primary">
                View
              </a>
            </td>
          </tr>
        </c:forEach>
        </tbody>
      </table>
    </div>
  </c:if>
</div>
</body>
</html>