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
    <title>${pageTitle} - Ocean View Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.11.5/css/dataTables.bootstrap5.min.css">
    <style>
        :root { --primary-color: #0d6efd; --primary-dark: #0b5ed7; --sidebar-width: 280px; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Poppins', sans-serif; background: #f4f6f9; overflow-x: hidden; }

        .sidebar {
            position: fixed; top: 0; left: 0; height: 100vh; width: var(--sidebar-width);
            background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%);
            color: white; padding: 20px 0; z-index: 1000; box-shadow: 2px 0 10px rgba(0,0,0,0.1);
        }
        .sidebar-brand { padding: 0 20px 20px; border-bottom: 1px solid rgba(255,255,255,0.2); margin-bottom: 20px; }
        .sidebar-brand h3 { font-size: 1.5rem; font-weight: 600; margin: 0; }
        .sidebar-brand p { font-size: 0.85rem; opacity: 0.8; margin: 5px 0 0; }
        .sidebar-menu { list-style: none; padding: 0; margin: 0; }
        .sidebar-menu li { margin-bottom: 5px; }
        .sidebar-menu a {
            display: flex; align-items: center; padding: 12px 20px;
            color: rgba(255,255,255,0.8); text-decoration: none;
            transition: all 0.3s; border-left: 3px solid transparent;
        }
        .sidebar-menu a:hover, .sidebar-menu a.active {
            background: rgba(255,255,255,0.1); color: white; border-left-color: white;
        }
        .sidebar-menu a i { width: 30px; font-size: 1.2rem; }

        .main-content { margin-left: var(--sidebar-width); padding: 20px 30px; }
        .top-nav {
            background: white; border-radius: 15px; padding: 15px 25px;
            margin-bottom: 25px; box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            display: flex; justify-content: space-between; align-items: center;
        }
        .page-title h2 { font-size: 1.5rem; font-weight: 600; color: #212529; margin: 0; }
        .user-profile { display: flex; align-items: center; gap: 10px; }
        .user-avatar {
            width: 40px; height: 40px;
            background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%);
            border-radius: 50%; display: flex; align-items: center;
            justify-content: center; color: white; font-weight: 600;
        }
        .user-info .name { font-weight: 600; color: #212529; font-size: 0.9rem; }
        .user-info .role { font-size: 0.8rem; color: #6c757d; }

        .content-card {
            background: white; border-radius: 15px; padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        .card-header-bar {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 20px; padding-bottom: 15px; border-bottom: 2px solid #f0f0f0;
        }
        .card-header-bar h3 { font-size: 1.3rem; font-weight: 600; color: #212529; margin: 0; }

        .table th {
            background: #f8f9fa; color: #495057; font-weight: 600;
            font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.5px;
            border-bottom: 2px solid #dee2e6;
        }
        .table td { vertical-align: middle; color: #212529; }
        .badge-status { padding: 5px 10px; border-radius: 20px; font-size: 0.8rem; font-weight: 500; display: inline-block; }
        .badge-confirmed { background: #d4edda; color: #155724; }
        .badge-pending { background: #fff3cd; color: #856404; }
        .badge-checked-in { background: #cce5ff; color: #004085; }
        .badge-checked-out { background: #e2e3e5; color: #383d41; }
        .badge-cancelled { background: #f8d7da; color: #721c24; }
        .badge-paid { background: #d4edda; color: #155724; }
        .badge-unpaid { background: #f8d7da; color: #721c24; }

        .btn-action { padding: 5px 10px; border-radius: 5px; font-size: 0.8rem; margin: 0 2px; transition: all 0.3s; }
        .btn-action:hover { transform: translateY(-2px); }

        .search-box { display: flex; gap: 10px; margin-bottom: 20px; }
        .search-box input {
            flex: 1; padding: 10px 15px; border: 2px solid #e0e0e0;
            border-radius: 10px; font-size: 0.95rem; transition: all 0.3s;
        }
        .search-box input:focus { outline: none; border-color: var(--primary-color); box-shadow: 0 0 0 3px rgba(13,110,253,0.1); }
        .search-box button {
            padding: 10px 25px; background: var(--primary-color); color: white;
            border: none; border-radius: 10px; font-weight: 500; transition: all 0.3s; cursor: pointer;
        }
        .search-box button:hover { background: var(--primary-dark); }

        .alert { border-radius: 10px; padding: 15px 20px; margin-bottom: 20px; border: none; }
        .alert-success { background: #d4edda; color: #155724; }
        .alert-danger { background: #f8d7da; color: #721c24; }

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
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/dashboard">
            <i class="fas fa-chart-pie"></i><span>Dashboard</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations" class="active">
            <i class="fas fa-calendar-alt"></i><span>Reservations</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations/new">
            <i class="fas fa-plus-circle"></i><span>New Reservation</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations/search">
            <i class="fas fa-search"></i><span>Search</span></a></li>
        <% if (isAdmin) { %>
        <li><a href="${pageContext.request.contextPath}/admin/manage-rooms">
            <i class="fas fa-door-open"></i><span>Rooms</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/guests">
            <i class="fas fa-users"></i><span>Guests</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/reports">
            <i class="fas fa-chart-bar"></i><span>Reports</span></a></li>
        <% } else { %>
        <li><a href="${pageContext.request.contextPath}/staff/guests">
            <i class="fas fa-users"></i><span>Guests</span></a></li>
        <li><a href="${pageContext.request.contextPath}/staff/rooms">
            <i class="fas fa-door-open"></i><span>Rooms</span></a></li>
        <% } %>
        <li><a href="${pageContext.request.contextPath}/logout">
            <i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
    </ul>
</div>

<!-- Main Content -->
<div class="main-content">
    <div class="top-nav">
        <div class="page-title">
            <h2>${pageTitle}</h2>
        </div>
        <div class="user-profile">
            <div class="user-avatar">
                <%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %>
            </div>
            <div class="user-info d-none d-md-block">
                <div class="name"><%= user.getFullName() %></div>
                <div class="role"><%= user.getRole() %></div>
            </div>
        </div>
    </div>

    <!-- Alert Messages -->
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

    <!-- Search Box -->
    <div class="search-box">
        <input type="text" id="searchInput" placeholder="Search by reservation number, guest name, or room..."
               value="${param.search}">
        <button onclick="searchReservations()">
            <i class="fas fa-search me-2"></i>Search
        </button>
    </div>

    <!-- Reservations Table -->
    <div class="content-card">
        <div class="card-header-bar">
            <h3>All Reservations
                <c:if test="${not empty totalCount}">
                    <small class="text-muted fs-6">(${totalCount} total)</small>
                </c:if>
            </h3>
            <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/new" class="btn btn-primary">
                <i class="fas fa-plus-circle me-2"></i>New Reservation
            </a>
        </div>

        <div class="table-responsive">
            <table class="table table-hover" id="reservationsTable">
                <thead>
                <tr>
                    <th>Reservation #</th>
                    <th>Guest Name</th>
                    <th>Room</th>
                    <th>Check-in</th>
                    <th>Check-out</th>
                    <th>Nights</th>
                    <th>Total</th>
                    <th>Status</th>
                    <th>Payment</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty reservations}">
                        <tr>
                            <td colspan="10" class="text-center py-5 text-muted">
                                <i class="fas fa-calendar-times fa-3x mb-3 d-block" style="opacity:0.3;"></i>
                                No reservations found.
                                <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/new">Create one now</a>
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="res" items="${reservations}">
                            <tr>
                                <td><strong>${res.reservationNumber}</strong></td>
                                <td>
                                        ${res.guestName}<br>
                                    <small class="text-muted">${res.guestPhone}</small>
                                </td>
                                <td>
                                        ${res.roomNumber}<br>
                                    <small class="text-muted">${res.roomType}</small>
                                </td>
                                <td>${res.checkInDate}</td>
                                <td>${res.checkOutDate}</td>
                                <td>${res.totalNights}</td>
                                <td>$<fmt:formatNumber value="${res.totalAmount}" pattern="#,##0.00"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${res.reservationStatus == 'CONFIRMED'}">
                                            <span class="badge-status badge-confirmed">Confirmed</span>
                                        </c:when>
                                        <c:when test="${res.reservationStatus == 'CHECKED_IN'}">
                                            <span class="badge-status badge-checked-in">Checked In</span>
                                        </c:when>
                                        <c:when test="${res.reservationStatus == 'CHECKED_OUT'}">
                                            <span class="badge-status badge-checked-out">Checked Out</span>
                                        </c:when>
                                        <c:when test="${res.reservationStatus == 'CANCELLED'}">
                                            <span class="badge-status badge-cancelled">Cancelled</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-status badge-pending">Pending</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${res.paymentStatus == 'PAID'}">
                                            <span class="badge-status badge-paid">Paid</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-status badge-unpaid">${res.paymentStatus}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="btn-group" role="group">
                                        <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/view?id=${res.id}"
                                           class="btn btn-sm btn-outline-primary btn-action" title="View">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/edit?id=${res.id}"
                                           class="btn btn-sm btn-outline-success btn-action" title="Edit">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/print-bill?id=${res.id}"
                                           class="btn btn-sm btn-outline-info btn-action" title="Print Bill" target="_blank">
                                            <i class="fas fa-print"></i>
                                        </a>
                                            <%-- Check-in / Check-out quick actions --%>
                                        <c:if test="${res.reservationStatus == 'CONFIRMED'}">
                                            <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/checkin?id=${res.id}"
                                               class="btn btn-sm btn-outline-secondary btn-action" title="Check In"
                                               onclick="return confirm('Check in this guest?')">
                                                <i class="fas fa-sign-in-alt"></i>
                                            </a>
                                        </c:if>
                                        <c:if test="${res.reservationStatus == 'CHECKED_IN'}">
                                            <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/checkout?id=${res.id}"
                                               class="btn btn-sm btn-outline-warning btn-action" title="Check Out"
                                               onclick="return confirm('Check out this guest?')">
                                                <i class="fas fa-sign-out-alt"></i>
                                            </a>
                                        </c:if>
                                            <%-- Delete: available to both staff and admin --%>
                                        <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/delete?id=${res.id}"
                                           class="btn btn-sm btn-outline-danger btn-action"
                                           onclick="return confirm('Are you sure you want to delete this reservation?')"
                                           title="Delete">
                                            <i class="fas fa-trash"></i>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>

        <!-- Pagination -->
        <c:if test="${totalPages > 1}">
            <nav aria-label="Page navigation">
                <ul class="pagination justify-content-center mt-3">
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${currentPage - 1}&size=10">Previous</a>
                    </li>
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="page-item ${currentPage == i ? 'active' : ''}">
                            <a class="page-link" href="?page=${i}&size=10">${i}</a>
                        </li>
                    </c:forEach>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${currentPage + 1}&size=10">Next</a>
                    </li>
                </ul>
            </nav>
        </c:if>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.11.5/js/dataTables.bootstrap5.min.js"></script>
<script>
    $(document).ready(function() {
        $('#reservationsTable').DataTable({
            "paging": false, "searching": false, "info": false,
            "ordering": true, "order": [[3, "desc"]]
        });
    });

    function searchReservations() {
        var v = document.getElementById('searchInput').value;
        window.location.href = '${pageContext.request.contextPath}<%= basePath %>/reservations/search?searchValue=' + encodeURIComponent(v);
    }

    document.getElementById('searchInput').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') searchReservations();
    });
</script>
</body>
</html>
