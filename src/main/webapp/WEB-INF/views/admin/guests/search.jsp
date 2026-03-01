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
    <title>Search Guests - Ocean View Hotel</title>
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
        .search-card {
            background: white; border-radius: 15px; padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        .search-box {
            display: flex; gap: 10px; margin-bottom: 30px;
        }
        .search-box input {
            flex: 1; padding: 12px 20px; border: 2px solid #e0e0e0;
            border-radius: 10px; font-size: 1rem;
        }
        .search-box button {
            padding: 12px 30px; background: var(--primary-color); color: white;
            border: none; border-radius: 10px; font-weight: 500;
        }
    </style>
</head>
<body>

<div class="sidebar">
    <div class="sidebar-brand">
        <h3>Ocean View</h3>
        <p>Hotel Reservation System</p>
    </div>
    <ul class="sidebar-menu">
        <li><a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fas fa-chart-pie"></i>Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/admin/reservations"><i class="fas fa-calendar-alt"></i>Reservations</a></li>
        <li><a href="${pageContext.request.contextPath}/admin/guests" class="active"><i class="fas fa-users"></i>Guests</a></li>
        <li><a href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i>Logout</a></li>
    </ul>
</div>

<div class="main-content">
    <div class="top-nav">
        <h2>Search Guests</h2>
        <div class="user-avatar">
            <%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %>
        </div>
    </div>

    <div class="search-card">
        <div class="search-box">
            <input type="text" id="searchInput" placeholder="Enter name, email, phone or guest number..."
                   value="${keyword}">
            <button onclick="searchGuests()">
                <i class="fas fa-search me-2"></i>Search
            </button>
        </div>

        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                <tr>
                    <th>Guest #</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>VIP</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="guest" items="${results}">
                    <tr>
                        <td>${guest.guestNumber}</td>
                        <td>${guest.fullName}</td>
                        <td>${guest.email}</td>
                        <td>${guest.phone}</td>
                        <td>
                            <c:if test="${guest.isVip}">
                                <span class="badge bg-warning">VIP</span>
                            </c:if>
                        </td>
                        <td>
                            <a href="${pageContext.request.contextPath}/admin/guests/view?id=${guest.id}"
                               class="btn btn-sm btn-primary">View</a>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty results}">
                    <tr>
                        <td colspan="6" class="text-center py-4">
                            No guests found. Try a different search term.
                        </td>
                    </tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    function searchGuests() {
        var keyword = document.getElementById('searchInput').value;
        window.location.href = '${pageContext.request.contextPath}/admin/guests/search?keyword=' +
            encodeURIComponent(keyword);
    }

    document.getElementById('searchInput').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') searchGuests();
    });
</script>
</body>
</html>