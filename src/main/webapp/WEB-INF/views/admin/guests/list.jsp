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
    <title>Manage Guests - Ocean View Hotel</title>
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

        /* Sidebar Styles */
        .sidebar {
            position: fixed; top: 0; left: 0; height: 100vh; width: var(--sidebar-width);
            background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%);
            color: white; padding: 20px 0; transition: all 0.3s; z-index: 1000;
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

        /* Main Content */
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

        /* Content Card */
        .content-card {
            background: white; border-radius: 15px; padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        .card-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 20px; padding-bottom: 15px; border-bottom: 2px solid #f0f0f0;
        }
        .card-header h3 { font-size: 1.3rem; font-weight: 600; color: #212529; margin: 0; }

        /* Search Box */
        .search-box {
            display: flex; gap: 10px; margin-bottom: 20px;
        }
        .search-box input {
            flex: 1; padding: 10px 15px; border: 2px solid #e0e0e0;
            border-radius: 10px; font-size: 0.95rem;
        }
        .search-box input:focus {
            outline: none; border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.1);
        }
        .search-box button {
            padding: 10px 25px; background: var(--primary-color); color: white;
            border: none; border-radius: 10px; font-weight: 500;
        }

        /* Table */
        .table th {
            background: #f8f9fa; color: #495057; font-weight: 600;
            font-size: 0.9rem; text-transform: uppercase;
        }
        .table td { vertical-align: middle; }
        .badge-vip { background: #ffc107; color: #212529; padding: 5px 10px; border-radius: 20px; }
        .btn-action { padding: 5px 10px; border-radius: 5px; margin: 0 2px; }
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
            <h2>Manage Guests</h2>
        </div>
        <div class="user-avatar">
            <%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %>
        </div>
    </div>

    <!-- Search Box -->
    <div class="search-box">
        <input type="text" id="searchInput" placeholder="Search by name, email, phone or guest number..."
               value="${param.keyword}">
        <button onclick="searchGuests()">
            <i class="fas fa-search me-2"></i>Search
        </button>
    </div>

    <!-- Guests Table -->
    <div class="content-card">
        <div class="card-header">
            <h3>All Guests</h3>
            <a href="${pageContext.request.contextPath}/admin/guests/new" class="btn btn-primary">
                <i class="fas fa-plus-circle me-2"></i>Add Guest
            </a>
        </div>

        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                <tr>
                    <th>Guest #</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>VIP Status</th>
                    <th>Loyalty Points</th>
                    <th>Created</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="guest" items="${guests}">
                    <tr>
                        <td><strong>${guest.guestNumber}</strong></td>
                        <td>${guest.fullName}</td>
                        <td>${guest.email}</td>
                        <td>${guest.phone}</td>
                        <td>
                            <c:if test="${guest.isVip}">
                                <span class="badge-vip"><i class="fas fa-crown me-1"></i>VIP</span>
                            </c:if>
                        </td>
                        <td>${guest.loyaltyPoints}</td>
                        <td><fmt:formatDate value="${guest.createdAt}" pattern="dd MMM yyyy"/></td>
                        <td>
                            <a href="${pageContext.request.contextPath}/admin/guests/view?id=${guest.id}"
                               class="btn btn-sm btn-outline-primary btn-action" title="View">
                                <i class="fas fa-eye"></i>
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/guests/edit?id=${guest.id}"
                               class="btn btn-sm btn-outline-success btn-action" title="Edit">
                                <i class="fas fa-edit"></i>
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/reservations/new?guestId=${guest.id}"
                               class="btn btn-sm btn-outline-info btn-action" title="New Reservation">
                                <i class="fas fa-plus-circle"></i>
                            </a>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>

        <!-- Pagination -->
        <c:if test="${totalPages > 1}">
            <nav aria-label="Page navigation">
                <ul class="pagination justify-content-center">
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

<script>
    function searchGuests() {
        var keyword = document.getElementById('searchInput').value;
        window.location.href = '${pageContext.request.contextPath}/admin/guests/search?keyword=' + encodeURIComponent(keyword);
    }

    document.getElementById('searchInput').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            searchGuests();
        }
    });
</script>
</body>
</html>