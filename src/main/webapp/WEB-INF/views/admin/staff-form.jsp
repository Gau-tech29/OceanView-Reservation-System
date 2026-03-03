<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    String mode  = (String) request.getAttribute("mode");
    User   staff = (User)   request.getAttribute("staff");
    String error = (String) request.getAttribute("error");
    boolean isEdit = "edit".equals(mode);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Edit" : "Add" %> Staff - Ocean View Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root { --primary:#0d6efd; --sidebar-width:280px; }
        body { font-family:'Poppins',sans-serif; background:#f4f6f9; }
        .sidebar {
            position:fixed; top:0; left:0; height:100vh; width:var(--sidebar-width);
            background:linear-gradient(180deg,#0a58ca 0%,#0d6efd 100%);
            color:white; z-index:1000; overflow-y:auto;
        }
        .sidebar-brand { padding:25px; border-bottom:2px solid rgba(255,255,255,.15); }
        .sidebar-brand h3 { font-size:1.6rem; font-weight:700; margin:0; }
        .sidebar-brand p  { font-size:.85rem; opacity:.9; margin:4px 0 0; }
        .sidebar-menu { list-style:none; padding:10px 15px; margin:0; }
        .sidebar-menu li { margin-bottom:6px; }
        .sidebar-menu a {
            display:flex; align-items:center; padding:12px 20px;
            color:rgba(255,255,255,.85); text-decoration:none;
            border-radius:12px; transition:all .3s;
        }
        .sidebar-menu a:hover, .sidebar-menu a.active { background:rgba(255,255,255,.15); color:white; transform:translateX(5px); }
        .sidebar-menu a i { width:30px; }
        .main-content { margin-left:var(--sidebar-width); padding:25px 35px; }
        .top-nav {
            background:white; border-radius:18px; padding:16px 28px;
            margin-bottom:28px; box-shadow:0 4px 20px rgba(13,110,253,.1);
            display:flex; justify-content:space-between; align-items:center;
        }
        .page-title h2 { font-size:1.6rem; font-weight:600; color:var(--primary); margin:0; }
        .form-card { background:white; border-radius:18px; padding:30px; box-shadow:0 4px 20px rgba(13,110,253,.08); }
        .form-section-title {
            font-size:1rem; font-weight:600; color:#212529;
            margin-bottom:18px; padding-bottom:10px; border-bottom:2px solid #e9ecef;
            display:flex; align-items:center; gap:8px;
        }
        .form-section-title i { color:var(--primary); }
        .form-label { font-weight:500; color:#495057; margin-bottom:7px; }
        .form-control, .form-select {
            border:2px solid #e9ecef; border-radius:12px;
            padding:11px 15px; font-size:.9rem; transition:all .3s;
        }
        .form-control:focus, .form-select:focus {
            border-color:var(--primary); box-shadow:0 0 0 4px rgba(13,110,253,.1); outline:none;
        }
        .input-group-text { background:#f8f9fa; border:2px solid #e9ecef; color:#6c757d; border-radius:12px 0 0 12px; }
        .input-group .form-control { border-radius:0 12px 12px 0; }
        .hint { font-size:.8rem; color:#6c757d; margin-top:5px; }
        .hint i { color:var(--primary); }
        .btn-save {
            background:linear-gradient(135deg,#0d6efd,#0a58ca); color:white; border:none;
            padding:12px 32px; border-radius:12px; font-weight:500; font-size:.9rem;
            transition:all .2s; box-shadow:0 4px 15px rgba(13,110,253,.3);
        }
        .btn-save:hover { transform:translateY(-2px); box-shadow:0 6px 20px rgba(13,110,253,.4); color:white; }
        .btn-cancel {
            background:white; border:2px solid #e9ecef; color:#495057;
            padding:12px 28px; border-radius:12px; font-weight:500;
            text-decoration:none; display:inline-flex; align-items:center; gap:6px;
        }
        .btn-cancel:hover { background:#f8f9fa; color:#495057; }
        .alert-error { background:#fee2e2; color:#991b1b; border-radius:12px; padding:13px 18px; margin-bottom:22px; display:flex; align-items:center; gap:10px; border:none; }
        .notice-box {
            background:#eff6ff; border:1.5px solid #bfdbfe; border-radius:12px;
            padding:14px 18px; margin-top:6px; display:flex; align-items:flex-start; gap:10px; font-size:.875rem; color:#1e40af;
        }
        .notice-box i { margin-top:2px; flex-shrink:0; }
        @media(max-width:992px){ .sidebar{transform:translateX(-100%);} .main-content{margin-left:0; padding:15px;} }
    </style>
</head>
<body>
<div class="sidebar">
    <div class="sidebar-brand">
        <h3><i class="fas fa-hotel me-2"></i>Ocean View</h3>
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

<div class="main-content">
    <div class="top-nav">
        <div class="page-title">
            <h2><i class="fas fa-<%= isEdit ? "user-edit" : "user-plus" %> me-2"></i><%= isEdit ? "Edit Staff Member" : "Add New Staff Member" %></h2>
        </div>
        <a href="${pageContext.request.contextPath}/admin/manage-staff" class="btn-cancel">
            <i class="fas fa-arrow-left"></i> Back to List
        </a>
    </div>

    <% if (error != null) { %>
    <div class="alert-error"><i class="fas fa-exclamation-circle"></i> <%= error %></div>
    <% } %>

    <div class="form-card">
        <form action="${pageContext.request.contextPath}/admin/manage-staff" method="POST" id="staffForm">
            <input type="hidden" name="action" value="<%= isEdit ? "update" : "create" %>">
            <% if (isEdit && staff != null) { %><input type="hidden" name="id" value="<%= staff.getId() %>"><% } %>

            <!-- Personal Info -->
            <div class="form-section-title"><i class="fas fa-id-card"></i>Personal Information</div>
            <div class="row g-3 mb-4">
                <div class="col-md-6">
                    <label class="form-label">First Name <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-user"></i></span>
                        <input type="text" class="form-control" name="firstName" required placeholder="First name"
                               value="<%= (isEdit && staff != null) ? staff.getFirstName() : "" %>">
                    </div>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Last Name <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-user"></i></span>
                        <input type="text" class="form-control" name="lastName" required placeholder="Last name"
                               value="<%= (isEdit && staff != null) ? staff.getLastName() : "" %>">
                    </div>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Email Address <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-envelope"></i></span>
                        <input type="email" class="form-control" name="email" required placeholder="email@example.com"
                               value="<%= (isEdit && staff != null) ? staff.getEmail() : "" %>">
                    </div>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Phone Number</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-phone"></i></span>
                        <input type="tel" class="form-control" name="phone" placeholder="e.g. +94771234567"
                               value="<%= (isEdit && staff != null && staff.getPhone() != null) ? staff.getPhone() : "" %>">
                    </div>
                </div>
            </div>

            <!-- Account Settings -->
            <div class="form-section-title"><i class="fas fa-cog"></i>Account Settings</div>
            <div class="row g-3 mb-4">
                <div class="col-md-6">
                    <label class="form-label">Username <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-at"></i></span>
                        <input type="text" class="form-control" name="username"
                            <%= isEdit ? "readonly style=\"background:#f8f9fa;\"" : "required" %>
                               placeholder="username"
                               value="<%= (isEdit && staff != null) ? staff.getUsername() : "" %>">
                    </div>
                    <% if (!isEdit) { %><div class="hint"><i class="fas fa-info-circle"></i> 3–50 characters, letters, numbers and underscore only</div><% } %>
                    <% if (isEdit) { %><div class="hint"><i class="fas fa-lock"></i> Username cannot be changed after creation</div><% } %>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Role <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-user-tag"></i></span>
                        <select class="form-select" name="role" required>
                            <option value="STAFF" <%= (isEdit && staff != null && staff.getRole() == User.UserRole.STAFF) ? "selected" : "" %>>Staff</option>
                            <option value="ADMIN" <%= (isEdit && staff != null && staff.getRole() == User.UserRole.ADMIN) ? "selected" : "" %>>Admin</option>
                        </select>
                    </div>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Status</label>
                    <div class="d-flex align-items-center gap-3 mt-2">
                        <div class="form-check form-switch">
                            <input class="form-check-input" type="checkbox" name="active" id="activeSwitch"
                                   style="width:44px; height:22px; cursor:pointer;"
                                <%= (!isEdit || (isEdit && staff != null && staff.isActive())) ? "checked" : "" %>>
                            <label class="form-check-label ms-2" for="activeSwitch" style="cursor:pointer; font-weight:500;">Active</label>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Password section — create only -->
            <% if (!isEdit) { %>
            <div class="form-section-title"><i class="fas fa-lock"></i>Password</div>
            <div class="row g-3 mb-4">
                <div class="col-md-6">
                    <label class="form-label">Password <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-lock"></i></span>
                        <input type="password" class="form-control" name="password" id="pw" required placeholder="Enter password">
                        <button type="button" class="btn btn-outline-secondary" style="border-radius:0 12px 12px 0;" onclick="togglePw('pw','eyePw')">
                            <i class="fas fa-eye" id="eyePw"></i>
                        </button>
                    </div>
                    <div class="hint"><i class="fas fa-info-circle"></i> Min 8 chars · uppercase · lowercase · number</div>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Confirm Password <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-lock"></i></span>
                        <input type="password" class="form-control" name="confirmPassword" id="cpw" required placeholder="Confirm password">
                        <button type="button" class="btn btn-outline-secondary" style="border-radius:0 12px 12px 0;" onclick="togglePw('cpw','eyeCpw')">
                            <i class="fas fa-eye" id="eyeCpw"></i>
                        </button>
                    </div>
                </div>
            </div>
            <% } %>

            <!-- Password notice for edit mode -->
            <% if (isEdit && staff != null) { %>
            <div class="notice-box mb-4">
                <i class="fas fa-info-circle"></i>
                <div>
                    <strong>Password not shown here.</strong>
                    To reset this user's password, use the
                    <a href="${pageContext.request.contextPath}/admin/manage-staff?action=resetpw&id=<%= staff.getId() %>"
                       style="color:#1e40af; font-weight:600;">
                        <i class="fas fa-key me-1"></i>Reset Password
                    </a>
                    option instead.
                </div>
            </div>
            <% } %>

            <div class="text-end d-flex justify-content-end gap-2">
                <a href="${pageContext.request.contextPath}/admin/manage-staff" class="btn-cancel">
                    <i class="fas fa-times"></i> Cancel
                </a>
                <button type="submit" class="btn-save">
                    <i class="fas fa-save me-2"></i><%= isEdit ? "Save Changes" : "Create Staff Member" %>
                </button>
            </div>
        </form>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function togglePw(inputId, iconId) {
        var inp = document.getElementById(inputId);
        var ico = document.getElementById(iconId);
        if (inp.type === 'password') { inp.type = 'text'; ico.className = 'fas fa-eye-slash'; }
        else { inp.type = 'password'; ico.className = 'fas fa-eye'; }
    }

    $('#staffForm').on('submit', function(e) {
        <% if (!isEdit) { %>
        var pw  = $('#pw').val();
        var cpw = $('#cpw').val();
        if (pw !== cpw) { alert('Passwords do not match.'); e.preventDefault(); return false; }
        if (pw.length < 8) { alert('Password must be at least 8 characters.'); e.preventDefault(); return false; }
        if (!/[A-Z]/.test(pw) || !/[a-z]/.test(pw) || !/[0-9]/.test(pw)) {
            alert('Password must contain uppercase, lowercase and a number.'); e.preventDefault(); return false;
        }
        <% } %>
        var email = $('input[name="email"]').val();
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) { alert('Invalid email address.'); e.preventDefault(); return false; }
        return true;
    });
</script>
</body>
</html>