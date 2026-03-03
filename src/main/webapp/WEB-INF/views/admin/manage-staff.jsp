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
    String successMsg = (String) request.getAttribute("successMsg");
    String errorMsg   = (String) request.getAttribute("errorMsg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Staff - Ocean View Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.11.5/css/dataTables.bootstrap5.min.css">
    <style>
        :root { --primary: #0d6efd; --primary-dark: #0b5ed7; --sidebar-width: 280px; }
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Poppins',sans-serif; background:#f4f6f9; overflow-x:hidden; }

        .sidebar {
            position:fixed; top:0; left:0; height:100vh; width:var(--sidebar-width);
            background:linear-gradient(180deg,#0a58ca 0%,#0d6efd 100%);
            color:white; z-index:1000; box-shadow:5px 0 25px rgba(13,110,253,.3); overflow-y:auto;
        }
        .sidebar-brand { padding:25px; border-bottom:2px solid rgba(255,255,255,.15); margin-bottom:10px; }
        .sidebar-brand h3 { font-size:1.6rem; font-weight:700; margin:0; }
        .sidebar-brand p  { font-size:.85rem; opacity:.9; margin:4px 0 0; }
        .sidebar-menu { list-style:none; padding:0 15px; margin:0; }
        .sidebar-menu li { margin-bottom:6px; }
        .sidebar-menu a {
            display:flex; align-items:center; padding:12px 20px;
            color:rgba(255,255,255,.85); text-decoration:none;
            transition:all .3s; border-radius:12px;
        }
        .sidebar-menu a:hover, .sidebar-menu a.active { background:rgba(255,255,255,.15); color:white; transform:translateX(5px); }
        .sidebar-menu a i { width:30px; font-size:1.1rem; }
        .sidebar-menu a span { font-size:.9rem; font-weight:500; }

        .main-content { margin-left:var(--sidebar-width); padding:25px 35px; }
        .top-nav {
            background:white; border-radius:18px; padding:16px 28px;
            margin-bottom:28px; box-shadow:0 4px 20px rgba(13,110,253,.1);
            display:flex; justify-content:space-between; align-items:center;
        }
        .page-title h2 { font-size:1.6rem; font-weight:600; color:var(--primary); margin:0; }
        .page-title p  { color:#6c757d; margin:4px 0 0; font-size:.875rem; }
        .user-avatar {
            width:42px; height:42px; background:linear-gradient(135deg,#0d6efd,#0a58ca);
            border-radius:12px; display:flex; align-items:center;
            justify-content:center; color:white; font-weight:600; font-size:1rem;
        }

        .content-card {
            background:white; border-radius:18px; padding:24px;
            box-shadow:0 4px 20px rgba(13,110,253,.08);
        }
        .card-header-bar {
            display:flex; justify-content:space-between; align-items:center;
            margin-bottom:22px; padding-bottom:14px; border-bottom:2px solid #e9ecef;
        }
        .card-header-bar h3 { font-size:1.2rem; font-weight:600; color:#212529; margin:0; }

        .btn-add-staff {
            background:linear-gradient(135deg,#0d6efd,#0a58ca); color:white; border:none;
            padding:10px 22px; border-radius:12px; font-weight:500; font-size:.875rem;
            text-decoration:none; display:inline-flex; align-items:center; gap:7px;
            transition:all .2s; box-shadow:0 4px 15px rgba(13,110,253,.3);
        }
        .btn-add-staff:hover { transform:translateY(-2px); box-shadow:0 6px 20px rgba(13,110,253,.4); color:white; }

        /* Table */
        .table th { color:#6c757d; font-weight:600; font-size:.8rem; text-transform:uppercase; letter-spacing:.5px; padding:14px 10px; border-top:none; }
        .table td { padding:14px 10px; vertical-align:middle; font-size:.875rem; }
        .table tbody tr { transition:background .15s; }
        .table tbody tr:hover { background:#fafbff; }

        /* Badges */
        .badge-pill { padding:5px 13px; border-radius:50px; font-size:.76rem; font-weight:600; display:inline-block; }
        .badge-active    { background:#d1fae5; color:#065f46; }
        .badge-inactive  { background:#fee2e2; color:#991b1b; }
        .badge-admin-role{ background:#dbeafe; color:#1e40af; }
        .badge-staff-role{ background:#e5e7eb; color:#374151; }

        /* Action buttons */
        .btn-act { padding:5px 10px; border-radius:8px; font-size:.78rem; font-weight:500; margin:1px; transition:all .15s; }
        .btn-act:hover { transform:translateY(-1px); }
        .btn-act.btn-resetpw { background:#7c3aed; color:white; border:none; }
        .btn-act.btn-resetpw:hover { background:#6d28d9; color:white; box-shadow:0 3px 10px rgba(124,58,237,.3); }

        /* Alert */
        .alert-custom {
            border-radius:12px; padding:13px 18px; margin-bottom:22px;
            display:flex; align-items:center; gap:10px; font-size:.875rem; border:none;
        }
        .alert-success-custom { background:#d1fae5; color:#065f46; }
        .alert-error-custom   { background:#fee2e2; color:#991b1b; }

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
            <h2><i class="fas fa-users-cog me-2"></i>Manage Staff</h2>
            <p>View, manage and configure hotel staff members</p>
        </div>
        <div class="d-flex align-items-center gap-3">
            <div class="user-avatar"><%= currentUser.getFirstName().charAt(0) %><%= currentUser.getLastName().charAt(0) %></div>
            <div>
                <div style="font-weight:600; font-size:.9rem;"><%= currentUser.getFullName() %></div>
                <div style="font-size:.75rem; color:#6c757d;"><%= currentUser.getRole() %></div>
            </div>
        </div>
    </div>

    <% if (successMsg != null) { %>
    <div class="alert-custom alert-success-custom">
        <i class="fas fa-check-circle"></i> <%= successMsg %>
    </div>
    <% } %>
    <% if (errorMsg != null) { %>
    <div class="alert-custom alert-error-custom">
        <i class="fas fa-exclamation-circle"></i> <%= errorMsg %>
    </div>
    <% } %>

    <div class="content-card">
        <div class="card-header-bar">
            <h3><i class="fas fa-list me-2" style="color:var(--primary);"></i>Staff Members
                <% if (staffList != null) { %>
                <span style="font-size:.85rem; color:#6c757d; font-weight:400; margin-left:8px;">(<%= staffList.size() %> total)</span>
                <% } %>
            </h3>
            <a href="${pageContext.request.contextPath}/admin/manage-staff?action=new" class="btn-add-staff">
                <i class="fas fa-plus-circle"></i> Add New Staff
            </a>
        </div>

        <div class="table-responsive">
            <table id="staffTable" class="table table-hover">
                <thead>
                <tr>
                    <th>ID</th><th>Username</th><th>Name</th><th>Email</th>
                    <th>Phone</th><th>Role</th><th>Status</th><th>Last Login</th><th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <% if (staffList != null && !staffList.isEmpty()) {
                    for (User staff : staffList) { %>
                <tr>
                    <td><strong>#<%= staff.getId() %></strong></td>
                    <td><i class="fas fa-user me-1 text-muted" style="font-size:.8rem;"></i><%= staff.getUsername() %></td>
                    <td><strong><%= staff.getFullName() %></strong></td>
                    <td><a href="mailto:<%= staff.getEmail() %>" style="color:inherit; text-decoration:none;"><%= staff.getEmail() %></a></td>
                    <td><%= staff.getPhone() != null ? staff.getPhone() : "—" %></td>
                    <td><span class="badge-pill <%= staff.isAdmin() ? "badge-admin-role" : "badge-staff-role" %>"><%= staff.getRole() %></span></td>
                    <td><span class="badge-pill <%= staff.isActive() ? "badge-active" : "badge-inactive" %>">
                        <i class="fas fa-circle me-1" style="font-size:.5rem;"></i><%= staff.isActive() ? "Active" : "Inactive" %></span>
                    </td>
                    <td style="font-size:.8rem; color:#6c757d;">
                        <% if (staff.getLastLogin() != null) { %>
                        <i class="fas fa-clock me-1"></i><%= staff.getLastLogin().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) %>
                        <% } else { %><span style="color:#adb5bd;">Never</span><% } %>
                    </td>
                    <td>
                        <a href="${pageContext.request.contextPath}/admin/manage-staff?action=view&id=<%= staff.getId() %>"
                           class="btn btn-sm btn-outline-primary btn-act" title="View"><i class="fas fa-eye"></i></a>
                        <a href="${pageContext.request.contextPath}/admin/manage-staff?action=edit&id=<%= staff.getId() %>"
                           class="btn btn-sm btn-outline-success btn-act" title="Edit"><i class="fas fa-edit"></i></a>
                        <a href="${pageContext.request.contextPath}/admin/manage-staff?action=resetpw&id=<%= staff.getId() %>"
                           class="btn btn-sm btn-act btn-resetpw" title="Reset Password"><i class="fas fa-key"></i></a>
                        <% if (staff.isActive()) { %>
                        <a href="${pageContext.request.contextPath}/admin/manage-staff?action=toggle&id=<%= staff.getId() %>&toggle=deactivate"
                           class="btn btn-sm btn-outline-warning btn-act" title="Deactivate"
                           onclick="return confirm('Deactivate <%= staff.getFullName().replace("'", "\\'") %>?')"><i class="fas fa-ban"></i></a>
                        <% } else { %>
                        <a href="${pageContext.request.contextPath}/admin/manage-staff?action=toggle&id=<%= staff.getId() %>&toggle=activate"
                           class="btn btn-sm btn-outline-success btn-act" title="Activate"
                           onclick="return confirm('Activate <%= staff.getFullName().replace("'", "\\'") %>?')"><i class="fas fa-check-circle"></i></a>
                        <% } %>
                        <a href="${pageContext.request.contextPath}/admin/manage-staff?action=delete&id=<%= staff.getId() %>"
                           class="btn btn-sm btn-outline-danger btn-act" title="Deactivate & Remove"
                           onclick="return confirm('Delete <%= staff.getFullName().replace("'", "\\'") %>? This cannot be undone.')"><i class="fas fa-trash"></i></a>
                    </td>
                </tr>
                <% } } else { %>
                <tr><td colspan="9" class="text-center py-5 text-muted">
                    <i class="fas fa-users fa-3x mb-3 d-block" style="opacity:.3;"></i>
                    No staff members found.
                    <a href="${pageContext.request.contextPath}/admin/manage-staff?action=new" class="btn btn-link p-0 ms-1">Add one now</a>
                </td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.11.5/js/dataTables.bootstrap5.min.js"></script>
<script>
    $(document).ready(function(){
        $('#staffTable').DataTable({
            pageLength: 10,
            order: [[0, 'desc']],
            language: { search:"Search staff:", lengthMenu:"Show _MENU_ entries", info:"Showing _START_ to _END_ of _TOTAL_ staff" }
        });
        setTimeout(function(){ $('.alert-custom').fadeOut('slow'); }, 5000);
    });
</script>
</body>
</html>