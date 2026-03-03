<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<User> staffList = (List<User>) request.getAttribute("staffList");
    String success = request.getParameter("success");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Staff - Ocean View Hotel</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Font Awesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <!-- DataTables -->
    <link rel="stylesheet" href="https://cdn.datatables.net/1.11.5/css/dataTables.bootstrap5.min.css">

    <style>
        :root {
            --primary-color: #0d6efd;
            --primary-dark: #0b5ed7;
            --primary-light: #e6f2ff;
            --sidebar-width: 280px;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: #f4f6f9;
            overflow-x: hidden;
        }

        /* Sidebar Styles */
        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            width: var(--sidebar-width);
            background: linear-gradient(180deg, #0a58ca 0%, #0d6efd 100%);
            color: white;
            transition: all 0.3s;
            z-index: 1000;
            box-shadow: 5px 0 25px rgba(13, 110, 253, 0.3);
        }

        .sidebar-brand {
            padding: 25px 25px;
            border-bottom: 2px solid rgba(255,255,255,0.15);
            margin-bottom: 20px;
        }

        .sidebar-brand h3 {
            font-size: 1.8rem;
            font-weight: 700;
            margin: 0;
        }

        .sidebar-brand p {
            font-size: 0.9rem;
            opacity: 0.9;
            margin: 5px 0 0;
        }

        .sidebar-menu {
            list-style: none;
            padding: 0 15px;
            margin: 0;
        }

        .sidebar-menu li {
            margin-bottom: 8px;
        }

        .sidebar-menu a {
            display: flex;
            align-items: center;
            padding: 12px 20px;
            color: rgba(255,255,255,0.85);
            text-decoration: none;
            transition: all 0.3s;
            border-radius: 12px;
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

        /* Main Content */
        .main-content {
            margin-left: var(--sidebar-width);
            padding: 25px 35px;
        }

        /* Top Navigation */
        .top-nav {
            background: white;
            border-radius: 20px;
            padding: 15px 30px;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(13, 110, 253, 0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .page-title h2 {
            font-size: 1.8rem;
            font-weight: 600;
            color: var(--primary-color);
            margin: 0;
        }

        .page-title p {
            color: #6c757d;
            margin: 5px 0 0;
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .user-avatar {
            width: 45px;
            height: 45px;
            background: linear-gradient(135deg, #0d6efd, #0a58ca);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
        }

        /* Content Card */
        .content-card {
            background: white;
            border-radius: 20px;
            padding: 25px;
            box-shadow: 0 10px 30px rgba(13, 110, 253, 0.1);
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid #e9ecef;
        }

        .card-header h3 {
            font-size: 1.4rem;
            font-weight: 600;
            color: #212529;
            margin: 0;
        }

        .btn-primary {
            background: linear-gradient(135deg, #0d6efd, #0a58ca);
            border: none;
            padding: 10px 20px;
            border-radius: 12px;
            font-weight: 500;
            box-shadow: 0 5px 15px rgba(13, 110, 253, 0.3);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(13, 110, 253, 0.4);
        }

        /* Table Styles */
        .table {
            margin: 0;
        }

        .table th {
            border-top: none;
            color: #6c757d;
            font-weight: 600;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 15px 10px;
        }

        .table td {
            padding: 15px 10px;
            vertical-align: middle;
            color: #212529;
        }

        .badge-status {
            padding: 6px 12px;
            border-radius: 50px;
            font-size: 0.8rem;
            font-weight: 500;
        }

        .badge-active {
            background: #d4edda;
            color: #155724;
        }

        .badge-inactive {
            background: #f8d7da;
            color: #721c24;
        }

        .badge-admin {
            background: #cce5ff;
            color: #004085;
        }

        .badge-staff {
            background: #e2e3e5;
            color: #383d41;
        }

        .btn-action {
            padding: 6px 12px;
            border-radius: 8px;
            margin: 0 3px;
            font-size: 0.85rem;
        }

        /* Alert Messages */
        .alert {
            border-radius: 12px;
            padding: 15px 20px;
            margin-bottom: 25px;
            border: none;
        }

        .alert-success {
            background: #d4edda;
            color: #155724;
        }

        .alert-danger {
            background: #f8d7da;
            color: #721c24;
        }

        @media (max-width: 992px) {
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
        <li><a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fas fa-chart-pie"></i><span>Dashboard</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/manage-staff" class="active"><i class="fas fa-users-cog"></i><span>Manage Staff</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/manage-rooms"><i class="fas fa-door-open"></i><span>Manage Rooms</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/reservations"><i class="fas fa-calendar-alt"></i><span>All Reservations</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/guests"><i class="fas fa-users"></i><span>Guests</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/payments"><i class="fas fa-credit-card"></i><span>Payments & Bills</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/reports"><i class="fas fa-chart-bar"></i><span>Reports</span></a></li>
        <li><a href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
    </ul>
</div>

<!-- Main Content -->
<div class="main-content">
    <!-- Top Navigation -->
    <div class="top-nav">
        <div class="page-title">
            <h2>Manage Staff</h2>
            <p><i class="fas fa-users me-2"></i>View and manage hotel staff members</p>
        </div>
        <div class="user-profile">
            <div class="user-avatar">
                <%= currentUser.getFirstName().charAt(0) %><%= currentUser.getLastName().charAt(0) %>
            </div>
            <div>
                <div style="font-weight: 600;"><%= currentUser.getFullName() %></div>
                <div style="font-size: 0.8rem; color: #6c757d;"><%= currentUser.getRole() %></div>
            </div>
        </div>
    </div>

    <!-- Alert Messages -->
    <% if (success != null) { %>
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <% if ("created".equals(success)) { %>
        <i class="fas fa-check-circle me-2"></i>Staff member created successfully!
        <% } else if ("updated".equals(success)) { %>
        <i class="fas fa-check-circle me-2"></i>Staff member updated successfully!
        <% } else if ("deleted".equals(success)) { %>
        <i class="fas fa-check-circle me-2"></i>Staff member deactivated successfully!
        <% } else if ("statuschanged".equals(success)) { %>
        <i class="fas fa-check-circle me-2"></i>Staff status changed successfully!
        <% } %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <% if (error != null) { %>
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="fas fa-exclamation-circle me-2"></i><%= error %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <!-- Content Card -->
    <div class="content-card">
        <div class="card-header">
            <h3><i class="fas fa-list me-2" style="color: #0d6efd;"></i>Staff Members</h3>
            <a href="${pageContext.request.contextPath}/admin/manage-staff?action=new" class="btn btn-primary">
                <i class="fas fa-plus-circle me-2"></i>Add New Staff
            </a>
        </div>

        <div class="table-responsive">
            <table id="staffTable" class="table table-hover">
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Username</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>Role</th>
                    <th>Status</th>
                    <th>Last Login</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <% if (staffList != null && !staffList.isEmpty()) { %>
                <% for (User staff : staffList) { %>
                <tr>
                    <td><strong>#<%= staff.getId() %></strong></td>
                    <td><%= staff.getUsername() %></td>
                    <td><%= staff.getFullName() %></td>
                    <td><%= staff.getEmail() %></td>
                    <td><%= staff.getPhone() != null ? staff.getPhone() : "-" %></td>
                    <td>
                                    <span class="badge-status <%= staff.isAdmin() ? "badge-admin" : "badge-staff" %>">
                                        <%= staff.getRole() %>
                                    </span>
                    </td>
                    <td>
                                    <span class="badge-status <%= staff.isActive() ? "badge-active" : "badge-inactive" %>">
                                        <%= staff.isActive() ? "Active" : "Inactive" %>
                                    </span>
                    </td>
                    <td>
                        <% if (staff.getLastLogin() != null) { %>
                        <%= staff.getLastLogin().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) %>
                        <% } else { %>
                        Never
                        <% } %>
                    </td>
                    <td>
                        <a href="${pageContext.request.contextPath}/admin/manage-staff?action=view&id=<%= staff.getId() %>"
                           class="btn btn-sm btn-outline-primary btn-action" title="View">
                            <i class="fas fa-eye"></i>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/manage-staff?action=edit&id=<%= staff.getId() %>"
                           class="btn btn-sm btn-outline-success btn-action" title="Edit">
                            <i class="fas fa-edit"></i>
                        </a>
                        <% if (staff.isActive()) { %>
                        <a href="${pageContext.request.contextPath}/admin/manage-staff?action=toggle&id=<%= staff.getId() %>&toggle=deactivate"
                           class="btn btn-sm btn-outline-warning btn-action" title="Deactivate"
                           onclick="return confirm('Are you sure you want to deactivate this staff member?')">
                            <i class="fas fa-ban"></i>
                        </a>
                        <% } else { %>
                        <a href="${pageContext.request.contextPath}/admin/manage-staff?action=toggle&id=<%= staff.getId() %>&toggle=activate"
                           class="btn btn-sm btn-outline-success btn-action" title="Activate"
                           onclick="return confirm('Are you sure you want to activate this staff member?')">
                            <i class="fas fa-check-circle"></i>
                        </a>
                        <% } %>
                        <a href="${pageContext.request.contextPath}/admin/manage-staff?action=delete&id=<%= staff.getId() %>"
                           class="btn btn-sm btn-outline-danger btn-action" title="Delete"
                           onclick="return confirm('Are you sure you want to delete this staff member? This action cannot be undone.')">
                            <i class="fas fa-trash"></i>
                        </a>
                    </td>
                </tr>
                <% } %>
                <% } else { %>
                <tr>
                    <td colspan="9" class="text-center py-4">
                        <i class="fas fa-users fa-3x mb-3" style="color: #dee2e6;"></i>
                        <p class="mb-0">No staff members found</p>
                        <a href="${pageContext.request.contextPath}/admin/manage-staff?action=new" class="btn btn-link">Add your first staff member</a>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.11.5/js/dataTables.bootstrap5.min.js"></script>

<script>
    $(document).ready(function() {
        $('#staffTable').DataTable({
            pageLength: 10,
            order: [[0, 'desc']],
            language: {
                search: "Search staff:",
                lengthMenu: "Show _MENU_ entries",
                info: "Showing _START_ to _END_ of _TOTAL_ staff members"
            }
        });

        // Auto-hide alerts after 5 seconds
        setTimeout(function() {
            $('.alert').fadeOut('slow');
        }, 5000);
    });
</script>
</body>
</html>