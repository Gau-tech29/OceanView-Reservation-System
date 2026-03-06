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
    boolean isAdmin = user.isAdmin();
    String basePath = isAdmin ? "/admin" : "/staff";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Reservations - Ocean View Hotel</title>
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
        .sidebar-brand p { font-size: 0.85rem; opacity: 0.8; margin: 5px 0 0; }
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

        .search-card {
            background: white; border-radius: 15px; padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-bottom: 25px;
        }
        .search-card h4 {
            font-size: 1.2rem; font-weight: 600; color: #212529;
            margin-bottom: 20px; padding-bottom: 10px; border-bottom: 2px solid #f0f0f0;
        }
        .form-label { font-weight: 500; color: #495057; }
        .form-control, .form-select {
            border: 2px solid #e0e0e0; border-radius: 10px; padding: 10px 15px;
        }
        .form-control:focus, .form-select:focus {
            border-color: var(--primary-color); box-shadow: 0 0 0 3px rgba(13,110,253,0.1);
        }
        .btn-search {
            background: var(--primary-color); color: white; padding: 12px 30px;
            border: none; border-radius: 10px; font-weight: 600; transition: all 0.3s;
        }
        .btn-search:hover { background: var(--primary-dark); transform: translateY(-2px); }
        .btn-reset {
            background: #6c757d; color: white; padding: 12px 30px;
            border: none; border-radius: 10px; font-weight: 600; transition: all 0.3s;
        }
        .btn-reset:hover { background: #5a6268; transform: translateY(-2px); }

        .results-table {
            background: white; border-radius: 15px; padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        .badge-status { padding: 5px 10px; border-radius: 20px; font-size: 0.8rem; font-weight: 500; }
        .badge-confirmed  { background: #d4edda; color: #155724; }
        .badge-checked-in { background: #cce5ff; color: #004085; }
        .badge-checked-out{ background: #e2e3e5; color: #383d41; }
        .badge-cancelled  { background: #f8d7da; color: #721c24; }
        .badge-paid       { background: #d4edda; color: #155724; }
        .badge-unpaid     { background: #f8d7da; color: #721c24; }
        .badge-pending    { background: #fff3cd; color: #856404; }

        .btn-action { padding: 5px 10px; border-radius: 5px; font-size: 0.8rem; margin: 0 2px; transition: all 0.3s; }
        .btn-action:hover { transform: translateY(-2px); }

        .no-results { text-align: center; padding: 50px; color: #6c757d; }
        .no-results i { font-size: 4rem; margin-bottom: 20px; opacity: 0.3; }

        @media (max-width: 768px) {
            .sidebar { transform: translateX(-100%); }
            .main-content { margin-left: 0; padding: 20px; }
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
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/dashboard"><i class="fas fa-chart-pie"></i><span>Dashboard</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations"><i class="fas fa-calendar-alt"></i><span>Reservations</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations/new"><i class="fas fa-plus-circle"></i><span>New Reservation</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations/search" class="active"><i class="fas fa-search"></i><span>Search</span></a></li>
        <% if (isAdmin) { %>
        <li><a href="${pageContext.request.contextPath}/admin/guests"><i class="fas fa-users"></i><span>Guests</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/manage-rooms"><i class="fas fa-door-open"></i><span>Rooms</span></a></li>
        <% } else { %>
        <li><a href="${pageContext.request.contextPath}/staff/guests"><i class="fas fa-users"></i><span>Guests</span></a></li>
        <li><a href="${pageContext.request.contextPath}/staff/rooms"><i class="fas fa-door-open"></i><span>Rooms</span></a></li>
        <% } %>
        <li><a href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
    </ul>
</div>

<!-- Main Content -->
<div class="main-content">
    <div class="top-nav">
        <div class="page-title"><h2>Search Reservations</h2></div>
        <div class="d-flex align-items-center gap-3">
            <div class="user-avatar"><%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %></div>
            <div>
                <div style="font-weight:600;font-size:.9rem;"><%= user.getFullName() %></div>
                <div style="font-size:.75rem;color:#6c757d;"><%= user.getRole() %></div>
            </div>
        </div>
    </div>

    <!-- Search Form -->
    <div class="search-card">
        <h4><i class="fas fa-filter me-2"></i>Search Criteria</h4>
        <form action="${pageContext.request.contextPath}<%= basePath %>/reservations/search" method="post" id="searchForm">
            <div class="row">
                <div class="col-md-4 mb-3">
                    <label class="form-label">Search By</label>
                    <select class="form-select" name="searchType">
                        <option value="all" ${empty criteria.searchType or criteria.searchType == 'all' ? 'selected' : ''}>All Fields</option>
                        <option value="reservationNumber" ${criteria.searchType == 'reservationNumber' ? 'selected' : ''}>Reservation Number</option>
                        <option value="guestName" ${criteria.searchType == 'guestName' ? 'selected' : ''}>Guest Name</option>
                        <option value="roomNumber" ${criteria.searchType == 'roomNumber' ? 'selected' : ''}>Room Number</option>
                        <option value="guestEmail" ${criteria.searchType == 'guestEmail' ? 'selected' : ''}>Guest Email</option>
                        <option value="guestPhone" ${criteria.searchType == 'guestPhone' ? 'selected' : ''}>Guest Phone</option>
                    </select>
                </div>
                <div class="col-md-8 mb-3">
                    <label class="form-label">Search Value</label>
                    <input type="text" class="form-control" name="searchValue"
                           value="${criteria.searchValue}" placeholder="Enter search term...">
                </div>
                <div class="col-md-3 mb-3">
                    <label class="form-label">Check-in Date</label>
                    <input type="date" class="form-control" name="checkInDate" value="${criteria.checkInDate}">
                </div>
                <div class="col-md-3 mb-3">
                    <label class="form-label">Check-out Date</label>
                    <input type="date" class="form-control" name="checkOutDate" value="${criteria.checkOutDate}">
                </div>
                <div class="col-md-3 mb-3">
                    <label class="form-label">Status</label>
                    <select class="form-select" name="status">
                        <option value="">All Statuses</option>
                        <option value="CONFIRMED" ${criteria.status == 'CONFIRMED' ? 'selected' : ''}>Confirmed</option>
                        <option value="CHECKED_IN" ${criteria.status == 'CHECKED_IN' ? 'selected' : ''}>Checked In</option>
                        <option value="CHECKED_OUT" ${criteria.status == 'CHECKED_OUT' ? 'selected' : ''}>Checked Out</option>
                        <option value="CANCELLED" ${criteria.status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                    </select>
                </div>
                <div class="col-md-3 mb-3">
                    <label class="form-label">Payment Status</label>
                    <select class="form-select" name="paymentStatus">
                        <option value="">All</option>
                        <option value="PAID" ${criteria.paymentStatus == 'PAID' ? 'selected' : ''}>Paid</option>
                        <option value="PENDING" ${criteria.paymentStatus == 'PENDING' ? 'selected' : ''}>Pending</option>
                        <option value="PARTIAL" ${criteria.paymentStatus == 'PARTIAL' ? 'selected' : ''}>Partial</option>
                    </select>
                </div>
                <div class="col-12 text-center mt-3">
                    <button type="submit" class="btn-search me-2"><i class="fas fa-search me-2"></i>Search</button>
                    <button type="button" class="btn-reset" onclick="resetSearch()"><i class="fas fa-redo-alt me-2"></i>Reset</button>
                </div>
            </div>
        </form>
    </div>

    <!-- Search Results -->
    <div class="results-table">
        <h5 class="mb-3">
            <i class="fas fa-list me-2"></i>Search Results
            <c:if test="${not empty results}">
                <span class="badge bg-secondary ms-2">${results.size()} found</span>
            </c:if>
        </h5>

        <c:choose>
            <c:when test="${empty results}">
                <div class="no-results">
                    <i class="fas fa-search d-block"></i>
                    <h5>No reservations found</h5>
                    <p class="text-muted">Try adjusting your search criteria above.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead class="table-light">
                        <tr>
                            <th>Reservation #</th>
                            <th>Guest Name</th>
                            <th>Rooms</th>
                            <th>Check-in</th>
                            <th>Check-out</th>
                            <th>Total</th>
                            <th>Status</th>
                            <th>Payment</th>
                            <th>Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="res" items="${results}">
                            <tr>
                                <td><strong>${res.reservationNumber}</strong></td>
                                <td>${res.guestName}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty res.rooms}">
                                            <c:forEach var="room" items="${res.rooms}" varStatus="loop">
                                                ${room.roomNumber}<c:if test="${not loop.last}">, </c:if>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>${res.roomNumber}</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${res.formattedCheckInDate}</td>
                                <td>${res.formattedCheckOutDate}</td>
                                <td>Rs.<fmt:formatNumber value="${res.totalAmount}" pattern="#,##0.00"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${res.reservationStatus == 'CONFIRMED'}"><span class="badge-status badge-confirmed">Confirmed</span></c:when>
                                        <c:when test="${res.reservationStatus == 'CHECKED_IN'}"><span class="badge-status badge-checked-in">Checked In</span></c:when>
                                        <c:when test="${res.reservationStatus == 'CHECKED_OUT'}"><span class="badge-status badge-checked-out">Checked Out</span></c:when>
                                        <c:when test="${res.reservationStatus == 'CANCELLED'}"><span class="badge-status badge-cancelled">Cancelled</span></c:when>
                                        <c:otherwise><span class="badge-status badge-pending">${res.reservationStatus}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${res.paymentStatus == 'PAID'}"><span class="badge-status badge-paid">Paid</span></c:when>
                                        <c:otherwise><span class="badge-status badge-unpaid">${res.paymentStatus}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/view?id=${res.id}"
                                       class="btn btn-sm btn-outline-primary btn-action" title="View"><i class="fas fa-eye"></i></a>
                                    <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/edit?id=${res.id}"
                                       class="btn btn-sm btn-outline-success btn-action" title="Edit"><i class="fas fa-edit"></i></a>
                                    <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/print-bill?id=${res.id}"
                                       class="btn btn-sm btn-outline-info btn-action" title="Print Bill" target="_blank"><i class="fas fa-print"></i></a>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function resetSearch() {
        $('select[name="searchType"]').val('all');
        $('input[name="searchValue"]').val('');
        $('input[name="checkInDate"]').val('');
        $('input[name="checkOutDate"]').val('');
        $('select[name="status"]').val('');
        $('select[name="paymentStatus"]').val('');
        $('#searchForm').submit();
    }
    $('select[name="status"], select[name="paymentStatus"]').on('change', function() { $('#searchForm').submit(); });
    $('input[name="checkInDate"], input[name="checkOutDate"]').on('change', function() {
        if ($('input[name="checkInDate"]').val() && $('input[name="checkOutDate"]').val()) $('#searchForm').submit();
    });
</script>
</body>
</html>
