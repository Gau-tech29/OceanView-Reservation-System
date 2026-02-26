<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String mode = (String) request.getAttribute("mode");
    User staff = (User) request.getAttribute("staff");
    String error = (String) request.getAttribute("error");

    boolean isEdit = "edit".equals(mode);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Edit" : "Add" %> Staff - Ocean View Hotel</title>

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
        }

        /* Sidebar Styles (same as before) */
        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            width: var(--sidebar-width);
            background: linear-gradient(180deg, #0a58ca 0%, #0d6efd 100%);
            color: white;
            z-index: 1000;
            box-shadow: 5px 0 25px rgba(13, 110, 253, 0.3);
        }

        .sidebar-brand {
            padding: 25px 25px;
            border-bottom: 2px solid rgba(255,255,255,0.15);
        }

        .sidebar-brand h3 {
            font-size: 1.8rem;
            font-weight: 700;
            margin: 0;
        }

        .sidebar-menu {
            list-style: none;
            padding: 0 15px;
            margin-top: 20px;
        }

        .sidebar-menu a {
            display: flex;
            align-items: center;
            padding: 12px 20px;
            color: rgba(255,255,255,0.85);
            text-decoration: none;
            border-radius: 12px;
            margin-bottom: 8px;
        }

        .sidebar-menu a:hover,
        .sidebar-menu a.active {
            background: rgba(255,255,255,0.15);
            color: white;
        }

        .sidebar-menu a i {
            width: 30px;
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

        /* Form Card */
        .form-card {
            background: white;
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(13, 110, 253, 0.1);
        }

        .form-header {
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid #e9ecef;
        }

        .form-header h3 {
            font-size: 1.4rem;
            font-weight: 600;
            color: #212529;
            margin: 0;
        }

        .form-label {
            font-weight: 500;
            color: #495057;
            margin-bottom: 8px;
        }

        .form-control, .form-select {
            border: 2px solid #e9ecef;
            border-radius: 12px;
            padding: 12px 15px;
            font-size: 0.95rem;
            transition: all 0.3s;
        }

        .form-control:focus, .form-select:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 4px rgba(13, 110, 253, 0.1);
            outline: none;
        }

        .input-group-text {
            background: #f8f9fa;
            border: 2px solid #e9ecef;
            border-radius: 12px 0 0 12px;
            color: #6c757d;
        }

        .btn-primary {
            background: linear-gradient(135deg, #0d6efd, #0a58ca);
            border: none;
            padding: 12px 30px;
            border-radius: 12px;
            font-weight: 500;
            box-shadow: 0 5px 15px rgba(13, 110, 253, 0.3);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(13, 110, 253, 0.4);
        }

        .btn-secondary {
            background: white;
            border: 2px solid #e9ecef;
            color: #495057;
            padding: 12px 30px;
            border-radius: 12px;
            font-weight: 500;
        }

        .btn-secondary:hover {
            background: #f8f9fa;
            border-color: #dee2e6;
        }

        .alert {
            border-radius: 12px;
            padding: 15px 20px;
            margin-bottom: 25px;
            border: none;
        }

        .alert-danger {
            background: #f8d7da;
            color: #721c24;
        }

        .form-check-input {
            width: 20px;
            height: 20px;
            margin-right: 10px;
            cursor: pointer;
        }

        .form-check-input:checked {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }

        .form-check-label {
            cursor: pointer;
            color: #495057;
        }

        .password-hint {
            font-size: 0.85rem;
            color: #6c757d;
            margin-top: 5px;
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
        <li><a href="#"><i class="fas fa-calendar-alt"></i><span>All Reservations</span></a></li>
        <li><a href="#"><i class="fas fa-users"></i><span>Guests</span></a></li>
        <li><a href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
    </ul>
</div>

<!-- Main Content -->
<div class="main-content">
    <!-- Top Navigation -->
    <div class="top-nav">
        <div class="page-title">
            <h2><%= isEdit ? "Edit Staff" : "Add New Staff" %></h2>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/admin/manage-staff" class="btn btn-outline-secondary">
                <i class="fas fa-arrow-left me-2"></i>Back to List
            </a>
        </div>
    </div>

    <!-- Error Alert -->
    <% if (error != null) { %>
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="fas fa-exclamation-circle me-2"></i><%= error %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <!-- Form Card -->
    <div class="form-card">
        <div class="form-header">
            <h3><i class="fas fa-user-edit me-2" style="color: #0d6efd;"></i><%= isEdit ? "Edit Staff Information" : "Staff Information" %></h3>
        </div>

        <form action="${pageContext.request.contextPath}/admin/manage-staff" method="POST" id="staffForm">
            <input type="hidden" name="action" value="<%= isEdit ? "update" : "create" %>">
            <% if (isEdit) { %>
            <input type="hidden" name="id" value="<%= staff.getId() %>">
            <% } %>

            <div class="row">
                <div class="col-md-6 mb-4">
                    <label class="form-label">Username</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-user"></i></span>
                        <input type="text"
                               class="form-control"
                               name="username"
                               value="<%= isEdit ? staff.getUsername() : "" %>"
                            <%= isEdit ? "readonly" : "required" %>
                               placeholder="Enter username">
                    </div>
                    <% if (!isEdit) { %>
                    <div class="password-hint">
                        <i class="fas fa-info-circle me-1"></i>3-50 characters, alphanumeric and underscore only
                    </div>
                    <% } %>
                </div>

                <% if (!isEdit) { %>
                <div class="col-md-6 mb-4">
                    <label class="form-label">Password</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-lock"></i></span>
                        <input type="password"
                               class="form-control"
                               name="password"
                               required
                               placeholder="Enter password">
                    </div>
                    <div class="password-hint">
                        <i class="fas fa-info-circle me-1"></i>Min 8 characters with uppercase, lowercase and number
                    </div>
                </div>
                <% } %>

                <div class="col-md-6 mb-4">
                    <label class="form-label">First Name</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-signature"></i></span>
                        <input type="text"
                               class="form-control"
                               name="firstName"
                               value="<%= isEdit ? staff.getFirstName() : "" %>"
                               required
                               placeholder="Enter first name">
                    </div>
                </div>

                <div class="col-md-6 mb-4">
                    <label class="form-label">Last Name</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-signature"></i></span>
                        <input type="text"
                               class="form-control"
                               name="lastName"
                               value="<%= isEdit ? staff.getLastName() : "" %>"
                               required
                               placeholder="Enter last name">
                    </div>
                </div>

                <div class="col-md-6 mb-4">
                    <label class="form-label">Email</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-envelope"></i></span>
                        <input type="email"
                               class="form-control"
                               name="email"
                               value="<%= isEdit ? staff.getEmail() : "" %>"
                               required
                               placeholder="Enter email">
                    </div>
                </div>

                <div class="col-md-6 mb-4">
                    <label class="form-label">Phone Number</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-phone"></i></span>
                        <input type="tel"
                               class="form-control"
                               name="phone"
                               value="<%= isEdit ? staff.getPhone() : "" %>"
                               placeholder="Enter phone number">
                    </div>
                </div>

                <div class="col-md-6 mb-4">
                    <label class="form-label">Role</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-user-tag"></i></span>
                        <select class="form-select" name="role" required>
                            <option value="STAFF" <%= isEdit && staff.getRole() == User.UserRole.STAFF ? "selected" : "" %>>Staff</option>
                            <option value="ADMIN" <%= isEdit && staff.getRole() == User.UserRole.ADMIN ? "selected" : "" %>>Admin</option>
                        </select>
                    </div>
                </div>

                <div class="col-md-6 mb-4">
                    <label class="form-label">Status</label>
                    <div class="form-check form-switch mt-2">
                        <input class="form-check-input"
                               type="checkbox"
                               name="active"
                               id="activeSwitch"
                            <%= isEdit && staff.isActive() ? "checked" : "checked" %>>
                        <label class="form-check-label" for="activeSwitch">Active</label>
                    </div>
                </div>
            </div>

            <div class="mt-4 text-end">
                <a href="${pageContext.request.contextPath}/admin/manage-staff" class="btn btn-secondary me-2">
                    <i class="fas fa-times me-2"></i>Cancel
                </a>
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save me-2"></i><%= isEdit ? "Update Staff" : "Create Staff" %>
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Scripts -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
    $(document).ready(function() {
        // Form validation
        $('#staffForm').on('submit', function(e) {
            <% if (!isEdit) { %>
            var password = $('input[name="password"]').val();
            if (password.length < 8) {
                alert('Password must be at least 8 characters long');
                e.preventDefault();
                return false;
            }

            var hasUpper = /[A-Z]/.test(password);
            var hasLower = /[a-z]/.test(password);
            var hasNumber = /[0-9]/.test(password);

            if (!hasUpper || !hasLower || !hasNumber) {
                alert('Password must contain at least one uppercase letter, one lowercase letter, and one number');
                e.preventDefault();
                return false;
            }
            <% } %>

            var email = $('input[name="email"]').val();
            var emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailPattern.test(email)) {
                alert('Please enter a valid email address');
                e.preventDefault();
                return false;
            }

            return true;
        });

        // Auto-hide alerts
        setTimeout(function() {
            $('.alert').fadeOut('slow');
        }, 5000);
    });
</script>
</body>
</html>